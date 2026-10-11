import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

class _Round {
  const _Round(this.type, this.prompt, this.detail, this.answer, this.strong);
  final LevelType type;
  final String prompt;
  final String detail;
  final String answer;
  final bool strong; // mock judgement → difficulty goes up or down
}

const _rounds = [
  _Round(LevelType.listening, 'Where is the train going?', '"The 9:40 to Manchester is now leaving from platform 6."', 'To Manchester, from platform 6.', true),
  _Round(LevelType.quickReply, 'What did you do last weekend?', 'Answer in a few seconds. 3 questions.', 'I visited my parents and cooked a lot.', true),
  _Round(LevelType.thinkInEnglish, 'Describe the picture.', 'Two or three sentences.', 'She is cooking breakfast. The sun is coming in. Next she will make tea.', false),
  _Round(LevelType.pronunciation, 'Could you give me a MINUTE?', 'Repeat the line.', 'Could you give me a minute?', true),
  _Round(LevelType.soundNatural, 'I am agree with you.', 'Say a natural version.', 'I agree with you.', true),
];

const _bands = ['A1', 'A2', 'B1', 'B2', 'C1'];

/// Onboarding steps 3–7: one adaptive round of each level type. A strong
/// answer makes the next round harder, a weak one makes it easier.
class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  int _i = 0;
  int _band = 2; // starts at B1
  String? _caption;
  bool? _lastStrong;

  void _send() {
    final r = _rounds[_i];
    setState(() => _caption = r.answer);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _lastStrong = r.strong;
        _band = (_band + (r.strong ? 1 : -1)).clamp(0, 4);
        _i++;
        _caption = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final done = _i >= _rounds.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            children: [
              ThemeBar(value: (2 + _i) / 7, height: 8, duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 14),
              // Round chips.
              Row(
                children: [
                  for (var k = 0; k < _rounds.length; k++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 44,
                        decoration: BoxDecoration(
                          color: k < _i ? c.green : (k == _i ? c.surfaceGreen : c.surfaceMuted),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: k == _i ? c.green : c.border),
                        ),
                        child: Icon(_rounds[k].type.icon, size: 22, color: k < _i ? Colors.white : (k == _i ? c.green : c.inkMuted)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _DifficultyMeter(band: _band, lastStrong: _lastStrong),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: done ? _finished(context) : _round(context, _rounds[_i]),
                ),
              ),
              if (done)
                PrimaryButton(label: 'See my profile', trailingIcon: Icons.chevron_right_rounded, onTap: () => demoNav(context, 'Skill profile'))
              else
                MicButton(size: 92, enabled: _caption == null, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }

  Widget _round(BuildContext context, _Round r) {
    final c = context.sq;
    return SingleChildScrollView(
      key: ValueKey(_i),
      child: Column(
        children: [
          LevelTag(r.type.label),
          const SizedBox(height: 10),
          if (r.type == LevelType.thinkInEnglish) ...[const KitchenScene(height: 150), const SizedBox(height: 12)],
          if (r.type == LevelType.listening) ...[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CharacterAvatar(spec: CharacterSpec.daniel, size: 64),
              const SizedBox(width: 12),
              Waveform(bars: 16, height: 40, active: _caption == null, seed: 31),
            ]),
            const SizedBox(height: 12),
          ],
          Text(
            r.prompt,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(r.type == LevelType.listening ? 'Answer aloud.' : r.detail,
              textAlign: TextAlign.center, style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
          const SizedBox(height: 16),
          if (_caption != null)
            ChatBubble(text: '', fromLearner: true, child: LiveCaption(text: _caption!, style: context.text.titleMedium)),
        ],
      ),
    );
  }

  Widget _finished(BuildContext context) {
    final c = context.sq;
    return Column(
      key: const ValueKey('done'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Mascot(size: 140, mood: MascotMood.happy),
        Text('That\'s everything', style: context.text.displaySmall),
        const SizedBox(height: 6),
        Text('Building your profile and first plan.', style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
      ],
    );
  }
}

class _DifficultyMeter extends StatelessWidget {
  const _DifficultyMeter({required this.band, required this.lastStrong});
  final int band;
  final bool? lastStrong;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _bands.length; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= band ? c.greenSoft : c.surfaceMuted,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            lastStrong == null ? 'Rounds adapt to you as you go.' : (lastStrong! ? 'Strong answer. Next one is a bit harder.' : 'Next one is a bit lighter.'),
            key: ValueKey('$lastStrong$band'),
            style: context.text.bodySmall,
          ),
        ),
      ],
    );
  }
}
