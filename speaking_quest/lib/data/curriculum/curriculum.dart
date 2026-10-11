// The full curriculum skeleton: every theme across Daily life, Work, Travel
// and Study, plus reference info for each level type from the spec.

import 'daily_life_a.dart';
import 'daily_life_b.dart';
import 'models.dart';
import 'study.dart';
import 'travel.dart';
import 'work_a.dart';
import 'work_b.dart';

export 'models.dart';

const curriculumCategories = ['Daily life', 'Work', 'Travel', 'Study'];

const List<CurriculumTheme> curriculum = [
  ...dailyLifeThemesA,
  ...dailyLifeThemesB,
  ...workThemesA,
  ...workThemesB,
  ...travelThemes,
  ...studyThemes,
];

CurriculumTheme? themeByName(String name) {
  for (final t in curriculum) {
    if (t.name == name) return t;
  }
  return null;
}

class PowerUpInfo {
  const PowerUpInfo(this.name, this.weight, this.what);
  final String name;
  final double weight; // help weight used in scoring
  final String what;
}

class LevelTypeInfo {
  const LevelTypeInfo({
    required this.type,
    required this.what,
    required this.win,
    required this.rounds,
    required this.powerUps,
  });
  final LevelType type;
  final String what;
  final String win;
  final String rounds;
  final List<PowerUpInfo> powerUps;
}

const levelTypeInfo = <LevelType, LevelTypeInfo>{
  LevelType.conversation: LevelTypeInfo(
    type: LevelType.conversation,
    what: 'Role-play with an AI character who has a hidden need or obstacle.',
    win: 'The AI judges the goal reached (e.g. order remade).',
    rounds: '1 scene, 4–8 turns',
    powerUps: [
      PowerUpInfo('Hint', 0.15, 'First words of a good reply'),
      PowerUpInfo('Slower', 0.05, 'Character speaks slower'),
      PowerUpInfo('Simplify', 0.15, 'Simpler version of the line'),
      PowerUpInfo('Translate', 0.3, 'Line in your language'),
    ],
  ),
  LevelType.listening: LevelTypeInfo(
    type: LevelType.listening,
    what: 'Hear a clip, then answer or ask a follow-up aloud.',
    win: 'Correct spoken answer, or a relevant clarifying question.',
    rounds: '1–3 clips',
    powerUps: [
      PowerUpInfo('Replay', 0.05, 'Hear the clip again'),
      PowerUpInfo('0.75× speed', 0.05, 'Slower playback'),
      PowerUpInfo('Show key word', 0.15, 'Highlights the word that matters'),
      PowerUpInfo('Transcript', 0.3, 'Full text of the clip'),
    ],
  ),
  LevelType.thinkInEnglish: LevelTypeInfo(
    type: LevelType.thinkInEnglish,
    what: 'Describe a picture or scene with prompt chips (Who? Doing what? What next?).',
    win: 'A set number of connected sentences without long pauses.',
    rounds: '1–2 scenes',
    powerUps: [
      PowerUpInfo('Prompt chip', 0.05, 'A question to keep you going'),
      PowerUpInfo('Starter words', 0.1, 'A few useful words'),
      PowerUpInfo('Example sentence', 0.15, 'One model sentence'),
    ],
  ),
  LevelType.quickReply: LevelTypeInfo(
    type: LevelType.quickReply,
    what: 'Short questions with a soft 3–5 s timer. A short answer is enough.',
    win: 'A relevant answer in time on most rounds (e.g. 4 of 5).',
    rounds: '5',
    powerUps: [
      PowerUpInfo('Extra time (+3 s)', 0.1, 'More time this round'),
      PowerUpInfo('Starter words', 0.15, 'How to begin'),
      PowerUpInfo('Skip', 0.1, 'Move to the next question'),
    ],
  ),
  LevelType.pronunciation: LevelTypeInfo(
    type: LevelType.pronunciation,
    what: 'Listen to a native line, repeat, compare waveforms.',
    win: 'Intelligible with the target stress.',
    rounds: '3–5 lines',
    powerUps: [
      PowerUpInfo('Slow example', 0.05, 'Hear it slower'),
      PowerUpInfo('Syllable breakdown', 0.1, 'Word split into beats'),
      PowerUpInfo('Mouth tip', 0.1, 'How to shape the sound'),
    ],
  ),
  LevelType.soundNatural: LevelTypeInfo(
    type: LevelType.soundNatural,
    what: 'Fix a wrong or stiff sentence. Wrong → why + fix; stiff → accept + bonus; valid variation → praise.',
    win: 'A correct, natural version.',
    rounds: '3–5 sentences',
    powerUps: [
      PowerUpInfo('Highlight the error', 0.1, 'Marks what to fix'),
      PowerUpInfo('Explain simply', 0.15, 'One-line why'),
      PowerUpInfo('Show answer', 0.3, 'A natural version'),
    ],
  ),
  LevelType.boss: LevelTypeInfo(
    type: LevelType.boss,
    what: "Unscripted conversation using the theme's targets plus shaky items.",
    win: 'Goal reached and most target items used.',
    rounds: '1 scene',
    powerUps: [
      PowerUpInfo('Hint', 0.15, 'First words of a good reply'),
      PowerUpInfo('Slower', 0.05, 'Character speaks slower'),
      PowerUpInfo('Simplify', 0.15, 'Simpler version of the line'),
      PowerUpInfo('Translate', 0.3, 'Line in your language'),
    ],
  ),
};
