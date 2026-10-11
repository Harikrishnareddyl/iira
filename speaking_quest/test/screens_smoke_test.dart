import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_quest/data/curriculum/curriculum.dart';
import 'package:speaking_quest/screens/catalog_screen.dart';
import 'package:speaking_quest/screens/curriculum/curriculum_scene_screen.dart';
import 'package:speaking_quest/screens/curriculum/curriculum_theme_screen.dart';
import 'package:speaking_quest/screens/registry.dart';
import 'package:speaking_quest/theme/app_theme.dart';

Future<void> _loadFonts() async {
  for (final fam in ['Nunito', 'NunitoSans']) {
    final loader = FontLoader(fam);
    for (final f in Directory('assets/fonts').listSync().whereType<File>()) {
      final name = f.uri.pathSegments.last;
      if (name.startsWith('$fam-')) {
        loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
      }
    }
    await loader.load();
  }
}

Widget _wrap(Widget child, ThemeMode mode) => MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: child,
    );

Future<void> _pumpScreen(WidgetTester tester, Widget w, ThemeMode mode) async {
  // Collect framework errors (overflows, assertions) ourselves so the report
  // stays readable, then fail with the list.
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').first);
  addTearDown(() => FlutterError.onError = previous);
  await tester.pumpWidget(_wrap(w, mode));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
  // Tear down so periodic timers are cancelled.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
  FlutterError.onError = previous;
  expect(errors, isEmpty);
}

void main() {
  setUpAll(_loadFonts);

  for (final (size, mode) in const [(Size(390, 844), ThemeMode.light), (Size(360, 740), ThemeMode.dark)]) {
    {
      final tag = '${size.width.toInt()}x${size.height.toInt()} ${mode.name}';
      testWidgets('catalog renders ($tag)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _pumpScreen(tester, const CatalogScreen(), mode);
      });
      for (final g in screenGroups) {
        for (final e in g.entries) {
          testWidgets('${g.title} / ${e.title} renders ($tag)', (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await _pumpScreen(tester, Builder(builder: e.builder), mode);
          });
        }
      }
    }
  }

  testWidgets('every curriculum theme and scene renders', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final t in curriculum) {
      await tester.pumpWidget(_wrap(CurriculumThemeScreen(theme: t), ThemeMode.light));
      await tester.pump(const Duration(milliseconds: 300));
      for (final s in [...t.scenes, t.finale]) {
        await tester.pumpWidget(_wrap(CurriculumSceneScreen(theme: t, scene: s), ThemeMode.light));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  });
}
