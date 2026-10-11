import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

const _moods = [
  (MascotMood.idle, 'Idle', 'Breathes and blinks. Home, pause, waiting.'),
  (MascotMood.wave, 'Wave', 'Hello and goodbye. Welcome, home, Free play.'),
  (MascotMood.talking, 'Talking', 'Speaks in Free talk, tips and nudges.'),
  (MascotMood.listening, 'Listening', 'Hand to ear while the learner speaks.'),
  (MascotMood.thinking, 'Thinking', 'Building a scene, saving a tip.'),
  (MascotMood.happy, 'Happy', 'Goal reached, a good answer.'),
  (MascotMood.cheer, 'Cheer', 'Results, recap, theme complete.'),
  (MascotMood.sad, 'Missed', 'Goal not reached. Dimmed, never mocking.'),
];

/// Character sheet for Echo: every mood and where it's used.
class MascotScreen extends StatefulWidget {
  const MascotScreen({super.key});

  @override
  State<MascotScreen> createState() => _MascotScreenState();
}

class _MascotScreenState extends State<MascotScreen> {
  MascotMood _big = MascotMood.wave;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Meet $mascotName'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Center(child: Mascot(size: 200, mood: _big)),
                  Text(
                    'A speech bubble with sound-bar hair. The guide everywhere and the Free talk partner. '
                    'Scene characters (barista, manager…) stay separate so role-play feels real.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium!.copyWith(color: c.inkMuted),
                  ),
                  const SizedBox(height: 16),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 214,
                    ),
                    children: [
                      for (final (mood, name, use) in _moods)
                        Pressable(
                          onTap: () => setState(() => _big = mood),
                          child: SqCard(
                            color: _big == mood ? c.surfaceGreen : null,
                            borderColor: _big == mood ? c.greenSoft : null,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Mascot(size: 96, mood: mood, showRays: false),
                                Text(name, style: context.text.titleMedium),
                                const SizedBox(height: 2),
                                Text(use, textAlign: TextAlign.center, style: context.text.bodySmall),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const MascotTip(text: 'Tips and nudges look like this.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
