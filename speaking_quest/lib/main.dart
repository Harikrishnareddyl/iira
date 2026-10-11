import 'package:flutter/material.dart';

import 'screens/catalog_screen.dart';
import 'screens/registry.dart';
import 'theme/app_theme.dart';

void main() {
  // Web deep links for previews: ?screen=<title>&theme=dark
  final q = Uri.base.queryParameters;
  if (q['theme'] == 'dark') themeMode.value = ThemeMode.dark;
  runApp(SpeakingQuestApp(initialScreen: q['screen']));
}

class SpeakingQuestApp extends StatelessWidget {
  const SpeakingQuestApp({super.key, this.initialScreen});

  /// Title of a registry screen to open on top of the catalog.
  final String? initialScreen;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Speaking Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        // Keep a phone-width column on wide screens (web/desktop preview).
        builder: (context, child) => ColoredBox(
          color: Theme.of(context).extension<SqColors>()!.surfaceMuted,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        ),
        home: const CatalogScreen(),
        onGenerateInitialRoutes: (_) {
          final entry = _find(initialScreen);
          return [
            MaterialPageRoute(builder: (_) => const CatalogScreen()),
            if (entry != null) MaterialPageRoute(builder: entry.builder),
          ];
        },
      ),
    );
  }
}

ScreenEntry? _find(String? title) {
  if (title == null) return null;
  for (final g in screenGroups) {
    for (final e in g.entries) {
      if (e.title.toLowerCase() == title.toLowerCase()) return e;
    }
  }
  return null;
}
