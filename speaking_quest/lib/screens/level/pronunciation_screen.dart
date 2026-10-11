import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

class _Line {
  const _Line(this.before, this.stress, this.after, this.syllables, this.mouth, this.wrongStress);
  final String before, stress, after, syllables, mouth, wrongStress;
}

const _lines = [
  _Line('Could you give me a ', 'MINUTE', '?', 'MIN · ute', 'Short "i" as in "sit". Relax the second part: "nit".', 'give'),
  _Line("I'd like to ", 'BOOK', ' a table.', 'BOOK', 'Round your lips for "oo", short and quick.', 'like'),
  _Line("It's on the ", 'THIRD', ' floor.', 'THIRD', 'Tongue lightly between your teeth for "th".', 'floor'),
];

/// Pronunciation: listen, repeat, compare waveforms. The stressed word is
/// highlighted in the example and in the learner's version.
class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  int _line = 0;
  int _attempt = 0; // 0 none, 1 off stress, 2 good
  bool _playingExample = false, _playingYou = false;
  bool _syllables = false, _mouth = false, _slow = false;
  final Map<String, int> _uses = {};

  void _play(bool example) async {
    setState(() => example ? _playingExample = true : _playingYou = true);
    await Future.delayed(Duration(milliseconds: _slow && example ? 2600 : 1600));
    if (mounted) setState(() => example ? _playingExample = false : _playingYou = false);
  }

  void _next() {
    if (_line == _lines.length - 1) {
      demoNav(context, 'Results');
      return;
    }
    setState(() {
      _line++;
      _attempt = 0;
      _syllables = _mouth = _slow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final l = _lines[_line];
    final good = _attempt == 2;
    return LevelScaffold(
      title: 'Pronunciation',
      goal: 'Listen, then repeat.',
      progress: (_line + (good ? 1 : 0)) / _lines.length,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SqCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text.rich(
                    key: ValueKey(_line),
                    TextSpan(children: [
                      TextSpan(text: l.before),
                      TextSpan(text: _syllables ? l.syllables : l.stress, style: TextStyle(color: c.green)),
                      TextSpan(text: l.after),
                    ]),
                    textAlign: TextAlign.center,
                    style: context.text.displaySmall!.copyWith(fontSize: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _WaveRow(
              label: 'Example',
              playing: _playingExample,
              onPlay: () => _play(true),
              seed: 21 + _line,
              highlight: (9, 13),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _attempt == 0 ? 0.45 : 1,
              child: _WaveRow(
                label: 'You',
                playing: _playingYou,
                onPlay: _attempt == 0 ? null : () => _play(false),
                seed: _attempt == 1 ? 40 + _line : 21 + _line,
                highlight: _attempt == 0 ? null : (_attempt == 1 ? (3, 6) : (9, 13)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (_attempt) {
                    0 => Column(
                        key: const ValueKey('tip'),
                        children: [
                          HintCard(text: "Stress '${l.stress.toLowerCase()}'."),
                          if (_mouth) ...[const SizedBox(height: 8), HintCard(text: l.mouth, icon: Icons.face_rounded)],
                        ],
                      ),
                    1 => SqCard(
                        key: const ValueKey('off'),
                        color: c.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(children: [
                                const TextSpan(text: 'You stressed '),
                                TextSpan(text: "'${l.wrongStress}'", style: TextStyle(color: c.amber, fontWeight: FontWeight.w800)),
                                const TextSpan(text: '. Clear overall. Try leaning on '),
                                TextSpan(text: "'${l.stress.toLowerCase()}'", style: TextStyle(color: c.green, fontWeight: FontWeight.w800)),
                                const TextSpan(text: '.'),
                              ]),
                              style: context.text.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    _ => SqCard(
                        key: const ValueKey('good'),
                        color: c.surfaceGreen,
                        borderColor: c.greenSoft,
                        onTap: _next,
                        child: Row(
                          children: [
                            const Mascot(size: 48, mood: MascotMood.happy, showRays: false),
                            const SizedBox(width: 10),
                            Expanded(child: Text('That sounded natural.', style: context.text.titleMedium)),
                            Text(_line == _lines.length - 1 ? 'Finish' : 'Next', style: context.text.titleSmall!.copyWith(color: c.green)),
                            Icon(Icons.chevron_right_rounded, color: c.green),
                          ],
                        ),
                      ),
                  },
                ),
              ),
            ),
            PowerUpRow(
              height: 76,
              counts: _uses,
              items: [
                const PowerUp('Slower', emoji: '🐌', weight: 0.05),
                PowerUp('Syllables', icon: Icons.graphic_eq_rounded, color: c.coral, weight: 0.1),
                const PowerUp('Mouth tip', emoji: '👄', weight: 0.1),
              ],
              onUse: (p) {
                setState(() {
                  _uses[p.label] = (_uses[p.label] ?? 0) + 1;
                  if (p.label == 'Syllables') _syllables = !_syllables;
                  if (p.label == 'Mouth tip') _mouth = true;
                  if (p.label == 'Slower') _slow = true;
                });
                if (p.label == 'Slower') _play(true);
              },
            ),
            const SizedBox(height: 8),
            MicButton(size: 88, enabled: !good, onSend: () => setState(() => _attempt = _attempt == 0 ? 1 : 2)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _WaveRow extends StatelessWidget {
  const _WaveRow({required this.label, required this.playing, required this.onPlay, required this.seed, this.highlight});
  final String label;
  final bool playing;
  final VoidCallback? onPlay;
  final int seed;
  final (int, int)? highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: context.text.titleSmall)),
          Pressable(
            onTap: onPlay,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: onPlay == null ? c.greenSoft : c.green),
              child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRect(
              child: Waveform(bars: 22, height: 36, active: playing, seed: seed, barWidth: 3.5, gap: 3, highlight: highlight),
            ),
          ),
        ],
      ),
    );
  }
}
