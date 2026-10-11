import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';

/// Home: one next step. Theme bar (opens My plan), next scene card, Play,
/// Free play, coins, streak, Expressions and Profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _themeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    // Long-press the theme card to preview switching themes (progress is per theme).
    final theme = Mock.plan.where((t) => t.status != ThemeStatus.complete).toList()[_themeIndex];
    final scene = _themeIndex == 0
        ? Mock.nextScene
        : const Scene(
            title: 'Monday coffee',
            goal: 'Ask about their weekend.',
            type: LevelType.conversation);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => demoNav(context, 'Settings'),
                            icon: Icon(Icons.settings_rounded, color: c.inkSoft, size: 30),
                          ),
                          const Spacer(),
                          CoinChip(coins: Learner.coins, onTap: () => demoNav(context, 'Streak & coins')),
                          const SizedBox(width: 8),
                          StreakChip(days: Learner.streak, onTap: () => demoNav(context, 'Streak & coins')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Ready\nto talk?',
                          textAlign: TextAlign.center,
                          style: context.text.displayLarge!.copyWith(fontSize: 52)),
                      const SizedBox(height: 4),
                      Center(
                        child: Mascot(
                          size: 160,
                          mood: MascotMood.wave,
                          showRays: true,
                          rayColor: c.green,
                        ),
                      ),
                      const Spacer(),
                      Pressable(
                        onTap: () => demoNav(context, 'My plan'),
                        child: GestureDetector(
                          onLongPress: () => setState(() => _themeIndex = (_themeIndex + 1) % 2),
                          child: SqCard(
                            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                            child: Row(
                              children: [
                                IconBlob(emoji: theme.emoji, size: 54, color: c.amberSoft),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        layoutBuilder: _leftLayout,
                                        child: Text(theme.name,
                                            key: ValueKey(theme.name),
                                            style: context.text.titleLarge!.copyWith(fontSize: 22)),
                                      ),
                                      const SizedBox(height: 8),
                                      ThemeBar(key: ValueKey(theme.name), value: theme.progress),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: c.inkSoft, size: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SqCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const TargetIcon(size: 34),
                            const SizedBox(width: 14),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                layoutBuilder: _leftLayout,
                                child: Column(
                                  key: ValueKey(scene.title),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(scene.title,
                                        style: context.text.titleLarge!.copyWith(fontSize: 22)),
                                    Text(scene.goal,
                                        style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _BreathingPlay(onTap: () => demoNav(context, 'Level intro → Coffee mix-up')),
                      const SizedBox(height: 12),
                      SoftButton(
                        label: 'Free play',
                        icon: Icons.chat_bubble_rounded,
                        onTap: () => demoNav(context, 'Free play'),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _BottomLink(
                              icon: Icons.menu_book_outlined,
                              label: 'Expressions',
                              onTap: () => demoNav(context, 'Expressions'),
                            ),
                          ),
                          Container(width: 1, height: 44, color: c.border),
                          Expanded(
                            child: _BottomLink(
                              icon: Icons.person_outline_rounded,
                              label: 'Profile',
                              onTap: () => demoNav(context, 'Profile'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingPlay extends StatefulWidget {
  const _BreathingPlay({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BreathingPlay> createState() => _BreathingPlayState();
}

class _BreathingPlayState extends State<_BreathingPlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.025)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: PrimaryButton(
        label: 'Play',
        icon: Icons.play_arrow_rounded,
        height: 76,
        fontSize: 34,
        onTap: widget.onTap,
      ),
    );
  }
}

class _BottomLink extends StatelessWidget {
  const _BottomLink({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Pressable(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: c.inkSoft, size: 32),
          const SizedBox(height: 2),
          Text(label, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
        ],
      ),
    );
  }
}

Widget _leftLayout(Widget? current, List<Widget> previous) => Stack(
      alignment: Alignment.centerLeft,
      children: [...previous, ?current],
    );
