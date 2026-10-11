import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Row of sound bars. When [active] the bars move; otherwise they are a
/// static, seeded waveform (used for recorded clips).
class Waveform extends StatefulWidget {
  const Waveform({
    super.key,
    this.bars = 9,
    this.height = 40,
    this.active = false,
    this.color,
    this.fadeColor,
    this.seed = 1,
    this.barWidth = 4,
    this.gap = 4,
    this.progress,
    this.highlight,
  });

  final int bars;
  final double height;
  final bool active;
  final Color? color;
  final Color? fadeColor;
  final int seed;
  final double barWidth;
  final double gap;

  /// 0..1 — bars before this point use [color], after use [fadeColor].
  final double? progress;

  /// Optional index range to emphasise (e.g. a stressed syllable).
  final (int, int)? highlight;

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final List<double> _base = _makeBase();

  List<double> _makeBase() {
    final r = math.Random(widget.seed);
    return List.generate(widget.bars, (i) {
      // Symmetric-ish envelope so it reads as speech.
      final mid = (widget.bars - 1) / 2;
      final env = 1 - (i - mid).abs() / (mid + 1) * 0.6;
      return (0.25 + r.nextDouble() * 0.75) * env;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(Waveform old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat();
    if (!widget.active && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.sq.green;
    final fade = widget.fadeColor ?? context.sq.greenSoft;
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.bars; i++) ...[
                if (i > 0) SizedBox(width: widget.gap),
                _bar(i, color, fade),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int i, Color color, Color fade) {
    var h = _base[i];
    if (widget.active) {
      final p = math.sin((_c.value + i * 0.17) * 2 * math.pi);
      final q = math.sin((_c.value * 2 + i * 0.41) * 2 * math.pi);
      h = (h * (0.55 + 0.3 * p + 0.15 * q)).clamp(0.12, 1.0);
    }
    final progress = widget.progress;
    var col = progress == null || i / widget.bars <= progress ? color : fade;
    final hl = widget.highlight;
    if (hl != null) {
      col = i >= hl.$1 && i <= hl.$2 ? context.sq.amber : col;
    }
    return Container(
      width: widget.barWidth,
      height: math.max(widget.barWidth, widget.height * h),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(widget.barWidth),
      ),
    );
  }
}

enum MicMode { hold, tap }

/// The big mic button. Hold-to-speak by default: press shows rings and a
/// moving waveform, release "sends". In tap mode one tap starts/stops.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.onSend,
    this.mode = MicMode.hold,
    this.idleLabel,
    this.size = 112,
    this.showSideWaves = true,
    this.enabled = true,
    this.onStart,
  });

  final VoidCallback onSend;
  final VoidCallback? onStart;
  final MicMode mode;
  final String? idleLabel;
  final double size;
  final bool showSideWaves;
  final bool enabled;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  bool _listening = false;
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _start() {
    if (!widget.enabled || _listening) return;
    HapticFeedback.lightImpact();
    setState(() => _listening = true);
    widget.onStart?.call();
  }

  void _stop() {
    if (!_listening) return;
    setState(() => _listening = false);
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    final s = widget.size;
    final label = _listening
        ? (widget.mode == MicMode.hold ? 'Release to send' : 'Listening… tap to send')
        : (widget.idleLabel ??
            (widget.mode == MicMode.hold ? 'Hold to speak' : 'Tap to speak'));

    final button = AnimatedBuilder(
      animation: _ring,
      builder: (context, _) {
        return SizedBox.square(
          dimension: s * 1.45,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_listening)
                for (final k in [0.0, 0.5])
                  _Ring(
                    t: (_ring.value + k) % 1,
                    size: s,
                    color: c.green,
                  ),
              // Static soft halo.
              Container(
                width: s * 1.16,
                height: s * 1.16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.greenTint.withValues(alpha: widget.enabled ? 1 : 0.5),
                ),
              ),
              AnimatedScale(
                scale: _listening ? 1.06 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.enabled
                        ? (_listening ? c.greenDeep : c.green)
                        : c.greenSoft,
                    boxShadow: [
                      BoxShadow(
                        color: c.green.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _listening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: s * 0.46,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    final gesture = widget.mode == MicMode.hold
        ? GestureDetector(
            onTapDown: (_) => _start(),
            onTapUp: (_) => _stop(),
            onTapCancel: _stop,
            onLongPressEnd: (_) => _stop(),
            child: button,
          )
        : GestureDetector(
            onTap: () => _listening ? _stop() : _start(),
            child: button,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showSideWaves)
              Waveform(
                bars: 5,
                height: s * 0.5,
                active: _listening,
                seed: 3,
                color: _listening ? c.green : c.greenSoft,
              ),
            const SizedBox(width: 6),
            gesture,
            const SizedBox(width: 6),
            if (widget.showSideWaves)
              Waveform(
                bars: 5,
                height: s * 0.5,
                active: _listening,
                seed: 7,
                color: _listening ? c.green : c.greenSoft,
              ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: context.text.titleMedium!.copyWith(
              color: _listening ? c.ink : c.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.t, required this.size, required this.color});
  final double t;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final d = size * (1 + 0.45 * t);
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.22 * (1 - t)),
      ),
    );
  }
}

/// Small round "voice" badge used next to learner bubbles.
class VoiceBadge extends StatelessWidget {
  const VoiceBadge({super.key, this.size = 44, this.filled = true});
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? c.greenSoft : c.surface,
        border: Border.all(color: c.greenSoft, width: 2),
      ),
      child: Icon(Icons.graphic_eq_rounded,
          color: filled ? Colors.white : c.green, size: size * 0.55),
    );
  }
}

/// Simulated "speech": types out a transcript so the learner can see how
/// they were heard (live caption).
class LiveCaption extends StatefulWidget {
  const LiveCaption({super.key, required this.text, this.style, this.onDone});
  final String text;
  final TextStyle? style;
  final VoidCallback? onDone;

  @override
  State<LiveCaption> createState() => _LiveCaptionState();
}

class _LiveCaptionState extends State<LiveCaption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 28 * widget.text.length + 200),
  )
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone?.call();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final n = (widget.text.length * _c.value).round();
        return Text(widget.text.substring(0, n), style: widget.style);
      },
    );
  }
}
