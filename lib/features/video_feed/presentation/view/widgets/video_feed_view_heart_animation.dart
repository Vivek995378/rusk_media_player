import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';

class VideoFeedViewHeartAnimation extends StatefulWidget {
  const VideoFeedViewHeartAnimation({super.key});

  @override
  State<VideoFeedViewHeartAnimation> createState() =>
      VideoFeedViewHeartAnimationState();
}

class VideoFeedViewHeartAnimationState
    extends State<VideoFeedViewHeartAnimation>
    with TickerProviderStateMixin {
  final List<_BurstEntry> _bursts = [];
  int _counter = 0;

  void trigger(Offset position) {
    HapticFeedback.lightImpact();
    final id = _counter++;
    final ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.heartAnimation,
    );
    final entry = _BurstEntry(
      id: id,
      position: position,
      controller: ctrl,
    );
    setState(() => _bursts.add(entry));
    ctrl
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ctrl.dispose();
          if (mounted) {
            setState(() {
              _bursts.removeWhere((b) => b.id == id);
            });
          }
        }
      });
  }

  @override
  void dispose() {
    for (final b in _bursts) {
      b.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bursts.isEmpty) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: _bursts
            .map(
              (b) => _HeartBurst(
                key: ValueKey(b.id),
                origin: b.position,
                controller: b.controller,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _BurstEntry {
  _BurstEntry({
    required this.id,
    required this.position,
    required this.controller,
  });
  final int id;
  final Offset position;
  final AnimationController controller;
}

class _HeartBurst extends StatefulWidget {
  const _HeartBurst({
    required this.origin,
    required this.controller,
    super.key,
  });
  final Offset origin;
  final AnimationController controller;

  @override
  State<_HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<_HeartBurst> {
  final _rng = Random();

  late final Animation<double> _primaryScale;
  late final Animation<double> _primaryOpacity;
  late final Animation<double> _primaryDy;

  late final List<_Satellite> _satellites;

  static const _palette = [
    heartRed,
    heartPink,
    heartLight,
    heartSoft,
    heartFuchsia,
  ];

  @override
  void initState() {
    super.initState();
    final ctrl = widget.controller;

    _primaryScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.3).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 50,
      ),
    ]).animate(ctrl);

    _primaryOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 74,
      ),
    ]).animate(ctrl);

    _primaryDy = Tween<double>(begin: 0, end: -90).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Curves.easeOut,
      ),
    );

    _satellites = List.generate(4, (i) {
      return _Satellite(
        size: _rng.nextDouble() * AppSizes.heartSatelliteMinSize +
            AppSizes.heartSatelliteMinSize,
        color: _palette[_rng.nextInt(_palette.length)].withValues(alpha: 0.9),
        dxEnd: (_rng.nextDouble() - 0.5) * 100,
        dyEnd: -(_rng.nextDouble() * 80 + 60),
        delay: _rng.nextDouble() * 0.22,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            _buildPrimary(),
            ..._satellites.map(_buildSatellite),
          ],
        );
      },
    );
  }

  Widget _buildPrimary() {
    const half = AppSizes.heartPrimarySize / 2;
    return Positioned(
      left: widget.origin.dx - half,
      top: widget.origin.dy - half + _primaryDy.value,
      child: Opacity(
        opacity: _primaryOpacity.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: _primaryScale.value.clamp(0.0, 2.0),
          child: const Icon(
            Icons.favorite,
            color: heartRed,
            size: AppSizes.heartPrimarySize,
            shadows: [
              Shadow(
                color: Color(0x55FF1744),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSatellite(_Satellite s) {
    final t = ((widget.controller.value - s.delay) / (1.0 - s.delay))
        .clamp(0.0, 1.0);

    final double scale;
    if (t < 0.40) {
      scale = 0.4 + Curves.easeOut.transform(t / 0.40) * 0.8;
    } else if (t < 0.60) {
      scale = 1.2 - Curves.easeOutCubic.transform((t - 0.40) / 0.20) * 0.2;
    } else {
      scale = 1;
    }

    final opacity = t < 0.26
        ? 1.0
        : (1.0 - Curves.easeIn.transform((t - 0.26) / 0.74)).clamp(0.0, 1.0);

    final dy = Curves.easeOut.transform(t) * s.dyEnd;
    final dx = Curves.easeInOut.transform(t) * s.dxEnd;
    final half = s.size / 2;

    return Positioned(
      left: widget.origin.dx - half + dx,
      top: widget.origin.dy - half + dy,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale.clamp(0.0, 2.0),
          child: Icon(
            Icons.favorite,
            color: s.color,
            size: s.size,
          ),
        ),
      ),
    );
  }
}

class _Satellite {
  const _Satellite({
    required this.size,
    required this.color,
    required this.dxEnd,
    required this.dyEnd,
    required this.delay,
  });
  final double size;
  final Color color;
  final double dxEnd;
  final double dyEnd;
  final double delay;
}
