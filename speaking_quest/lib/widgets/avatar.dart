import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum HairStyle { bun, short, long }

/// A flat, adult character drawn in code (placeholder for real illustrations).
class CharacterSpec {
  const CharacterSpec({
    required this.name,
    this.hair = HairStyle.bun,
    this.hairColor = const Color(0xFF7A4A2B),
    this.skin = const Color(0xFFF8D2B8),
    this.top = const Color(0xFF2E3330),
    this.apron,
    this.glasses = false,
    this.setting = Setting.cafe,
  });

  final String name;
  final HairStyle hair;
  final Color hairColor;
  final Color skin;
  final Color top;
  final Color? apron;
  final bool glasses;
  final Setting setting;

  static const maya = CharacterSpec(
    name: 'Maya',
    apron: Color(0xFF4E7F52),
    setting: Setting.cafe,
  );
  static const mayaCasual = CharacterSpec(
    name: 'Maya',
    top: Color(0xFFF3EBDD),
    apron: Color(0xFF4E7F52),
    setting: Setting.plain,
  );
  static const sam = CharacterSpec(
    name: 'Sam',
    hair: HairStyle.short,
    hairColor: Color(0xFF5B3A22),
    skin: Color(0xFFF2C6A5),
    top: Color(0xFF4E8A57),
    setting: Setting.plain,
  );
  static const priya = CharacterSpec(
    name: 'Priya',
    hair: HairStyle.long,
    hairColor: Color(0xFF2B1D16),
    skin: Color(0xFFD9A47F),
    top: Color(0xFF8E6CC9),
    glasses: true,
    setting: Setting.office,
  );
  static const daniel = CharacterSpec(
    name: 'Daniel',
    hair: HairStyle.short,
    hairColor: Color(0xFF2A2420),
    skin: Color(0xFFB98563),
    top: Color(0xFF3F5C7A),
    setting: Setting.office,
  );
}

enum Setting { plain, cafe, office }

class CharacterAvatar extends StatefulWidget {
  const CharacterAvatar({
    super.key,
    this.spec = CharacterSpec.maya,
    this.size = 120,
    this.talking = false,
    this.circle = true,
    this.width,
    this.background,
  });

