// Mock data for the UI prototype. Everything here is placeholder content that
// will later come from the content engine (curriculum skeleton, scheduler,
// scoring). Keep shapes close to the spec's data model so wiring is simple.

import 'package:flutter/material.dart';

enum LevelType {
  conversation('Conversation', Icons.forum_rounded, 'Communicating in a situation'),
  listening('Listening', Icons.headphones_rounded, 'Understanding real speech'),
  thinkInEnglish('Think in English', Icons.psychology_rounded, 'Building sentences without translating'),
  quickReply('Quick reply', Icons.bolt_rounded, 'Answering fast, no time to translate'),
  pronunciation('Pronunciation', Icons.record_voice_over_rounded, 'Stress, rhythm, clarity'),
  soundNatural('Sound natural', Icons.auto_fix_high_rounded, 'Correct, natural phrasing'),
  boss('Theme finale', Icons.flag_rounded, 'Retention across a theme');

  const LevelType(this.label, this.icon, this.trains);
  final String label;
  final IconData icon;
  final String trains;
}

enum ThemeStatus { notStarted, inProgress, complete }

extension ThemeStatusLabel on ThemeStatus {
  String get label => switch (this) {
        ThemeStatus.notStarted => 'Not started',
        ThemeStatus.inProgress => 'In progress',
        ThemeStatus.complete => 'Complete',
      };
}

enum Fit { easy, right, challenging }

extension FitLabel on Fit {
  String get label => switch (this) {
        Fit.easy => 'Easy for you',
        Fit.right => 'Right for you',
        Fit.challenging => 'Challenging',
      };
}

class SqTheme {
  const SqTheme({
    required this.name,
    required this.emoji,
    required this.category,
    required this.progress,
    required this.status,
    required this.fit,
    this.blurb = '',
    this.prerequisite,
  });
  final String name;
  final String emoji;
  final String category;
  final double progress; // mastery-based, never shown as a number
  final ThemeStatus status;
  final Fit fit;
  final String blurb;
  final String? prerequisite;
}

class Scene {
  const Scene({
    required this.title,
    required this.goal,
    required this.type,
    this.stars = 0,
    this.done = false,
    this.setup = '',
    this.minutes = 3,
  });
  final String title;
  final String goal;
  final LevelType type;
  final int stars;
  final bool done;
  final String setup;
  final int minutes;
}

class Expression {
  const Expression({
    required this.text,
    required this.meaning,
    required this.youSaid,
    required this.scene,
    required this.theme,
    required this.examples,
    this.mastered = false,
  });
  final String text;
  final String meaning;
  final String youSaid;
  final String scene;
  final String theme;
  final List<(String context, String line)> examples;
  final bool mastered;
}

class Learner {
  static const name = 'Alex';
  static const job = 'Product designer';
  static const coins = 240;
  static const streak = 6;
  static const streakFreezes = 1;
  static const freeSessionsLeft = 2;
  static const freeSessionsPerDay = 3;
  static const scenesPlayed = 27;
  static const themesCompleted = 1;
  static const expressionsUnlocked = 18;
}

class Mock {
  static const currentTheme = SqTheme(
    name: 'Café & food',
    emoji: '☕',
    category: 'Daily life',
    progress: 0.42,
    status: ThemeStatus.inProgress,
    fit: Fit.right,
    blurb: 'Order, fix mix-ups and chat with staff.',
  );

  static const nextScene = Scene(
    title: 'Coffee mix-up',
    goal: 'Get your order remade.',
    type: LevelType.conversation,
    setup: 'Your drink came with regular milk. You asked for oat milk.',
    minutes: 3,
  );

