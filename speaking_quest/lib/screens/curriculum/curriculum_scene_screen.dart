import 'package:flutter/material.dart';

import '../../data/curriculum/curriculum.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/level.dart';
import 'curriculum_widgets.dart';

/// One scenario template: goal, setting, character, hidden obstacle, targets,
/// rubric, the type-specific material, twists (variations), power-ups and
/// how the engine re-queues it.
class CurriculumSceneScreen extends StatelessWidget {
  const CurriculumSceneScreen({super.key, required this.theme, required this.scene});
  final CurriculumTheme theme;
  final SceneTemplate scene;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final s = scene;
    final info = levelTypeInfo[s.type]!;
    final targetItems = [
      for (final name in s.targets)
        theme.targets.firstWhere((t) => t.text == name,
            orElse: () => TargetItem(name, kind: TargetKind.expression, band: s.band, meaning: '', example: '', types: const [])),
    ];
    // Weak items come back in a different level type first.
    final otherTypes = {
      for (final t in targetItems) ...t.types,
    }..removeWhere((t) => t == s.type || t == LevelType.boss);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SqTopBar(title: theme.name),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      TypeBadge(s.type),
                      if (s.type == LevelType.boss) const LevelTag('Theme finale'),
                      BandChip(s.band.label),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(s.title, textAlign: TextAlign.center, style: context.text.displaySmall),
                  const SizedBox(height: 10),
                  Center(child: GoalPill(goal: s.goal)),
                  const SizedBox(height: 18),
                  SqCard(
                    color: c.surface,
                    child: Column(
                      children: [
                        InfoBlock('Setting', s.setting, icon: Icons.place_outlined),
                        InfoBlock('Character', s.character, icon: Icons.person_outline_rounded),
                        InfoBlock('Hidden obstacle', s.obstacle, icon: Icons.visibility_off_outlined),
                        InfoBlock('Success rubric', s.rubric, icon: Icons.rule_rounded),
                      ],
                    ),
                  ),
                  const SectionLabel('Target items'),
                  for (final t in targetItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SqCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(child: Text(t.text, style: context.text.titleMedium)),
                              Text(t.kind.label, style: context.text.labelMedium),
                            ]),
                            if (t.meaning.isNotEmpty) Text(t.meaning, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                          ],
                        ),
                      ),
                    ),
                  SectionLabel(_materialTitle(s.type)),
                  _Material(scene: s),
                  const SectionLabel('New twists · variations'),
                  for (final t in s.twists)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SqCard(
                        color: c.lavenderSoft,
                        borderColor: Colors.transparent,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.shuffle_rounded, color: c.lavender, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(t, style: context.text.bodyMedium)),
                          ],
                        ),
                      ),
                    ),
                  const SectionLabel('Power-ups (all free, counted)'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final p in info.powerUps)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: c.surfaceWarm, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.border)),
                          child: Text('${p.name} · ${p.weight}', style: context.text.labelMedium!.copyWith(color: c.inkSoft)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Win: ${info.win} (${info.rounds})', style: context.text.bodySmall),
                  const SectionLabel('If an item stays weak'),
                  SqCard(
                    color: c.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Rule(color: c.green, title: 'Strong (85+)', body: 'Marked learned. Light review about 30, 80 and 200 scenes later.'),
                        _Rule(color: c.amber, title: 'Shaky (65–84)', body: 'A new variant 5–10 scenes later, same theme, same type (${s.type.label}).'),
                        _Rule(
                          color: c.coral,
                          title: 'Weak (under 65)',
                          body: 'A simpler variant 2–4 scenes later in a different type'
                              '${otherTypes.isEmpty ? '' : ': ${otherTypes.map((t) => t.label).join(', ')}'}.',
                        ),
                        _Rule(color: c.inkMuted, title: 'Finale gate', body: 'Every item still shaky or weak is pulled into "${theme.finale.title}".'),
                      ],
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

  String _materialTitle(LevelType t) => switch (t) {
        LevelType.conversation || LevelType.boss => 'Character lines',
        LevelType.listening => 'Clip',
        LevelType.thinkInEnglish => 'Picture & prompts',
        LevelType.quickReply => 'Questions',
        LevelType.pronunciation => 'Lines to repeat',
        LevelType.soundNatural => 'Sentences to fix',
      };
}

