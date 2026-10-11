import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_quest/data/curriculum/curriculum.dart';

void main() {
  test('every category has themes and names are unique', () {
    for (final cat in curriculumCategories) {
      expect(curriculum.where((t) => t.category == cat), isNotEmpty, reason: cat);
    }
    final names = curriculum.map((t) => t.name).toList();
    expect(names.toSet().length, names.length);
    final ids = curriculum.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  for (final theme in curriculum) {
    test('theme ${theme.name} is well formed', () {
      expect(theme.scenes.length, inInclusiveRange(10, 14));
      expect(theme.finale.type, LevelType.boss);
      final types = theme.scenes.map((s) => s.type).toSet();
      for (final t in LevelType.values.where((t) => t != LevelType.boss)) {
        expect(types, contains(t), reason: '${theme.name} misses ${t.label}');
      }
      expect(theme.scenes.any((s) => s.type == LevelType.boss), isFalse);
      final targetTexts = theme.targets.map((t) => t.text).toSet();
      for (final kind in TargetKind.values) {
        expect(theme.targets.any((t) => t.kind == kind), isTrue, reason: '${theme.name} has no ${kind.label}');
      }
      for (final s in [...theme.scenes, theme.finale]) {
        expect(s.goal.trim(), isNotEmpty);
        expect(s.twists, isNotEmpty, reason: s.title);
        for (final t in s.targets) {
          expect(targetTexts, contains(t), reason: '${theme.name} / ${s.title} target "$t"');
        }
        if (s.type == LevelType.quickReply) expect(s.material.length, 5, reason: s.title);
        if (s.type == LevelType.listening) expect(s.material.length, 3, reason: s.title);
        if (s.type == LevelType.thinkInEnglish) expect(s.material.length, 5, reason: s.title);
      }
      for (final p in theme.prerequisites) {
        expect(themeByName(p), isNotNull, reason: '${theme.name} prerequisite "$p"');
      }
    });
  }
}
