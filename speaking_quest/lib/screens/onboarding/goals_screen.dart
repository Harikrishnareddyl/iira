import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Onboarding step 2: what English is for, and minutes per day.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _picked = <String>{'Work'};
  int _minutes = 10;

  static const _goals = [
    ('Work', '💼', 'Meetings, calls, small talk'),
    ('Travel', '✈️', 'Airports, hotels, getting around'),
    ('Study', '🎓', 'Seminars, projects, exams'),
    ('Daily life', '🏠', 'Shops, doctors, neighbours'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThemeBar(value: 2 / 7, from: 1 / 7, height: 8),
              const SizedBox(height: 20),
              Text('What do you need English for?', style: context.text.displaySmall),
              const SizedBox(height: 4),
              Text('Pick all that fit.', style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final g in _goals)
                    Pressable(
                      onTap: () => setState(() => _picked.contains(g.$1) ? _picked.remove(g.$1) : _picked.add(g.$1)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _picked.contains(g.$1) ? c.surfaceGreen : c.surfaceWarm,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _picked.contains(g.$1) ? c.green : c.border, width: _picked.contains(g.$1) ? 2 : 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(g.$2, style: const TextStyle(fontSize: 30)),
                                const Spacer(),
                                AnimatedScale(
                                  scale: _picked.contains(g.$1) ? 1 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.elasticOut,
                                  child: Icon(Icons.check_circle_rounded, color: c.green),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(g.$1, style: context.text.titleLarge),
                            Text(g.$3, style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text('How long a day?', style: context.text.titleLarge),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final m in [5, 10, 15, 20])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Pressable(
                          onTap: () => setState(() => _minutes = m),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 64,
                            decoration: BoxDecoration(
                              color: _minutes == m ? c.green : c.surfaceWarm,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _minutes == m ? c.green : c.border),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('$m', style: context.text.titleLarge!.copyWith(color: _minutes == m ? Colors.white : c.ink)),
                                Text('min', style: context.text.labelMedium!.copyWith(color: _minutes == m ? Colors.white : c.inkMuted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('About ${(_minutes / 3).round()} scenes a day.', style: context.text.bodySmall),
              const Spacer(),
              PrimaryButton(
                label: 'Continue',
                trailingIcon: Icons.chevron_right_rounded,
                onTap: _picked.isEmpty ? null : () => demoNav(context, 'Placement run'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
