import 'package:flutter/material.dart';

import '../../data/curriculum/curriculum.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'curriculum_theme_screen.dart';
import 'curriculum_widgets.dart';

/// Curriculum skeleton browser: every theme by category, plus a reference of
/// the level types (what they train, win condition, power-ups and weights).
class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  String _cat = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final scenes = curriculum.fold<int>(0, (n, t) => n + t.scenes.length + 1);
    final targets = curriculum.fold<int>(0, (n, t) => n + t.targets.length);
    final q = _query.toLowerCase();
    final list = curriculum.where((t) {
      if (_cat != 'All' && t.category != _cat) return false;
      if (q.isEmpty) return true;
      return t.name.toLowerCase().contains(q) ||
          t.blurb.toLowerCase().contains(q) ||
          t.whoFor.toLowerCase().contains(q) ||
          t.targets.any((x) => x.text.toLowerCase().contains(q));
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SqTopBar(title: 'Curriculum'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    _Stat('${curriculum.length}', 'themes'),
                    _Stat('$scenes', 'scenes'),
                    _Stat('$targets', 'targets'),
                    _Stat('${curriculumCategories.length}', 'areas'),
                  ],
                ),
              ),
              TabBar(
                labelStyle: context.text.titleSmall,
                labelColor: c.green,
                unselectedLabelColor: c.inkMuted,
                indicatorColor: c.green,
                dividerColor: c.border,
                tabs: const [Tab(text: 'Themes'), Tab(text: 'Level types')],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: TextField(
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(
                              hintText: 'Search themes, people or expressions',
                              prefixIcon: Icon(Icons.search_rounded),
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              for (final cat in ['All', ...curriculumCategories])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('$cat · ${cat == 'All' ? curriculum.length : curriculum.where((t) => t.category == cat).length}'),
                                    selected: _cat == cat,
                                    showCheckmark: false,
                                    selectedColor: c.surfaceGreen,
                                    backgroundColor: c.surfaceWarm,
                                    side: BorderSide(color: _cat == cat ? c.green : c.border),
                                    onSelected: (_) => setState(() => _cat = cat),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: list.isEmpty
                              ? Center(child: Text('No themes match.', style: context.text.bodyLarge))
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                                  itemCount: list.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                                  itemBuilder: (context, i) => _ThemeCard(theme: list[i]),
                                ),
                        ),
                      ],
                    ),
                    const _LevelTypesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: context.text.headlineSmall!.copyWith(color: context.sq.green)),
          Text(label, style: context.text.bodySmall),
        ]),
      );
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.theme});
  final CurriculumTheme theme;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final types = {for (final s in theme.scenes) s.type};
    return Pressable(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CurriculumThemeScreen(theme: theme))),
      child: SqCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBlob(emoji: theme.emoji, size: 50, color: c.surface),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(theme.name, style: context.text.titleLarge!.copyWith(fontSize: 19)),
                      Text(theme.blurb, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.inkSoft),
              ],
            ),
            const SizedBox(height: 10),
            Text(theme.whoFor, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
            const SizedBox(height: 10),
            Row(
              children: [
                BandChip(theme.band),
                const SizedBox(width: 6),
                BandChip(theme.category),
                const Spacer(),
                Text('${theme.scenes.length} scenes + finale', style: context.text.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final t in LevelType.values)
                  if (types.contains(t) || t == LevelType.boss) TypeBadge(t, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTypesTab extends StatelessWidget {
  const _LevelTypesTab();

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final counts = <LevelType, int>{};
    for (final t in curriculum) {
      for (final s in [...t.scenes, t.finale]) {
        counts[s.type] = (counts[s.type] ?? 0) + 1;
      }
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Text('Every level type ends with the learner speaking.', style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
        const SizedBox(height: 12),
        for (final info in levelTypeInfo.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SqCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TypeIcon(info.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.type.label, style: context.text.titleLarge),
                            Text('Trains: ${info.type.trains}', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                      Text('${counts[info.type] ?? 0}', style: context.text.titleLarge!.copyWith(color: c.green)),
                      const SizedBox(width: 4),
                      Text('scenes', style: context.text.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(info.what, style: context.text.bodyMedium),
                  const SizedBox(height: 6),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Win: ', style: TextStyle(fontWeight: FontWeight.w800, color: c.green)),
                    TextSpan(text: info.win),
                    TextSpan(text: '  ·  ${info.rounds}', style: TextStyle(color: c.inkMuted)),
                  ]), style: context.text.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final p in info.powerUps)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(9), border: Border.all(color: c.border)),
                          child: Text('${p.name} · ${p.weight}', style: context.text.labelMedium),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Text('Numbers after power-ups are help weights used in scoring.', style: context.text.bodySmall),
      ],
    );
  }
}
