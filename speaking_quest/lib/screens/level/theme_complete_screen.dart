import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';

/// Theme complete: +50 coins, a calm confetti burst, then the next unfinished
/// theme in the plan starts automatically.
class ThemeCompleteScreen extends StatefulWidget {
  const ThemeCompleteScreen({super.key});

  @override
  State<ThemeCompleteScreen> createState() => _ThemeCompleteScreenState();
}

class _ThemeCompleteScreenState extends State<ThemeCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burst,
                  builder: (context, _) => CustomPaint(painter: _Confetti(_burst.value, [c.green, c.amber, c.greenSoft, c.coral])),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
              child: StaggerIn(
                step: const Duration(milliseconds: 140),
                children: [
                  Text('Theme complete', textAlign: TextAlign.center, style: context.text.displayMedium),
                  const SizedBox(height: 8),
                  Text('Café & food is yours now.', textAlign: TextAlign.center, style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                  const SizedBox(height: 16),
                  Center(
                    child: ProgressRing(
                      value: 1,
                      size: 150,
                      stroke: 10,
                      child: const Text('☕', style: TextStyle(fontSize: 60)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 20, 8),
                      decoration: BoxDecoration(color: c.amberSoft, borderRadius: BorderRadius.circular(30)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const CoinIcon(size: 36),
                        const SizedBox(width: 10),
                        Text('+50 coins', style: context.text.titleLarge),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SqCard(
                    child: Row(
                      children: [
                        const _Stat('14', 'scenes'),
                        _divider(c),
                        const _Stat('9', 'expressions'),
                        _divider(c),
                        const _Stat('6', 'mastered'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SqCard(
                    color: c.surfaceGreen,
                    child: Row(
                      children: [
                        const CompanionMark(size: 52, mood: CompanionMood.pleased, showRays: false),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Up next in your plan', style: context.text.bodySmall),
                              Text('💼  Work small talk', style: context.text.titleLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: 'Continue', trailingIcon: Icons.chevron_right_rounded, onTap: () => demoNav(context, 'Home (Work small talk)')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(SqColors c) => Container(width: 1, height: 40, color: c.border);
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: context.text.headlineMedium),
          Text(label, style: context.text.bodySmall),
        ]),
      );
}

class _Confetti extends CustomPainter {
  _Confetti(this.t, this.colors);
  final double t;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(4);
    final origin = Offset(size.width / 2, size.height * 0.3);
    for (var i = 0; i < 46; i++) {
      final a = r.nextDouble() * math.pi * 2;
      final speed = 180 + r.nextDouble() * 260;
      final p = origin + Offset(math.cos(a), math.sin(a)) * speed * t + Offset(0, 260 * t * t);
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: (1 - t).clamp(0, 1));
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(a + t * 6);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 10, 6), const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Confetti old) => old.t != t;
}
