import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/google/auth_service.dart';
import '../../tasks/domain/quadrant.dart';
import '../domain/board_doc_codec.dart';

/// Channel 2: the whole board, live, through Firestore. Unlike channel 1
/// there is no outbox here — the Firestore SDK queues offline writes
/// itself — and no serialized pass: local mutations write through as they
/// happen, and a snapshot listener applies remote changes under
/// whole-document last-writer-wins (ties → remote).
///
/// Channel 1 boundaries this service respects:
/// - `calendarEventId` never travels; links are per-device.
/// - A remote move OUT of Schedule deletes our linked event (we own it);
///   a remote move INTO Schedule books nothing — the originating device
///   owns the slot, we only mirror `scheduledTs` while unlinked.
class BoardSyncService {
  BoardSyncService(this._db, this._auth);

  final AppDatabase _db;
  final GoogleAuthService _auth;

  /// uid → the updatedTs this device last pushed or applied. The push
  /// loop only sends rows whose clock moved past this, which is what
  /// keeps remote applies from echoing straight back out.
  final _seenTs = <String, int>{};
  int _seenAreasTs = -1;
  int _seenQuotesTs = -1;

  StreamSubscription<List<TaskRow>>? _tasksSub;
  StreamSubscription<List<AreaRow>>? _areasSub;
  StreamSubscription<List<QuoteRow>>? _quotesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _metaSub;
  bool _running = false;

  DocumentReference<Map<String, dynamic>> get _board =>
      FirebaseFirestore.instance.doc('boards/main');
  CollectionReference<Map<String, dynamic>> get _tasks =>
      _board.collection('tasks');

