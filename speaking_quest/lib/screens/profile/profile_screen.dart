import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Profile: streak, scenes played, themes completed, expressions, and the
/// per-skill profile (bands, no grades).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SqTopBar(
              title: 'Profile',
              trailing: IconButton(onPressed: () => demoNav(context, 'Settings'), icon: Icon(Icons.settings_rounded, color: c.inkSoft)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  StaggerIn(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: c.surfaceGreen,
                            child: Text('A', style: context.text.headlineMedium!.copyWith(color: c.green)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Learner.name, style: context.text.headlineMedium),
                                Text('${Learner.job} · Work, Travel', style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _Stat(icon: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF28C28)), value: '${Learner.streak}', label: 'day streak', onTap: () => demoNav(context, 'Streak & coins'))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(icon: const CoinIcon(size: 24), value: '${Learner.coins}', label: 'coins', onTap: () => demoNav(context, 'Streak & coins'))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _Stat(icon: Icon(Icons.play_circle_rounded, color: c.green), value: '${Learner.scenesPlayed}', label: 'scenes played')),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(icon: Icon(Icons.flag_rounded, color: c.green), value: '${Learner.themesCompleted}', label: 'theme done')),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat(icon: Icon(Icons.menu_book_rounded, color: c.green), value: '${Learner.expressionsUnlocked}', label: 'expressions', onTap: () => demoNav(context, 'Expressions'))),
                        ],
                      ),
                      const SectionLabel('Your speaking'),
                      SqCard(
                        color: c.surface,
                        child: Column(
                          children: [
                            for (final s in Mock.skillProfile)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(s.$1, style: context.text.titleSmall)),
                                        Text(s.$2, style: context.text.titleSmall!.copyWith(color: c.green)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ThemeBar(value: s.$3, height: 7),
                                    const SizedBox(height: 4),
                                    Text(s.$4, style: context.text.bodySmall),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SectionLabel('This week'),
                      SqCard(
                        color: c.surface,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final (d, on) in [('M', true), ('T', true), ('W', true), ('T', true), ('F', true), ('S', true), ('S', false)])
                              Column(children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: on ? c.amberSoft : c.surfaceMuted),
                                  child: Icon(Icons.local_fire_department_rounded, size: 18, color: on ? const Color(0xFFF28C28) : c.border),
                                ),
                                const SizedBox(height: 4),
                                Text(d, style: context.text.labelMedium),
                              ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label, this.onTap});
  final Widget icon;
  final String value, label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: SqCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(height: 8),
              Text(value, style: context.text.headlineMedium),
              Text(label, style: context.text.bodySmall),
            ],
          ),
        ),
      );
}
