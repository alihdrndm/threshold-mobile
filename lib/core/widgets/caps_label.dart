import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// The tracked-caps label voice: 10sp, +0.14em, uppercase, muted ink.
/// Area chips, slot chips, day headers, legends, panel headers — one voice
/// for every quiet label in the product.
class CapsLabel extends StatelessWidget {
  const CapsLabel(
    this.text, {
    super.key,
    this.size = 10,
    this.color,
    this.onZone = false,
  });

  final String text;
  final double size;
  final Color? color;

  /// On a zone-tinted card, use the brighter zone ink.
  final bool onZone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      text.toUpperCase(),
      style: AppTypography.labelCaps(size: size).copyWith(
        color: color ?? (onZone ? c.zoneInkMuted : c.inkMuted),
        fontFeatures: AppTypography.tabular,
      ),
    );
  }
}