  static const plan = <SqTheme>[
    currentTheme,
    SqTheme(
      name: 'Work small talk',
      emoji: '💼',
      category: 'Work',
      progress: 0.18,
      status: ThemeStatus.inProgress,
      fit: Fit.right,
      blurb: 'Chat before meetings, weekends, plans.',
    ),
    SqTheme(
      name: 'Asking for help',
      emoji: '🙋',
      category: 'Daily life',
      progress: 1,
      status: ThemeStatus.complete,
      fit: Fit.easy,
      blurb: 'Ask clearly and politely.',
    ),
    SqTheme(
      name: 'Making plans',
      emoji: '📅',
      category: 'Daily life',
      progress: 0,
      status: ThemeStatus.notStarted,
      fit: Fit.right,
      blurb: 'Suggest, accept, move and cancel plans.',
    ),
  ];

  static const catalog = <SqTheme>[
    ...plan,
    SqTheme(name: 'At the doctor', emoji: '🩺', category: 'Daily life', progress: 0, status: ThemeStatus.notStarted, fit: Fit.challenging, blurb: 'Describe symptoms, book visits.'),
    SqTheme(name: 'Shopping & returns', emoji: '🛍️', category: 'Daily life', progress: 0, status: ThemeStatus.notStarted, fit: Fit.easy, blurb: 'Ask, compare, return items.'),
    SqTheme(name: 'Meetings', emoji: '🗣️', category: 'Work', progress: 0, status: ThemeStatus.notStarted, fit: Fit.right, blurb: 'Give updates, agree, disagree.'),
    SqTheme(name: 'Making requests', emoji: '🤝', category: 'Work', progress: 0, status: ThemeStatus.notStarted, fit: Fit.right, blurb: 'Ask for time, help and changes.'),
    SqTheme(name: 'Negotiating', emoji: '⚖️', category: 'Work', progress: 0, status: ThemeStatus.notStarted, fit: Fit.challenging, blurb: 'Push back politely and find a deal.', prerequisite: 'Making requests'),
    SqTheme(name: 'Job interviews', emoji: '🎯', category: 'Work', progress: 0, status: ThemeStatus.notStarted, fit: Fit.challenging, blurb: 'Talk about yourself with confidence.'),
    SqTheme(name: 'At the airport', emoji: '✈️', category: 'Travel', progress: 0, status: ThemeStatus.notStarted, fit: Fit.easy, blurb: 'Check in, gates, delays.'),
    SqTheme(name: 'Hotel check-in', emoji: '🏨', category: 'Travel', progress: 0, status: ThemeStatus.notStarted, fit: Fit.easy, blurb: 'Rooms, problems, requests.'),
    SqTheme(name: 'Asking directions', emoji: '🧭', category: 'Travel', progress: 0, status: ThemeStatus.notStarted, fit: Fit.right, blurb: 'Find your way and confirm it.'),
    SqTheme(name: 'Seminars', emoji: '🎓', category: 'Study', progress: 0, status: ThemeStatus.notStarted, fit: Fit.challenging, blurb: 'Share opinions, ask questions.'),
    SqTheme(name: 'Group projects', emoji: '🧩', category: 'Study', progress: 0, status: ThemeStatus.notStarted, fit: Fit.right, blurb: 'Split work, check progress.'),
  ];

  /// The theme path. Done scenes, the current one, then locked ones (titles
  /// hidden). Reviews look like any other scene.
  static const themePath = <Scene>[
    Scene(title: 'First order', goal: 'Order a drink and a snack.', type: LevelType.conversation, stars: 3, done: true),
    Scene(title: 'Menu words', goal: 'Say what you want naturally.', type: LevelType.soundNatural, stars: 2, done: true),
    Scene(title: 'Busy counter', goal: 'Catch your order number.', type: LevelType.listening, stars: 3, done: true),
    Scene(title: 'Quick choices', goal: 'Answer the barista fast.', type: LevelType.quickReply, stars: 2, done: true),
    Scene(title: 'Table for two', goal: 'Get a table by the window.', type: LevelType.conversation, stars: 1, done: true),
    nextScene,
    Scene(title: '???', goal: '', type: LevelType.thinkInEnglish),
    Scene(title: '???', goal: '', type: LevelType.pronunciation),
    Scene(title: '???', goal: '', type: LevelType.conversation),
    Scene(title: 'Café finale', goal: 'Host a friend for brunch.', type: LevelType.boss),
  ];