  final CharacterSpec spec;
  final double size;
  final double? width;
  final bool talking;
  final bool circle;
  final Color? background;

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final w = widget.width ?? widget.size;
    final radius = widget.circle
        ? BorderRadius.circular(widget.size)
        : BorderRadius.circular(22);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: w,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _CharacterPainter(
              spec: widget.spec,
              t: _c.value,
              talking: widget.talking,
              bg: widget.background ?? c.amberSoft,
              c: c,
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  _CharacterPainter({
    required this.spec,
    required this.t,
    required this.talking,
    required this.bg,
    required this.c,
  });

  final CharacterSpec spec;
  final double t;
  final bool talking;
  final Color bg;
  final SqColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    // Small avatars stay clean; scenery only when there is room for it.
    if (size.height >= 100) _setting(canvas, size);

    // Character is sized from height so wide cards keep the person centred.
    final u = h; // unit
    final cx = w / 2 - (spec.setting == Setting.plain ? 0 : u * 0.06);
    final headC = Offset(cx, u * 0.45);
    final headR = u * 0.2;
    final sway = math.sin(t * 2 * math.pi) * u * 0.004;

    canvas.save();
    canvas.translate(sway, 0);

    // Hair behind (long hair).
    final hair = Paint()..color = spec.hairColor;
    if (spec.hair == HairStyle.long) {
      final p = Path()
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: headC + Offset(0, headR * 0.7),
                width: headR * 2.5,
                height: headR * 2.9),
            Radius.circular(headR)));
      canvas.drawPath(p, hair);
    }

    // Body.
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - u * 0.33, u * 0.7, u * 0.66, u * 0.45),
      topLeft: Radius.circular(u * 0.18),
      topRight: Radius.circular(u * 0.18),
    );
    canvas.drawRRect(body, Paint()..color = spec.top);
    // Neck.
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx, u * 0.66), width: u * 0.12, height: u * 0.14),
            Radius.circular(u * 0.03)),
        Paint()..color = _shade(spec.skin, 0.92));
    // Collar V.
    final v = Path()
      ..moveTo(cx - u * 0.07, u * 0.7)
      ..lineTo(cx, u * 0.78)
      ..lineTo(cx + u * 0.07, u * 0.7)
      ..close();
    canvas.drawPath(v, Paint()..color = _shade(spec.skin, 0.92));

    // Apron.
    if (spec.apron != null) {
      final ap = Paint()..color = spec.apron!;
      canvas.drawRRect(
          RRect.fromRectAndCorners(
              Rect.fromLTWH(cx - u * 0.2, u * 0.8, u * 0.4, u * 0.4),
              topLeft: Radius.circular(u * 0.03),
              topRight: Radius.circular(u * 0.03)),
          ap);
      final strap = Paint()
        ..color = spec.apron!
        ..strokeWidth = u * 0.04;
      canvas.drawLine(Offset(cx - u * 0.17, u * 0.81),
          Offset(cx - u * 0.12, u * 0.7), strap);
      canvas.drawLine(Offset(cx + u * 0.17, u * 0.81),
          Offset(cx + u * 0.12, u * 0.7), strap);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - u * 0.12, u * 0.88, u * 0.1, u * 0.035),
              Radius.circular(u * 0.01)),
          Paint()..color = Colors.white.withValues(alpha: 0.9));
    }

    // Ears.
    final skin = Paint()..color = spec.skin;
    canvas.drawCircle(headC + Offset(-headR * 0.98, headR * 0.12), headR * 0.2, skin);
    canvas.drawCircle(headC + Offset(headR * 0.98, headR * 0.12), headR * 0.2, skin);
    // Head.
    canvas.drawOval(
        Rect.fromCenter(center: headC, width: headR * 2, height: headR * 2.15),
        skin);

    // Hair front.
    switch (spec.hair) {
      case HairStyle.bun:
        canvas.drawCircle(headC + Offset(headR * 0.15, -headR * 1.25),
            headR * 0.48, hair);
        _hairCap(canvas, headC, headR, hair, sidePart: true);
      case HairStyle.short:
        _hairCap(canvas, headC, headR, hair, sidePart: false, short: true);
      case HairStyle.long:
        _hairCap(canvas, headC, headR, hair, sidePart: true);
    }

    // Face.
    final ink = Paint()..color = const Color(0xFF2A211C);
    final blink = (t % 0.5) > 0.47; // quick blink twice per loop
    for (final dx in [-0.42, 0.42]) {
      final e = headC + Offset(headR * dx, headR * 0.12);
      if (blink) {
        canvas.drawLine(e - Offset(headR * 0.1, 0), e + Offset(headR * 0.1, 0),
            ink..strokeWidth = headR * 0.06);
      } else {
        canvas.drawOval(
            Rect.fromCenter(center: e, width: headR * 0.2, height: headR * 0.26),
            ink);
        canvas.drawCircle(e + Offset(headR * 0.04, -headR * 0.05),
            headR * 0.045, Paint()..color = Colors.white);
      }
      // Brows.
      final brow = Paint()
        ..color = _shade(spec.hairColor, 0.9)
        ..strokeWidth = headR * 0.07
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
          Rect.fromCenter(
              center: e + Offset(0, -headR * 0.22),
              width: headR * 0.36,
              height: headR * 0.16),
          math.pi * 1.1,
          math.pi * 0.8,
          false,
          brow);
    }
    if (spec.glasses) {
      final g = Paint()
        ..color = const Color(0xFF2A211C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = headR * 0.06;
      for (final dx in [-0.42, 0.42]) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: headC + Offset(headR * dx, headR * 0.12),
                    width: headR * 0.56,
                    height: headR * 0.46),
                Radius.circular(headR * 0.14)),
            g);
      }
      canvas.drawLine(headC + Offset(-headR * 0.14, headR * 0.1),
          headC + Offset(headR * 0.14, headR * 0.1), g);
    }
    // Cheeks.
    final cheek = Paint()..color = const Color(0xFFF08F86).withValues(alpha: 0.45);
    canvas.drawCircle(headC + Offset(-headR * 0.62, headR * 0.45), headR * 0.16, cheek);
    canvas.drawCircle(headC + Offset(headR * 0.62, headR * 0.45), headR * 0.16, cheek);
    // Nose.
    canvas.drawArc(
        Rect.fromCenter(
            center: headC + Offset(0, headR * 0.36),
            width: headR * 0.16,
            height: headR * 0.1),
        0,
        math.pi,
        false,
        Paint()
          ..color = _shade(spec.skin, 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = headR * 0.05
          ..strokeCap = StrokeCap.round);
    // Mouth.
    final open = talking ? (0.5 + 0.5 * math.sin(t * 2 * math.pi * 14)).abs() : 0.0;
    final mouthC = headC + Offset(0, headR * 0.62);
    if (open > 0.2) {
      canvas.drawOval(
          Rect.fromCenter(
              center: mouthC, width: headR * 0.38, height: headR * 0.26 * open),
          Paint()..color = const Color(0xFFB8463B));
    } else {
      canvas.drawArc(
          Rect.fromCenter(center: mouthC - Offset(0, headR * 0.06), width: headR * 0.44, height: headR * 0.26),
          0.15,
          math.pi - 0.3,
          false,
          Paint()
            ..color = const Color(0xFFB8463B)
            ..style = PaintingStyle.stroke
            ..strokeWidth = headR * 0.08
            ..strokeCap = StrokeCap.round);
    }
    canvas.restore();
  }

  void _hairCap(Canvas canvas, Offset headC, double r, Paint hair,
      {required bool sidePart, bool short = false}) {
    final p = Path();
    final top = headC.dy - r * 1.12;
    p.moveTo(headC.dx - r * 1.05, headC.dy + r * (short ? -0.05 : 0.25));
    p.cubicTo(headC.dx - r * 1.15, top - r * 0.1, headC.dx + r * 0.2,
        top - r * 0.35, headC.dx + r * 1.05, headC.dy - r * 0.35);
    p.lineTo(headC.dx + r * 1.05, headC.dy + r * (short ? -0.05 : 0.2));
    // Fringe line.
    if (sidePart) {
      p.quadraticBezierTo(headC.dx + r * 0.7, headC.dy - r * 0.75,
          headC.dx - r * 0.15, headC.dy - r * 0.62);
      p.quadraticBezierTo(headC.dx - r * 0.75, headC.dy - r * 0.45,
          headC.dx - r * 0.85, headC.dy + r * 0.1);
    } else {
      p.quadraticBezierTo(headC.dx + r * 0.6, headC.dy - r * 0.6,
          headC.dx, headC.dy - r * 0.62);
      p.quadraticBezierTo(headC.dx - r * 0.7, headC.dy - r * 0.62,
          headC.dx - r * 0.9, headC.dy - r * 0.1);
    }
    p.close();
    canvas.drawPath(p, hair);
  }

  void _setting(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    switch (spec.setting) {
      case Setting.plain:
        return;
      case Setting.cafe:
        // Shelf with cups, a plant, an espresso machine silhouette.
        final shelf = Paint()..color = const Color(0xFFE6CFAF);
        canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.32, w * 0.38, h * 0.03), shelf);
        canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.55, w * 0.38, h * 0.03), shelf);
        final cup = Paint()..color = const Color(0xFFFFFBF4);
        for (var i = 0; i < 3; i++) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(w * (0.68 + i * 0.1), h * 0.25, w * 0.06, h * 0.07),
                  Radius.circular(h * 0.01)),
              cup);
        }
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.72, h * 0.62, w * 0.2, h * 0.38),
                Radius.circular(h * 0.03)),
            Paint()..color = const Color(0xFFD9C3A5));
        // Plant on the left.
        final leaf = Paint()..color = const Color(0xFF7FA779);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.03, h * 0.62, w * 0.12, h * 0.12),
                Radius.circular(h * 0.02)),
            Paint()..color = const Color(0xFFD08C5C));
        for (final a in [-0.9, -0.4, 0.1, 0.6]) {
          canvas.save();
          canvas.translate(w * 0.09, h * 0.62);
          canvas.rotate(a);
          canvas.drawOval(
              Rect.fromCenter(center: Offset(0, -h * 0.08), width: w * 0.06, height: h * 0.16),
              leaf);
          canvas.restore();
        }
        // Counter.
        canvas.drawRect(Rect.fromLTWH(0, h * 0.9, w, h * 0.1),
            Paint()..color = const Color(0xFFE9D6BA));
      case Setting.office:
        final win = Paint()..color = const Color(0xFFDCE9F0);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.66, h * 0.12, w * 0.3, h * 0.4),
                Radius.circular(h * 0.03)),
            win);
        canvas.drawLine(Offset(w * 0.81, h * 0.12), Offset(w * 0.81, h * 0.52),
            Paint()
              ..color = Colors.white
              ..strokeWidth = h * 0.015);
        canvas.drawRect(Rect.fromLTWH(0, h * 0.88, w, h * 0.12),
            Paint()..color = const Color(0xFFD9CBB6));
    }
  }

  Color _shade(Color col, double f) => Color.from(
        alpha: col.a,
        red: col.r * f,
        green: col.g * f,
        blue: col.b * f,
      );

  @override
  bool shouldRepaint(_CharacterPainter old) => true;
}

