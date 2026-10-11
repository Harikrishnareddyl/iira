import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// My plan: added themes with a progress ring and status. Switch, reorder
/// (up/down) or remove (progress is kept).
class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  late List<SqTheme> _themes = [...Mock.plan];
  String _current = Mock.currentTheme.name;
  bool _editing = false;

  void _move(int i, int d) {
    final j = i + d;
    if (j < 0 || j >= _themes.length) return;
    setState(() {
      final t = _themes.removeAt(i);
      _themes.insert(j, t);
    });
  }

  void _remove(SqTheme t) {
    final i = _themes.indexOf(t);
    setState(() => _themes.remove(t));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${t.name} removed. Progress is kept if you add it back.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _themes = [..._themes]..insert(i, t)),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SqTopBar(
              title: 'My plan',
              trailing: TextButton(
                onPressed: () => setState(() => _editing = !_editing),
                child: Text(_editing ? 'Done' : 'Edit',
                    style: context.text.titleSmall!.copyWith(color: c.green)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Text('Your themes. The next scene always comes from the one you are playing.',
                      style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
                  const SizedBox(height: 14),
                  for (var i = 0; i < _themes.length; i++)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Padding(
                        key: ValueKey(_themes[i].name),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PlanTile(
                          theme: _themes[i],
                          current: _themes[i].name == _current,
                          editing: _editing,
                          onSwitch: () {
                            setState(() => _current = _themes[i].name);
                            toast(context, 'Now playing ${_themes[i].name}. You\'ll resume where you left off.');
                          },
                          onUp: i == 0 ? null : () => _move(i, -1),
                          onDown: i == _themes.length - 1 ? null : () => _move(i, 1),
                          onRemove: () => _remove(_themes[i]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  SoftButton(
                    label: 'Add a theme',
                    icon: Icons.add_rounded,
                    onTap: () => demoNav(context, 'Explore themes'),
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

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.theme,
    required this.current,
    required this.editing,
    required this.onSwitch,
    required this.onUp,
    required this.onDown,
    required this.onRemove,
  });

  final SqTheme theme;
  final bool current;
  final bool editing;
  final VoidCallback onSwitch;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final statusColor = switch (theme.status) {
      ThemeStatus.complete => c.green,
      ThemeStatus.inProgress => c.inkSoft,
      ThemeStatus.notStarted => c.inkMuted,
    };
    return Pressable(
      onTap: editing || current ? null : onSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: current ? c.surfaceGreen : c.surfaceWarm,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: current ? c.greenSoft : c.border, width: current ? 1.5 : 1),
        ),
        child: Row(
          children: [
            ProgressRing(
              value: theme.progress,
              size: 56,
              child: theme.status == ThemeStatus.complete
                  ? Icon(Icons.check_rounded, color: c.green, size: 28)
                  : Text(theme.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(theme.name, style: context.text.titleLarge!.copyWith(fontSize: 19)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(theme.status.label,
                          style: context.text.bodyMedium!.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
                      if (current) ...[
                        Text('  ·  ', style: context.text.bodySmall),
                        Text('Playing now',
                            style: context.text.bodyMedium!.copyWith(color: c.green, fontWeight: FontWeight.w800)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (editing) ...[
              _SmallIcon(Icons.keyboard_arrow_up_rounded, onUp),
              _SmallIcon(Icons.keyboard_arrow_down_rounded, onDown),
              _SmallIcon(Icons.close_rounded, onRemove, color: c.coral),
            ] else if (!current)
              Text('Switch', style: context.text.titleSmall!.copyWith(color: c.green)),
          ],
        ),
      ),
    );
  }
}

class _SmallIcon extends StatelessWidget {
  const _SmallIcon(this.icon, this.onTap, {this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, color: onTap == null ? c.border : (color ?? c.inkSoft)),
    );
  }
}
