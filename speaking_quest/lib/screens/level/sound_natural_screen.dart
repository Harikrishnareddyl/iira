import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

enum _Verdict { correct, stiff, wrong, variation }

class _Item {
  const _Item(this.prompt, this.errorPart, this.explain, this.answer, this.attempts);
  final String prompt;
  final String errorPart;
  final String explain;
  final String answer;
  // Mock learner attempts and how they are judged.
  final List<(String, _Verdict, String)> attempts;
}

const _items = [
  _Item('I am agree with you.', 'am', "Use 'agree' without 'am'.", 'I agree with you.', [
    ('I agree with you.', _Verdict.correct, 'That sounds natural!'),
  ]),
  _Item('I would like to request one coffee.', 'request one', 'Correct, but formal for a café.', 'Can I get a coffee, please?', [
    ('I would like a coffee, please.', _Verdict.stiff, "Correct. Even more natural: \"Can I get a coffee, please?\""),
  ]),
  _Item('I am came to office early.', 'am came', "'Came' is already past. Drop 'am'. Add 'the' before office.", 'I came to the office early.', [
    ('I came to office early.', _Verdict.wrong, "Almost. Say 'to the office'. Try it again."),
    ('I came to the office early.', _Verdict.correct, 'That sounds natural!'),
  ]),
  _Item("She don't like mornings.", "don't", "With she / he / it, use 'doesn't'.", "She doesn't like mornings.", [
    ("She isn't a morning person.", _Verdict.variation, 'A different way to say it, and it works. Nice.'),
  ]),
];

/// Sound natural: fix a wrong or stiff sentence. Wrong → why + fix + say it.
/// Stiff → accept + "even more natural" bonus. Valid variation → praise.
class SoundNaturalScreen extends StatefulWidget {
  const SoundNaturalScreen({super.key});

  @override
  State<SoundNaturalScreen> createState() => _SoundNaturalScreenState();
}

class _SoundNaturalScreenState extends State<SoundNaturalScreen> {
  int _i = 0, _attempt = -1;
  bool _highlight = false, _explain = false, _show = false;
  final Map<String, int> _uses = {};

  _Item get _item => _items[_i];
  bool get _accepted => _attempt >= 0 && _item.attempts[_attempt].$2 != _Verdict.wrong;

  void _next() {
    if (_i == _items.length - 1) {
      demoNav(context, 'Results');
      return;
    }
    setState(() {
      _i++;
      _attempt = -1;
      _highlight = _explain = _show = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final item = _item;
    final att = _attempt >= 0 ? item.attempts[_attempt] : null;
    final parts = item.prompt.split(item.errorPart);
    return LevelScaffold(
      title: 'Sound natural',
      progress: (_i + (_accepted ? 1 : 0)) / _items.length,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(_i),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(color: c.surfaceWarm, borderRadius: BorderRadius.circular(20)),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: parts.first),
                            TextSpan(
                              text: item.errorPart,
                              style: _highlight
                                  ? TextStyle(color: c.coral, decoration: TextDecoration.lineThrough, decorationColor: c.coral, decorationThickness: 2)
                                  : null,
                            ),
                            TextSpan(text: parts.length > 1 ? parts[1] : ''),
                          ]),
                          textAlign: TextAlign.center,
                          style: context.text.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (att != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            color: att.$2 == _Verdict.wrong ? c.amberSoft : c.surfaceGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: LiveCaption(
                            key: ValueKey(_attempt),
                            text: att.$1,
                            style: context.text.headlineMedium,
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.border, width: 1.5),
                          ),
                          child: Text('Say a natural version', textAlign: TextAlign.center, style: context.text.titleMedium!.copyWith(color: c.inkMuted)),
                        ),
                      const SizedBox(height: 12),
                      if (att != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Mascot(
                              size: 64,
                              mood: att.$2 == _Verdict.wrong ? MascotMood.idle : MascotMood.happy,
                              showRays: false,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: c.surfaceGreen, borderRadius: BorderRadius.circular(16)),
                                child: Text(att.$3, style: context.text.titleMedium),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (_explain) HintCard(text: item.explain),
                      if (_show) ...[
                        const SizedBox(height: 8),
                        HintCard(text: item.answer, icon: Icons.visibility_rounded),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            PowerUpRow(
              height: 76,
              counts: _uses,
              items: [
                PowerUp('Highlight', icon: Icons.edit_rounded, color: c.coral, weight: 0.1),
                PowerUp('Explain', icon: Icons.lightbulb_outline_rounded, color: c.amber, weight: 0.15),
                PowerUp('See answer', icon: Icons.visibility_rounded, color: c.greenDeep, weight: 0.3),
              ],
              onUse: (p) => setState(() {
                _uses[p.label] = (_uses[p.label] ?? 0) + 1;
                if (p.label == 'Highlight') _highlight = true;
                if (p.label == 'Explain') _explain = true;
                if (p.label == 'See answer') _show = true;
              }),
            ),
            const SizedBox(height: 10),
            if (_accepted)
              PrimaryButton(label: 'Next', trailingIcon: Icons.chevron_right_rounded, onTap: _next)
            else
              MicButton(
                size: 88,
                onSend: () => setState(() => _attempt = (_attempt + 1).clamp(0, item.attempts.length - 1)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
