# Threshold Mobile — Engineering & Design Handoff

This repository will hold **Threshold Mobile**, a Flutter port of Threshold — a local-first
focus product that currently ships as a Windows desktop app (Tauri v2: React 19 + Rust +
SQLite) at `github.com/alihdrndm/threshold`. This document is the founding contract: the
product spec, the design system, the sync wire protocol, and the implementation plan. It was
assembled from three exhaustive audits of the desktop codebase; where a desktop source file
is named, treat it as the reference implementation.

Read this whole file before writing code. The desktop app's source comments are unusually
load-bearing — they are the design documentation — and the quotes below are verbatim.

---

## 1. What Threshold is

> "A local-only Windows app that interrupts autopilot at the moment it takes over: the first
> seconds after boot, wake, or unlock." — README.md

Threshold is three things sharing one philosophy:

1. **A refined personal task list** — an Eisenhower matrix, deliberately *not* a project
   manager: "There are no due dates, no subtasks and no tags on purpose: the interceptor is
   the product, and a task feature that grows teeth starts competing with it for attention."
2. **A focus ritual** — a fullscreen intention/prediction/commitment flow that fires at the
   moments autopilot takes over, rotating its look and interaction daily "because identical
   dialogs are neurologically habituated within a handful of exposures."
3. **A calendar bridge** — the Schedule quadrant syncs two-way with Google Calendar.

**Mobile v1 scope (user-decided):** the board, areas, repeats, week view, task reminders
with snooze, full two-way Google Calendar sync (including a new whole-board sync channel),
**and** the focus ritual + check-in as *commitment-only* sessions. **No site blocking in
v1** — the desktop's hosts-file/DoH/elevated-helper machinery is Windows-only and out of
scope (a future VpnService project).

### The philosophy that must survive the port

These lines define the product. Violating them is a bug, not a style choice:

- **Reward is reserved for finishing.** "Nothing congratulates the user for *stating* an
  intention — praise at that moment licenses the very behaviour being avoided." The ritual's
  confirmation is the deliberately flat "Intention set." No confetti, ever: "celebrating is
  what licenses the scroll that follows."
- **The honourable exit is a feature, not a failure path.** "Always present, always one
  click, never worded so that taking it reads as failure — the RCT this design follows found
  the explicit dismiss option to be its single most effective feature."
- **No lapse is a verdict.** The check-in offers "Did it / Partly / Not this time" — three,
  not two: "a binary forces a partly-true session into one of two lies, and the lie people
  pick is the harsh one." Nothing happens after you answer.
- **Undo, not confirm.** "A dialog guards against a click; an undo forgives one, and costs
  nothing on the nineteen deletes that were meant." The only two-step confirm in the entire
  product is erasing history ("there is no undo for forgetting").
- **Nothing is red.** "Alarm colour just teaches you to stop seeing it." Errors are
  accent-tinted. Do First is warm amber, not red.
