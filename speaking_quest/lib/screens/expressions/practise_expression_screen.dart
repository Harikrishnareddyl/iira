import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

const _turns = [
  ('Priya', 'The deck for the client is ready. Can you check it before 3?', "Sure. Oh, there's a typo on slide 4. Could you remake it?"),
  ('Priya', 'Good catch! Anything else?', 'No, the rest looks great. Thanks!'),
];

/// Practise it: a one-minute scene using one expression in a new situation.
/// Works like Free play (doesn't move the plan, still updates mastery).
class PractiseExpressionScreen extends StatefulWidget {
  const PractiseExpressionScreen({super.key});

  @override
  State<PractiseExpressionScreen> createState() => _PractiseExpressionScreenState();
}

class _PractiseExpressionScreenState extends State<PractiseExpressionScreen> {
  int _turn = 0;
  String? _caption;
  bool _used = false;
  int _secs = 60;
  late final Timer _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secs > 0 && _turn < _turns.length) setState(() => _secs--);
    });
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  void _send() {
    final t = _turns[_turn];
    setState(() {
      _caption = t.$3;
      if (t.$3.contains('Could you remake it?')) _used = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _turn++;
        _caption = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final done = _turn >= _turns.length;
    return LevelScaffold(
      title: 'Fix the slides',
      tag: 'Practice',
      goal: 'Use "Could you remake it?" at work.',
      progress: _turn / _turns.length,
      headerTrailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timer_outlined, size: 20, color: c.inkMuted),
        const SizedBox(width: 4),
        Text('0:${_secs.toString().padLeft(2, '0')}', style: context.text.titleSmall),
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _used ? c.surfaceGreen : c.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _used ? c.green : c.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_used ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: _used ? c.green : c.inkMuted, size: 20),
                const SizedBox(width: 8),
                Text('Could you remake it?', style: context.text.titleSmall),
              ]),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CharacterAvatar(spec: CharacterSpec.priya, size: 90, talking: _caption == null && !done),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: done
                        ? ChatBubble(key: const ValueKey('end'), text: 'Perfect, I\'ll fix it now. Thanks!')
                        : ChatBubble(key: ValueKey(_turn), text: _turns[_turn].$2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: done
                    ? Column(
                        key: const ValueKey('done'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CompanionMark(size: 110, mood: CompanionMood.pleased),
                          Text('Used naturally', style: context.text.headlineMedium),
                          const SizedBox(height: 4),
                          Text("It's moving toward Mastered.", style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                        ],
                      )
                    : _caption != null
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: ChatBubble(key: ValueKey(_caption), text: '', fromLearner: true, child: LiveCaption(text: _caption!, style: context.text.titleMedium)),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
            if (done)
              PrimaryButton(label: 'Done', onTap: () => Navigator.maybePop(context))
            else
              MicButton(size: 92, enabled: _caption == null, onSend: _send),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
