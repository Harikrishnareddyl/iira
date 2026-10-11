import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';
import 'voice.dart';

/// Shared frame for every level type: pause, title, a thin in-level progress
/// bar and the single goal.
class LevelScaffold extends StatelessWidget {
  const LevelScaffold({
    super.key,
    required this.title,
    required this.body,
    this.goal,
    this.progress,
    this.goalTrailing,
    this.tag,
    this.headerTrailing,
  });

  final String title;
  final String? goal;
  final double? progress;
  final Widget body;
  final Widget? goalTrailing;
  final String? tag;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Pause',
                    onPressed: () => showPauseSheet(context),
                    icon: Icon(Icons.pause_rounded, color: c.ink, size: 34),
                  ),
                  const SizedBox(width: 6),
                  if (progress != null)
                    Expanded(
                      child: ThemeBar(
                        value: progress!,
                        height: 9,
                        duration: const Duration(milliseconds: 500),
                      ),
                    )
                  else
                    const Spacer(),
                  if (headerTrailing != null) ...[
                    const SizedBox(width: 12),
                    headerTrailing!,
                  ] else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            if (tag != null) ...[
              const SizedBox(height: 6),
              LevelTag(tag!),
            ],
            const SizedBox(height: 6),
            Text(title,
                style: context.text.displaySmall!.copyWith(fontSize: 30),
                textAlign: TextAlign.center),
            if (goal != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GoalPill(goal: goal!, trailing: goalTrailing),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class LevelTag extends StatelessWidget {
  const LevelTag(this.text, {super.key, this.color, this.textColor});
  final String text;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? c.surfaceGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: context.text.labelMedium!.copyWith(
              color: textColor ?? c.greenDeep, fontWeight: FontWeight.w800)),
    );
  }
}

class PowerUp {
  const PowerUp(this.label, {this.icon, this.emoji, this.color, this.weight = 0.05});
  final String label;
  final IconData? icon;
  final String? emoji;
  final Color? color;
  final double weight; // help weight used in scoring
}

/// Unlimited power-ups. Each tap is counted (shapes stars), never blocked.
class PowerUpRow extends StatelessWidget {
  const PowerUpRow({
    super.key,
    required this.items,
    required this.onUse,
    this.counts = const {},
    this.height = 92,
  });

  final List<PowerUp> items;
  final void Function(PowerUp) onUse;
  final Map<String, int> counts;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: PowerUpTile(
              item: items[i],
              count: counts[items[i].label] ?? 0,
              onTap: () => onUse(items[i]),
              height: height,
            ),
          ),
        ],
      ],
    );
  }
}

class PowerUpTile extends StatefulWidget {
  const PowerUpTile({
    super.key,
    required this.item,
    required this.onTap,
    this.count = 0,
    this.height = 92,
  });

  final PowerUp item;
  final VoidCallback onTap;
  final int count;
  final double height;

  @override
  State<PowerUpTile> createState() => _PowerUpTileState();
}

class _PowerUpTileState extends State<PowerUpTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final used = widget.count > 0;
    final compact = widget.height < 72;
    return Pressable(
      onTap: () {
        _bounce.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        decoration: BoxDecoration(
          color: used ? c.amberSoft : c.surfaceWarm,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: used ? c.amber.withValues(alpha: 0.5) : c.border),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _bounce,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                          0, -8 * Curves.easeOut.transform(1 - (2 * _bounce.value - 1).abs())),
                      child: child,
                    ),
                    child: widget.item.emoji != null
                        ? Text(widget.item.emoji!,
                            style: TextStyle(fontSize: compact ? 20 : 28, height: 1.15))
                        : Icon(widget.item.icon,
                            size: compact ? 24 : 32, color: widget.item.color ?? c.inkSoft),
                  ),
                  SizedBox(height: compact ? 2 : 6),
                  Text(widget.item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium!
                          .copyWith(color: c.inkSoft, fontSize: 12.5)),
                ],
              ),
            ),
            if (used)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: c.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('×${widget.count}',
                      style: context.text.labelSmall!
                          .copyWith(color: Colors.white, fontSize: 10.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chat bubble. Partner bubbles are neutral; learner bubbles are green with a
/// voice badge.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    this.fromLearner = false,
    this.big = false,
    this.child,
    this.note,
  });

  final String text;
  final bool fromLearner;
  final bool big;
  final Widget? child;
  final Widget? note;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final style = (big ? context.text.titleLarge! : context.text.bodyLarge!)
        .copyWith(fontWeight: big ? FontWeight.w700 : FontWeight.w600,
            fontFamily: AppTheme.body, fontSize: big ? 22 : 18);
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: fromLearner ? c.surfaceGreen : c.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: Radius.circular(fromLearner ? 22 : 6),
          bottomRight: Radius.circular(fromLearner ? 6 : 22),
        ),
      ),
      child: child ?? Text(text, style: style),
    );
    return Column(
      crossAxisAlignment:
          fromLearner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              fromLearner ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: bubble),
            if (fromLearner) ...[
              const SizedBox(width: 8),
              const VoiceBadge(size: 40),
            ],
          ],
        ),
        if (note != null) Padding(padding: const EdgeInsets.only(top: 6), child: note),
      ],
    );
  }
}

/// Amber-lit hint card ("💡 Could you remake it?").
class HintCard extends StatelessWidget {
  const HintCard({super.key, required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.amberSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.lightbulb_rounded, color: c.amber, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: context.text.bodyLarge!.copyWith(color: c.inkSoft)),
          ),
        ],
      ),
    );
  }
}

/// Pause menu (bottom sheet) shared by all levels.
Future<void> showPauseSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (ctx) => const PauseSheetBody(),
  );
}

class PauseSheetBody extends StatefulWidget {
  const PauseSheetBody({super.key});

  @override
  State<PauseSheetBody> createState() => _PauseSheetBodyState();
}

class _PauseSheetBodyState extends State<PauseSheetBody> {
  bool quiet = false;
  bool captions = true;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Paused', style: context.text.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Take a breath. Your progress in this scene is kept.',
                textAlign: TextAlign.center, style: context.text.bodyMedium!.copyWith(color: c.inkMuted)),
            const SizedBox(height: 16),
            SwitchListTile(
              value: quiet,
              onChanged: (v) => setState(() => quiet = v),
              title: Text('Quiet mode', style: context.text.titleMedium),
              subtitle: Text('Fewer speaking-only moments this session',
                  style: context.text.bodySmall),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: captions,
              onChanged: (v) => setState(() => captions = v),
              title: Text('Live captions', style: context.text.titleMedium),
              subtitle: Text('See how you were heard', style: context.text.bodySmall),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Resume',
              icon: Icons.play_arrow_rounded,
              fontSize: 20,
              height: 56,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            SoftButton(
              label: 'Restart scene',
              icon: Icons.refresh_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.maybePop(context);
              },
              child: Text('Leave scene',
                  style: context.text.titleMedium!.copyWith(color: c.inkMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
