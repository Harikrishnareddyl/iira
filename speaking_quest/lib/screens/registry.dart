import 'package:flutter/material.dart';

import 'curriculum/curriculum_screen.dart';
import 'expressions/expression_detail_screen.dart';
import 'expressions/expressions_screen.dart';
import 'expressions/practise_expression_screen.dart';
import 'free_play/free_play_screen.dart';
import 'free_play/free_talk_recap_screen.dart';
import 'free_play/free_talk_screen.dart';
import 'free_play/make_scene_screen.dart';
import 'free_play/session_limit_screen.dart';
import 'home/explore_themes_screen.dart';
import 'home/home_screen.dart';
import 'home/my_plan_screen.dart';
import 'home/theme_path_screen.dart';
import 'level/boss_screen.dart';
import 'level/conversation_screen.dart';
import 'level/level_intro_screen.dart';
import 'level/listening_screen.dart';
import 'level/pronunciation_screen.dart';
import 'level/quick_reply_screen.dart';
import 'level/results_screen.dart';
import 'level/retry_screen.dart';
import 'level/sound_natural_screen.dart';
import 'level/theme_complete_screen.dart';
import 'level/think_in_english_screen.dart';
import 'onboarding/goals_screen.dart';
import 'onboarding/hello_chat_screen.dart';
import 'onboarding/placement_screen.dart';
import 'onboarding/skill_profile_screen.dart';
import 'onboarding/welcome_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/streak_coins_screen.dart';

class ScreenEntry {
  const ScreenEntry(this.title, this.note, this.icon, this.builder);
  final String title;
  final String note;
  final IconData icon;
  final WidgetBuilder builder;
}

class ScreenGroup {
  const ScreenGroup(this.title, this.blurb, this.entries);
  final String title;
  final String blurb;
  final List<ScreenEntry> entries;
}

final screenGroups = <ScreenGroup>[
  ScreenGroup('Curriculum skeleton', 'Every theme, its scenes across all level types, targets and variations.', [
    ScreenEntry('All themes & level types', 'Daily life, Work, Travel, Study · open any theme', Icons.account_tree_rounded, (_) => const CurriculumScreen()),
  ]),
  ScreenGroup('Onboarding', 'A 3–4 minute run of mini-levels that builds the skill profile.', [
    ScreenEntry('Welcome', 'First launch, companion intro', Icons.waving_hand_rounded, (_) => const WelcomeScreen()),
    ScreenEntry('Hello chat', '60 s chat about name, work and why English', Icons.chat_bubble_rounded, (_) => const HelloChatScreen()),
    ScreenEntry('Goals & daily time', 'Work, travel, study, daily life + minutes', Icons.tune_rounded, (_) => const GoalsScreen()),
    ScreenEntry('Placement run', 'One adaptive round of each level type', Icons.route_rounded, (_) => const PlacementScreen()),
    ScreenEntry('Skill profile & first plan', 'Per-skill bands and the starting themes', Icons.insights_rounded, (_) => const SkillProfileScreen()),
  ]),
  ScreenGroup('Home & plan', 'One next step. Themes live one tap away.', [
    ScreenEntry('Home', 'Theme bar, next scene, Play, Free play', Icons.home_rounded, (_) => const HomeScreen()),
    ScreenEntry('My plan', 'Switch, reorder or remove themes', Icons.list_alt_rounded, (_) => const MyPlanScreen()),
    ScreenEntry('Explore themes', 'Catalog by category with fit labels', Icons.explore_rounded, (_) => const ExploreThemesScreen()),
    ScreenEntry('Theme path', 'Ordered scenes, finale at the end', Icons.timeline_rounded, (_) => const ThemePathScreen()),
  ]),
  ScreenGroup('Levels', 'Six level types plus the boss. Every one ends in speaking.', [
    ScreenEntry('Level intro', 'Title, goal, setup, time, type tag', Icons.flag_circle_rounded, (_) => const LevelIntroScreen()),
    ScreenEntry('Conversation', 'Role-play with a hidden obstacle', Icons.forum_rounded, (_) => const ConversationScreen()),
    ScreenEntry('Listening', 'Hear a clip, answer aloud', Icons.headphones_rounded, (_) => const ListeningScreen()),
    ScreenEntry('Think in English', 'Describe a picture in connected sentences', Icons.psychology_rounded, (_) => const ThinkInEnglishScreen()),
    ScreenEntry('Quick reply', '5 rounds, soft timer', Icons.bolt_rounded, (_) => const QuickReplyScreen()),
    ScreenEntry('Pronunciation', 'Listen, repeat, compare waveforms', Icons.record_voice_over_rounded, (_) => const PronunciationScreen()),
    ScreenEntry('Sound natural', 'Fix a wrong or stiff sentence', Icons.auto_fix_high_rounded, (_) => const SoundNaturalScreen()),
    ScreenEntry('Theme finale (boss)', 'Unscripted scene with target checklist', Icons.emoji_events_rounded, (_) => const BossScreen()),
  ]),
  ScreenGroup('After a level', 'Results, soft failure and theme completion.', [
    ScreenEntry('Results', 'Stars, coins, bar fill, new expression', Icons.star_rounded, (_) => const ResultsScreen()),
    ScreenEntry('One more try', 'Close! Expressions that would help + Retry', Icons.refresh_rounded, (_) => const RetryScreen()),
    ScreenEntry('Theme complete', '+50 coins, next theme starts', Icons.celebration_rounded, (_) => const ThemeCompleteScreen()),
  ]),
  ScreenGroup('Free play', 'Practise what you know. Never moves the plan.', [
    ScreenEntry('Free play hub', 'Free talk, Make a scene, Try again, Twists', Icons.sports_esports_rounded, (_) => const FreePlayScreen()),
    ScreenEntry('Free play (empty state)', 'Before any scene is completed', Icons.inbox_rounded, (_) => const FreePlayScreen(empty: true)),
    ScreenEntry('Make your own scene', 'Type or say a real situation', Icons.edit_rounded, (_) => const MakeSceneScreen()),
    ScreenEntry('Free talk', 'Open chat with Maya, live timer', Icons.graphic_eq_rounded, (_) => const FreeTalkScreen()),
    ScreenEntry('Free talk recap', 'Went well, try next time, said naturally', Icons.summarize_rounded, (_) => const FreeTalkRecapScreen()),
    ScreenEntry('Out of free sessions', 'Use 30 coins for another session', Icons.hourglass_empty_rounded, (_) => const SessionLimitScreen()),
  ]),
  ScreenGroup('Expressions', 'Chunks unlocked by using them in scenes.', [
    ScreenEntry('Expressions', 'Grouped by theme, Practising / Mastered', Icons.menu_book_rounded, (_) => const ExpressionsScreen()),
    ScreenEntry('Expression detail', 'Meaning, you said, other ways, practise', Icons.bookmark_rounded, (_) => const ExpressionDetailScreen()),
    ScreenEntry('Practise it', 'One-minute scene in a new situation', Icons.bolt_rounded, (_) => const PractiseExpressionScreen()),
  ]),
  ScreenGroup('Profile', 'Streak, coins and settings.', [
    ScreenEntry('Profile', 'Scenes played, themes done, skills', Icons.person_rounded, (_) => const ProfileScreen()),
    ScreenEntry('Streak & coins', 'Freeze, repair, extra sessions', Icons.local_fire_department_rounded, (_) => const StreakCoinsScreen()),
    ScreenEntry('Settings', 'Theme, voice, quiet mode, reminders', Icons.settings_rounded, (_) => const SettingsScreen()),
  ]),
];