  /// Exchange the google_sign_in session for a Firebase session. One
  /// dialogless hop: Play Services already holds the account.
  Future<bool> ensureSignedIn() async {
    if (FirebaseAuth.instance.currentUser != null) return true;
    final idToken = await _auth.idToken();
    if (idToken == null) return false;
    try {
      final cred = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken));
      // Surfaced once so the owner UID can be pinned into firestore.rules.
      debugPrint('threshold-board-sync uid=${cred.user?.uid}');
      return true;
    } on Object catch (e) {
      debugPrint('threshold-board-sync sign-in failed: $e');
      return false;
    }
  }

  /// Idempotent. Safe to call on every app open/resume; no-ops until
  /// Firebase is initialized and the Google session bridges.
  Future<void> start() async {
    if (_running) return;
    if (!await ensureSignedIn()) return;
    _running = true;

    // Remote first: seed the clocks from the current server state, so the
    // local watchers that start next only push what is genuinely newer.
    final first = Completer<void>();
    _remoteSub = _tasks.snapshots().listen((snap) async {
      for (final change in snap.docChanges) {
        final doc = change.doc;
        if (doc.metadata.hasPendingWrites) continue; // our own echo
        final decoded = BoardDoc.fromMap(doc.id, doc.data() ?? const {});
        if (decoded != null) await _applyRemote(decoded);
      }
      if (!first.isCompleted) first.complete();
    }, onError: (Object e) {
      debugPrint('threshold-board-sync tasks listen: $e');
      if (!first.isCompleted) first.complete();
    });
    _metaSub = _board.snapshots().listen((snap) async {
      if (snap.metadata.hasPendingWrites) return;
      final data = snap.data() ?? const {};
      final decoded = areasFromMap(data);
      if (decoded != null) await _applyRemoteAreas(decoded.$1, decoded.$2);
      final quotes = quotesFromMap(data);
      if (quotes != null) await _applyRemoteQuotes(quotes.$1, quotes.$2);
    }, onError: (Object e) {
      debugPrint('threshold-board-sync meta listen: $e');
    });
    await first.future.timeout(const Duration(seconds: 10), onTimeout: () {});

    _tasksSub = _db.select(_db.tasks).watch().listen(_pushTasks);
    _areasSub = _db.select(_db.areas).watch().listen(_pushAreas);
    _quotesSub = _db.select(_db.quotes).watch().listen(_pushQuotes);
  }

  Future<void> stop() async {
    _running = false;
    await _tasksSub?.cancel();
    await _areasSub?.cancel();
    await _quotesSub?.cancel();
    await _remoteSub?.cancel();
    await _metaSub?.cancel();
  }

  // ---- local → Firestore -------------------------------------------------

  Future<void> _pushTasks(List<TaskRow> rows) async {
    final areaNames = {
      for (final a in await _db.select(_db.areas).get()) a.uid: a.name,
    };
    for (final r in rows) {
      if ((_seenTs[r.uid] ?? -1) >= r.updatedTs) continue;
      _seenTs[r.uid] = r.updatedTs;
      final doc = BoardDoc.fromRow(r,
          areaName: r.areaUid == null ? null : areaNames[r.areaUid]);
      try {
        await _tasks.doc(r.uid).set(doc.toMap());
      } on Object catch (e) {
        _seenTs.remove(r.uid); // retry on the next emission
        debugPrint('threshold-board-sync push ${r.uid}: $e');
        return;
      }
    }
  }

  Future<void> _pushAreas(List<AreaRow> rows) async {
    if (rows.isEmpty) return;
    final maxTs = rows.map((a) => a.updatedTs).reduce((a, b) => a > b ? a : b);
    if (_seenAreasTs >= maxTs) return;
    _seenAreasTs = maxTs;
    final sorted = [...rows]..sort((a, b) => a.sortOrder - b.sortOrder);
    try {
      // merge, never replace: quotes share this document under their own
      // clock, and a full set would erase them.
      await _board.set(
          areasToMap(
              [for (final a in sorted) (name: a.name, sortOrder: a.sortOrder)],
              maxTs),
          SetOptions(merge: true));
    } on Object catch (e) {
      _seenAreasTs = -1;
      debugPrint('threshold-board-sync push areas: $e');
    }
  }

  Future<void> _pushQuotes(List<QuoteRow> rows) async {
    final clockRow = await (_db.select(_db.settingsKV)
          ..where((s) => s.key.equals('quotes_updated_ts')))
        .getSingleOrNull();
    final clock = int.tryParse(clockRow?.value ?? '') ?? 0;
    if (clock == 0 || _seenQuotesTs >= clock) return;
    _seenQuotesTs = clock;
    try {
      await _board.set(
          quotesToMap(
              [
                for (final q in rows)
                  (text: q.body, author: q.author, createdTs: q.createdTs)
              ],
              clock),
          SetOptions(merge: true));
    } on Object catch (e) {
      _seenQuotesTs = -1;
      debugPrint('threshold-board-sync push quotes: $e');
    }
  }

  // ---- Firestore → local -------------------------------------------------

  Future<void> _applyRemote(BoardDoc doc) async {
    await _db.transaction(() async {
      final local = await (_db.select(_db.tasks)
            ..where((t) => t.uid.equals(doc.uid)))
          .getSingleOrNull();

      if (local != null) {
        final alreadyOurs = _seenTs[doc.uid] == doc.updatedTs;
        final localWins = local.updatedTs > doc.updatedTs ||
            (local.updatedTs == doc.updatedTs && alreadyOurs);
        if (localWins) return;
      }
      _seenTs[doc.uid] = doc.updatedTs;

      final (urgent, important) = flagsOf(doc.quadrant);
      final areaUid = await _resolveArea(doc.area, doc.updatedTs);

      if (local == null) {
        if (doc.status == 'deleted') return; // tombstone for a stranger
        await _db.into(_db.tasks).insert(TasksCompanion.insert(
              uid: doc.uid,
              title: doc.title,
              note: Value(doc.note),
              areaUid: Value(areaUid),
              urgent: Value(urgent),
              important: Value(important),
              sortOrder: Value(doc.sortOrder),
              status: Value(doc.status),
              createdTs: epochToIso(doc.createdTs)!,
              completedTs: Value(epochToIso(doc.completedTs)),
              scheduledTs: Value(doc.scheduledTs),
              repeatDays: Value(doc.repeatDays),
              legacyDesktopId: Value(doc.legacyDesktopId),
              updatedTs: doc.updatedTs,
            ));
        return;
      }

      // We own a channel-1 event and the task remotely left Schedule (or
      // life): delete the lingering event, desktop's rule.
      final leftSchedule = doc.quadrant != Quadrant.schedule ||
          doc.status == 'done' ||
          doc.status == 'deleted';
      if (local.calendarEventId != null && leftSchedule) {
        await _db.into(_db.pendingOps).insert(PendingOpsCompanion.insert(
              taskUid: doc.uid,
              kind: 'deleteEvent',
              payload:
                  Value(jsonEncode({'eventId': local.calendarEventId})),
              createdTs: doc.updatedTs,
            ));
      }
      final keepLink = local.calendarEventId != null && !leftSchedule;

      await (_db.update(_db.tasks)..where((t) => t.uid.equals(doc.uid)))
          .write(TasksCompanion(
        title: Value(doc.title),
        note: Value(doc.note),
        areaUid: Value(areaUid),
        urgent: Value(urgent),
        important: Value(important),
        sortOrder: Value(doc.sortOrder),
        status: Value(doc.status),
        completedTs: Value(epochToIso(doc.completedTs)),
        repeatDays: Value(doc.repeatDays),
        legacyDesktopId: Value(doc.legacyDesktopId ?? local.legacyDesktopId),
        updatedTs: Value(doc.updatedTs),
        // Channel 1 owns a linked slot; mirror the wire value only while
        // unlinked (desktop-born tasks before their event is matched).
        scheduledTs:
            keepLink ? const Value.absent() : Value(doc.scheduledTs),
        calendarEventId:
            keepLink ? const Value.absent() : const Value(null),
        calendarHtmlLink:
            keepLink ? const Value.absent() : const Value(null),
        remindFiredForTs:
            keepLink ? const Value.absent() : const Value(null),
        remindSnoozedUntil:
            keepLink ? const Value.absent() : const Value(null),
      ));
    });
  }

  Future<String?> _resolveArea(String? name, int ts) async {
    if (name == null || name.isEmpty) return null;
    final existing = await (_db.select(_db.areas)
          ..where((a) => a.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing.uid;
    final max = await (_db.selectOnly(_db.areas)
          ..addColumns([_db.areas.sortOrder.max()]))
        .getSingle();
    final uid = 'remote-${name.toLowerCase().replaceAll(RegExp(r'\s+'), '-')}';
    await _db.into(_db.areas).insert(
        AreasCompanion.insert(
          uid: uid,
          name: name,
          sortOrder: (max.read(_db.areas.sortOrder.max()) ?? -1) + 1,
          updatedTs: ts,
        ),
        mode: InsertMode.insertOrIgnore);
    return uid;
  }

  Future<void> _applyRemoteQuotes(
      List<({String text, String? author, String createdTs})> remote,
      int updatedTs) async {
    await _db.transaction(() async {
      final clockRow = await (_db.select(_db.settingsKV)
            ..where((s) => s.key.equals('quotes_updated_ts')))
          .getSingleOrNull();
      final local = int.tryParse(clockRow?.value ?? '') ?? 0;
      final alreadyOurs = _seenQuotesTs == updatedTs;
      if (local > updatedTs || (local == updatedTs && alreadyOurs)) return;
      _seenQuotesTs = updatedTs;
      // Whole-list LWW: the newer reservoir replaces the older one.
      await _db.delete(_db.quotes).go();
      for (final q in remote) {
        await _db.into(_db.quotes).insert(
              QuotesCompanion.insert(
                body: q.text,
                author: Value(q.author),
                createdTs: q.createdTs,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await _db.into(_db.settingsKV).insertOnConflictUpdate(
          SettingsKVCompanion.insert(
              key: 'quotes_updated_ts', value: '$updatedTs'));
    });
  }

  Future<void> _applyRemoteAreas(
      List<({String name, int sortOrder})> remote, int updatedTs) async {
    await _db.transaction(() async {
      final rows = await _db.select(_db.areas).get();
      final localMax = rows.isEmpty
          ? -1
          : rows.map((a) => a.updatedTs).reduce((a, b) => a > b ? a : b);
      final alreadyOurs = _seenAreasTs == updatedTs;
      if (localMax > updatedTs || (localMax == updatedTs && alreadyOurs)) {
        return;
      }
      _seenAreasTs = updatedTs;
      final byName = {for (final a in rows) a.name: a};
      final keep = <String>{};
      for (final r in remote) {
        final existing = byName[r.name];
        if (existing == null) {
          await _resolveArea(r.name, updatedTs);
          final made = await (_db.select(_db.areas)
                ..where((a) => a.name.equals(r.name)))
              .getSingleOrNull();
          if (made != null) keep.add(made.uid);
          continue;
        }
        keep.add(existing.uid);
        if (existing.sortOrder != r.sortOrder) {
          await (_db.update(_db.areas)
                ..where((a) => a.uid.equals(existing.uid)))
              .write(AreasCompanion(
                  sortOrder: Value(r.sortOrder), updatedTs: Value(updatedTs)));
        }
      }
      for (final a in rows) {
        if (!keep.contains(a.uid)) {
          await (_db.delete(_db.areas)..where((x) => x.uid.equals(a.uid)))
              .go();
        }
      }
    });
  }
}
