import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/level.dart';
import '../../widgets/mascot.dart';

enum IntroVariant { plan, finale, freePlay, practice }

/// Level intro: title, goal, setup line, time estimate, level type tag, plus a
/// context tag for Theme finale, Free play and Practice.
class LevelIntroScreen extends StatefulWidget {
  const LevelIntroScreen({super.key});

  @override
  State<LevelIntroScreen> createState() => _LevelIntroScreenState();
}

class _LevelIntroScreenState extends State<LevelIntroScreen> {
  IntroVariant _v = IntroVariant.plan;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final (title, goal, setup, type, mins, contextTag) = switch (_v) {
      IntroVariant.plan => (Mock.nextScene.title, Mock.nextScene.goal, Mock.nextScene.setup, LevelType.conversation, 3, null),
      IntroVariant.finale => ('Brunch with a friend', 'Host your friend and sort out the order.', 'Your friend is visiting. Order for both of you and fix anything that goes wrong.', LevelType.boss, 4, 'Theme finale'),
      IntroVariant.freePlay => ('Too much sugar', 'Ask for a new drink without sugar.', 'A twist on Coffee mix-up. Same skills, new situation.', LevelType.conversation, 3, 'Free play'),
      IntroVariant.practice => ('Fix the slides', 'Use "Could you remake it?" at work.', 'Your teammate shared slides with a typo before a client call.', LevelType.conversation, 1, 'Practice'),
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: StaggerIn(
                    key: ValueKey(_v),
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          LevelTag(type.label),
                          if (contextTag != null)
                            LevelTag(contextTag,
                                color: _v == IntroVariant.finale ? c.amberSoft : c.lavenderSoft,
                                textColor: _v == IntroVariant.finale ? const Color(0xFF9A6A0B) : c.lavender),
                          LevelTag('~$mins min', color: c.surfaceMuted, textColor: c.inkMuted),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: CharacterAvatar(
                          spec: _v == IntroVariant.practice ? CharacterSpec.priya : CharacterSpec.maya,
                          size: 200,
                          width: 320,
                          circle: false,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(title, textAlign: TextAlign.center, style: context.text.displaySmall),
                      const SizedBox(height: 12),
                      Center(child: GoalPill(goal: goal)),
                      const SizedBox(height: 16),
                      Text(setup,
                          textAlign: TextAlign.center,
                          style: context.text.bodyLarge!.copyWith(color: c.inkSoft)),
                      if (_v == IntroVariant.finale) ...[
                        const SizedBox(height: 14),
                        SqCard(
                          color: c.surface,
                          child: Text(
                            'Uses this theme\'s expressions, plus the ones still shaky. No script this time.',
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium!.copyWith(color: c.inkMuted),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      MascotTip(
                        text: switch (_v) {
                          IntroVariant.finale => 'No script this time. Use what you learned in this theme.',
                          IntroVariant.practice => 'One minute. Just use the expression once.',
                          _ => 'Stuck? Hints are free. Use them.',
                        },
                        mood: MascotMood.talking,
                        size: 54,
                      ),
                      if (_v == IntroVariant.freePlay || _v == IntroVariant.practice) ...[
                        const SizedBox(height: 14),
                        Text("Doesn't move your plan.",
                            textAlign: TextAlign.center,
                            style: context.text.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: PrimaryButton(
                label: 'Start',
                icon: Icons.play_arrow_rounded,
                onTap: () => demoNav(context, '${type.label} level'),
              ),
            ),
            _VariantSwitch(value: _v, onChanged: (v) => setState(() => _v = v)),
          ],
        ),
      ),
    );
  }
}

class _VariantSwitch extends StatelessWidget {
  const _VariantSwitch({required this.value, required this.onChanged});
  final IntroVariant value;
  final ValueChanged<IntroVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    const labels = {
      IntroVariant.plan: 'Plan',
      IntroVariant.finale: 'Finale',
      IntroVariant.freePlay: 'Free play',
      IntroVariant.practice: 'Practice',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Preview:', style: context.text.labelMedium),
          for (final v in IntroVariant.values)
            TextButton(
              onPressed: () => onChanged(v),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(labels[v]!,
                  style: context.text.labelMedium!.copyWith(
                      color: v == value ? c.green : c.inkMuted,
                      fontWeight: v == value ? FontWeight.w800 : FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
