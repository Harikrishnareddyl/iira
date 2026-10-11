import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Surface card: flat, thin border, rounded.
class SqCard extends StatelessWidget {
  const SqCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 20,
    this.borderColor,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final content = Padding(padding: padding, child: child);
    return Material(
      color: color ?? c.surfaceWarm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// Press-to-shrink wrapper for tappable things.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        child: widget.child,
      ),
    );
  }
}

/// The one big green action.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onTap,
    this.height = 64,
    this.fontSize = 24,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final enabled = onTap != null;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: enabled ? c.green : c.greenSoft,
          borderRadius: BorderRadius.circular(height / 2.6),
          border: enabled
              ? Border(bottom: BorderSide(color: c.greenDeep, width: 3))
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: fontSize * 1.25),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.display,
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 10),
              Icon(trailingIcon, color: Colors.white, size: fontSize * 1.1),
            ],
          ],
        ),
      ),
    );
  }
}

/// Secondary full-width button on a warm surface.
class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
    this.iconColor,
    this.height = 58,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? iconColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color ?? c.surfaceWarm,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? c.green, size: 26),
              const SizedBox(width: 10),
            ],
            Text(label,
                style: context.text.titleLarge!.copyWith(fontSize: 19)),
          ],
        ),
      ),
    );
  }
}

/// Red concentric target used for goals.
class TargetIcon extends StatelessWidget {
  const TargetIcon({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _TargetPainter(context.sq.coral)),
    );
  }
}

class _TargetPainter extends CustomPainter {
  _TargetPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22;
    canvas.drawCircle(c, r * 0.85, p);
    canvas.drawCircle(c, r * 0.45, p);
    canvas.drawCircle(c, r * 0.12, Paint()..color = color);
    // Little arrow.
    final a = Paint()
      ..color = color
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, c + Offset(r * 0.9, -r * 0.9), a);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "◎ Get your order remade." goal pill.
class GoalPill extends StatelessWidget {
  const GoalPill({super.key, required this.goal, this.trailing});
  final String goal;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.surfaceWarm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TargetIcon(size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(goal,
                style: context.text.bodyMedium!.copyWith(color: c.inkSoft)),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Plain progress bar, no numbers. Animates its fill.
class ThemeBar extends StatelessWidget {
  const ThemeBar({
    super.key,
    required this.value,
    this.from,
    this.height = 10,
    this.duration = const Duration(milliseconds: 900),
    this.color,
  });

  final double value;
  final double? from;
  final double height;
  final Duration duration;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from ?? 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: height,
        decoration: BoxDecoration(
          color: c.surfaceMuted,
          borderRadius: BorderRadius.circular(height),
          border: Border.all(color: c.border, width: 0.5),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? c.green,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 52,
    this.stroke = 5,
    this.child,
    this.color,
  });

  final double value;
  final double size;
  final double stroke;
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(v, color ?? c.green, c.surfaceMuted, stroke),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color, this.track, this.stroke);
  final double v;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(r, 0, math.pi * 2, false,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.v != v || old.color != color;
}

/// Gold coin glyph.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF6C344),
        border: Border.all(color: const Color(0xFFE3A325), width: size * 0.09),
      ),
      alignment: Alignment.center,
      child: Text(
        r'$',
        style: TextStyle(
          fontFamily: AppTheme.display,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.55,
          height: 1,
          color: const Color(0xFFD08A12),
        ),
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.leading, required this.label, this.onTap});
  final Widget leading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: c.amberSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 8),
            Text(label,
                style: context.text.titleMedium!
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class CoinChip extends StatelessWidget {
  const CoinChip({super.key, required this.coins, this.onTap});
  final int coins;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => StatChip(
        leading: const CoinIcon(size: 26),
        label: '$coins',
        onTap: onTap,
      );
}

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.days, this.onTap});
  final int days;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => StatChip(
        leading: Icon(Icons.local_fire_department_rounded,
            color: const Color(0xFFF28C28), size: 26),
        label: '$days',
        onTap: onTap,
      );
}

