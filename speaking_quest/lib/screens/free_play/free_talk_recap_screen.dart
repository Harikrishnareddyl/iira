import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';

/// Free talk recap: duration and coins, two things that went well, two to try
/// next time, one sentence said more naturally.
class FreeTalkRecapScreen extends StatelessWidget {
  const FreeTalkRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            StaggerIn(
              step: const Duration(milliseconds: 90),
              children: [
                const Center(child: Mascot(size: 120, mood: MascotMood.cheer)),
                Text('Good chat', textAlign: TextAlign.center, style: context.text.displaySmall),
                const SizedBox(height: 4),
                Text('With $mascotName · about your project', textAlign: TextAlign.center, style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _Tile(icon: Icon(Icons.timer_outlined, color: c.green, size: 28), value: '4:12', label: 'talking')),
                    const SizedBox(width: 10),
                    const Expanded(child: _Tile(icon: CoinIcon(size: 28), value: '+10', label: 'coins')),
                    const SizedBox(width: 10),
                    Expanded(child: _Tile(icon: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF28C28), size: 28), value: '7', label: 'day streak')),
                  ],
                ),
                const SizedBox(height: 18),
                _Section(
                  title: 'Went well',
                  icon: Icons.check_circle_rounded,
                  color: c.green,
                  bg: c.surfaceGreen,
                  items: const [
                    'You used "run late" naturally.',
                    'You asked $mascotName a question back: "What would you do?"',
                  ],
                ),
                const SizedBox(height: 12),
                _Section(
                  title: 'Try next time',
                  icon: Icons.flag_rounded,
                  color: c.amber,
                  bg: c.amberSoft,
                  items: const [
                    'Use "make a decision" once more. It\'s still new.',
                    'Give a reason after yes/no: "Yes, because…"',
                  ],
                ),
                const SizedBox(height: 12),
                SqCard(
                  color: c.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SAID MORE NATURALLY', style: context.text.labelSmall),
                      const SizedBox(height: 10),
                      Text('the client want more changes',
                          style: context.text.bodyLarge!.copyWith(color: c.inkMuted, decoration: TextDecoration.lineThrough)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: Text('The client wants more changes.', style: context.text.titleLarge)),
                          IconButton(onPressed: () => toast(context, '🔊  The client wants more changes.'), icon: Icon(Icons.volume_up_rounded, color: c.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Done', onTap: () => demoNav(context, 'Free play')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.value, required this.label});
  final Widget icon;
  final String value, label;

  @override
  Widget build(BuildContext context) => SqCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          icon,
          const SizedBox(height: 6),
          Text(value, style: context.text.headlineSmall),
          Text(label, style: context.text.bodySmall),
        ]),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.color, required this.bg, required this.items});
  final String title;
  final IconData icon;
  final Color color, bg;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: context.text.titleLarge),
          ]),
          const SizedBox(height: 8),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: context.text.bodyLarge),
                  Expanded(child: Text(i, style: context.text.bodyLarge)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
