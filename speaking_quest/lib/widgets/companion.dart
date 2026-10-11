import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum CompanionMood { rest, pleased, listening, dim }

/// The companion: an abstract voice mark (speech bubble with sound bars).
/// Breathes gently at rest, bars dance when pleased, dims on a missed goal.
class CompanionMark extends StatefulWidget {
  const CompanionMark({
    super.key,
    this.mood = CompanionMood.rest,
    this.size = 120,
    this.showRays,
    this.rayColor,
  });

  final CompanionMood mood;
  final double size;
  final bool? showRays;
  final Color? rayColor;

  @override
  State<CompanionMark> createState() => _CompanionMarkState();
}

class _CompanionMarkState extends State<CompanionMark>
    with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void didUpdateWidget(CompanionMark old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _loop.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _pop]),
        builder: (context, _) => CustomPaint(
          painter: _CompanionPainter(
            t: _loop.value,
            pop: Curves.elasticOut.transform(_pop.value.clamp(0, 1)),
            mood: widget.mood,
            rays: widget.showRays ??
                (widget.mood == CompanionMood.pleased ||
                    widget.mood == CompanionMood.dim),
            c: c,
            rayColor: widget.rayColor,
          ),
        ),
      ),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  _CompanionPainter({
    required this.t,
    required this.pop,
    required this.mood,
    required this.rays,
    required this.c,
    this.rayColor,
  });

  final Color? rayColor;
  final double t;
  final double pop;
  final CompanionMood mood;
  final bool rays;
  final SqColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);
    final dim = mood == CompanionMood.dim;
    final wave = math.sin(t * 2 * math.pi);

    // Breathing scale.
    final breathe = mood == CompanionMood.rest || dim ? 1 + wave * 0.025 : 1.0;
    final r = s * 0.30 * breathe * (0.85 + 0.15 * pop);

    final fill = dim ? c.surfaceGreen.withValues(alpha: 0.9) : c.greenTint;
    final stroke = dim ? c.greenSoft.withValues(alpha: 0.7) : c.greenSoft;
    final bar = dim ? c.green.withValues(alpha: 0.75) : c.green;

    // Rays around the bubble.
    if (rays) {
      final rayPaint = Paint()
        ..color = (rayColor ?? (dim ? c.green : c.amber))
            .withValues(alpha: dim ? 0.55 : 0.95)
        ..strokeWidth = s * 0.035
        ..strokeCap = StrokeCap.round;
      final angles = dim
          ? [-150.0, -120.0, -60.0, -30.0, 160.0, 20.0]
          : [-160.0, -125.0, -55.0, -20.0, 15.0, 165.0, 200.0, -90.0];
      for (final a in angles) {
        final rad = a * math.pi / 180;
        final d0 = r * (1.25 + 0.05 * wave) * (0.8 + 0.2 * pop);
        final len = s * (dim ? 0.06 : 0.08) * pop;
        final p0 = center + Offset(math.cos(rad), math.sin(rad)) * d0;
        final p1 = center + Offset(math.cos(rad), math.sin(rad)) * (d0 + len);
        canvas.drawLine(p0, p1, rayPaint);
      }
    }

    // Bubble with tail.
    final bubble = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r));
    final tail = Path()
      ..moveTo(center.dx - r * 0.55, center.dy + r * 0.62)
      ..quadraticBezierTo(center.dx - r * 0.85, center.dy + r * 1.18,
          center.dx - r * 1.05, center.dy + r * 1.22)
      ..quadraticBezierTo(center.dx - r * 0.55, center.dy + r * 1.08,
          center.dx - r * 0.12, center.dy + r * 0.92)
      ..close();
    final whole = Path.combine(PathOperation.union, bubble, tail);
    canvas.drawPath(whole, Paint()..color = fill);
    canvas.drawPath(
      whole,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.025,
    );

    final barPaint = Paint()
      ..color = bar
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.045;

    if (dim) {
      // Bars on top, sleepy eyes and a small mouth below.
      for (var i = 0; i < 3; i++) {
        final x = center.dx + (i - 1) * r * 0.32;
        final h = r * (i == 1 ? 0.42 : 0.3);
        canvas.drawLine(Offset(x, center.dy - r * 0.15 - h),
            Offset(x, center.dy - r * 0.15), barPaint);
      }
      final face = Paint()
        ..color = c.ink.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s * 0.022;
      for (final dx in [-0.42, 0.42]) {
        final e = Offset(center.dx + r * dx, center.dy + r * 0.2);
        canvas.drawArc(Rect.fromCenter(center: e, width: r * 0.34, height: r * 0.22),
            0, math.pi, false, face);
      }
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(center.dx, center.dy + r * 0.6),
              width: r * 0.32,
              height: r * 0.2),
          math.pi,
          math.pi,
          false,
          face);
      return;
    }

    // Sound bars: dance when pleased/listening, gentle otherwise.
    const n = 4;
    final active = mood == CompanionMood.pleased || mood == CompanionMood.listening;
    for (var i = 0; i < n; i++) {
      final x = center.dx + (i - (n - 1) / 2) * r * 0.36;
      final base = [0.45, 0.8, 0.6, 0.35][i];
      final phase = math.sin((t * (active ? 4 : 1) + i * 0.23) * 2 * math.pi);
      final h = r * base * (active ? (0.75 + 0.35 * phase) : (0.95 + 0.05 * phase));
      canvas.drawLine(Offset(x, center.dy - h / 2), Offset(x, center.dy + h / 2),
          barPaint);
    }
  }

  @override
  bool shouldRepaint(_CompanionPainter old) => true;
}
