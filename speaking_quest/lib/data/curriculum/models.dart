// Curriculum skeleton models (Track B, step 1). Written by the team, then
// personalised by the engine. The prototype only displays them.

import '../mock_data.dart' show LevelType;

export '../mock_data.dart' show LevelType;

enum Band { a1, a2, b1, b2, c1 }

extension BandLabel on Band {
  String get label => name.toUpperCase();
}

enum TargetKind { expression, pattern, errorFix }

extension TargetKindLabel on TargetKind {
  String get label => switch (this) {
        TargetKind.expression => 'Expression',
        TargetKind.pattern => 'Pattern',
        TargetKind.errorFix => 'Common error',
      };
}

/// A target item: expression, sentence pattern or error to fix.
class TargetItem {
  const TargetItem(
    this.text, {
    required this.kind,
    required this.band,
    required this.meaning,
    required this.example,
    required this.types,
  });

  /// Expression / pattern text. For [TargetKind.errorFix] use
  /// "wrong → right", e.g. "I am agree → I agree".
  final String text;
  final TargetKind kind;
  final Band band;

  /// One simple English sentence (or the "why" line for error fixes).
  final String meaning;
  final String example;

  /// Level types that suit this item.
  final List<LevelType> types;
}

/// A scenario template for one scene in a theme.
///
/// [material] depends on [type]:
/// - conversation / boss: 2–4 lines the character might say (first is the
///   opening line).
/// - listening: [clip transcript, question asked after the clip, expected answer].
/// - thinkInEnglish: [picture description, prompt chip 1, chip 2, chip 3,
///   example sentence].
/// - quickReply: exactly 5 short questions.
/// - pronunciation: 3–5 lines; wrap the stressed word in CAPS
///   ("Could you give me a MINUTE?").
/// - soundNatural: 3–5 items as "wrong or stiff sentence → natural version".
class SceneTemplate {
  const SceneTemplate({
    required this.title,
    required this.type,
    required this.goal,
    required this.setting,
    required this.character,
    required this.obstacle,
    required this.targets,
    required this.rubric,
    required this.material,
    required this.twists,
    this.band = Band.b1,
  });

  final String title;
  final LevelType type;

  /// The single goal shown in the goal pill ("Get your order remade.").
  final String goal;
  final String setting;

  /// AI character: "Maya, barista" (or "Narrator" for non-conversation types).
  final String character;

  /// Hidden need or obstacle the learner must work around.
  final String obstacle;

  /// Target item texts from the theme taught here (1–3).
  final List<String> targets;

  /// Success rubric the AI judge uses.
  final String rubric;
  final List<String> material;

  /// New-twist variations: same skills, new situation (used for Free play and
  /// re-queued variants).
  final List<String> twists;
  final Band band;
}

class CurriculumTheme {
  const CurriculumTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.band,
    required this.blurb,
    required this.whoFor,
    required this.targets,
    required this.scenes,
    required this.finale,
    this.prerequisites = const [],
  });

  final String id;
  final String name;
  final String emoji;

  /// Daily life, Work, Travel or Study.
  final String category;

  /// Base difficulty band, e.g. "A2–B1".
  final String band;
  final String blurb;

  /// Who needs this theme (people and situations).
  final String whoFor;

  /// Suggested, never enforced (theme names).
  final List<String> prerequisites;
  final List<TargetItem> targets;

  /// Ordered scenes (10–14), covering every non-boss level type.
  final List<SceneTemplate> scenes;

  /// The theme finale (type boss).
  final SceneTemplate finale;
}
