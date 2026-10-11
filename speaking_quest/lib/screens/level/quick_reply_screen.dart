import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

const _rounds = [
  ('What do you do after work?', 'I usually go for a walk.', 'I usually… / I like to…'),
  ('How do you get to work?', 'By bus, mostly.', 'By… / I take the…'),
  ('Tea or coffee?', 'Coffee, definitely.', 'Coffee… / Tea…'),
  ('What did you have for lunch?', 'Just a sandwich.', 'I had… / Just a…'),
  ('Any plans for the weekend?', 'Not yet, maybe a film.', 'Not yet… / I\'m going to…'),
];

enum _R { pending, ok, missed }

/// Quick reply: 5 short questions, a soft timer (no red, no ticking),
/// "a short answer is enough".
class QuickReplyScreen extends StatefulWidget {
  const QuickReplyScreen({super.key});

  @override
  State<QuickReplyScreen> createState() => _QuickReplyScreenState();
}

class _QuickReplyScreenState extends State<QuickReplyScreen>
    with SingleTickerProviderStateMixin {
  int _round = 0;
  final _results = List.filled(5, _R.pending);
  String? _answer;
  bool _starter = false;
  bool _listening = false;
  final Map<String, int> _uses = {};

  late final AnimationController _timer = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )
    ..addListener(() => setState(() {}))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && _answer == null && !_listening) _finish(_R.missed);
    });

  @override
  void initState() {
    super.initState();
    _timer.forward();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _finish(_R r) {
    setState(() => _results[_round] = r);
    Future.delayed(Duration(milliseconds: r == _R.ok ? 1500 : 900), () {
      if (!mounted) return;
      if (_round == 4) {
        setState(() => _round = 5);
        return;
      }
      setState(() {
        _round++;
        _answer = null;
        _starter = false;
        _timer.duration = const Duration(seconds: 5);
      });
      _timer.forward(from: 0);
    });
  }

  void _extraTime() {
    final remaining = (1 - _timer.value) * _timer.duration!.inMilliseconds;
    final total = remaining + 3000;
    _timer.stop();
    _timer.duration = Duration(milliseconds: total.round());
    _timer.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final over = _round >= 5;
    final ok = _results.where((r) => r == _R.ok).length;
    final q = over ? null : _rounds[_round];
    final left = ((1 - _timer.value) * _timer.duration!.inMilliseconds / 1000).ceil();
    return LevelScaffold(
      title: 'Quick reply',
      progress: _results.where((r) => r != _R.pending).length / 5,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 5; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i == _round ? 18 : 16,
                    height: i == _round ? 18 : 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switch (_results[i]) {
                        _R.ok => c.green,
                        _R.missed => c.greenSoft.withValues(alpha: 0.5),
                        _R.pending => i == _round ? c.greenTint : c.surfaceMuted,
                      },
                      border: Border.all(color: i == _round ? c.green : c.border, width: i == _round ? 2 : 1),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0.15, 0), end: Offset.zero).animate(a), child: child),
                ),
                child: over
                    ? _Summary(key: const ValueKey('sum'), ok: ok)
                    : SingleChildScrollView(
                        key: ValueKey(_round),
                        child: Column(
                          children: [
                            SqCard(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(q!.$1, textAlign: TextAlign.center, style: context.text.displaySmall!.copyWith(fontSize: 32)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('A short answer is enough.', style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                            const SizedBox(height: 14),
                            ProgressRing(
                              value: 1 - _timer.value,
                              size: 108,
                              stroke: 8,
                              color: c.green,
                              child: Text(
                                _results[_round] == _R.missed ? '–' : '${left}s',
                                style: context.text.displaySmall,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_results[_round] == _R.missed)
                              Text("That's okay. Next one.", style: context.text.titleMedium!.copyWith(color: c.inkMuted))
                            else if (_answer != null)
                              ChatBubble(text: '', fromLearner: true, child: LiveCaption(text: _answer!, style: context.text.titleLarge!.copyWith(fontFamily: AppTheme.body, fontSize: 21)))
                            else if (_starter)
                              HintCard(text: q.$3),
                          ],
                        ),
                      ),
              ),
            ),
            if (!over) ...[
              PowerUpRow(
                height: 56,
                counts: _uses,
                items: [
                  const PowerUp('+3s', icon: Icons.hourglass_bottom_rounded, weight: 0.1),
                  PowerUp('Starter words', icon: Icons.lightbulb_outline_rounded, color: c.amber, weight: 0.15),
                  PowerUp('Skip', icon: Icons.skip_next_rounded, color: c.inkMuted, weight: 0.1),
                ],
                onUse: (p) {
                  if (_answer != null || _results[_round] != _R.pending) return;
                  setState(() => _uses[p.label] = (_uses[p.label] ?? 0) + 1);
                  if (p.label == '+3s') _extraTime();
                  if (p.label == 'Starter words') setState(() => _starter = true);
                  if (p.label == 'Skip') {
                    _timer.stop();
                    _finish(_R.missed);
                  }
                },
              ),
              const SizedBox(height: 8),
              MicButton(
                size: 88,
                enabled: _answer == null && _results[_round] == _R.pending,
                onStart: () {
                  _listening = true;
                  _timer.stop();
                },
                onSend: () {
                  _listening = false;
                  setState(() => _answer = q!.$2);
                  _finish(_R.ok);
                },
              ),
            ] else
              PrimaryButton(label: 'Continue', trailingIcon: Icons.chevron_right_rounded, onTap: () => demoNav(context, 'Results')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({super.key, required this.ok});
  final int ok;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final won = ok >= 4;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CompanionMark(size: 130, mood: won ? CompanionMood.pleased : CompanionMood.dim),
        const SizedBox(height: 12),
        Text(won ? 'Quick and clear' : 'Close', style: context.text.displaySmall),
        const SizedBox(height: 6),
        Text(won ? 'You answered $ok of 5 in time.' : 'You answered $ok of 5 in time. 4 wins it.',
            style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
      ],
    );
  }
}
