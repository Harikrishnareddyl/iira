import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Explore themes: full catalog by category, with a fit label relative to the
/// learner. Prerequisites are suggested, never enforced.
class ExploreThemesScreen extends StatefulWidget {
  const ExploreThemesScreen({super.key});

  @override
  State<ExploreThemesScreen> createState() => _ExploreThemesScreenState();
}

class _ExploreThemesScreenState extends State<ExploreThemesScreen> {
  static const _cats = ['Daily life', 'Work', 'Travel', 'Study'];
  String _cat = 'Work';
  final Set<String> _added = Mock.plan.map((t) => t.name).toSet();

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final list = Mock.catalog.where((t) => t.category == _cat).toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Explore themes'),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final cat in _cats)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Pressable(
                        onTap: () => setState(() => _cat = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _cat == cat ? c.green : c.surfaceWarm,
                            borderRadius: BorderRadius.circular(23),
                            border: Border.all(color: _cat == cat ? c.green : c.border),
                          ),
                          child: Text(cat,
                              style: context.text.titleSmall!.copyWith(
                                  color: _cat == cat ? Colors.white : c.inkSoft)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ListView.separated(
                  key: ValueKey(_cat),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ThemeTile(
                    theme: list[i],
                    added: _added.contains(list[i].name),
                    onToggle: () {
                      final t = list[i];
                      setState(() {
                        if (!_added.remove(t.name)) _added.add(t.name);
                      });
                      toast(context, _added.contains(t.name) ? '${t.name} added to My plan' : '${t.name} removed. Progress is kept.');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.theme, required this.added, required this.onToggle});
  final SqTheme theme;
  final bool added;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final (fitBg, fitFg) = switch (theme.fit) {
      Fit.easy => (c.surfaceGreen, c.greenDeep),
      Fit.right => (c.amberSoft, const Color(0xFF9A6A0B)),
      Fit.challenging => (c.coralSoft, c.coral),
    };
    return SqCard(
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
              const SizedBox(width: 8),
              Pressable(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: added ? c.green : c.surface,
                    border: Border.all(color: added ? c.green : c.border),
                  ),
                  child: Icon(added ? Icons.check_rounded : Icons.add_rounded,
                      color: added ? Colors.white : c.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: fitBg, borderRadius: BorderRadius.circular(10)),
                child: Text(theme.fit.label,
                    style: context.text.labelMedium!.copyWith(color: fitFg, fontWeight: FontWeight.w800)),
              ),
              if (theme.progress > 0 && theme.status != ThemeStatus.complete) ...[
                const SizedBox(width: 10),
                Expanded(child: ThemeBar(value: theme.progress, height: 6)),
              ],
            ],
          ),
          if (theme.prerequisite != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: c.amber, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Tip: try ${theme.prerequisite} first.',
                      style: context.text.bodyMedium!.copyWith(color: c.inkSoft)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
