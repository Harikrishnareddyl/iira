import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Theme path: scenes play in order, no numbers. Done scenes show stars,
/// future scenes stay hidden, the finale closes the theme.
class ThemePathScreen extends StatelessWidget {
  const ThemePathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    const theme = Mock.currentTheme;
    final path = Mock.themePath;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SqTopBar(title: theme.name),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
              child: Column(
                children: [
                  const ThemeBar(value: 0.42, height: 12),
                  const SizedBox(height: 8),
                  Text(theme.blurb, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: path.length,
                itemBuilder: (context, i) {
                  final s = path[i];
                  final isCurrent = !s.done && (i == 0 || path[i - 1].done);
                  final dx = math.sin(i * 1.1) * 80;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: _Node(
                        scene: s,
                        current: isCurrent,
                        onTap: () {
                          if (s.done) {
                            _showDone(context, s);
                          } else if (isCurrent) {
                            demoNav(context, 'Level intro → ${s.title}');
                          } else {
                            toast(context, s.type == LevelType.boss
                                ? 'The finale opens after the scenes before it.'
                                : 'Scenes play in order. This one opens soon.');
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDone(BuildContext context, Scene s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.title, style: ctx.text.headlineMedium),
            const SizedBox(height: 4),
            Text(s.goal, style: ctx.text.bodyLarge!.copyWith(color: ctx.sq.inkMuted)),
            const SizedBox(height: 12),
            MiniStars(stars: s.stars, size: 34),
            const SizedBox(height: 16),
            Text('Replays live in Free play → Try again.',
                style: ctx.text.bodyMedium!.copyWith(color: ctx.sq.inkMuted)),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Try again in Free play',
              fontSize: 19,
              height: 56,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

class _Node extends StatefulWidget {
  const _Node({required this.scene, required this.current, required this.onTap});
  final Scene scene;
  final bool current;
  final VoidCallback onTap;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.current) _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final s = widget.scene;
    final boss = s.type == LevelType.boss;
    final size = boss ? 86.0 : 72.0;
    final Color fill = s.done
        ? c.green
        : widget.current
            ? c.green
            : c.surfaceMuted;
    final icon = s.done
        ? Icons.check_rounded
        : widget.current
            ? Icons.play_arrow_rounded
            : boss
                ? Icons.flag_rounded
                : Icons.lock_outline_rounded;
    return Column(
      children: [
        Pressable(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                if (widget.current)
                  Container(
                    width: size * (1 + 0.35 * _pulse.value),
                    height: size * (1 + 0.35 * _pulse.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.green.withValues(alpha: 0.25 * (1 - _pulse.value)),
                    ),
                  ),
                child!,
              ],
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                border: Border(
                  bottom: BorderSide(
                      color: s.done || widget.current ? c.greenDeep : c.border, width: 4),
                ),
              ),
              child: Icon(icon,
                  color: s.done || widget.current ? Colors.white : c.inkMuted,
                  size: size * 0.5),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (s.done) ...[
          Text(s.title, style: context.text.titleSmall),
          MiniStars(stars: s.stars, size: 16),
        ] else if (widget.current)
          Text(s.title, style: context.text.titleMedium!.copyWith(color: c.green))
        else if (boss)
          Text('Theme finale', style: context.text.titleSmall!.copyWith(color: c.inkMuted)),
      ],
    );
  }
}