  static List<Scene> get completedScenes =>
      themePath.where((s) => s.done).toList();

  static const twists = <(String, String, String)>[
    ('Too much sugar', 'Coffee mix-up', 'Ask for a new drink without sugar.'),
    ('Wrong table', 'Table for two', 'Move to the table you booked.'),
    ('Cold soup', 'First order', 'Politely send your soup back.'),
  ];

  static const sampleScenePrompts = [
    "Doctor's appointment tomorrow",
    'Asking my landlord to fix the heater',
    'Small talk with a new teammate',
    'Returning shoes that don\'t fit',
  ];

  static const expressions = <Expression>[
    Expression(
      text: 'Could you remake it?',
      meaning: 'A polite way to ask someone to make something again.',
      youSaid: 'I asked for oat milk. Could you remake it?',
      scene: 'Coffee mix-up',
      theme: 'Café & food',
      examples: [
        ('At work', 'The slide has a typo. Could you remake it before the call?'),
        ('With friends', "This playlist is too sad. Could you remake it?"),
        ('In a shop', 'The key doesn\'t open the door. Could you remake it?'),
      ],
    ),
    Expression(
      text: 'run late',
      meaning: 'To be later than planned.',
      youSaid: "Sorry, I'm running late. I'll be there in ten minutes.",
      scene: 'Morning stand-up',
      theme: 'Work small talk',
      examples: [
        ('At work', 'The meeting is running late, so let\'s start at 3.'),
        ('With friends', "I'm running late, order without me!"),
      ],
      mastered: true,
    ),
    Expression(
      text: "I'll have the…",
      meaning: 'A natural way to order food or drinks.',
      youSaid: "I'll have the oat latte, please.",
      scene: 'First order',
      theme: 'Café & food',
      examples: [
        ('Restaurant', "I'll have the soup of the day."),
        ('Bar', "I'll have the same, thanks."),
      ],
      mastered: true,
    ),
    Expression(
      text: 'Is this seat taken?',
      meaning: 'Asking if you can sit somewhere.',
      youSaid: 'Excuse me, is this seat taken?',
      scene: 'Table for two',
      theme: 'Café & food',
      examples: [
        ('On a train', 'Sorry, is this seat taken?'),
        ('At a talk', 'Is this seat taken, or can I sit here?'),
      ],
    ),
    Expression(
      text: 'make a decision',
      meaning: 'To choose after thinking.',
      youSaid: 'We need to make a decision by Friday.',
      scene: 'Lunch plans',
      theme: 'Work small talk',
      examples: [
        ('At work', "Let's make a decision after the demo."),
        ('Shopping', "I can't make a decision, they're both nice."),
      ],
    ),
    Expression(
      text: 'Could you give me a minute?',
      meaning: 'Asking someone to wait a short time.',
      youSaid: 'Could you give me a minute? I\'m still reading the menu.',
      scene: 'Menu words',
      theme: 'Café & food',
      examples: [
        ('At work', 'Could you give me a minute? I\'ll join the call.'),
        ('On the phone', 'Could you give me a minute to find the number?'),
      ],
      mastered: true,
    ),
    Expression(
      text: 'How was your weekend?',
      meaning: 'A friendly question to start small talk.',
      youSaid: 'Hi Sam! How was your weekend?',
      scene: 'Monday coffee',
      theme: 'Work small talk',
      examples: [
        ('With neighbours', 'Morning! How was your weekend?'),
      ],
    ),
  ];

  static const skillProfile = <(String, String, double, String)>[
    ('Speaking range', 'B1', 0.55, 'Good variety of everyday words'),
    ('Listening', 'B2', 0.72, 'Prefers normal speed'),
    ('Response speed', '2.8 s', 0.40, 'Your baseline to beat'),
    ('Accuracy', '64', 0.64, 'Recurring: "am + verb", articles'),
    ('Pronunciation', '71', 0.71, 'Watch: th, word stress'),
  ];
}
