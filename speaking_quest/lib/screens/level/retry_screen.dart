import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';
import '../../widgets/voice.dart';

/// Soft failure: the companion says it was close, shows the expressions that
/// would have helped (tap to hear) and offers Retry. No lives, no coin loss.
class RetryScreen extends StatefulWidget {
  const RetryScreen({super.key});

  @override
  State<RetryScreen> createState() => _RetryScreenState();
}

class _RetryScreenState extends State<RetryScreen> {
  int? _playing;
  bool _flagged = false;

  Future<void> _play(int i) async {
    setState(() => _playing = i);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted && _playing == i) setState(() => _playing = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    const lines = ['I asked for oat milk.', 'Could you remake it?', 'Sorry, this isn\'t what I ordered.'];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggerIn(
                  children: [
                    Text('One more try', textAlign: TextAlign.center, style: context.text.displayMedium),
                    const SizedBox(height: 6),
                    const Center(child: CompanionMark(size: 150, mood: CompanionMood.dim)),
                    Text('That was close. These would have helped:',
                        textAlign: TextAlign.center, style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: c.amberSoft, borderRadius: BorderRadius.circular(18)),
                      child: Text('Ask for a new drink.', textAlign: TextAlign.center, style: context.text.titleLarge!.copyWith(fontFamily: AppTheme.body, fontSize: 21)),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < lines.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Pressable(
                          onTap: () => _play(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(18)),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.green),
                                  child: Icon(_playing == i ? Icons.volume_up_rounded : Icons.play_arrow_rounded, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(lines[i], style: context.text.titleMedium)),
                                Waveform(bars: 7, height: 30, active: _playing == i, seed: i + 4, barWidth: 3, gap: 3, color: c.greenSoft),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Center(
                      child: TextButton.icon(
                        onPressed: _flagged
                            ? null
                            : () {
                                setState(() => _flagged = true);
                                toast(context, 'Thanks. We\'ll review this attempt.');
                              },
                        icon: Icon(_flagged ? Icons.check_rounded : Icons.outlined_flag_rounded, color: c.inkMuted, size: 18),
                        label: Text(_flagged ? 'Sent for review' : 'I think I got this right',
                            style: context.text.labelLarge!.copyWith(color: c.inkMuted)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: PrimaryButton(label: 'Retry', icon: Icons.refresh_rounded, height: 70, fontSize: 30, onTap: () => demoNav(context, 'Conversation (retry)')),
            ),
            IconButton(
              onPressed: () => demoNav(context, 'Home'),
              icon: Icon(Icons.home_outlined, color: c.inkSoft, size: 34),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
