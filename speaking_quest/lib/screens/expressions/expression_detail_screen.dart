import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/voice.dart';

/// Expression detail: text with audio, meaning, "You said", other ways to use
/// it (with audio) and Practise it.
class ExpressionDetailScreen extends StatefulWidget {
  const ExpressionDetailScreen({super.key, this.expression});
  final Expression? expression;

  @override
  State<ExpressionDetailScreen> createState() => _ExpressionDetailScreenState();
}

class _ExpressionDetailScreenState extends State<ExpressionDetailScreen> {
  int? _playing;

  Future<void> _play(int i) async {
    setState(() => _playing = i);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted && _playing == i) setState(() => _playing = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final e = widget.expression ?? Mock.expressions.first;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  StaggerIn(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        decoration: BoxDecoration(color: c.surfaceWarm, borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          children: [
                            Text(e.text, textAlign: TextAlign.center, style: context.text.displaySmall),
                            const SizedBox(height: 14),
                            Pressable(
                              onTap: () => _play(-1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: c.border)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.volume_up_rounded, color: c.green),
                                    const SizedBox(width: 10),
                                    Waveform(bars: 12, height: 24, active: _playing == -1, seed: 9, barWidth: 3, gap: 3),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(e.meaning, textAlign: TextAlign.center, style: context.text.bodyLarge!.copyWith(color: c.inkSoft)),
                          ],
                        ),
                      ),
                      const SectionLabel('You said'),
                      SqCard(
                        color: c.surfaceGreen,
                        borderColor: c.greenTint,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('"${e.youSaid}"', style: context.text.titleLarge!.copyWith(fontFamily: AppTheme.body, fontSize: 19)),
                            const SizedBox(height: 8),
                            Text('${e.scene} · ${e.theme}', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                      const SectionLabel('Other ways to use it'),
                      for (final (i, ex) in e.examples.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Pressable(
                            onTap: () => _play(i),
                            child: SqCard(
                              color: c.surface,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: _playing == i ? c.green : c.surfaceGreen),
                                    child: Icon(Icons.volume_up_rounded, size: 20, color: _playing == i ? Colors.white : c.green),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ex.$1.toUpperCase(), style: context.text.labelSmall),
                                        const SizedBox(height: 2),
                                        Text(ex.$2, style: context.text.bodyLarge),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: PrimaryButton(label: 'Practise it', icon: Icons.mic_rounded, fontSize: 22, onTap: () => demoNav(context, 'Practise it (1-minute scene)')),
            ),
            Text("A one-minute scene. Doesn't move your plan.", style: context.text.bodySmall),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
