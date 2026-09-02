import '../../../core/db/app_database.dart' show TaskRow;
import '../../tasks/domain/quadrant.dart';

/// The channel-2 wire schema (HANDOFF §4.3) exists in exactly one place:
/// here. One Firestore document per task at boards/main/tasks/{uid}, plus
/// the areas list on boards/main. The desktop companion implements this
/// same codec in Rust — if a field changes, bump [schemaV] and keep
/// reading v1.
const schemaV = 1;

/// Wire values are snake_case strings; local truth is the desktop's two
/// nullable flags ("'unclassified' has an honest representation").
const _quadrantWire = {
  Quadrant.inbox: 'inbox',
  Quadrant.doFirst: 'do_first',
  Quadrant.schedule: 'schedule',
  Quadrant.delegate: 'delegate',
  Quadrant.eliminate: 'eliminate',
};

Quadrant quadrantFromWire(String? s) => _quadrantWire.entries
    .firstWhere((e) => e.value == s,
        orElse: () => const MapEntry(Quadrant.inbox, 'inbox'))
    .key;

/// A task as it travels. Timestamps are unix seconds on the wire even
/// though created/completed are RFC3339 text locally (desktop heritage).
class BoardDoc {
  const BoardDoc({
    required this.uid,
    required this.title,
    required this.quadrant,
    required this.status,
    required this.sortOrder,
    required this.updatedTs,
    required this.createdTs,
    this.note,
    this.area,
    this.repeatDays,
    this.scheduledTs,
    this.completedTs,
    this.legacyDesktopId,
  });

  final String uid;
  final String title;
  final String? note;
  final Quadrant quadrant;
  final String status; // open | done | deleted (deleted = tombstone)
  final int sortOrder;
  final String? area; // area NAME — the shared key across devices
  final String? repeatDays; // "1,3,5" desktop weekday encoding
  final int? scheduledTs; // informational mirror; channel 1 owns the slot
  final int createdTs;
  final int? completedTs;
  final int updatedTs; // the LWW clock
  final int? legacyDesktopId;

  Map<String, Object?> toMap() => {
        'schemaV': schemaV,
        'title': title,
        'note': note,
        'quadrant': _quadrantWire[quadrant],
        'status': status,
        'sortOrder': sortOrder,
        'area': area,
        'repeatDays': repeatDays,
        'scheduledTs': scheduledTs,
        'createdTs': createdTs,
        'completedTs': completedTs,
        'updatedTs': updatedTs,
        'legacyDesktopId': legacyDesktopId,
      };

  static BoardDoc? fromMap(String uid, Map<String, Object?> m) {
    final title = m['title'];
    final updatedTs = m['updatedTs'];
    if (title is! String || updatedTs is! int) return null; // malformed
    return BoardDoc(
      uid: uid,
      title: title,
      note: m['note'] as String?,
      quadrant: quadrantFromWire(m['quadrant'] as String?),
      status: (m['status'] as String?) ?? 'open',
      sortOrder: (m['sortOrder'] as int?) ?? 0,
      area: m['area'] as String?,
      repeatDays: m['repeatDays'] as String?,
      scheduledTs: m['scheduledTs'] as int?,
      createdTs: (m['createdTs'] as int?) ?? updatedTs,
      completedTs: m['completedTs'] as int?,
      updatedTs: updatedTs,
      legacyDesktopId: m['legacyDesktopId'] as int?,
    );
  }

  static BoardDoc fromRow(TaskRow r, {String? areaName}) => BoardDoc(
        uid: r.uid,
        title: r.title,
        note: r.note,
        quadrant: quadrantOf(r.urgent, r.important),
        status: r.status,
        sortOrder: r.sortOrder,
        area: areaName,
        repeatDays: r.repeatDays,
        scheduledTs: r.scheduledTs,
        createdTs: _toEpoch(r.createdTs) ?? r.updatedTs,
        completedTs: _toEpoch(r.completedTs),
        updatedTs: r.updatedTs,
        legacyDesktopId: r.legacyDesktopId,
      );

  static int? _toEpoch(String? rfc3339) {
    if (rfc3339 == null || rfc3339.isEmpty) return null;
    final dt = DateTime.tryParse(rfc3339);
    return dt == null ? null : dt.millisecondsSinceEpoch ~/ 1000;
  }
}

String? epochToIso(int? seconds) => seconds == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toIso8601String();

/// The areas list rides on the board meta document.
Map<String, Object?> areasToMap(
        List<({String name, int sortOrder})> areas, int updatedTs) =>
    {
      'schemaV': schemaV,
      'areas': [
        for (final a in areas) {'name': a.name, 'sortOrder': a.sortOrder}
      ],
      'updatedTs': updatedTs,
    };

/// The quote reservoir rides the same meta document, under its own clock
/// (`quotesUpdatedTs`) so areas and quotes win or lose independently.
Map<String, Object?> quotesToMap(
        List<({String text, String? author, String createdTs})> quotes,
        int updatedTs) =>
    {
      'quotes': [
        for (final q in quotes)
          {'text': q.text, 'author': q.author, 'createdTs': q.createdTs}
      ],
      'quotesUpdatedTs': updatedTs,
    };

(List<({String text, String? author, String createdTs})>, int)? quotesFromMap(
    Map<String, Object?> m) {
  final updatedTs = m['quotesUpdatedTs'];
  final raw = m['quotes'];
  if (updatedTs is! int || raw is! List) return null;
  final quotes = <({String text, String? author, String createdTs})>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final text = e['text'];
    if (text is! String || text.isEmpty) continue;
    quotes.add((
      text: text,
      author: e['author'] as String?,
      createdTs: (e['createdTs'] as String?) ?? '',
    ));
  }
  return (quotes, updatedTs);
}

(List<({String name, int sortOrder})>, int)? areasFromMap(
    Map<String, Object?> m) {
  final updatedTs = m['updatedTs'];
  final raw = m['areas'];
  if (updatedTs is! int || raw is! List) return null;
  final areas = <({String name, int sortOrder})>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final name = e['name'];
    if (name is! String || name.isEmpty) continue;
    areas.add((name: name, sortOrder: (e['sortOrder'] as int?) ?? areas.length));
  }
  return (areas, updatedTs);
}
