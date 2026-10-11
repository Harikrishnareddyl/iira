import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

class _Turn {
  const _Turn(this.maya, this.simple, this.translation, this.learner, this.hint,
      {this.define});
  final String maya;
  final String simple;
  final String translation;
  final String learner; // mock of what speech recognition hears
  final String hint;
  final String? define; // tappable expression inside Maya's line
}

const _script = [
  _Turn(
    'Hi there! What did you order?',
    'What drink did you ask for?',
    '¡Hola! ¿Qué pediste?',
    'I asked for oat milk.',
    'I asked for…',
  ),
  _Turn(
    'Oh, this one has regular milk. Sounds like a mix-up on our side.',
    'This has normal milk. We made a mistake.',
    'Oh, este tiene leche normal. Parece una confusión de nuestra parte.',
    'Could you remake it, please?',
    'Could you remake it?',
    define: 'mix-up',
  ),
  _Turn(
    'Of course. Oat latte, same size?',
    'Yes. Same size?',
    'Claro. Latte de avena, ¿del mismo tamaño?',
    'Yes, a large one. Thank you!',
    'Yes, a…',
  ),
];

/// Conversation: goal banner, character, chat bubbles with live caption,
/// power-ups and the big mic.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  int _turn = 0;
  bool _speaking = false;
  String? _caption;
  bool _hint = false, _simple = false, _translate = false, _slow = false;
  bool _done = false;
  bool _mayaTalking = true;
  final Map<String, int> _uses = {};

  @override
  void initState() {
    super.initState();
    _stopTalkingSoon();
  }

  void _stopTalkingSoon() {
    Future.delayed(Duration(milliseconds: _slow ? 2600 : 1600), () {
      if (mounted) setState(() => _mayaTalking = false);
    });
  }

  void _use(PowerUp p) {
    setState(() {
      _uses[p.label] = (_uses[p.label] ?? 0) + 1;
      switch (p.label) {
        case 'Hint':
          _hint = true;
        case 'Slower':
          _slow = true;
          _mayaTalking = true;
          _stopTalkingSoon();
        case 'Simplify':
          _simple = !_simple;
        case 'Translate':
          _translate = !_translate;
      }
    });
  }

  void _send() {
    final t = _script[_turn];
    setState(() {
      _speaking = false;
      _caption = t.learner;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        if (_turn == _script.length - 1) {
          _done = true;
          return;
        }
        _turn++;
        _caption = null;
        _hint = _simple = _translate = false;
        _mayaTalking = true;
      });
      _stopTalkingSoon();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final t = _script[_turn];
    return LevelScaffold(
      title: 'Coffee mix-up',
      goal: 'Get your order remade.',
      progress: (_turn + (_caption != null ? 1 : 0)) / _script.length,
      goalTrailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _done
            ? Icon(Icons.check_circle_rounded, key: const ValueKey(1), color: c.green, size: 22)
            : const SizedBox.shrink(key: ValueKey(0)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                children: [
                  CharacterAvatar(
                    spec: CharacterSpec.maya,
                    size: 160,
                    width: 170,
                    circle: false,
                    talking: _mayaTalking,
                  ),
                  Positioned(
                    left: 150,
                    right: 0,
                    top: 14,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0.05, 0.1), end: Offset.zero).animate(a),
                          child: child,
                        ),
                      ),
                      child: _MayaBubble(
                        key: ValueKey('$_turn$_simple$_translate'),
                        text: _simple ? t.simple : t.maya,
                        define: _simple ? null : t.define,
                        translation: _translate ? t.translation : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _done
                          ? _DoneBanner(key: const ValueKey('done'), onTap: () => demoNav(context, 'Results'))
                          : _caption != null
                              ? ChatBubble(
                                  key: ValueKey(_caption),
                                  text: '',
                                  fromLearner: true,
                                  child: LiveCaption(
                                    text: _caption!,
                                    style: context.text.bodyLarge!.copyWith(fontSize: 19, fontWeight: FontWeight.w600),
                                  ),
                                )
                              : _speaking
                                  ? Padding(
                                      key: const ValueKey('listening'),
                                      padding: const EdgeInsets.all(12),
                                      child: Waveform(bars: 22, height: 36, active: true, barWidth: 4, gap: 4),
                                    )
                                  : const SizedBox(key: ValueKey('empty'), height: 8),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _hint && !_done && _caption == null
                          ? HintCard(text: t.hint)
                          : const SizedBox(width: double.infinity),
                    ),
                    // Gentle nudge after leaning on Translate.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: (_uses['Translate'] ?? 0) >= 2 && !_done && _caption == null
                          ? const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: MascotTip(text: 'Try this one without Translate. You know more than you think.'),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
            PowerUpRow(
              items: [
                PowerUp('Hint', icon: Icons.lightbulb_outline_rounded, color: c.amber, weight: 0.15),
                const PowerUp('Slower', emoji: '🐢', weight: 0.05),
                PowerUp('Simplify', icon: Icons.eco_rounded, color: c.green, weight: 0.15),
                PowerUp('Translate', icon: Icons.translate_rounded, color: c.inkSoft, weight: 0.3),
              ],
              counts: _uses,
              onUse: _use,
              height: 84,
            ),
            const SizedBox(height: 10),
            MicButton(
              enabled: !_done && _caption == null,
              onStart: () => setState(() => _speaking = true),
              onSend: _send,
              size: 96,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MayaBubble extends StatelessWidget {
  const _MayaBubble({super.key, required this.text, this.define, this.translation});
  final String text;
  final String? define;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final style = context.text.bodyLarge!.copyWith(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3);
    final spans = <InlineSpan>[];
    if (define != null && text.contains(define!)) {
      final i = text.indexOf(define!);
      spans
        ..add(TextSpan(text: text.substring(0, i)))
        ..add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => _showDefine(context, define!),
            child: Text(define!,
                style: style.copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: c.green,
                  decorationThickness: 2.5,
                )),
          ),
        ))
        ..add(TextSpan(text: text.substring(i + define!.length)));
    } else {
      spans.add(TextSpan(text: text));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: spans), style: style),
          if (translation != null) ...[
            const SizedBox(height: 6),
            Text(translation!, style: context.text.bodyMedium!.copyWith(color: c.inkMuted, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  void _showDefine(BuildContext context, String word) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(word, style: ctx.text.headlineMedium),
                const SizedBox(width: 10),
                Icon(Icons.volume_up_rounded, color: ctx.sq.green),
              ],
            ),
            const SizedBox(height: 8),
            Text('A small mistake where one thing is confused with another.', style: ctx.text.bodyLarge),
            const SizedBox(height: 10),
            Text('"There was a mix-up with the dates."',
                style: ctx.text.bodyLarge!.copyWith(color: ctx.sq.inkMuted, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text('Light help · counts a little toward stars', style: ctx.text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DoneBanner extends StatelessWidget {
  const _DoneBanner({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return SqCard(
      color: c.surfaceGreen,
      borderColor: c.greenSoft,
      onTap: onTap,
      child: Row(
        children: [
          const Mascot(size: 56, mood: MascotMood.happy, showRays: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goal reached', style: context.text.titleLarge),
                Text('Maya is remaking your drink.', style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.green, size: 30),
        ],
      ),
    );
  }
}
