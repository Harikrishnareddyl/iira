import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

const _targets = ["I'll have the…", 'Could you remake it?', 'Is this seat taken?', 'Could you give me a minute?'];

const _exchanges = [
  ('Sam', 'Wow, this place is busy. Where should we sit?', 'Excuse me, is this seat taken? No? Great, let\'s sit here.', 'Is this seat taken?'),
  ('Server', 'Hi both! Ready to order?', 'Could you give me a minute? … Okay, I\'ll have the avocado toast.', 'Could you give me a minute?'),
  ('Sam', 'Hmm, my tea is cold.', 'Excuse me, this tea is cold. Could you remake it?', 'Could you remake it?'),
  ('Server', 'So sorry! Anything else?', "I'll have the lemon cake too, thanks.", "I'll have the…"),
];

/// Theme finale: unscripted, longer scene using the theme's targets plus
/// shaky items. A checklist shows targets as they are used.
class BossScreen extends StatefulWidget {
  const BossScreen({super.key});

  @override
  State<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends State<BossScreen> {
  int _turn = 0;
  final _used = <String>{};
  final _log = <(bool, String)>[(false, _exchanges[0].$2)];
  final _scroll = ScrollController();
  final Map<String, int> _uses = {};

  void _send() {
    final e = _exchanges[_turn];
    setState(() {
      _log.add((true, e.$3));
      _used.add(e.$4);
    });
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _turn++;
        if (_turn < _exchanges.length) _log.add((false, '${_exchanges[_turn].$1}: ${_exchanges[_turn].$2}'));
      });
      _scrollDown();
    });
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final done = _turn >= _exchanges.length;
    return LevelScaffold(
      title: 'Brunch with a friend',
      tag: 'Theme finale',
      goal: 'Host your friend and sort out the order.',
      progress: _used.length / _targets.length,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CharacterAvatar(spec: CharacterSpec.sam, size: 60),
                const SizedBox(width: 8),
                const CharacterAvatar(spec: CharacterSpec.maya, size: 60),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in _targets)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _used.contains(t) ? c.surfaceGreen : c.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _used.contains(t) ? c.greenSoft : c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_used.contains(t) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14, color: _used.contains(t) ? c.green : c.inkMuted),
                        const SizedBox(width: 4),
                        Text(t, style: context.text.labelMedium!.copyWith(color: c.inkSoft)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                itemCount: _log.length + (done ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == _log.length) {
                    return SqCard(
                      color: c.amberSoft,
                      onTap: () => demoNav(context, 'Theme complete'),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: c.amber, size: 34),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Finale passed. All targets used.', style: context.text.titleMedium)),
                          Icon(Icons.chevron_right_rounded, color: c.inkSoft),
                        ],
                      ),
                    );
                  }
                  final (me, text) = _log[i];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
                    child: ChatBubble(text: text, fromLearner: me),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            PowerUpRow(
              height: 64,
              counts: _uses,
              items: [
                PowerUp('Hint', icon: Icons.lightbulb_outline_rounded, color: c.amber),
                const PowerUp('Slower', emoji: '🐢'),
                PowerUp('Simplify', icon: Icons.eco_rounded, color: c.green),
                PowerUp('Translate', icon: Icons.translate_rounded, color: c.inkSoft),
              ],
              onUse: (p) {
                setState(() => _uses[p.label] = (_uses[p.label] ?? 0) + 1);
                if (p.label == 'Hint' && !done) toast(context, 'Try: "${_exchanges[_turn].$4}"');
              },
            ),
            const SizedBox(height: 8),
            MicButton(size: 88, enabled: !done && _log.last.$1 == false, onSend: _send),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
