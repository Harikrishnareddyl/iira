import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Streak & coins: the three uses of coins — extra sessions, streak freeze
/// (hold up to 2), streak repair (within 3 days, cost rises).
class StreakCoinsScreen extends StatefulWidget {
  const StreakCoinsScreen({super.key});

  @override
  State<StreakCoinsScreen> createState() => _StreakCoinsScreenState();
}

class _StreakCoinsScreenState extends State<StreakCoinsScreen> {
  int _coins = Learner.coins;
  int _freezes = Learner.streakFreezes;
  bool _broken = false; // preview the "streak broken" state
  int _missDay = 1;

  void _spend(int n, String msg, [VoidCallback? also]) {
    if (_coins < n) {
      toast(context, 'Not enough coins yet. Play a scene to earn more.');
      return;
    }
    setState(() {
      _coins -= n;
      also?.call();
    });
    toast(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final repairCost = [40, 80, 120][_missDay - 1];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Streak & coins'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SqCard(
                          child: Column(children: [
                            Icon(_broken ? Icons.local_fire_department_outlined : Icons.local_fire_department_rounded,
                                size: 46, color: _broken ? c.inkMuted : const Color(0xFFF28C28)),
                            Text(_broken ? '0' : '${Learner.streak}', style: context.text.displaySmall),
                            Text('day streak', style: context.text.bodySmall),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SqCard(
                          child: Column(children: [
                            const CoinIcon(size: 46),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text('$_coins', key: ValueKey(_coins), style: context.text.displaySmall),
                            ),
                            Text('coins', style: context.text.bodySmall),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Streak counts any day you practise: plan or Free play.', textAlign: TextAlign.center, style: context.text.bodySmall),
                  if (_broken) ...[
                    const SectionLabel('Repair your streak'),
                    SqCard(
                      color: c.amberSoft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You missed a day. Bring back your 6-day streak.', style: context.text.titleMedium),
                          const SizedBox(height: 4),
                          Text('Repair within 3 days. It costs more each day.', style: context.text.bodySmall),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (final (i, cost) in [40, 80, 120].indexed)
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: i + 1 == _missDay ? c.surface : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: i + 1 == _missDay ? c.amber : c.border),
                                    ),
                                    child: Column(children: [
                                      Text('Day ${i + 1}', style: context.text.labelMedium),
                                      Text('$cost', style: context.text.titleMedium),
                                    ]),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _BuyButton(cost: repairCost, label: 'Repair streak', onTap: () => _spend(repairCost, 'Streak repaired. 6 days and counting.', () => _broken = false)),
                        ],
                      ),
                    ),
                  ],
                  const SectionLabel('Use your coins'),
                  _ShopItem(
                    icon: Icons.ac_unit_rounded,
                    iconColor: const Color(0xFF5B9BD5),
                    title: 'Streak freeze',
                    body: 'Used automatically on a missed day. Hold up to 2.',
                    extra: Row(children: [
                      for (var i = 0; i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.ac_unit_rounded, size: 20, color: i < _freezes ? const Color(0xFF5B9BD5) : c.border),
                        ),
                      Text('  $_freezes of 2 held', style: context.text.bodySmall),
                    ]),
                    cost: 50,
                    enabled: _freezes < 2,
                    onBuy: () => _spend(50, 'Streak freeze ready.', () => _freezes++),
                  ),
                  const SizedBox(height: 10),
                  _ShopItem(
                    icon: Icons.forum_rounded,
                    iconColor: c.green,
                    title: 'Extra chat session',
                    body: 'One more Free talk or Make a scene today, after the 3 free ones.',
                    cost: 30,
                    enabled: true,
                    onBuy: () => _spend(30, 'One extra session added for today.'),
                  ),
                  const SizedBox(height: 16),
                  SqCard(
                    color: c.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How you earn coins', style: context.text.titleMedium),
                        const SizedBox(height: 8),
                        for (final r in const [
                          ('Plan scene', '10 + 10 per star'),
                          ('Free play scene', '5 + 5 per star'),
                          ('Free talk', '+10'),
                          ('Theme complete', '+50'),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(children: [
                              Expanded(child: Text(r.$1, style: context.text.bodyMedium)),
                              Text(r.$2, style: context.text.bodyMedium!.copyWith(fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        const SizedBox(height: 6),
                        Text('Coins are never needed to progress. Power-ups are always free.', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _broken = !_broken;
                        _missDay = _missDay % 3 + 1;
                      }),
                      child: Text(_broken ? 'Preview: streak active' : 'Preview: streak broken', style: context.text.labelMedium),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.cost,
    required this.enabled,
    required this.onBuy,
    this.extra,
  });
  final IconData icon;
  final Color iconColor;
  final String title, body;
  final int cost;
  final bool enabled;
  final VoidCallback onBuy;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return SqCard(
      child: Row(
        children: [
          IconBlob(icon: icon, iconColor: iconColor, color: c.surface),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                Text(body, style: context.text.bodySmall),
                if (extra != null) ...[const SizedBox(height: 6), extra!],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _BuyButton(cost: cost, onTap: enabled ? onBuy : null),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.cost, this.onTap, this.label});
  final int cost;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: onTap == null ? c.surfaceMuted : c.green,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label != null) ...[
              Text(label!, style: context.text.titleSmall!.copyWith(color: Colors.white)),
              const SizedBox(width: 10),
            ],
            const CoinIcon(size: 20),
            const SizedBox(width: 4),
            Text('$cost', style: context.text.titleSmall!.copyWith(color: onTap == null ? c.inkMuted : Colors.white)),
          ],
        ),
      ),
    );
  }
}
