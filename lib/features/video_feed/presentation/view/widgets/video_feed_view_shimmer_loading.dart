import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class VideoFeedViewShimmerLoading extends StatefulWidget {
  const VideoFeedViewShimmerLoading({super.key});

  @override
  State<VideoFeedViewShimmerLoading> createState() =>
      _VideoFeedViewShimmerLoadingState();
}

class _VideoFeedViewShimmerLoadingState
    extends State<VideoFeedViewShimmerLoading>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.shimmerPulse,
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: AppDurations.shimmerParticle,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shimmerController,
        _pulseController,
        _particleController,
      ]),
      builder: (context, _) {
        return ColoredBox(
          color: splashDark,
          child: Stack(
            children: [
              _GradientWaves(progress: _shimmerController.value),
              _FloatingParticles(progress: _particleController.value),
              Positioned(
                left: context.w(40),
                right: context.w(40),
                bottom: context.h(120),
                child: _LoadingBar(progress: _shimmerController.value),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: context.h(90),
                child: Center(
                  child: Opacity(
                    opacity: 0.3 + 0.3 * _pulseController.value,
                    child: const AppText(
                      AppStrings.loading,
                      style: AppTextStyle.bodySmall,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradientWaves extends StatelessWidget {
  const _GradientWaves({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WavePainter(progress: progress),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final offset = (progress + i * 0.33) % 1.0;
      final centerY = size.height * offset;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            accentPurple.withValues(alpha: 0.06 - i * 0.015),
            transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, centerY),
            radius: size.width * 0.8,
          ),
        );
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ParticlePainter(progress: progress),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    for (var i = 0; i < AppSizes.shimmerParticleCount; i++) {
      final x = rng.nextDouble();
      final speed = 0.15 + rng.nextDouble() * 0.4;
      final dotSize = 1.0 + rng.nextDouble() * 2.5;
      final opacity = 0.05 + rng.nextDouble() * 0.15;

      final y = 1.0 - (progress * speed + x) % 1.0;
      final paint = Paint()..color = accentPink.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        dotSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.radiusAll(2),
      child: SizedBox(
        height: context.h(3),
        child: CustomPaint(
          painter: _LoadingBarPainter(progress: progress),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  _LoadingBarPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = white.withValues(alpha: 0.06),
    );

    final segmentWidth = size.width * 0.35;
    final totalTravel = size.width + segmentWidth;
    final startX = -segmentWidth + totalTravel * progress;

    final gradient = const LinearGradient(
      colors: [shimmerPurpleStart, shimmerPinkCenter, shimmerOrangeEnd],
    ).createShader(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(_LoadingBarPainter old) => old.progress != progress;
}

class VideoFeedViewBufferingIndicator extends StatefulWidget {
  const VideoFeedViewBufferingIndicator({super.key});

  @override
  State<VideoFeedViewBufferingIndicator> createState() =>
      _VideoFeedViewBufferingIndicatorState();
}

class _VideoFeedViewBufferingIndicatorState
    extends State<VideoFeedViewBufferingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.bufferingBar,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: context.h(3),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _BufferingBarPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _BufferingBarPainter extends CustomPainter {
  _BufferingBarPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final segmentWidth = size.width * 0.3;
    final startX = (size.width + segmentWidth) * progress - segmentWidth;

    final gradient = const LinearGradient(
      colors: [
        Color(0x00FF006E),
        Color(0xFFFF006E),
        Color(0xFFFB5607),
        Color(0x00FB5607),
      ],
    ).createShader(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(_BufferingBarPainter old) => old.progress != progress;
}