- **Counts are mirrors, not meters.** Zone counts appear only when non-zero; follow-through
  is "3 of 4", never "75%" ("a percentage invites a target, which turns a mirror into a
  scoreboard"); the Overview "is a mirror that supports the ritual rather than a product
  competing with it. If it ever grows a graph, something has gone wrong."
- **Self-set limits are the ones people keep.** Every threshold, category and pause is
  user-editable; the Do First cap (3) is a nudge, never a limit.
- **A pause is a first-class feature** — "a break that is hard to take gets taken by
  uninstalling instead." When a pause ends, the next trigger is a normal ritual, not a
  lecture.
- **Local-first.** No accounts, no telemetry, no server. Sync happens through the user's own
  Google Calendar with their own OAuth client.

---

## 2. Product specification (v1)

### 2.1 The task model

Mirror of desktop SQLite (through migration v7), plus mobile's sync additions:

| Field | Type | Rules |
|---|---|---|
| `id` | int autoincrement | local only, never leaves the device |
| `uid` | UUIDv4, unique, NOT NULL | **the canonical cross-device identity** (new; desktop gains it in the companion change) |
| `title` | text NOT NULL | verbatim; wraps in UI, never truncates |
| `note` | text? | free text |
| `areaUid` | ref areas | one area max; nullable |
| `urgent`, `important` | bool? each | **both NULL = Inbox.** (1,1)=Do First, (0,1)=Schedule, (1,0)=Delegate, (0,0)=Eliminate |
| `sortOrder` | int | per-zone position; new tasks append to Inbox end |
| `status` | open\|done\|archived\|deleted | delete keeps the row (undo = restore) |
| `createdTs` / `completedTs` | RFC3339 text | parity with desktop |
| `scheduledTs` | unix seconds? | **set only while in Schedule, cleared on leaving.** "Not a deadline; it is where the task lives on the calendar for as long as it lives in that quadrant." |
| `calendarEventId` / `calendarHtmlLink` | text? | the channel-1 event link |
| `repeatDays` | "1,3,5" (Mon=1..Sun=7)? | NULL = off; empty string is illegal. Schedule-only: cleared when leaving the quadrant (kept through delete for undo) |
| `remindFiredForTs` | unix? | reminder spent iff `== scheduledTs` — a move re-arms with zero clearing code |
| `remindSnoozedUntil` | unix? | consumes the base fire; survives a same-time write, dies on a real move |
| `boardEventId` | text? | channel-2 event id cache |
| `legacyDesktopId` | int? | rowid seen in a desktop-era `thresholdTaskId` |
| `updatedTs` | unix NOT NULL | LWW clock, bumped on every user-meaningful mutation |

**Areas** (`contexts` on desktop): `uid`, name (≤24 chars, case-insensitively unique, `#`
stripped, whitespace collapsed), sortOrder, updatedTs. **MAX = 8**: "past this they are not
areas, they are tags, and tags are the feature this list refuses to grow." Seed: Job /
Personal / Side. Removing an area unlabels its tasks, never deletes them.

**Quadrant rules:**
- `quadrantOf`: either flag NULL → Inbox. Reading order `inbox → do-first → schedule →
  delegate → eliminate → done` (sorts search results).
- `DO_FIRST_SOFT_CAP = 3`, UI-only. Over cap: "Four things cannot all be first. Move one?" —
  calm, inline, not a warning.
- Zone copy (label / sr-hint / empty invitation):
  Inbox / unclassified / "New tasks land here" · Do First / urgent and important / "For what
  cannot wait" · Schedule / important, not urgent / "For what deserves a date" · Delegate or
  shrink / urgent, not important / "For what someone else can carry" · Eliminate / neither /
  "For what you can let go".
- Done today: same zone machinery, quietest fill, header `Done today · N`. Completed tasks
  leave the grid entirely. "A checkmark is the reward."

**`#area` quick-add syntax** (port `src/windows/dashboard/tasks/areas.ts` exactly): regex
`/(^|\s)#([^\s#]+)/g`; only the first tag counts; matching case-insensitive; tag stripped
from stored title; unknown tag files the task arealess + notice `No area called "{name}"
yet` with action `Create {name}` (creates AND assigns); a typed `#tag` beats the active
filter chip. Caret autocomplete follows the Todoist convention; accepting rewrites the tag
and keeps focus. The `#` glyph on an arealess card "teaches the shortcut in the input."

**Delete + undo:** delete = `status='deleted'`, instant optimistic removal, notice
`Deleted "{title}"` + Undo for 6 s (fade begins at 5.82 s — "self-dismissal fades; only
user-triggered removal is instant"). One notice at a time, at most one action.

### 2.2 Repeats

Weekday-mask, single-instance, **advance-on-complete**:
- Completing an open, scheduled, repeating task never marks it done — it advances:
  `next_occurrence(after=max(scheduledTs, now), mask, hour, minute)` → same task, new slot,
  notice `Done — back {slot}` + Undo. "A weekly slot is a place, not a deadline."
- `next_occurrence` (port `src-tauri/src/calendar/repeat.rs` with its test vectors): next
  date **strictly after** `after`'s date whose weekday is in the mask, same wall-clock time.
  DST: ambiguous → earlier offset; nonexistent → +1 hour. Same-day never matches.
- **Roll-forward**: an uncompleted repeat keeps its day until local midnight, then rolls to
  the first mask day ≥ today — "a week of missed dailies becomes one slot today, not seven
  behind you." Non-repeating past tasks are exempt ("a one-off in the past is the user's
  business"). Runs at the top of every sync pass; **Google is patched first, local written
  second** (a failed patch waits for the next pass).
- Repeats never slot-hunt: "a ritual keeps its time. Conflicts stay visible on the week
  panel, where the person — not an algorithm — decides which one moves."

### 2.3 Week view & slots

- 7-day strip from local midnight: own tasks (accent-edged blocks), **foreign Google events
  with titles** (v1 upgrade over desktop's anonymous busy stripes), dashed "echo" outlines
  projecting where repeats will land ("drawn as an outline of the task it will be, never as
  solid time"), a now-line with a glowing dot, working-hours shading.
- Tapping a day expands it (desktop's signature FLIP morph — the day grows out of its own
  cell; see §3.6) showing the full 24h, "Room" (free gaps within working hours, with sizes)
  and "Booked".
- **Slotting** (port `slot.rs::next_free_slot`): quarter-hour grid, working hours
  (defaults 09:00–18:00, Mon–Fri, buffer 15 min), skips busy±buffer, 14-day horizon,
  failure message "no free slot in the next two weeks - widen your working hours". Slot
  length is a **fixed 30 minutes** everywhere.
- Slot controls per Schedule task: Move to next free slot · Pick a time… (auto-saves after
  700 ms settle, "Saves as you pick" → "Saved · {slot}") · Repeat… (7 day pills + Every
  day + Off; every tap commits) · Open in Google Calendar · Remove from calendar.
- Slot label: `no date yet` / `Today 9:30 AM` / `Tomorrow …` / `Wed …` (2–6 days) /
  `Jun 3 …`; append ` ↻` when repeating.
- **Foreign events**: shown with their titles; one-tap **"Adopt as task"** creates a local
  task in Schedule linked to that event (the event is *claimed* by patching a
  `thresholdTaskUid` onto it — never delete+recreate). Never auto-imported. Excluded from
  adoption UI: birthdays, workingLocation event types, declined invitations.

### 2.4 Reminders

Desktop semantics, notification-based delivery:
- Lead: setting `remind_before_min`, default **10** ("the same ten minutes the calendar
  event itself asks of the phone, so both devices knock together"); **0 = off**.
- Pure decision `due_now(now, scheduledTs, firedForTs, snoozedUntil, lead)` → Not | Fire |
  Stale. Snooze outranks the base schedule. `STALE_AFTER = 30 min` (one slot): late fires
  within it still show; beyond it are written off silently — "a reminder … an hour after
  the slot ended … would not be a reminder, just an accusation."
- Bookkeeping (identical writes): fire is consumed by user action or staleness, never by
  showing; snooze consumes the base fire in the same write; a real slot move clears snooze
  and re-arms by key; leaving Schedule wipes both.
- **Delivery**: `flutter_local_notifications` `zonedSchedule` with exact alarms; actions
  **Done · Snooze 10m · More…** (Android's 3-action cap; More… deep-links to a 5/10/15/30
  sheet). Recompute-on-open + after every sync: cancel-and-reschedule the next 7 days of
  eligible rows. Reminders are suppressed while paused ("the phone still carries Google's
  own popup, so the safety net survives the silence" — on mobile, the channel-1 event's
  built-in 10-min popup is that safety net).

### 2.5 The ritual, sessions, check-in

**Ritual** (fullscreen route, always dark): steps `arrival → intention → prediction →
ifthen → commit → confirm`, plus `browsing` (honourable exit) and an `express` single
screen for "Focus on this task". Daily theme rotation `THEMES[floor(localMidnightMs/86400000) % 4]`:

| id | surface | accent | glow | intentionMode | durationMode | greeting |
|---|---|---|---|---|---|---|
| ash | #0b0c0e | #6b8afd | rgba(107,138,253,.2) | type | chips | "Fresh session." |
| ember | #0e0b0a | #e8a06b | rgba(232,160,107,.18) | choose | slider | "Back at it." |
| tide | #080d0d | #5fc7b8 | rgba(95,199,184,.18) | type | slider | "Here again." |
| dusk | #0c0a0f | #a98bf0 | rgba(169,139,240,.18) | choose | chips | "New start." |

The greetings/intention/if-then/duration prompts rotate; **the prediction prompt never
does** ("Will you start this before opening anything else?") — "each one is carrying a
specific effect and rewording them into something softer would quietly throw that away."
Prediction buttons are **never pre-focused**. Durations: chips 25/50/90 or slider 10–120
step 5 (server-side clamp 120). If-then defaults: "take one breath and return to my task" /
"write the urge on the scratchpad" / "stand up for thirty seconds". Intention suggestions:
top-3 Do First tasks then distinct recent intention texts. Arrival shows a breathing ring
(3 s cycle, "explicitly exempt from the sub-300ms rule") and one user quote if the
reservoir is non-empty. Exit labels: "Just browsing today" / (express) "Not right now".
Express refuses Start until the prediction is answered.

**Sessions** (commitment-only in v1 — no blocking): states `running, awaiting_checkin,
completed, partly, missed, ended_early, lapsed, unanswered`; at most one `running` (unique
partial index). `intentions` is append-only ("an intention is … what you said at the
start, while a session has a life"). `task_title` is a snapshot, not a join. A session
banner chip + ongoing notification with chronometer while running; End session lives in the
banner only.

**Check-in**: fires when a session ends (exact notification → check-in screen; also
auto-routed on app open while `awaiting_checkin`). Grace **10 minutes**, then `lapsed`
silently ("a guessed answer scored against a real prediction is worse than no answer at
all"). Headline `"{elapsed} minutes on {subject}."` + "You thought you would(n't)." /
"No prediction on this one." Answers: **Did it / Partly / Not this time** → completed /
partly / missed. Follow-ups: Partly → "There's some left, then." (Keep going now → 25/50/90
· Give it a date · Just note it); Not this time → "Want another run at it?" (Start it
again · Give it a date · Just note it). "Mark this task done" checkbox only when the task
still exists and is open. Continue carries intention/task/title but **never the
prediction** ("a prediction nobody re-made must not be re-scored"). `unanswered` (walked
away) and `missed` (answered "no") stay distinct.

**Overview tab**: five stat tiles — Streak ("{n}d"; a single missed day forgiven, two
consecutive reset; "yesterday was missed — one miss does not break a habit"), Time
reclaimed (elapsed clamped to committed, completed+partly only), Sessions
(completed/(completed+browsing)), Drift, Follow-through ("{kept} of {said}"). Plus a
searchable recent-intentions list and the data-location line. No graphs. Ever.

**Quotes**: user-added only (≤280 chars, unique text, author optional), two surfaces
(ritual arrival / — desktop-only: the wall), pinned or shuffle; empty reservoir shows
nothing ("a line the app chose for you is exactly the borrowed sentiment the reservoir
exists to replace").

### 2.6 Settings (v1 keys)

`work_days` "1,2,3,4,5" · `work_start` "09:00" · `work_end` "18:00" · `cal_buffer_min` 15 ·
`remind_before_min` 10 · `reminder_sound` on · `appearance` system|light|dark ·
`week_open` · `paused_until` (pause presets 1/3/7 days, range 1–90; pause suppresses ritual
entry and reminders, never the check-in) · `quote_ritual` shuffle|id · google auth state.
Settings write through immediately, no Save button. Every section carries an explanatory
prose note — that's where the app does its explaining.

### 2.7 Explicitly out of scope for v1

Site blocking (hosts/DoH/VPN), the blocked-site wall, boot/wake/unlock interception,
the elevated helper, drift events, `archived` UI (status exists in schema only), iOS
builds (architecture must permit them; don't ship them).

---

## 3. Design system

Dark is the base, not a mode. Nothing outside `core/theme` names a color — enforce with a
lint/test the way desktop enforces it with a CI grep ("Ten of them accumulated before
anyone noticed").

### 3.1 Color

**Dark (base):**
```
surface        #0b0c0e     surfaceRaised  #141619
fillSubtle     8% white    fillSelected   10% white     borderSubtle  8% white
ink            #e8e9eb (16.1:1)            inkMuted      #8b8f96 (6.02:1)
accent         #6b8afd     glow           rgba(107,138,253, .20)
```
**Light (ratio-matched, NOT inverted):** "the ratios are matched to the dark palette rather
than the colours … Porting a dark palette by flipping its values is what makes light modes
look unfinished."
```
surface  #f7f7f5 ("fractionally warm, so it reads as paper")   surfaceRaised #ffffff
fillSubtle #ffffff   fillSelected #e4e6ea   borderSubtle 15% black
ink #17181b (16.5:1)   inkMuted #5a5f68 (5.98:1)   accent #4258d8 (5.41:1 — a different hue,
because #6b8afd is only 2.9:1 as text on light)
```
**Zone washes** (≤8% saturation — "washes, not colour blocks"; hue carries identity,
distance-from-page carries priority; **nothing is red**):

| zone | dark | light |
|---|---|---|
| doFirst (amber) | #2a1f16 | #f8e5cd |
| schedule (teal) | #14211f | #dfeeea |
| delegate (violet) | #1e1a26 | #eeeaf8 |
| inbox (cool gray) | #17191c | #ecedf1 |
| eliminate | #131417 | #f1f1f2 |
| done | #121316 | #f4f4f5 |

`zoneInkMuted` #9ba0a8 dark / #565a61 light (brighter than inkMuted — contrast on tinted
cards). Card fill = mix(white 6%, zoneBg) on dark; on light, cards are plain raised white
on the tinted zone ("white paper on a tinted board is the canonical reading") + a 1px
0.05-alpha shadow. Dashed border = one meaning everywhere: **"not settled"** (Inbox rail,
a lifted card's slot, echo blocks). Selection/focus/active/error all use accent; error
surfaces are accent-tinted (border 50%, fill 8%), never red. Semantic roles and the four
ritual themes: §2.5 table + tokens above.

### 3.2 Typography

Inter, bundled (400/500 + a 300 weight for display). One serif exists on desktop only (the
wall). **Weights 300/400/500 only** — emphasis by contrast and size, never bold or color.

The signature is the **tracked-caps label voice**: 10sp, +0.14em tracking, uppercase,
muted ink — area chips, slot chips, day headers, legends, panel headers. The full tracking
ladder (uppercase only): 0.14em (10–14sp labels) · 0.16em (stat labels) · 0.18em + w500
(zone headers) · 0.22em (axis labels, citations) · 0.24em (ritual eyebrows at 50% ink).
Body is 14sp; titles wrap and never truncate; `tabular-nums`
(`FontFeature.tabularFigures()`) wherever a number sits in a column or changes in place —
ordinals, counts, times. Ritual Question: 30sp w300 tight tracking, centered, balanced.

### 3.3 Shape, space, elevation

- **Radius:** 5 (week blocks) · 8 (menu items, inputs) · 12 (cards, popovers, notices) ·
  16 (zones, tiles, modals) · 24 (the wall) · **full (∞) for everything pressable and
  everything typable.** "There is not a single rounded-md button in the app."
- **Borders:** always 1px. Default borderSubtle; accent-mixed for states.
- **Spacing:** 4/8/12/16/24/32/48; card padding 12×10; zone padding 16; gaps — 8 between
  cards, 12 between zones (the 1:1.5 ratio keeps grouping legible without lines).
- **Shadows:** large-blur, negative-spread, pure black; alpha ~⅓ on light. Popover
  `0 12 32 -12 @.50` → corner card `0 18 40 -12 @.55` → modal `0 24 64 -16 @.60`.

### 3.4 Voice

Sentence case everywhere; lowercase for ambient chrome (`no date yet`, `sync now`,
`synced 4 min ago`); `·` is the universal separator; `…` marks "opens something else";
`↻` marks repeating; curly quotes around user data; zero exclamation marks. Empty states
invite ("New tasks land here"), never mourn. Every async action reports its own failure to
a single per-surface error line. Buttons say what happens ("Move to next free slot", not
"OK"). Use `aria-disabled`-style still-tappable controls that answer *why* in the error
line instead of dead gray buttons.

### 3.5 Motion

```dart
abstract final class AppCurves {
  static const out = Cubic(0.23, 1.0, 0.32, 1.0);       // the house curve — NOT Curves.easeOut
  static const inOut = Cubic(0.77, 0.0, 0.175, 1.0);
}  // NEVER ease-in on UI: "it delays the exact moment the eye is watching most closely."
```
Durations: press 160 · menus 160 · card fade-in 180 · notices 200 · saved dot 220 · step
stagger 240 (40ms/child, cap 240) · window-scale entrances 260–280 · ambient 3s/4s.
Default implicit duration 150ms on the house curve. **Entrances scale from 0.96–0.99,
never lower** ("never from nothing"); rises are 2–8px; **no bounce, overshoot, or spring
anywhere** ("the one curve this app never speaks"). Exits are faster than entrances
(−25–30%) and *removal the user asked for is instant; removal the system initiates fades*.
Press feedback: `scale(0.97)` @160ms house curve (0.99 for large surfaces) — build a
`PressableScale` wrapper and use it for every pressable. Keyboard/IME-summoned surfaces
never animate. Stagger: 40ms for ritual steps, 12ms cap-120 for week blocks.

**Three motion personalities** — "the dashboard and the ritual share a token file but
should never share a tempo. That contrast is the design.":
1. Board: brisk surface-being-edited — 100–200ms, opacity+tint only, no travel.
2. Week: unfolding — staggered assembly; a day grows out of its own cell.
3. Ritual: arriving somewhere else — slow luminous 240–280ms + breathing 3–4s ambient glow.

**Reduced motion** (`MediaQuery.disableAnimations` + the OS setting): "fewer and gentler,
not none: comprehension-carrying fades stay, movement goes." Glow off first; the breath
ring keeps its 3s opacity cycle at a fixed scale ("that cycle is the instruction");
staggers collapse to 0; travels are skipped, fades kept.

### 3.6 The day-expansion morph (signature transition)

Port desktop's FLIP morph: capture the tapped cell's rect → mount the day view at final
layout → animate transform-only from cell-rect to rest, 280ms house curve, content fading
in at +90ms ("the growth reads before the detail does") → close reverses, 200ms, and an
interrupt mid-open **reverses the running controller** rather than starting a new
animation ("retarget from where the card actually is … it cannot snap"). In Flutter:
a manually driven `AnimationController` (so `.reverse()` works mid-flight), not a page
route transition.

---

## 4. Sync architecture

Google Calendar is the hub. Two channels, one engine. The user's own Google Cloud project
supplies OAuth clients (desktop client exists; an **Android client** — package
`com.threshold.mobile` + the signing SHA-1s — must be added to the same project).

### 4.1 OAuth (mobile)

- `flutter_appauth` (custom-scheme redirect `com.threshold.mobile:/oauth2redirect`; no
  client secret — Android clients are public; PKCE S256 mandatory).
- Scopes: `https://www.googleapis.com/auth/calendar.events` +
  `https://www.googleapis.com/auth/calendar.freebusy` +
  `https://www.googleapis.com/auth/calendar.app.created` (granular scope for creating and
  managing app-created secondary calendars — channel 2). Both platforms' clients live in
  one GCP project so both see the same "Threshold" calendar. Fallback if `app.created`
  misbehaves: full `calendar` scope (documented, acceptable for a personal app).
- Request `access_type=offline&prompt=consent` on connect; store tokens in
  `flutter_secure_storage`; refresh transparently; treat `invalid_grant` as a first-class
  visible "Reconnect" state (outbox keeps queueing). **Never call `/revoke` on sign-out**
  (it can kill the other device's grant); just wipe local tokens.

### 4.2 Channel 1 — scheduled tasks on the primary calendar (existing desktop ABI)

The exact wire contract desktop ships today. Mobile must produce byte-compatible events:

```json
POST /calendars/primary/events
{
  "summary": "<task.title>",
  "description": "Scheduled by Threshold.",
  "start": { "dateTime": "2026-08-31T09:15:00+05:00" },
  "end":   { "dateTime": "2026-08-31T09:45:00+05:00" },
  "extendedProperties": { "private": {
      "thresholdTaskUid": "<uuid>",          // mobile always writes this
      "thresholdTaskId": "<rowid>"           // only when known (desktop-born tasks)
  }},
  "reminders": { "useDefault": false, "overrides": [ { "method": "popup", "minutes": 10 } ] }
}
```
Rules (each learned from the desktop audit — violating any breaks the other device):
- `dateTime` with UTC offset, **no `timeZone` key**; end = start + **exactly 30 minutes**.
- **Moves are PATCH** (`start`/`end` only). Never delete+recreate: desktop's
  cancelled-branch clears the link and deliberately never re-creates — a recreate orphans
  the task on desktop forever.
- Delete tolerates 404/410 as success.
- Listing: `singleEvents=true&showDeleted=true&maxResults=250`, **pageToken loop until
  exhausted, persist `nextSyncToken` only from the final page** (desktop lacks pagination;
  mobile must not). Own per-device syncToken. HTTP 410 → drop token, full re-list with
  `timeMin = now - 90d`.
- Reconcile rules (desktop's, verbatim): event cancelled → clear the task's schedule, never
  recreate; event moved & task still open-in-Schedule → **Google's time wins**; task no
  longer scheduled locally → delete the lingering event.
- Before any insert, query `privateExtendedProperty=thresholdTaskUid%3D<uid>` — if an event
  exists, patch it (duplicate guard for two-writer races).
- Match desktop-born events by `thresholdTaskId` → `legacyDesktopId`, learn the task, and
  patch a `thresholdTaskUid` onto the event (the desktop companion change does the same in
  the other direction).
- Known one-way losses (accepted, documented): titles are never patched after insert;
  durations snap back to 30 min on the next patch; all-day conversions are invisible to
  desktop.

### 4.3 Channel 2 — the whole board on a hidden "Threshold" calendar (CANONICAL SPEC)

A secondary calendar named **"Threshold"**, created via `calendars.insert` under the
`calendar.app.created` scope, `calendarList` entry patched `selected=false` (hidden from
normal Google views). One event per task; the event is a metadata carrier, not a real
calendar entry:

```
summary        = task title                 (mirror for debugging; NOT parsed)
description    = task note or ""
start/end      = all-day {date: createdTs local date} .. +1 day   (never moves)
transparency   = "transparent"              (never blocks free/busy)
reminders      = { useDefault: false, overrides: [] }
extendedProperties.private:
  thresholdTaskUid : UUIDv4                 REQUIRED — identity
  thresholdKind    : "board"                REQUIRED — discriminator
  schemaV          : "1"
  title            : canonical title        (≤1KB by construction)
  quadrant         : inbox|do_first|schedule|delegate|eliminate
  status           : open|done|archived|deleted     (deleted = tombstone; PATCH, don't delete)
  sortOrder        : "<int>"
  area             : area NAME (not id) or absent
  repeatDays       : "1,3,5" or absent
  scheduledTs      : "<unix>" or absent     (informational mirror; channel 1 owns the slot)
  createdTs        : RFC3339
  completedTs      : RFC3339 or absent
  updatedTs        : "<unix>"               REQUIRED — LWW clock
  thresholdTaskId  : "<rowid>"              optional legacy bridge (desktop writes it)

Plus ONE meta event:  thresholdKind:"meta", thresholdMetaId:"board",
  areas: JSON [{"name":"Job","sortOrder":0},...]   (≤8 areas × ≤24 chars — fits the 1024-byte
  per-value cap), updatedTs.
```

Conflict rule: **whole-record last-writer-wins on `updatedTs` (seconds); ties → remote
wins.** Tombstones garbage-collected (real delete) 30 days after `updatedTs` by whichever
device notices. Every board mutation enqueues a channel-2 upsert; the pull loop uses the
same pageToken/syncToken machinery as channel 1 against the Threshold calendar id.

**This section is the contract the desktop companion change implements too. If it ever
changes, bump `schemaV` and keep reading v1.**

### 4.4 Foreign events & adoption

Unfiltered `events.list` on primary feeds a local `GoogleEventMap` (id, summary, start/end,
allDay, updated, isThreshold, adoptedTaskUid). Week/day views render them with titles.
"Adopt as task": mint a uid, create the local task in Schedule with the event's time,
**claim the event** by patching `thresholdTaskUid` (+ description) onto it, and emit the
channel-2 upsert. FreeBusy remains only an input to `next_free_slot`.

### 4.5 The engine

One serialized `SyncCoordinator` (never two passes concurrently). Triggers: app resume ·
pull-to-refresh · WorkManager ≥15 min (network constraint) · debounced 3 s outbox push
after any local mutation. Pass order (desktop-proven): **roll-forward → drain outbox
(coalesced per task, FIFO, 3-attempt backoff, never blocks the queue) → pull primary →
pull Threshold calendar → recompute reminders → refresh UI providers.** UI is always
optimistic-local; "a task move never waits on the calendar" — sync failures land in a
status line, never block the board.

---

## 5. Flutter architecture

Standard: Riverpod codegen (`@riverpod`, AsyncNotifier — no GetIt, no setState beyond
ephemeral) · Clean Architecture, feature-first · GoRouter typed routes · drift (numbered
migrations, desktop's discipline: each step transactional, tested with hand-built old
schemas) · freezed/json_serializable · fpdart `Either<AppFailure, T>` in domain/data.

```
lib/
  main.dart                 # init: db, timezone, notifications, ProviderScope
  app.dart                  # MaterialApp.router, appearance axis (system/light/dark)
  core/
    theme/                  # app_colors, app_typography, app_spacing, app_radii,
                            # app_durations, app_curves, ritual_themes, theme_controller
    router/                 # typed GoRouter, 4-tab StatefulShellRoute + fullscreen routes
    db/                     # app_database (drift), tables/, daos/, migrations
    google/                 # Calendar REST client + auth token http layer
    background/             # workmanager dispatcher + callback routing
    error/  utils/  widgets/  # AppFailure; clock/uuid/day-index; PressableScale, CapsLabel,
                            # AppSheet, EmptyState, reduced-motion wrappers
  features/
    tasks/       domain(data(presentation   # THE domain core: Task/Area/Quadrant, repeat &
                                            # slot pure logic, repositories, TaskCard, #parser
    board/       presentation              # matrix screen, drag/reorder, undo, Done today
    week/        domain|data|presentation  # strip + expandable day, foreign tiles + adopt
    calendar_sync/ domain|data|presentation# BoardEventCodec (THE codec), outbox, reconciler,
                                            # hidden-calendar bootstrap, sync status UI
    auth/                                  # AppAuth flow, secure token store
    ritual/      domain|data|presentation  # step machine, themes, express, intentions dao
    sessions/    domain|data|presentation  # 8-state machine, unique-running, banner
    checkin/     domain|presentation       # answers, lapse handling
    reminders/   domain|data|presentation  # ReminderPlan (pure), scheduler, snooze sheet
    settings/    presentation
    overview/    presentation
test/                       # mirrors lib/; goldens for all palettes; port-parity vectors
```

Rules: `board`/`week`/`overview`/`checkin` own no `data/` — they consume `tasks`/`sessions`
repositories. The channel-2 wire schema exists in exactly one place
(`calendar_sync/domain/board_event_codec.dart`).

**Packages**: flutter_riverpod + riverpod_annotation (+generator/lints) · go_router ·
freezed + json_serializable + build_runner · drift + drift_flutter + sqlite3_flutter_libs ·
fpdart · flutter_appauth · flutter_secure_storage · googleapis + http · 
flutter_local_notifications · timezone + flutter_timezone · workmanager ·
permission_handler · uuid · intl · collection · (dev) mocktail. Deliberately absent:
flutter_animate, dio, google_sign_in (wrong token model), get_it. Inter as bundled assets.

**Screen map**: shell tabs `/board` `/week` `/overview` `/settings`; fullscreen `/ritual`
(`?express&taskUid=`), `/checkin/:sessionId` (notification-launched), `/reminder/:taskUid`
(the More… snooze sheet), `/task/:uid` bottom sheet (note/area/repeat/slot). On the phone
the matrix becomes vertically stacked zone sections with long-press drag between zones;
zone identity still comes from the wash + tracked-caps header.

---

## 6. Milestones

Each independently shippable to the target device (Samsung A56, USB, `flutter run` /
`adb install -r`). Sizes: S/M/L.

- **M0 (S)** — scaffold, CI (analyze + test + release-APK artifact), lints, `core/theme`
  complete **with golden tests for all six palettes** (dark, light, 4 ritual), PressableScale/
  CapsLabel, router shell, drift v1, Inter bundled. Exit: runs on the A56, CI green.
- **M1 (L)** — the local board, complete and offline: tasks/areas domain + daos, matrix
  screen with all zones + Done today, quick-add with `#area` + caret autocomplete, search
  (reaches across everything, ignores filters), task sheet, drag/reorder, undo notices,
  repeat advance + local roll-forward, settings (areas/hours/appearance). **Port-parity
  unit tests against the Rust test vectors in `repeat.rs` / `slot.rs`.** Exit: a fully
  usable offline task app.
- **M2 (M)** — OAuth + read-only calendar: AppAuth against the user's Android client (they
  add package + SHA-1s to their GCP project; hand them exact values), all three scopes,
  token refresh + Reconnect state, unfiltered events.list with pagination into
  GoogleEventMap, week view shows foreign titles. **Spike `calendar.app.created`** (create
  + list a throwaway calendar). Exit: week mirrors Google.
- **M3 (L)** — two-way channel-1 sync + adopt, **desktop unmodified**: outbox +
  SyncCoordinator, insert/patch/delete per §4.2, duplicate guard, slot hunting on
  enter-Schedule, reschedule/pick/remove, roll-forward patches, 410 recovery, WorkManager,
  adopt-as-task. Soak test against the live desktop. Exit: both apps agree through Google.
- **M4 (L)** — channel-2 board sync + **the desktop companion change** (separate branch in
  `alihdrndm/threshold`): (1) migration v8 `tasks.uid` UUID backfill + unique index;
  (2) add `calendar.app.created` scope → re-consent; (3) write `thresholdTaskUid` on
  channel-1 inserts + lazily patch onto existing events; (4) pageToken loop in
  `list_task_events`; (5) implement §4.3 codec + outbox mirroring of every board mutation +
  pull loop with own syncToken; (6) accept mobile-born tasks (uid canonical, mint local
  rowid); (7) `updated_ts` column + LWW; (8) tombstones + GC. Exit: full board converges
  both directions.
- **M5 (M)** — reminders: notification permissions flows (POST_NOTIFICATIONS,
  SCHEDULE_EXACT_ALARM + OneUI battery settings deep-link), zonedSchedule exact,
  Done/Snooze-10m/More… actions handled without app launch, desktop-identical bookkeeping,
  recompute-on-open. Exit: the phone knocks at slot-time parity with desktop.
- **M6 (L)** — ritual + sessions + check-in + overview + quotes, per §2.5. Exit: the full
  loop (ritual → session → check-in → overview) works on the phone.
- **M7 (M)** — polish: reduced-motion policy, TalkBack + 48dp targets + accessible
  drag alternative (move-to-zone menu), dynamic type, light-mode audit at matched ratios,
  haptics on commit/complete, R8 rules for appauth/notifications, docs.

Effort share ≈ 6 / 18 / 10 / 18 / 18 / 10 / 14 / 6 (%).

## 7. Risks

1. **Android refresh-token loss** (uninstall, storage wipe) → visible Reconnect banner,
   outbox queues indefinitely, `prompt=consent` on connect, test the refresh path.
2. **OneUI Doze / exact-alarm revocation** → schedule-ahead + recompute-on-open self-heal,
   `exactAllowWhileIdle`, onboarding deep-links to Alarms & reminders + battery settings,
   graceful inexact fallback.
3. **`calendar.app.created` behavior across two clients of one project** → M2 spike;
   fallback to full `calendar` scope documented; channel 2 optional at runtime (channel 1 +
   local board remain fully functional without it).
4. **Two-writer races** (desktop 2-min poll vs mobile pushes; midnight roll-forward) →
   PATCH-only, LWW with remote-wins ties, duplicate guard, deterministic shared roll-forward
   math, M3/M4 soak tests. Accepted v1 caveat: cross-timezone roll-forward ping-pong
   (single user, same TZ in practice).
5. **Sideload distribution** → fixed self-managed keystore, register BOTH debug and release
   SHA-1s in the Android OAuth client, CI produces the signed APK, `adb install -r`.

## 8. Reference pointers (desktop repo)

| Topic | File |
|---|---|
| Schema + migration discipline | `src-tauri/src/db/mod.rs` |
| Task/area/reminder invariants + test vectors | `src-tauri/src/db/tasks.rs` |
| Reconcile ordering, conflict rules, roll-forward | `src-tauri/src/calendar/sync.rs` |
| Channel-1 wire bodies, syncToken/410 | `src-tauri/src/calendar/api.rs` |
| Pure repeat/slot math (port with identical semantics) | `src-tauri/src/calendar/repeat.rs`, `slot.rs` |
| Reminder decision logic | `src-tauri/src/reminder.rs` |
| Session reconciliation, check-in gates | `src-tauri/src/session.rs` |
| Design tokens, curves, themes, reduced motion | `src/styles/index.css` |
| Ritual copy + themes | `src/windows/popup/ritual/copy.ts`, `src/themes/` |
| Quadrant/board rules | `src/windows/dashboard/tasks/quadrants.ts`, `areas.ts` |

## 9. Working agreements

- Branch per task; meaningful commit messages in the repo's narrative style; no co-author
  trailers; never commit generated `*.g.dart`/`*.freezed.dart` conflicts unresolved — run
  build_runner before committing.
- Testing bar: pure logic (repeat, slot, codec, reminder plan, LWW) has port-parity unit
  tests; theme has goldens; every milestone exits only when `flutter analyze` and
  `flutter test` are green and the app has actually run on the device.
- Design bar: every screen ships all five states (initial/loading/success/empty/error);
  every spacing value from tokens; no color literals outside `core/theme`; press feedback
  on every pressable; reduced-motion respected from M0.
