/// The `#area` quick-add syntax — a port of desktop `tasks/areas.ts`.
/// Todoist's convention, "the one people already have in their hands."
library;

class ParsedTitle {
  const ParsedTitle({required this.title, this.areaName, this.unknown});

  /// The stored title, tag stripped, whitespace collapsed.
  final String title;

  /// The matched area's name (canonical casing), when the tag named one.
  final String? areaName;

  /// The tag's text when it named no existing area — the task files
  /// arealess and the notice offers to create it: "a name that vanishes on
  /// Enter is a name the user thinks was saved."
  final String? unknown;
}

final _tag = RegExp(r'(^|\s)#([^\s#]+)');

/// Only the first tag counts — a task has one area. Matching is
/// case-insensitive; the tag beats any active filter chip ("the tag was
/// typed for this task, the chip was chosen for the view").
ParsedTitle parseTitle(String raw, List<String> areaNames) {
  final match = _tag.firstMatch(raw);
  if (match == null) {
    return ParsedTitle(title: raw.trim().replaceAll(RegExp(r'\s+'), ' '));
  }
  final tag = match.group(2)!;
  final stripped = raw
      .replaceFirst(_tag, match.group(1) ?? '')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  final known = areaNames.firstWhere(
    (n) => n.toLowerCase() == tag.toLowerCase(),
    orElse: () => '',
  );
  return known.isNotEmpty
      ? ParsedTitle(title: stripped, areaName: known)
      : ParsedTitle(title: stripped, unknown: tag);
}

final _tagAtCaret = RegExp(r'(?:^|\s)#([^\s#]*)$');

/// The partial tag being typed at [caret], or null when the caret is not
/// inside one. Drives the autocomplete popover.
({String partial, int start})? tagAtCaret(String text, int caret) {
  final before = text.substring(0, caret.clamp(0, text.length));
  final m = _tagAtCaret.firstMatch(before);
  if (m == null) return null;
  return (partial: m.group(1)!, start: m.start + (m.group(0)!.startsWith('#') ? 0 : 1));
}

/// Areas whose names start with the partial, in toolbar order.
List<String> suggestAreas(String partial, List<String> areaNames) {
  final p = partial.toLowerCase();
  return [
    for (final n in areaNames)
      if (n.toLowerCase().startsWith(p)) n,
  ];
}

/// Area names: trimmed, leading `#` stripped ("the '#' is quick-add syntax,
/// not part of the name"), whitespace collapsed, ≤24 chars, non-empty.
String tidyAreaName(String raw) {
  final name = raw
      .trim()
      .replaceFirst(RegExp(r'^#'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty) throw const FormatException('an area needs a name');
  if (name.length > 24) {
    throw const FormatException('area names stay under 24 characters');
  }
  return name;
}

/// "The most areas a person can hold in their head as areas. Past this they
/// are tags, and tags are the feature this list refuses to grow."
const maxAreas = 8;
