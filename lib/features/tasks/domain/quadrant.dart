/// Position on the Eisenhower matrix is stored as two nullable flags rather
/// than a quadrant name, "so 'unclassified' has an honest representation -
/// both NULL, which is the Inbox."
enum Quadrant { inbox, doFirst, schedule, delegate, eliminate }

/// "Deliberately a nudge and not a limit: self-set rules get kept, imposed
/// ones get worked around." Lives in the UI's vocabulary only.
const doFirstSoftCap = 3;

/// Reading order of the board — also sorts search results.
const placeOrder = [
  Quadrant.inbox,
  Quadrant.doFirst,
  Quadrant.schedule,
  Quadrant.delegate,
  Quadrant.eliminate,
];

Quadrant quadrantOf(bool? urgent, bool? important) {
  if (urgent == null || important == null) return Quadrant.inbox;
  if (urgent && important) return Quadrant.doFirst;
  if (!urgent && important) return Quadrant.schedule;
  if (urgent && !important) return Quadrant.delegate;
  return Quadrant.eliminate;
}

/// The flags a quadrant writes back. Inbox is (null, null).
(bool?, bool?) flagsOf(Quadrant q) => switch (q) {
      Quadrant.inbox => (null, null),
      Quadrant.doFirst => (true, true),
      Quadrant.schedule => (false, true),
      Quadrant.delegate => (true, false),
      Quadrant.eliminate => (false, false),
    };

extension QuadrantCopy on Quadrant {
  String get label => switch (this) {
        Quadrant.inbox => 'Inbox',
        Quadrant.doFirst => 'Do First',
        Quadrant.schedule => 'Schedule',
        Quadrant.delegate => 'Delegate or shrink',
        Quadrant.eliminate => 'Eliminate',
      };

  /// "each is the one moment its meaning is worth a sentence."
  String get invitation => switch (this) {
        Quadrant.inbox => 'New tasks land here',
        Quadrant.doFirst => 'For what cannot wait',
        Quadrant.schedule => 'For what deserves a date',
        Quadrant.delegate => 'For what someone else can carry',
        Quadrant.eliminate => 'For what you can let go',
      };
}
