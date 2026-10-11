import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';

/// Out of free sessions: Free talk and Make your own share 3 free sessions a
/// day; another one costs 30 coins. Power-ups and the plan are never paid.
class SessionLimitScreen extends StatefulWidget {
  const SessionLimitScreen({super.key});

  @override
  State<SessionLimitScreen> createState() => _SessionLimitScreenState();
}

class _SessionLimitScreenState extends State<SessionLimitScreen> {
  int _coins = Learner.coins;
  bool _bought = false;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SqTopBar(trailing: Padding(padding: const EdgeInsets.only(right: 8), child: Center(child: _CoinCount(_coins)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CompanionMark(size: 130, mood: CompanionMood.rest),
                    const SizedBox(height: 10),
                    Text(_bought ? 'One more chat' : 'Free chats used for today',
                        textAlign: TextAlign.center, style: context.text.displaySmall),
                    const SizedBox(height: 10),
                    Text(
                      _bought
                          ? 'Enjoy it. Free chats reset tomorrow.'
                          : 'Free talk and Make a scene share 3 free sessions a day. They reset tomorrow.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge!.copyWith(color: c.inkMuted),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 40,
                            height: 8,
                            decoration: BoxDecoration(color: c.greenSoft, borderRadius: BorderRadius.circular(4)),
                          ),
                        if (_bought)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            builder: (context, v, _) => Transform.scale(
                              scale: v,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: 40,
                                height: 8,
                                decoration: BoxDecoration(color: c.amber, borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SqCard(
                      color: c.surface,
                      child: Text('Plan scenes, Try again and power-ups are always free.',
                          textAlign: TextAlign.center, style: context.text.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _bought
                  ? PrimaryButton(label: 'Start chat', icon: Icons.play_arrow_rounded, onTap: () => demoNav(context, 'Free talk'))
                  : Pressable(
                      onTap: () => setState(() {
                        _coins -= 30;
                        _bought = true;
                      }),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: c.green,
                          borderRadius: BorderRadius.circular(24),
                          border: Border(bottom: BorderSide(color: c.greenDeep, width: 3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Use', style: context.text.titleLarge!.copyWith(color: Colors.white, fontSize: 22)),
                            const SizedBox(width: 10),
                            const CoinIcon(size: 28),
                            const SizedBox(width: 6),
                            Text('30', style: context.text.titleLarge!.copyWith(color: Colors.white, fontSize: 22)),
                          ],
                        ),
                      ),
                    ),
            ),
            TextButton(
              onPressed: () => demoNav(context, 'Free play'),
              child: Text('Maybe tomorrow', style: context.text.labelLarge!.copyWith(color: c.inkMuted)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CoinCount extends StatelessWidget {
  const _CoinCount(this.coins);
  final int coins;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        const CoinIcon(size: 20),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text('$coins', key: ValueKey(coins), style: context.text.labelLarge),
        ),
      ]);
}
