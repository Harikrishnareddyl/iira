import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

const _sentences = [
  'She is making an omelette in her kitchen.',
  'It looks like breakfast, because the sun is coming in.',
  'Next, she is going to make some tea with the kettle.',
];

const _chips = {
  'Who?': 'A woman in a green jumper…',
  'Doing what?': 'She is cooking… / She is frying…',
  'What next?': 'After that, she is going to…',
};

/// Think in English: describe a picture in connected sentences, with prompt
/// chips, a sentence counter and a "Keep going in English" nudge.
class ThinkInEnglishScreen extends StatefulWidget {
  const ThinkInEnglishScreen({super.key});

  @override
  State<ThinkInEnglishScreen> createState() => _ThinkInEnglishScreenState();
}

class _ThinkInEnglishScreenState extends State<ThinkInEnglishScreen> {
  int _said = 0;
  String? _chip;
  bool _starter = false, _example = false, _nudge = false;
  final Map<String, int> _uses = {};
  Timer? _idle;

  @override
  void initState() {
    super.initState();
    _armNudge();
  }

  void _armNudge() {
    _idle?.cancel();
    _idle = Timer(const Duration(seconds: 6), () {
      if (mounted && _said < 3) setState(() => _nudge = true);
    });
  }

  @override
  void dispose() {
    _idle?.cancel();
    super.dispose();
  }

  void _send() {
    setState(() {
      _said++;
      _nudge = false;
      _chip = null;
    });
    _armNudge();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final done = _said >= 3;
    return LevelScaffold(
      title: 'Think in English',
      goal: 'Say 3 connected sentences.',
      progress: _said / 3,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const KitchenScene(height: 170),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final k in _chips.keys) ...[
                  Expanded(
                    child: Pressable(
                      onTap: () => setState(() {
                        _chip = k;
                        _uses['Prompt chip'] = (_uses['Prompt chip'] ?? 0) + 1;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _chip == k ? c.amberSoft : c.surfaceWarm,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _chip == k ? c.amber : c.border),
                        ),
                        child: Text(k, style: context.text.titleSmall),
                      ),
                    ),
                  ),
                  if (k != _chips.keys.last) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // Sentence counter.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i < _said ? 22 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: i < _said ? c.green : c.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < _said && i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: c.surfaceGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: i == _said - 1
                              ? LiveCaption(text: _sentences[i], style: context.text.titleMedium)
                              : Text(_sentences[i], style: context.text.titleMedium),
                        ),
                      ),
                    if (_said == 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: c.surfaceGreen, borderRadius: BorderRadius.circular(16)),
                        child: Text('She is making…', style: context.text.headlineSmall),
                      ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: done
                          ? SqCard(
                              key: const ValueKey('done'),
                              color: c.surfaceGreen,
                              borderColor: c.greenSoft,
                              onTap: () => demoNav(context, 'Results'),
                              child: Row(
                                children: [
                                  const CompanionMark(size: 48, mood: CompanionMood.pleased, showRays: false),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text('Three connected sentences. That flowed well.', style: context.text.titleMedium)),
                                  Icon(Icons.chevron_right_rounded, color: c.green),
                                ],
                              ),
                            )
                          : _nudge
                              ? HintCard(key: const ValueKey('nudge'), text: 'Keep going in English. Simple is fine.', icon: Icons.chat_bubble_outline_rounded)
                              : _chip != null
                                  ? HintCard(key: ValueKey(_chip), text: _chips[_chip]!)
                                  : _starter
                                      ? const HintCard(key: ValueKey('starter'), text: 'Starter words: kitchen · cooking · pan · breakfast · next')
                                      : _example
                                          ? const HintCard(key: ValueKey('example'), text: 'Example: "A man is reading on the train. He looks tired."', icon: Icons.format_quote_rounded)
                                          : const HintCard(key: ValueKey('base'), text: 'Use 3 connected sentences.'),
                    ),
                  ],
                ),
              ),
            ),
            PowerUpRow(
              height: 60,
              counts: _uses,
              items: [
                PowerUp('Starter words', icon: Icons.lightbulb_outline_rounded, color: c.amber, weight: 0.1),
                PowerUp('Example', icon: Icons.format_quote_rounded, color: c.inkSoft, weight: 0.15),
              ],
              onUse: (p) => setState(() {
                _uses[p.label] = (_uses[p.label] ?? 0) + 1;
                _chip = null;
                _starter = p.label == 'Starter words';
                _example = p.label == 'Example';
              }),
            ),
            const SizedBox(height: 8),
            MicButton(size: 92, enabled: !done, onSend: _send),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
