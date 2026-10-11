import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/level.dart';
import '../../widgets/mascot.dart';

/// End of onboarding: the skill profile (one score per skill) and the first
/// plan (3–5 themes from goals and profile).
class SkillProfileScreen extends StatelessWidget {
  const SkillProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final plan = Mock.plan.where((t) => t.status != ThemeStatus.complete).toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  StaggerIn(
                    step: const Duration(milliseconds: 90),
                    children: [
                      const ThemeBar(value: 1, from: 6 / 7, height: 8),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Mascot(size: 70, mood: MascotMood.happy, showRays: false),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Here\'s how you speak today', style: context.text.headlineMedium)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('You understand a lot. Speaking quickly is where we\'ll start.',
                          style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                      const SizedBox(height: 14),
                      SqCard(
                        color: c.surface,
                        child: Column(
                          children: [
                            for (final s in Mock.skillProfile)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    SizedBox(width: 130, child: Text(s.$1, style: context.text.titleSmall)),
                                    Expanded(child: ThemeBar(value: s.$3, height: 8, duration: const Duration(milliseconds: 1400))),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 46,
                                      child: Text(s.$2, textAlign: TextAlign.end, style: context.text.titleSmall!.copyWith(color: c.green)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      HintCard(text: 'More Quick reply levels to build speed. Your speed is compared to you, not to native speakers.', icon: Icons.bolt_rounded),
                      const SectionLabel('Your first plan'),
                      for (final t in plan)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RowCard(
                            title: t.name,
                            subtitle: t.blurb,
                            leading: IconBlob(emoji: t.emoji, color: c.amberSoft),
                            trailing: Text(t.fit.label, style: context.text.labelMedium!.copyWith(color: c.green)),
                          ),
                        ),
                      Text('You can change, add or reorder themes anytime in My plan.', style: context.text.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: PrimaryButton(label: 'Start playing', icon: Icons.play_arrow_rounded, onTap: () => demoNav(context, 'Home')),
            ),
          ],
        ),
      ),
    );
  }
}
