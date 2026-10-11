import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/companion.dart';
import 'registry.dart';

/// Prototype index: every screen, grouped by flow, each opens standalone.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final total = screenGroups.fold<int>(0, (n, g) => n + g.entries.length);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
                child: Row(
                  children: [
                    const CompanionMark(size: 64, mood: CompanionMood.rest),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Speaking Quest', style: context.text.headlineMedium),
                          Text('Prototype · $total screens · mock data',
                              style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: themeMode,
                      builder: (context, mode, _) => IconButton(
                        tooltip: 'Toggle light / dark',
                        onPressed: () => themeMode.value =
                            mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                        icon: Icon(
                          mode == ThemeMode.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: c.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final g in screenGroups) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.title, style: context.text.titleLarge),
                      const SizedBox(height: 2),
                      Text(g.blurb, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: g.entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final e = g.entries[i];
                    return Pressable(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: e.builder)),
                      child: SqCard(
                        color: c.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            IconBlob(icon: e.icon, color: c.surfaceGreen, size: 42),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title, style: context.text.titleMedium),
                                  Text(e.note, style: context.text.bodySmall),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: c.inkMuted),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
