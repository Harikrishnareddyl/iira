import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/companion.dart';

/// First launch: the companion, the promise, one button.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            children: [
              const Spacer(),
              const CompanionMark(size: 190, mood: CompanionMood.pleased, showRays: true),
              const SizedBox(height: 8),
              StaggerIn(
                step: const Duration(milliseconds: 160),
                children: [
                  Text('Speak first.\nThink in English.', textAlign: TextAlign.center, style: context.text.displayMedium),
                  const SizedBox(height: 14),
                  Text('Short spoken scenes, one goal each. Press Play and talk. We take care of the rest.',
                      textAlign: TextAlign.center, style: context.text.bodyLarge!.copyWith(color: c.inkMuted)),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 6,
                    children: [
                      for (final (icon, t) in [(Icons.mic_rounded, '2–4 min'), (Icons.flag_rounded, '1 goal'), (Icons.favorite_rounded, 'No lives')])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Chip(
                            avatar: Icon(icon, size: 18, color: c.green),
                            label: Text(t),
                            backgroundColor: c.surfaceWarm,
                            side: BorderSide(color: c.border),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(label: "Let's start", trailingIcon: Icons.chevron_right_rounded, onTap: () => demoNav(context, 'Hello chat')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => demoNav(context, 'Sign in'),
                child: Text('I already have an account', style: context.text.labelLarge!.copyWith(color: c.inkMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