class _Rule extends StatelessWidget {
  const _Rule({required this.color, required this.title, required this.body});
  final Color color;
  final String title, body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(margin: const EdgeInsets.only(top: 6), width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: '$title  ', style: const TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(text: body),
              ]), style: context.text.bodyMedium),
            ),
          ],
        ),
      );
}

class _Material extends StatelessWidget {
  const _Material({required this.scene});
  final SceneTemplate scene;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final m = scene.material;
    String at(int i) => i < m.length ? m[i] : '';
    switch (scene.type) {
      case LevelType.conversation:
      case LevelType.boss:
        return Column(
          children: [
            for (final (i, line) in m.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChatBubble(
                  text: line,
                  note: i == 0 ? Text('Opening line', style: context.text.labelSmall) : null,
                ),
              ),
          ],
        );
      case LevelType.listening:
        return SqCard(
          color: c.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoBlock('Transcript', at(0), icon: Icons.headphones_rounded),
              InfoBlock('Asked after the clip', at(1), icon: Icons.help_outline_rounded),
              InfoBlock('Expected spoken answer', at(2), icon: Icons.mic_none_rounded),
            ],
          ),
        );
      case LevelType.thinkInEnglish:
        return SqCard(
          color: c.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoBlock('Picture', at(0), icon: Icons.image_outlined),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final chip in m.skip(1).take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: c.surfaceWarm, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
                    child: Text(chip, style: context.text.titleSmall),
                  ),
              ]),
              const SizedBox(height: 12),
              InfoBlock('Example', at(4), icon: Icons.format_quote_rounded),
            ],
          ),
        );
      case LevelType.quickReply:
        return Column(
          children: [
            for (final (i, q) in m.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SqCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? c.green : c.greenTint),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(q, style: context.text.titleMedium)),
                  ]),
                ),
              ),
          ],
        );
      case LevelType.pronunciation:
        return Column(
          children: [
            for (final line in m)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SqCard(
                  padding: const EdgeInsets.all(14),
                  child: _StressLine(line),
                ),
              ),
          ],
        );
      case LevelType.soundNatural:
        return Column(
          children: [
            for (final item in m)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SqCard(
                  color: c.surface,
                  padding: const EdgeInsets.all(14),
                  child: Builder(builder: (context) {
                    final parts = item.split('→');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(parts.first.trim(), style: context.text.bodyLarge!.copyWith(color: c.coral, decoration: TextDecoration.lineThrough, decorationColor: c.coral)),
                        if (parts.length > 1) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.arrow_forward_rounded, size: 18, color: c.green),
                            const SizedBox(width: 6),
                            Expanded(child: Text(parts.sublist(1).join('→').trim(), style: context.text.titleMedium!.copyWith(color: c.greenDeep))),
                          ]),
                        ],
                      ],
                    );
                  }),
                ),
              ),
          ],
        );
    }
  }
}

/// Renders a pronunciation line, colouring the CAPS (stressed) word.
class _StressLine extends StatelessWidget {
  const _StressLine(this.line);
  final String line;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final words = line.split(' ');
    bool isStress(String w) {
      final letters = w.replaceAll(RegExp(r'[^A-Za-z]'), '');
      return letters.length > 1 && letters == letters.toUpperCase() && letters != 'I';
    }

    return Text.rich(
      TextSpan(children: [
        for (final (i, w) in words.indexed)
          TextSpan(
            text: i == words.length - 1 ? w : '$w ',
            style: isStress(w) ? TextStyle(color: c.green, fontWeight: FontWeight.w900) : null,
          ),
      ]),
      style: context.text.titleLarge!.copyWith(fontSize: 19),
    );
  }
}
