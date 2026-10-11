import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/mascot.dart';
import '../../widgets/common.dart';
import '../../widgets/level.dart';
import '../../widgets/voice.dart';

const _qa = [
  ("Hi, I'm $mascotName. What's your name?", "I'm Alex. Nice to meet you."),
  ('Nice to meet you, Alex. What do you do?', "I'm a product designer. I work with a team in London."),
  ('Cool! Why do you want to speak more English?', 'In meetings I understand everything, but I freeze when I have to speak.'),
];

/// Onboarding step 1: a 60-second hello chat. Measures vocabulary range and
/// sentence complexity while feeling like a conversation.
class HelloChatScreen extends StatefulWidget {
  const HelloChatScreen({super.key});

  @override
  State<HelloChatScreen> createState() => _HelloChatScreenState();
}

class _HelloChatScreenState extends State<HelloChatScreen> {
  final _log = <(bool, String)>[(false, _qa[0].$1)];
  int _turn = 0;
  int _secs = 60;
  late final Timer _t;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secs > 0 && _turn < _qa.length) setState(() => _secs--);
    });
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  void _send() {
    setState(() => _log.add((true, _qa[_turn].$2)));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _turn++;
        _log.add((false, _turn < _qa.length ? _qa[_turn].$1 : "That's really common, and very fixable. Let's see how you speak."));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final done = _turn >= _qa.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: ThemeBar(value: 1 / 7, height: 8)),
                  const SizedBox(width: 14),
                  ProgressRing(value: _secs / 60, size: 42, stroke: 4, child: Text('$_secs', style: context.text.labelLarge)),
                ],
              ),
              const SizedBox(height: 14),
              Text('Hello chat', style: context.text.displaySmall),
              Text('Just talk. There are no wrong answers.', style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
              const SizedBox(height: 14),
              Mascot(size: 110, mood: _log.last.$1 ? MascotMood.listening : MascotMood.talking, showRays: false),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: _scroll,
                  itemCount: _log.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final (me, text) = _log[i];
                    return me && i == _log.length - 1
                        ? ChatBubble(text: '', fromLearner: true, child: LiveCaption(text: text, style: context.text.bodyLarge!.copyWith(fontWeight: FontWeight.w600, fontSize: 18)))
                        : ChatBubble(text: text, fromLearner: me);
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (done)
                PrimaryButton(label: 'Continue', trailingIcon: Icons.chevron_right_rounded, onTap: () => demoNav(context, 'Goals'))
              else
                MicButton(size: 92, enabled: !_log.last.$1, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }
}
