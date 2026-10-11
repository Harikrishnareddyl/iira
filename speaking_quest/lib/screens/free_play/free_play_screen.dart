import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/voice.dart';

/// Free play: Free talk card on top, then Make your own scene, Try again,
/// New twists and Surprise me. Never moves the plan.
class FreePlayScreen extends StatelessWidget {
  const FreePlayScreen({super.key, this.empty = false});

  /// Before any scene is completed.
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Free play'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  StaggerIn(
                    children: [
                      if (!empty) ...[
                        const _FreeTalkCard(locked: false),
                        const SizedBox(height: 12),
                      ] else ...[
                        Text('Start with a real situation of your own.',
                            style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                        const SizedBox(height: 12),
                      ],
                      _row(context, 'Make a scene', Icons.edit_rounded, c.amberSoft, const Color(0xFFD0763A),
                          () => demoNav(context, 'Make your own scene')),
                      if (empty) ...[
                        const SizedBox(height: 16),
                        SqCard(
                          color: c.surface,
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: c.inkMuted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Replays and new twists appear here as you finish scenes in your plan. Free talk with Maya opens after 2 scenes.',
                                    style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        RowCard(
                          title: 'Try again',
                          leading: IconBlob(icon: Icons.refresh_rounded, color: c.surfaceGreen),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            const MiniStars(stars: 3, size: 22),
                            Icon(Icons.chevron_right_rounded, color: c.inkSoft, size: 28),
                          ]),
                          onTap: () => _tryAgain(context),
                        ),
                        const SizedBox(height: 10),
                        _row(context, 'New twists', Icons.shuffle_rounded, c.lavenderSoft, c.lavender, () => _twists(context)),
                        const SizedBox(height: 10),
                        _row(context, 'Surprise me', Icons.casino_rounded, c.coralSoft, c.coral, () {
                          final all = [
                            ...Mock.completedScenes.map((s) => 'Replay: ${s.title}'),
                            ...Mock.twists.map((t) => 'Twist: ${t.$1}'),
                          ];
                          toast(context, '🎲  ${all[math.Random().nextInt(all.length)]}');
                        }),
                      ],
                      const SizedBox(height: 18),
                      Text("Free play doesn't move your plan. Results still help decide what comes back.",
                          textAlign: TextAlign.center, style: context.text.bodySmall),
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

  Widget _row(BuildContext context, String title, IconData icon, Color bg, Color fg, VoidCallback onTap) =>
      RowCard(title: title, leading: IconBlob(icon: icon, color: bg, iconColor: fg), onTap: onTap);

  void _tryAgain(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SheetList(
        title: 'Try again',
        subtitle: 'Café & food · scenes you finished',
        children: [
          for (final s in Mock.completedScenes)
            RowCard(
              title: s.title,
              subtitle: '${s.type.label} · Done',
              leading: IconBlob(icon: s.type.icon, color: ctx.sq.surfaceGreen, size: 42),
              trailing: MiniStars(stars: s.stars),
              onTap: () {
                Navigator.pop(ctx);
                demoNav(context, 'Level intro (Free play) → ${s.title}');
              },
            ),
        ],
      ),
    );
  }

  void _twists(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SheetList(
        title: 'New twists',
        subtitle: 'Same skills, new situation',
        children: [
          for (final t in Mock.twists)
            RowCard(
              title: t.$1,
              subtitle: '${t.$3}\nTwist on ${t.$2}',
              leading: IconBlob(icon: Icons.shuffle_rounded, color: ctx.sq.lavenderSoft, iconColor: ctx.sq.lavender, size: 42),
              onTap: () {
                Navigator.pop(ctx);
                demoNav(context, 'Level intro (Free play) → ${t.$1}');
              },
            ),
        ],
      ),
    );
  }
}

class _SheetList extends StatelessWidget {
  const _SheetList({required this.title, required this.subtitle, required this.children});
  final String title, subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.text.headlineMedium),
            Text(subtitle, style: context.text.bodySmall),
            const SizedBox(height: 12),
            for (final w in children) Padding(padding: const EdgeInsets.only(bottom: 8), child: w),
          ],
        ),
      ),
    );
  }
}

class _FreeTalkCard extends StatelessWidget {
  const _FreeTalkCard({required this.locked});
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              Opacity(
                opacity: locked ? 0.5 : 1,
                child: CharacterAvatar(
                  spec: CharacterSpec.mayaCasual,
                  size: 190,
                  width: 440,
                  circle: false,
                  background: c.surfaceGreen,
                ),
              ),
              Positioned(
                right: 22,
                top: 22,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.greenSoft, width: 2.5),
                  ),
                  child: Waveform(bars: 4, height: 28, active: !locked, barWidth: 4, gap: 3, seed: 2),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('Talk with Maya', style: context.text.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  locked
                      ? 'Opens after you finish 2 scenes'
                      : '${Learner.freeSessionsLeft} free chats left today',
                  style: context.text.bodyLarge!.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: 12),
                if (!locked)
                  PrimaryButton(
                    label: 'Start',
                    icon: Icons.play_arrow_rounded,
                    height: 60,
                    fontSize: 26,
                    onTap: () => demoNav(context, 'Free talk'),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, color: c.inkMuted, size: 18),
                      const SizedBox(width: 6),
                      Text('Free talk', style: context.text.titleSmall!.copyWith(color: c.inkMuted)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