/// Picture used by Think in English: a person cooking in a kitchen.
class KitchenScene extends StatelessWidget {
  const KitchenScene({super.key, this.height = 190});
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _KitchenPainter()),
      ),
    );
  }
}

class _KitchenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFBEEDB));
    // Window.
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.68, h * 0.08, w * 0.26, h * 0.42),
            const Radius.circular(10)),
        Paint()..color = const Color(0xFFCFE5F2));
    canvas.drawCircle(Offset(w * 0.86, h * 0.2), h * 0.05, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.82, h * 0.22), h * 0.04, Paint()..color = Colors.white);
    // Shelf + jars.
    canvas.drawRect(Rect.fromLTWH(w * 0.04, h * 0.3, w * 0.26, h * 0.025),
        Paint()..color = const Color(0xFFC9925E));
    for (var i = 0; i < 2; i++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * (0.06 + i * 0.1), h * 0.19, w * 0.06, h * 0.11),
              const Radius.circular(4)),
          Paint()..color = i == 0 ? const Color(0xFFE59A5B) : const Color(0xFFB9D3B2));
    }
    // Plants.
    final leaf = Paint()..color = const Color(0xFF6E9E68);
    for (final base in [Offset(w * 0.08, h * 0.6), Offset(w * 0.84, h * 0.6)]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: base + Offset(0, h * 0.06), width: w * 0.07, height: h * 0.1),
              const Radius.circular(4)),
          Paint()..color = const Color(0xFFD08C5C));
      for (final a in [-0.8, -0.3, 0.2, 0.7]) {
        canvas.save();
        canvas.translate(base.dx, base.dy);
        canvas.rotate(a);
        canvas.drawOval(Rect.fromCenter(center: Offset(0, -h * 0.07), width: w * 0.035, height: h * 0.14), leaf);
        canvas.restore();
      }
    }
    // Counter.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28),
        Paint()..color = const Color(0xFFE7C9A0));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.03),
        Paint()..color = const Color(0xFFD5B285));

    // Person.
    final cx = w * 0.46;
    final skin = Paint()..color = const Color(0xFFF6CDB1);
    final hair = Paint()..color = const Color(0xFF7A4A2B);
    canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(cx - h * 0.22, h * 0.5, h * 0.44, h * 0.3),
            topLeft: Radius.circular(h * 0.12), topRight: Radius.circular(h * 0.12)),
        Paint()..color = const Color(0xFF5E9562));
    canvas.drawCircle(Offset(cx + h * 0.05, h * 0.12), h * 0.07, hair);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.33), width: h * 0.28, height: h * 0.3), skin);
    final cap = Path()
      ..moveTo(cx - h * 0.15, h * 0.36)
      ..cubicTo(cx - h * 0.17, h * 0.12, cx + h * 0.12, h * 0.1, cx + h * 0.15, h * 0.3)
      ..quadraticBezierTo(cx + h * 0.02, h * 0.22, cx - h * 0.12, h * 0.36)
      ..close();
    canvas.drawPath(cap, hair);
    final ink = Paint()..color = const Color(0xFF2A211C);
    canvas.drawCircle(Offset(cx - h * 0.05, h * 0.34), h * 0.015, ink);
    canvas.drawCircle(Offset(cx + h * 0.05, h * 0.34), h * 0.015, ink);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, h * 0.39), width: h * 0.07, height: h * 0.04), 0.2, 2.7, false,
        Paint()
          ..color = const Color(0xFFB8463B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.012
          ..strokeCap = StrokeCap.round);
    // Arm + pan.
    canvas.drawLine(Offset(cx + h * 0.14, h * 0.6), Offset(cx + h * 0.3, h * 0.66),
        Paint()
          ..color = const Color(0xFF5E9562)
          ..strokeWidth = h * 0.07
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + h * 0.3, h * 0.66), Offset(cx + h * 0.42, h * 0.7),
        Paint()
          ..color = const Color(0xFF3A3A3A)
          ..strokeWidth = h * 0.025
          ..strokeCap = StrokeCap.round);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + h * 0.58, h * 0.71), width: h * 0.34, height: h * 0.08),
        Paint()..color = const Color(0xFF2F2F2F));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + h * 0.58, h * 0.695), width: h * 0.2, height: h * 0.045),
        Paint()..color = const Color(0xFFF4C542));
    // Steam.
    final steam = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.012
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = cx + h * (0.5 + i * 0.08);
      final p = Path()
        ..moveTo(x, h * 0.64)
        ..quadraticBezierTo(x - h * 0.03, h * 0.58, x, h * 0.53)
        ..quadraticBezierTo(x + h * 0.03, h * 0.48, x, h * 0.43);
      canvas.drawPath(p, steam);
    }
    // Kettle + tomato.
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.76, h * 0.6, w * 0.08, h * 0.13), const Radius.circular(8)),
        Paint()..color = const Color(0xFF9AA4A6));
    canvas.drawCircle(Offset(w * 0.18, h * 0.76), h * 0.04, Paint()..color = const Color(0xFFD9473A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
