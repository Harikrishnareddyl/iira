import 'package:flutter/material.dart';

import '../../data/curriculum/curriculum.dart';
import '../../theme/app_theme.dart';

(Color bg, Color fg) typeColors(LevelType t, SqColors c) => switch (t) {
      LevelType.conversation => (c.surfaceGreen, c.greenDeep),
      LevelType.listening => (const Color(0x335B9BD5), const Color(0xFF3E78B0)),
      LevelType.thinkInEnglish => (c.lavenderSoft, c.lavender),
      LevelType.quickReply => (c.amberSoft, const Color(0xFFB07A10)),
      LevelType.pronunciation => (c.coralSoft, c.coral),
      LevelType.soundNatural => (const Color(0x3326A69A), const Color(0xFF1F857B)),
      LevelType.boss => (c.amberSoft, const Color(0xFF9A6A0B)),
    };

class TypeBadge extends StatelessWidget {
  const TypeBadge(this.type, {super.key, this.compact = false});
  final LevelType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = typeColors(type, context.sq);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: fg),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(type.label, style: context.text.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

class TypeIcon extends StatelessWidget {
  const TypeIcon(this.type, {super.key, this.size = 44});
  final LevelType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = typeColors(type, context.sq);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(type.icon, color: fg, size: size * 0.5),
    );
  }
}

class BandChip extends StatelessWidget {
  const BandChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Text(text, style: context.text.labelMedium!.copyWith(fontWeight: FontWeight.w800, color: c.inkSoft)),
    );
  }
}

/// Small labelled block of text used on detail pages.
class InfoBlock extends StatelessWidget {
  const InfoBlock(this.label, this.body, {super.key, this.icon});
  final String label;
  final String body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 20, color: c.green)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: context.text.labelSmall!.copyWith(letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(body, style: context.text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
