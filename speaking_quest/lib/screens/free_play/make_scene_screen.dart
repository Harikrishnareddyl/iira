import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/mascot.dart';
import '../../widgets/level.dart';

enum _Stage { input, building, ready }

/// Make your own scene: type or say a real situation, the AI builds a
/// one-off scene. Uses one of the shared daily free sessions.
class MakeSceneScreen extends StatefulWidget {
  const MakeSceneScreen({super.key});

  @override
  State<MakeSceneScreen> createState() => _MakeSceneScreenState();
}

class _MakeSceneScreenState extends State<MakeSceneScreen> {
  final _ctrl = TextEditingController();
  _Stage _stage = _Stage.input;
  bool _dictating = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _build() async {
    FocusScope.of(context).unfocus();
    setState(() => _stage = _Stage.building);
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) setState(() => _stage = _Stage.ready);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Make a scene'),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: switch (_stage) {
                  _Stage.input => _input(context, c),
                  _Stage.building => _building(context, c),
                  _Stage.ready => _ready(context, c),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(BuildContext context, SqColors c) {
    return ListView(
      key: const ValueKey('input'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Text('What do you need to say in real life?', style: context.text.headlineMedium),
        const SizedBox(height: 6),
        Text("Describe it in a few words. We'll build a short scene for it.",
            style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
        const SizedBox(height: 16),
        TextField(
          controller: _ctrl,
          minLines: 3,
          maxLines: 5,
          onChanged: (_) => setState(() {}),
          style: context.text.bodyLarge,
          decoration: InputDecoration(
            hintText: "e.g. Doctor's appointment tomorrow",
            suffixIcon: IconButton(
              onPressed: () async {
                setState(() => _dictating = true);
                await Future.delayed(const Duration(milliseconds: 1400));
                if (!mounted) return;
                setState(() {
                  _dictating = false;
                  _ctrl.text = 'Asking my manager for Friday off for my sister\'s wedding';
                });
              },
              icon: Icon(_dictating ? Icons.graphic_eq_rounded : Icons.mic_none_rounded, color: c.green),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Try one of these', style: context.text.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in Mock.sampleScenePrompts)
              ActionChip(
                label: Text(p),
                labelStyle: context.text.bodyMedium,
                backgroundColor: c.surfaceWarm,
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onPressed: () => setState(() => _ctrl.text = p),
              ),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Build my scene',
          icon: Icons.auto_awesome_rounded,
          fontSize: 21,
          onTap: _ctrl.text.trim().isEmpty ? null : _build,
        ),
        const SizedBox(height: 10),
        Text('Uses 1 of your ${Learner.freeSessionsLeft} free sessions left today.',
            textAlign: TextAlign.center, style: context.text.bodySmall),
      ],
    );
  }

  Widget _building(BuildContext context, SqColors c) {
    return Column(
      key: const ValueKey('building'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Mascot(size: 140, mood: MascotMood.thinking),
        const SizedBox(height: 16),
        Text('Building your scene…', style: context.text.headlineSmall),
        const SizedBox(height: 18),
        for (final (i, s) in ['Setting the place', 'Choosing a character', 'Picking expressions you know'].indexed)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + i * 650),
            builder: (context, v, _) => Opacity(
              opacity: v,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(v >= 1 ? Icons.check_circle_rounded : Icons.circle_outlined, color: c.green, size: 18),
                    const SizedBox(width: 8),
                    Text(s, style: context.text.bodyLarge),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _ready(BuildContext context, SqColors c) {
    final text = _ctrl.text.trim();
    return ListView(
      key: const ValueKey('ready'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Center(child: LevelTag('Free play', color: c.lavenderSoft, textColor: c.lavender)),
        const SizedBox(height: 14),
        const Center(child: CharacterAvatar(spec: CharacterSpec.priya, size: 170, width: 300, circle: false)),
        const SizedBox(height: 14),
        Text('Friday off', textAlign: TextAlign.center, style: context.text.displaySmall),
        const SizedBox(height: 10),
        const Center(child: GoalPill(goal: 'Get Friday off approved.')),
        const SizedBox(height: 14),
        SqCard(
          color: c.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv(context, 'Your situation', text),
              _kv(context, 'Character', 'Priya, your manager. Friday has a client demo.'),
              _kv(context, 'Expressions to use', 'Could you give me a minute? · make a decision'),
              _kv(context, 'Length', 'About 3 minutes'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Start', icon: Icons.play_arrow_rounded, onTap: () => demoNav(context, 'Conversation (custom scene)')),
        TextButton(
          onPressed: () => setState(() => _stage = _Stage.input),
          child: Text('Change the situation', style: context.text.labelLarge!.copyWith(color: c.inkMuted)),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k.toUpperCase(), style: context.text.labelSmall),
            const SizedBox(height: 2),
            Text(v, style: context.text.bodyLarge),
          ],
        ),
      );
}
