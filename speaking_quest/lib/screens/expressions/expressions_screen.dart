import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'expression_detail_screen.dart';

/// Expressions tab: every unlocked expression grouped by theme, with a status
/// of Practising or Mastered (no numbers). Nothing is ever shown locked.
class ExpressionsScreen extends StatefulWidget {
  const ExpressionsScreen({super.key});

  @override
  State<ExpressionsScreen> createState() => _ExpressionsScreenState();
}

class _ExpressionsScreenState extends State<ExpressionsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final list = Mock.expressions.where((e) => switch (_filter) {
          'Practising' => !e.mastered,
          'Mastered' => e.mastered,
          _ => true,
        });
    final byTheme = <String, List<Expression>>{};
    for (final e in list) {
      byTheme.putIfAbsent(e.theme, () => []).add(e);
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Expressions'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.surfaceGreen : c.surface),
                  side: WidgetStateProperty.all(BorderSide(color: c.border)),
                  textStyle: WidgetStateProperty.all(context.text.titleSmall),
                ),
                segments: const [
                  ButtonSegment(value: 'All', label: Text('All')),
                  ButtonSegment(value: 'Practising', label: Text('Practising')),
                  ButtonSegment(value: 'Mastered', label: Text('Mastered')),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ListView(
                  key: ValueKey(_filter),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    for (final entry in byTheme.entries) ...[
                      SectionLabel(entry.key),
                      for (final e in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Pressable(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpressionDetailScreen(expression: e))),
                            child: SqCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.text, style: context.text.titleLarge!.copyWith(fontSize: 19)),
                                        const SizedBox(height: 2),
                                        Text(e.meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _Status(mastered: e.mastered),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.mastered});
  final bool mastered;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: mastered ? c.surfaceGreen : c.amberSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mastered ? Icons.verified_rounded : Icons.autorenew_rounded, size: 15, color: mastered ? c.green : const Color(0xFFB07A10)),
          const SizedBox(width: 4),
          Text(mastered ? 'Mastered' : 'Practising',
              style: context.text.labelMedium!.copyWith(color: mastered ? c.greenDeep : const Color(0xFF9A6A0B), fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
