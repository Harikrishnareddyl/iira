import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Working name of the mascot. Change it here and in copy if it's renamed.
const mascotName = 'Echo';

enum MascotMood {
  /// Breathes gently, blinks.
  idle,

  /// Pleased: small bounce, sound-bar hair dances.
  happy,

  /// Speaking: mouth moves, bars pulse.
  talking,

  /// Hand to ear, head tilted, bars pulse fast.
  listening,

  /// Hand on chin, eyes up.
  thinking,

  /// Missed goal: dimmed, droopy, still kind.
  sad,

  /// Celebrating: jumps with both arms up.
  cheer,

  /// Hello / goodbye.
  wave,
}

/// Echo, the mascot: a speech bubble with a face, small arms and sound-bar
/// hair. Used as the guide everywhere and as the Free talk partner.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 120,
    this.showRays,
    this.rayColor,
  });

  final MascotMood mood;
  final double size;

  /// Defaults to on for [MascotMood.cheer] and [MascotMood.happy] at large
  /// sizes.
  final bool? showRays;
  final Color? rayColor;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void didUpdateWidget(Mascot old) {
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
    final rays = widget.showRays ??
        (widget.mood == MascotMood.cheer ||
            (widget.mood == MascotMood.happy && widget.size >= 100));
    return Semantics(
      label: '$mascotName, ${widget.mood.name}',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _pop]),
          builder: (context, _) => CustomPaint(
            painter: _MascotPainter(
              t: _loop.value,
              pop: Curves.elasticOut.transform(_pop.value),
              mood: widget.mood,
              rays: rays,
              rayColor: widget.rayColor ?? c.amber,
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.t,
    required this.pop,
    required this.mood,
    required this.rays,
    required this.rayColor,
  });

  final double t;
  final double pop;
  final MascotMood mood;
  final bool rays;
  final Color rayColor;

  // Fixed character colours so Echo looks the same in light and dark.
  static const _body = Color(0xFFDCEBD6);
  static const _bodySad = Color(0xFFE2E6DF);
  static const _line = Color(0xFF7FAE7B);
  static const _lineSad = Color(0xFFA9B8A6);
  static const _bars = Color(0xFF4E8A57);
  static const _barsSad = Color(0xFF94AE91);
  static const _ink = Color(0xFF1F2A22);
  static const _cheek = Color(0x66F08F86);
  static const _mouth = Color(0xFFB8463B);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final wave = math.sin(t * 2 * math.pi);
    final sad = mood == MascotMood.sad;

    // Whole-body motion.
    var dy = 0.0;
    var tilt = 0.0;
    var squash = 1 + 0.018 * wave; // breathing
    switch (mood) {
      case MascotMood.happy:
        dy = -0.035 * (math.sin(t * 4 * math.pi)).abs();
      case MascotMood.cheer:
        final j = (math.sin(t * 4 * math.pi)).abs();
        dy = -0.07 * j;
        squash = 1 + 0.04 * (1 - j);
      case MascotMood.listening:
        tilt = 0.08;
      case MascotMood.thinking:
        tilt = -0.05;
      case MascotMood.sad:
        dy = 0.02;
        squash = 0.97;
      case MascotMood.talking:
        dy = -0.008 * wave;
      case MascotMood.idle:
      case MascotMood.wave:
        break;
    }

    // Ground shadow (stays on the ground while jumping).
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 0.93), width: s * (0.44 + dy), height: s * 0.05),
      Paint()..color = _ink.withValues(alpha: 0.08),
    );

    if (rays) _drawRays(canvas, s, wave);

    canvas.save();
    // Entrance pop + motion, pivoting around the feet.
    final pivot = p(0.5, 0.88);
    canvas.translate(pivot.dx, pivot.dy + dy * s);
    canvas.rotate(tilt);
    canvas.scale((0.85 + 0.15 * pop) * (2 - squash), (0.85 + 0.15 * pop) * squash);
    canvas.translate(-pivot.dx, -pivot.dy);

    final body = sad ? _bodySad : _body;
    final line = sad ? _lineSad : _line;
    final bars = sad ? _barsSad : _bars;
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.026
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Feet.
    for (final x in [0.41, 0.59]) {
      final f = Rect.fromCenter(center: p(x, 0.87), width: s * 0.13, height: s * 0.065);
      canvas.drawOval(f, Paint()..color = line);
    }

    // Arms (behind the body so they read as attached).
    _drawArms(canvas, s, wave, line);

    // Sound-bar hair.
    final hair = Paint()
      ..color = bars
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round;
    const hairX = [0.43, 0.5, 0.57];
    const hairH = [0.075, 0.12, 0.085];
    final speed = switch (mood) {
      MascotMood.listening || MascotMood.talking => 5.0,
      MascotMood.happy || MascotMood.cheer => 3.0,
      _ => 1.0,
    };
    for (var i = 0; i < 3; i++) {
      final ph = math.sin((t * speed + i * 0.27) * 2 * math.pi);
      var h = hairH[i] * (speed > 1 ? 0.75 + 0.35 * ph : 0.96 + 0.04 * ph);
      if (sad) h *= 0.6;
      final base = p(hairX[i], 0.33);
      final lean = sad ? (i - 1) * 0.04 : 0.0;
      canvas.drawLine(base, base + Offset(lean * s, -h * s), hair);
    }

    // Body: rounded speech bubble with a tail.
    final rect = Rect.fromCenter(center: p(0.5, 0.58), width: s * 0.62, height: s * 0.5);
    final bubble = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(s * 0.24)));
    final tail = Path()
      ..moveTo(s * 0.26, s * 0.7)
      ..quadraticBezierTo(s * 0.2, s * 0.84, s * 0.12, s * 0.87)
      ..quadraticBezierTo(s * 0.28, s * 0.86, s * 0.38, s * 0.79)
      ..close();
    final shape = Path.combine(PathOperation.union, bubble, tail);
    canvas.drawPath(shape, Paint()..color = body);
    canvas.drawPath(shape, stroke);

    _drawFace(canvas, s, wave);

    if (mood == MascotMood.thinking) {
      // Thought dots.
      final dot = Paint()..color = line;
      for (var i = 0; i < 3; i++) {
        final on = ((t * 3).floor() % 3) >= i;
        if (on) canvas.drawCircle(p(0.8 + i * 0.06, 0.3 - i * 0.05), s * (0.016 + i * 0.006), dot);
      }
    }
    canvas.restore();
  }

  void _drawRays(Canvas canvas, double s, double wave) {
    final center = Offset(s * 0.5, s * 0.55);
    final paint = Paint()
      ..color = rayColor
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    for (final a in [-155.0, -125.0, -55.0, -25.0, 200.0, 160.0, 20.0, -90.0]) {
      if (a == -90.0) continue; // keep the hair clear
      final r = a * math.pi / 180;
      final d0 = s * (0.4 + 0.015 * wave) * (0.8 + 0.2 * pop);
      final len = s * 0.07 * pop;
      final dir = Offset(math.cos(r), math.sin(r));
      canvas.drawLine(center + dir * d0, center + dir * (d0 + len), paint);
    }
  }

  void _drawArms(Canvas canvas, double s, double wave, Color line) {
    final arm = Paint()
      ..color = line
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final hand = Paint()..color = line;
    Offset p(double x, double y) => Offset(x * s, y * s);

    void limb(Offset from, Offset mid, Offset to) {
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
      canvas.drawPath(path, arm);
      canvas.drawCircle(to, s * 0.035, hand);
    }

    final left = p(0.22, 0.6), right = p(0.78, 0.6);
    switch (mood) {
      case MascotMood.cheer:
        final w = 0.02 * wave;
        limb(left, p(0.12, 0.5), p(0.11 + w, 0.36));
        limb(right, p(0.88, 0.5), p(0.89 - w, 0.36));
      case MascotMood.wave:
        final a = 0.05 * math.sin(t * 6 * math.pi);
        limb(left, p(0.14, 0.66), p(0.15, 0.74));
        limb(right, p(0.9, 0.52), p(0.9 + a, 0.38));
      case MascotMood.listening:
        limb(left, p(0.14, 0.66), p(0.15, 0.74));
        limb(right, p(0.9, 0.55), p(0.84, 0.44));
      case MascotMood.thinking:
        limb(left, p(0.14, 0.66), p(0.15, 0.74));
        limb(right, p(0.82, 0.76), p(0.62, 0.72));
      case MascotMood.happy:
        final w = 0.03 * math.sin(t * 4 * math.pi);
        limb(left, p(0.12, 0.58), p(0.11, 0.5 + w));
        limb(right, p(0.88, 0.58), p(0.89, 0.5 - w));
      case MascotMood.talking:
        final w = 0.03 * math.sin(t * 3 * math.pi);
        limb(left, p(0.14, 0.66), p(0.15, 0.74));
        limb(right, p(0.9, 0.62), p(0.9, 0.56 + w));
      case MascotMood.sad:
        limb(left, p(0.17, 0.7), p(0.2, 0.78));
        limb(right, p(0.83, 0.7), p(0.8, 0.78));
      case MascotMood.idle:
        limb(left, p(0.14, 0.66), p(0.15, 0.74));
        limb(right, p(0.86, 0.66), p(0.85, 0.74));
    }
  }

  void _drawFace(Canvas canvas, double s, double wave) {
    Offset p(double x, double y) => Offset(x * s, y * s);
    final ink = Paint()..color = _ink;
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;

    // Eyes.
    final blink = (t % 0.5) > 0.47 && mood != MascotMood.cheer;
    final look = switch (mood) {
      MascotMood.thinking => const Offset(0.012, -0.015),
      MascotMood.listening => const Offset(0.01, -0.005),
      _ => Offset.zero,
    };
    for (final x in [0.41, 0.59]) {
      final e = p(x + look.dx, 0.53 + look.dy);
      if (mood == MascotMood.sad) {
        canvas.drawArc(Rect.fromCenter(center: e, width: s * 0.07, height: s * 0.05), 0.1, math.pi - 0.2, false, line);
      } else if (mood == MascotMood.cheer || mood == MascotMood.happy && (t % 1) < 0.5) {
        // Smiling eyes ^ ^
        canvas.drawArc(Rect.fromCenter(center: e + Offset(0, s * 0.01), width: s * 0.07, height: s * 0.06), math.pi + 0.2, math.pi - 0.4, false, line);
      } else if (blink) {
        canvas.drawLine(e - Offset(s * 0.03, 0), e + Offset(s * 0.03, 0), line);
      } else {
        canvas.drawOval(Rect.fromCenter(center: e, width: s * 0.062, height: s * 0.085), ink);
        canvas.drawCircle(e + Offset(s * 0.012, -s * 0.018), s * 0.014, Paint()..color = Colors.white);
      }
    }

    // Brows only for sad / thinking.
    if (mood == MascotMood.sad) {
      canvas.drawLine(p(0.37, 0.465), p(0.44, 0.45), line);
      canvas.drawLine(p(0.63, 0.465), p(0.56, 0.45), line);
    } else if (mood == MascotMood.thinking) {
      canvas.drawLine(p(0.56, 0.45), p(0.63, 0.44), line);
    }

    // Cheeks.
    final cheek = Paint()..color = _cheek;
    canvas.drawCircle(p(0.34, 0.615), s * 0.034, cheek);
    canvas.drawCircle(p(0.66, 0.615), s * 0.034, cheek);

    // Mouth.
    final m = p(0.5, 0.645);
    switch (mood) {
      case MascotMood.talking:
        final open = 0.4 + 0.6 * (math.sin(t * 2 * math.pi * 7)).abs();
        canvas.drawOval(Rect.fromCenter(center: m, width: s * 0.07, height: s * 0.055 * open), Paint()..color = _mouth);
      case MascotMood.happy:
      case MascotMood.cheer:
        final path = Path()
          ..moveTo(m.dx - s * 0.05, m.dy - s * 0.01)
          ..quadraticBezierTo(m.dx, m.dy + s * 0.07, m.dx + s * 0.05, m.dy - s * 0.01)
          ..close();
        canvas.drawPath(path, Paint()..color = _mouth);
      case MascotMood.sad:
        canvas.drawArc(Rect.fromCenter(center: m + Offset(0, s * 0.02), width: s * 0.07, height: s * 0.04), math.pi + 0.3, math.pi - 0.6, false,
            Paint()
              ..color = _mouth
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * 0.02
              ..strokeCap = StrokeCap.round);
      case MascotMood.listening:
        canvas.drawOval(Rect.fromCenter(center: m, width: s * 0.035, height: s * 0.03), Paint()..color = _mouth);
      case MascotMood.thinking:
        canvas.drawLine(m - Offset(s * 0.02, 0), m + Offset(s * 0.03, -s * 0.006),
            Paint()
              ..color = _mouth
              ..strokeWidth = s * 0.02
              ..strokeCap = StrokeCap.round);
      case MascotMood.idle:
      case MascotMood.wave:
        canvas.drawArc(Rect.fromCenter(center: m - Offset(0, s * 0.012), width: s * 0.08, height: s * 0.05), 0.2, math.pi - 0.4, false,
            Paint()
              ..color = _mouth
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * 0.02
              ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) => true;
}

/// Echo with a short speech bubble — used for nudges, tips and feedback.
class MascotTip extends StatelessWidget {
  const MascotTip({
    super.key,
    required this.text,
    this.mood = MascotMood.talking,
    this.size = 58,
    this.color,
  });

  final String text;
  final MascotMood mood;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Mascot(size: size, mood: mood, showRays: false),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: size * 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: color ?? c.surfaceGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(text, style: context.text.titleMedium),
          ),
        ),
      ],
    );
  }
}
