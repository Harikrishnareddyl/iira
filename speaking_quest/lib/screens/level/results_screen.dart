import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';

/// Results: stars, coins, theme bar fill animation, new expression, Continue.
/// Score details are folded away.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _details = false;
  int _key = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: StaggerIn(
            key: ValueKey(_key),
            step: const Duration(milliseconds: 120),
            children: [
              GestureDetector(
                onTap: () => setState(() => _key++),
                child: Text('Well done', textAlign: TextAlign.center, style: context.text.displayMedium),
              ),
              const SizedBox(height: 14),
              const Center(child: StarRow(stars: 3, size: 64, delay: Duration(milliseconds: 300))),
              const SizedBox(height: 4),
              const Center(child: CompanionMark(size: 150, mood: CompanionMood.pleased)),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 20, 8),
                  decoration: BoxDecoration(color: c.amberSoft, borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinIcon(size: 38),
                      const SizedBox(width: 10),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: 40),
                        duration: const Duration(milliseconds: 1200),
                        builder: (context, v, _) => Text('+$v coins', style: context.text.titleLarge!.copyWith(fontSize: 22)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SqCard(
                child: Row(
                  children: [
                    IconBlob(emoji: '☕', size: 58, color: c.amberSoft),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Café & food', style: context.text.titleLarge!.copyWith(fontSize: 21)),
                          const SizedBox(height: 8),
                          const ThemeBar(value: 0.52, from: 0.42, duration: Duration(milliseconds: 1600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SqCard(
                onTap: () => demoNav(context, 'Expression detail'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_rounded, color: c.amber, size: 22),
                        const SizedBox(width: 8),
                        Text('New expression', style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14)),
                      child: Text('Could you remake it?', textAlign: TextAlign.center, style: context.text.titleLarge!.copyWith(fontSize: 21)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => setState(() => _details = !_details),
                child: Text(_details ? 'Hide details' : 'Details', style: context.text.labelLarge!.copyWith(color: c.inkMuted)),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: _details ? const _Details() : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Continue', trailingIcon: Icons.chevron_right_rounded, onTap: () => demoNav(context, 'Home → next scene')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details();

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    const rows = [
      ('Goal reached', 1.0),
      ('Target expressions', 1.0),
      ('Little help needed', 0.85),
      ('Fluency vs. your usual', 0.8),
      ('First try', 1.0),
    ];
    return SqCard(
      color: c.surface,
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(r.$1, style: context.text.bodyMedium)),
                  SizedBox(width: 120, child: ThemeBar(value: r.$2, height: 7)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text('Used Hint once. That still counts toward 3 stars.', style: context.text.bodySmall),
        ],
      ),
    );
  }
}