/// Stars that pop in one after another.
class StarRow extends StatefulWidget {
  const StarRow({
    super.key,
    required this.stars,
    this.size = 56,
    this.animate = true,
    this.delay = Duration.zero,
  });

  final int stars;
  final double size;
  final bool animate;
  final Duration delay;

  @override
  State<StarRow> createState() => _StarRowState();
}

class _StarRowState extends State<StarRow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.06),
              child: Transform.translate(
                offset: Offset(0, i == 1 ? -widget.size * 0.12 : 0),
                child: _star(i, c),
              ),
            ),
        ],
      ),
    );
  }

  Widget _star(int i, SqColors c) {
    final start = i * 0.22;
    final local = ((_c.value - start) / 0.45).clamp(0.0, 1.0);
    final earned = i < widget.stars;
    final scale = earned ? Curves.elasticOut.transform(local) : 1.0;
    return Transform.scale(
      scale: earned ? scale : 1,
      child: Transform.rotate(
        angle: earned ? (1 - local) * -0.6 : 0,
        child: Icon(
          Icons.star_rounded,
          size: widget.size,
          color: earned && local > 0 ? c.amber : c.surfaceMuted,
        ),
      ),
    );
  }
}

/// Small static stars for lists.
class MiniStars extends StatelessWidget {
  const MiniStars({super.key, required this.stars, this.size = 18});
  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(Icons.star_rounded,
              size: size, color: i < stars ? c.amber : c.border),
      ],
    );
  }
}

/// Icon in a soft circle (list leading).
class IconBlob extends StatelessWidget {
  const IconBlob({
    super.key,
    this.icon,
    this.emoji,
    this.color,
    this.iconColor,
    this.size = 48,
  });

  final IconData? icon;
  final String? emoji;
  final Color? color;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? c.amberSoft,
      ),
      alignment: Alignment.center,
      child: emoji != null
          ? Text(emojiPresentation(emoji!), style: TextStyle(fontSize: size * 0.5))
          : Icon(icon, color: iconColor ?? c.green, size: size * 0.52),
    );
  }
}

/// List row card: leading, title, subtitle, chevron.
class RowCard extends StatelessWidget {
  const RowCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.color,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Pressable(
      onTap: onTap,
      child: SqCard(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: context.text.titleLarge!.copyWith(fontSize: 19)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: context.text.bodyMedium!
                            .copyWith(color: c.inkMuted)),
                  ],
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right_rounded,
                        color: c.inkSoft, size: 28)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// Section heading.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(text.toUpperCase(),
                style: context.text.labelSmall!.copyWith(letterSpacing: 1.1)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Fades/slides children in, staggered — used for entry animations.
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.children,
    this.step = const Duration(milliseconds: 70),
    this.offset = 18,
  });

  final List<Widget> children;
  final Duration step;
  final double offset;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.step * widget.children.length +
        const Duration(milliseconds: 420),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _c.duration!.inMilliseconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final start = widget.step.inMilliseconds * i / total;
              final end = (start + 420 / total).clamp(0.0, 1.0);
              final v = Curves.easeOutCubic.transform(
                  ((_c.value - start) / (end - start)).clamp(0.0, 1.0));
              return Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, widget.offset * (1 - v)),
                  child: child,
                ),
              );
            },
            child: widget.children[i],
          ),
      ],
    );
  }
}

/// Shows where a navigation would go in the full app (screens are standalone
/// in this prototype).
void demoNav(BuildContext context, String target) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('In the full app this opens: $target'),
      duration: const Duration(milliseconds: 1600),
    ));
}

void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(milliseconds: 1600),
    ));
}

/// Plain top bar used by non-level screens: back chevron + centred title.
class SqTopBar extends StatelessWidget {
  const SqTopBar({super.key, this.title, this.trailing, this.onBack});
  final String? title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.ink, size: 24),
          ),
          Expanded(
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: context.text.headlineSmall,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: trailing ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Forces colour emoji presentation (adds VS16 when missing).
String emojiPresentation(String e) =>
    e.runes.length == 1 && e.runes.first > 0x2000 && e.runes.first < 0x3300 ? '$e\uFE0F' : e;
