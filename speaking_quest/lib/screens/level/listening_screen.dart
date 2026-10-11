import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

class _Clip {
  const _Clip(this.speaker, this.transcript, this.question, this.keyWords, this.answer, this.feedback);
  final CharacterSpec speaker;
  final String transcript;
  final String question;
  final String keyWords;
  final String answer;
  final String feedback;
}

const _clips = [
  _Clip(
    CharacterSpec.daniel,
    "Hi, it's Daniel. Thursday doesn't work for me any more, sorry. Could we meet on Friday at half past ten instead? Same room as last time.",
    'When will they meet?',
    'Friday · half past ten',
    'On Friday at half past ten.',
    'Right. Friday, 10:30.',
  ),
  _Clip(
    CharacterSpec.priya,
    "Quick update: the client loved the design, but they want the launch moved to next month. I'll send the new dates tonight.",
    'What did the client want to change?',
    'launch · next month',
    'They want to move the launch to next month.',
    'Exactly. The launch moves to next month.',
  ),
];

/// Listening: replay and 0.75× controls; the answer is spoken, never tapped.
class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen>
    with SingleTickerProviderStateMixin {
  int _clip = 0;
  bool _slow = false, _keyWords = false, _transcript = false;
  String? _answer;
  bool _correct = false;
  final Map<String, int> _uses = {};

  late final AnimationController _player = AnimationController(vsync: this, duration: _length)
    ..addListener(() => setState(() {}));

  Duration get _length => Duration(milliseconds: _slow ? 18700 : 14000);

  @override
  void initState() {
    super.initState();
    _player.forward();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _count(String k) => _uses[k] = (_uses[k] ?? 0) + 1;

  void _replay() {
    _count('Replay');
    _player.forward(from: 0);
  }

  void _toggleSpeed() {
    setState(() {
      _slow = !_slow;
      if (_slow) _count('0.75×');
      final v = _player.value;
      _player.duration = _length;
      if (_player.isAnimating) _player.forward(from: v);
    });
  }

  void _send() {
    final c = _clips[_clip];
    setState(() => _answer = c.answer);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _correct = true);
    });
  }

  void _next() {
    if (_clip == _clips.length - 1) {
      demoNav(context, 'Results');
      return;
    }
    setState(() {
      _clip++;
      _answer = null;
      _correct = _keyWords = _transcript = false;
    });
    _player.forward(from: 0);
  }

  String _fmt(Duration d) => '0:${(d.inSeconds).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final clip = _clips[_clip];
    final playing = _player.isAnimating;
    final pos = _player.duration! * _player.value;
    return LevelScaffold(
      title: 'Listening',
      goal: _clip == 0 ? 'Listen for the meeting time.' : 'Listen for what changed.',
      progress: (_clip + (_correct ? 1 : 0.3)) / _clips.length,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SqCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      CharacterAvatar(spec: clip.speaker, size: 78, talking: playing, background: c.amberSoft),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Waveform(
                              bars: 26,
                              height: 44,
                              active: playing,
                              progress: _player.value,
                              seed: _clip + 11,
                              barWidth: 3.5,
                              gap: 3,
                            ),
                            const SizedBox(height: 8),
                            ThemeBar(value: _player.value, height: 5, duration: Duration.zero, from: _player.value),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('${_fmt(pos)} / ${_fmt(_player.duration!)}', style: context.text.labelMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Pressable(
                        onTap: () => playing ? _player.stop() : _player.forward(from: _player.value >= 1 ? 0 : _player.value),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: c.green),
                          child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 34),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Pill(icon: Icons.replay_rounded, label: 'Replay', onTap: _replay),
                      const SizedBox(width: 8),
                      _Pill(label: '0.75×', active: _slow, onTap: _toggleSpeed),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(clip.question, textAlign: TextAlign.center, style: context.text.headlineMedium),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: c.surfaceGreen,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _correct ? c.green : Colors.transparent, width: 1.5),
                      ),
                      child: _answer == null
                          ? Text('Your answer…', style: context.text.bodyLarge!.copyWith(color: c.inkMuted))
                          : Row(
                              children: [
                                Expanded(
                                  child: LiveCaption(
                                    text: _answer!,
                                    style: context.text.bodyLarge!.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (_correct) Icon(Icons.check_circle_rounded, color: c.green),
                              ],
                            ),
                    ),
                    if (_correct) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const CompanionMark(size: 44, mood: CompanionMood.pleased, showRays: false),
                          const SizedBox(width: 8),
                          Expanded(child: Text(clip.feedback, style: context.text.bodyLarge)),
                          TextButton(onPressed: _next, child: Text(_clip == _clips.length - 1 ? 'Finish' : 'Next clip', style: context.text.titleSmall!.copyWith(color: c.green))),
                        ],
                      ),
                    ],
                    if (_keyWords) ...[const SizedBox(height: 10), HintCard(text: clip.keyWords, icon: Icons.key_rounded)],
                    if (_transcript) ...[
                      const SizedBox(height: 10),
                      SqCard(color: c.surface, child: Text(clip.transcript, style: context.text.bodyMedium)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            PowerUpRow(
              height: 60,
              counts: _uses,
              items: [
                PowerUp('Key words', icon: Icons.lightbulb_outline_rounded, color: c.amber, weight: 0.15),
                PowerUp('Transcript', icon: Icons.article_outlined, color: c.inkSoft, weight: 0.3),
              ],
              onUse: (p) => setState(() {
                _count(p.label);
                if (p.label == 'Key words') _keyWords = true;
                if (p.label == 'Transcript') _transcript = !_transcript;
              }),
            ),
            const SizedBox(height: 8),
            MicButton(size: 92, enabled: _answer == null, onSend: _send, idleLabel: 'Hold to answer'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({this.icon, required this.label, required this.onTap, this.active = false});
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? c.surfaceGreen : c.surface,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: active ? c.green : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: c.inkSoft), const SizedBox(width: 6)],
            Text(label, style: context.text.titleSmall),
          ],
        ),
      ),
    );
  }
}
