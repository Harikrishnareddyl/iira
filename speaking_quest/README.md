# Speaking Quest — UI prototype (Track A)

A Flutter prototype of **Speaking Quest**, a speaking-first English app built like a hyper-casual game. Every screen is standalone and uses mock data, so each one can later be wired to the real engine (Track B) on its own.

- Product spec: [`docs/SPEC.md`](docs/SPEC.md)
- Visual references: [`docs/references/`](docs/references)

## Run it

```bash
cd speaking_quest
flutter pub get
flutter run                 # device / simulator
flutter run -d chrome       # web
```

On web you can open a screen directly: `/?screen=Conversation`, `/?screen=Free%20talk&theme=dark`. Titles match the catalog entries.

## What's inside

The home page is a **catalog of every screen**, grouped by flow. Tap one to open it on its own. Screens are interactive with mock data: hold the mic to "speak" (a scripted transcript appears as a live caption), use power-ups, finish rounds and so on. Buttons that would move to another screen show a short note naming the screen they would open. The moon icon on the catalog switches light and dark.

| Group | Screens |
| --- | --- |
| Curriculum skeleton | All themes & level types → theme (scenes, targets, type mix) → scene template |
| Onboarding | Welcome, Hello chat, Goals & daily time, Placement run (adaptive), Skill profile & first plan |
| Home & plan | Home, My plan (switch / reorder / remove), Explore themes (fit labels, prerequisite tips), Theme path |
| Levels | Level intro (Plan / Finale / Free play / Practice tags), Conversation, Listening, Think in English, Quick reply, Pronunciation, Sound natural, Theme finale |
| After a level | Results, One more try (soft failure), Theme complete |
| Free play | Hub, Empty state, Make your own scene, Free talk, Free talk recap, Out of free sessions |
| Expressions | List (Practising / Mastered), Detail, Practise it |
| Profile | Profile, Streak & coins (freeze, repair, extra sessions), Settings |

Shared pieces live in `lib/widgets/`: the companion voice mark (breathes at rest, bars dance when pleased, dims on a miss), the hold-to-speak mic with rings and waveforms, power-up tiles (unlimited, counted), goal pill, plain theme bar (no numbers), stars, coins and code-drawn characters.

## Curriculum skeleton

`lib/data/curriculum/` holds the first draft of the content skeleton (Track B step 1) as typed Dart data (`models.dart`):

- **41 themes** across Daily life (14), Work (12), Travel (8) and Study (7), each with a band, who it serves, and suggested prerequisites.
- **12 ordered scenes + a theme finale per theme** (533 scenes). Every theme covers all six level types. Each scene has a goal, setting, character, hidden obstacle, target items, success rubric, type-specific material (lines, clips, questions, sentences to fix…) and 2–3 *new twist* variations.
- **~15 target items per theme** (614 in total): expressions, sentence patterns and common errors, each with band, meaning, example and suitable level types.

`test/curriculum_test.dart` checks the skeleton's integrity: type coverage, target references, material shape and prerequisites.

## Structure

```
lib/
  main.dart                 app + web deep links
  theme/app_theme.dart      forest-and-stone palette, light/dark, type scale
  data/mock_data.dart       learner, plan, expressions (mock)
  data/curriculum/          curriculum skeleton
  widgets/                  companion, voice (mic, waveform, captions), avatar, level, common
  screens/                  one folder per flow + registry.dart (catalog list)
test/                       curriculum integrity + render smoke test for every screen
```

## Next steps

Replace the mock data and scripted transcripts with the engine, speech recognition and the AI judge, one screen at a time, then connect the flows.
