import 'package:flutter/material.dart';

import '../../data/curriculum/curriculum.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'curriculum_scene_screen.dart';
import 'curriculum_widgets.dart';

/// One theme from the skeleton: ordered scenes ending in the finale, target
/// items (expressions, patterns, errors) and the level type mix.
class CurriculumThemeScreen extends StatelessWidget {
  const CurriculumThemeScreen({super.key, required this.theme});
  final CurriculumTheme theme;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SqTopBar(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconBlob(emoji: theme.emoji, size: 64, color: c.amberSoft),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(theme.name, style: context.text.headlineMedium),
                                    const SizedBox(height: 4),
                                    Row(children: [BandChip(theme.band), const SizedBox(width: 6), BandChip(theme.category)]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(theme.blurb, style: context.text.bodyLarge),
                          const SizedBox(height: 6),
                          Text(theme.whoFor, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                          if (theme.prerequisites.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.lightbulb_rounded, color: c.amber, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text('Tip: try ${theme.prerequisites.join(' and ')} first.',
                                      style: context.text.bodyMedium!.copyWith(color: c.inkSoft)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabsHeader(
                  TabBar(
                    labelStyle: context.text.titleSmall,
                    labelColor: c.green,
                    unselectedLabelColor: c.inkMuted,
                    indicatorColor: c.green,
                    dividerColor: c.border,
                    tabs: [
                      Tab(text: 'Scenes · ${theme.scenes.length + 1}'),
                      Tab(text: 'Targets · ${theme.targets.length}'),
                      const Tab(text: 'Type mix'),
                    ],
                  ),
                  c.background,
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _ScenesTab(theme: theme),
                _TargetsTab(theme: theme),
                _TypesTab(theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  _TabsHeader(this.tabs, this.bg);
  final TabBar tabs;
  final Color bg;

  @override
  double get minExtent => tabs.preferredSize.height;
  @override
  double get maxExtent => tabs.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => ColoredBox(color: bg, child: tabs);

  @override
  bool shouldRebuild(_TabsHeader old) => old.tabs != tabs || old.bg != bg;
}

void _openScene(BuildContext context, CurriculumTheme theme, SceneTemplate s) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CurriculumSceneScreen(theme: theme, scene: s)));

class _ScenesTab extends StatelessWidget {
  const _ScenesTab({required this.theme});
  final CurriculumTheme theme;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final all = [...theme.scenes, theme.finale];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      itemCount: all.length,
      itemBuilder: (context, i) {
        final s = all[i];
        final last = i == all.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Path line.
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(width: 2, height: 18, color: i == 0 ? Colors.transparent : c.border),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: last ? c.amber : c.greenSoft,
                        border: Border.all(color: c.background, width: 2),
                      ),
                    ),
                    Expanded(child: Container(width: 2, color: last ? Colors.transparent : c.border)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Pressable(
                    onTap: () => _openScene(context, theme, s),
                    child: SqCard(
                      color: last ? c.amberSoft : null,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          TypeIcon(s.type, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(s.title, style: context.text.titleMedium)),
                                    BandChip(s.band.label),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(s.goal, style: context.text.bodyMedium!.copyWith(color: c.inkSoft)),
                                const SizedBox(height: 4),
                                Text(last ? 'Theme finale' : s.type.label, style: context.text.labelMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TargetsTab extends StatelessWidget {
  const _TargetsTab({required this.theme});
  final CurriculumTheme theme;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        for (final kind in TargetKind.values) ...[
          SectionLabel('${kind.label}s · ${theme.targets.where((t) => t.kind == kind).length}'),
          for (final t in theme.targets.where((t) => t.kind == kind))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SqCard(
                color: c.surface,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _TargetText(t)),
                        BandChip(t.band.label),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.meaning, style: context.text.bodyMedium!.copyWith(color: c.inkSoft)),
                    const SizedBox(height: 4),
                    Text('"${t.example}"', style: context.text.bodyMedium!.copyWith(color: c.inkMuted, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 4, runSpacing: 4, children: [for (final ty in t.types) TypeBadge(ty)]),
                    const SizedBox(height: 6),
                    Text(
                      'Taught in: ${[...theme.scenes, theme.finale].where((s) => s.targets.contains(t.text)).map((s) => s.title).join(', ')}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _TargetText extends StatelessWidget {
  const _TargetText(this.t);
  final TargetItem t;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final style = context.text.titleLarge!.copyWith(fontSize: 18);
    if (t.kind == TargetKind.errorFix && t.text.contains('→')) {
      final parts = t.text.split('→');
      return Text.rich(
        TextSpan(children: [
          TextSpan(text: parts[0].trim(), style: TextStyle(color: c.coral, decoration: TextDecoration.lineThrough, decorationColor: c.coral)),
          const TextSpan(text: '  →  '),
          TextSpan(text: parts[1].trim(), style: TextStyle(color: c.green)),
        ]),
        style: style,
      );
    }
    return Text(t.text, style: style);
  }
}

class _TypesTab extends StatelessWidget {
  const _TypesTab({required this.theme});
  final CurriculumTheme theme;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final all = [...theme.scenes, theme.finale];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        for (final type in LevelType.values) ...[
          Builder(builder: (context) {
            final scenes = all.where((s) => s.type == type).toList();
            final info = levelTypeInfo[type]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SqCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TypeIcon(type, size: 40),
                        const SizedBox(width: 10),
                        Expanded(child: Text(type.label, style: context.text.titleLarge)),
                        Text('${scenes.length}', style: context.text.titleLarge!.copyWith(color: c.green)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Win: ${info.win}', style: context.text.bodySmall),
                    const SizedBox(height: 8),
                    for (final s in scenes)
                      InkWell(
                        onTap: () => _openScene(context, theme, s),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.subdirectory_arrow_right_rounded, size: 18, color: c.inkMuted),
                              const SizedBox(width: 6),
                              Expanded(child: Text('${s.title} — ${s.goal}', style: context.text.bodyMedium)),
                              Icon(Icons.chevron_right_rounded, size: 20, color: c.inkMuted),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
