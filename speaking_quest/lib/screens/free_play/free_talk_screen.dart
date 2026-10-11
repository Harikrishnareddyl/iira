import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/mascot.dart';
import '../../widgets/common.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

const _turns = [
  ('Last time you said the demo was on Friday. How did your project go?', 'It went well. We finished on time, but the client want more changes.', true),
  ('Oh, more changes? That always happens. Were you running late with anything?', "A bit. I'm running late with the new screens, so I need to make a decision today.", false),
  ('What are you choosing between?', 'Between doing it this weekend or asking for more time. What would you do?', false),
  ("Good question back! Honestly, I'd ask for more time. Weekends are precious.", 'Yes, you are right. I will ask my manager tomorrow.', false),
];

/// Free talk: open conversation with Echo, the mascot. No goal, no stars, no failure —
/// a live dot and a running timer replace the goal pill.
class FreeTalkScreen extends StatefulWidget {
  const FreeTalkScreen({super.key});

  @override
  State<FreeTalkScreen> createState() => _FreeTalkScreenState();
}

class _FreeTalkScreenState extends State<FreeTalkScreen> {
  int _turn = 0;
  bool _holdMode = false;
  bool _listening = false;
  String? _caption;
  bool _tipSaved = false;
  bool _hint = false;
  Duration _elapsed = const Duration(minutes: 2, seconds: 18);
  late final Timer _clock;
  final Map<String, int> _uses = {};

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _elapsed += const Duration(seconds: 1)));
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  void _send() {
    final t = _turns[_turn % _turns.length];
    setState(() {
      _listening = false;
      _caption = t.$2;
      _tipSaved = t.$3;
      _hint = false;
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() {
        _turn++;
        _caption = null;
        _tipSaved = false;
      });
    });
  }

  String get _time =>
      '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final t = _turns[_turn % _turns.length];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => showPauseSheet(context), icon: Icon(Icons.pause_rounded, color: c.ink, size: 34)),
                  Expanded(child: Text(mascotName, textAlign: TextAlign.center, style: context.text.headlineMedium)),
                  const _LiveDot(),
                  const SizedBox(width: 6),
                  Text(_time, style: context.text.titleMedium!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Mascot(size: 112, mood: _listening ? MascotMood.listening : (_caption != null ? (_tipSaved ? MascotMood.thinking : MascotMood.idle) : MascotMood.talking), showRays: false),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ChatBubble(key: ValueKey(_turn), text: t.$1, big: true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _caption != null
                          ? ChatBubble(
                              key: ValueKey(_caption),
                              text: '',
                              fromLearner: true,
                              child: LiveCaption(text: _caption!, style: context.text.titleLarge!.copyWith(fontFamily: AppTheme.body, fontSize: 20)),
                            )
                          : _hint
                              ? HintCard(text: _turn == 0 ? 'It went… / We finished…' : 'Ask a question back: "What about you?"')
                              : const SizedBox(height: 60, width: double.infinity),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _tipSaved ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, left: 8),
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_rounded, color: c.green, size: 22),
                            const SizedBox(width: 6),
                            Text('Tip saved for your recap', style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: SizedBox(
                  width: 260,
                  child: PowerUpRow(
                    height: 92,
                    counts: _uses,
                    items: [
                      PowerUp('Hint', icon: Icons.lightbulb_rounded, color: c.amber),
                      const PowerUp('Slower', emoji: '🐌'),
                    ],
                    onUse: (p) => setState(() {
                      _uses[p.label] = (_uses[p.label] ?? 0) + 1;
                      if (p.label == 'Hint') _hint = true;
                      if (p.label == 'Slower') toast(context, '$mascotName will speak a little slower.');
                    }),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Waveform(bars: 30, height: 80, active: _listening, seed: 5, barWidth: 4, gap: 5,
                    color: _listening ? c.green : c.greenSoft),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SideAction(
                      icon: Icons.mic_none_rounded,
                      label: _holdMode ? 'Tap mode' : 'Hold mode',
                      color: c.surfaceMuted,
                      iconColor: c.inkSoft,
                      onTap: () => setState(() => _holdMode = !_holdMode),
                    ),
                    Expanded(
                      child: MicButton(
                        mode: _holdMode ? MicMode.hold : MicMode.tap,
                        showSideWaves: false,
                        size: 100,
                        enabled: _caption == null,
                        idleLabel: _holdMode ? 'Hold to speak' : 'Tap to speak',
                        onStart: () => setState(() => _listening = true),
                        onSend: _send,
                      ),
                    ),
                    _SideAction(
                      icon: Icons.stop_rounded,
                      label: 'End',
                      color: c.coralSoft,
                      iconColor: c.coral,
                      onTap: () => demoNav(context, 'Free talk recap'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});
  final IconData icon;
  final String label;
  final Color color, iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Pressable(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 6),
            Text(label, style: context.text.bodyMedium!.copyWith(color: context.sq.inkSoft)),
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.4, end: 1.0).animate(_c),
        child: Container(width: 11, height: 11, decoration: BoxDecoration(shape: BoxShape.circle, color: context.sq.green)),
      );
}
