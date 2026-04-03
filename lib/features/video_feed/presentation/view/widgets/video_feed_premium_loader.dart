import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class VideoFeedPremiumLoader extends StatefulWidget {
  const VideoFeedPremiumLoader({super.key});

  @override
  State<VideoFeedPremiumLoader> createState() => _VideoFeedPremiumLoaderState();
}

class _VideoFeedPremiumLoaderState extends State<VideoFeedPremiumLoader>
    with TickerProviderStateMixin {
  // Diagonal shimmer sweep (slow, luxurious)
  late AnimationController _shimmerCtrl;
  // Radial glow breathing behind character
  late AnimationController _glowCtrl;
  // Frame image crossfade
  late AnimationController _frameCtrl;
  // Floating particles drift
  late AnimationController _particleCtrl;

  int _currentFrame = 0;
  int _nextFrame = 1;
  bool _transitioning = false;

  static const _frames = [
    'assets/png/frame1.png',
    'assets/png/frame2.png',
    'assets/png/frame3.png',
    'assets/png/frame4.png',
  ];

  static const _messages = [
    'Preparing your experience ✨',
    'Loading something special...',
    'Almost there 👀',
    'Just a moment more ⚡',
  ];

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _frameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _frameCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _currentFrame = _nextFrame;
          _transitioning = false;
        });
        _frameCtrl.reset();
        Future.delayed(const Duration(milliseconds: 1800), _triggerNextFrame);
      }
    });
    Future.delayed(const Duration(milliseconds: 2200), _triggerNextFrame);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  void _triggerNextFrame() {
    if (!mounted || _transitioning) return;
    _nextFrame = (_currentFrame + 1) % _frames.length;
    _transitioning = true;
    _frameCtrl.forward();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _glowCtrl.dispose();
    _frameCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msgIndex = _currentFrame % _messages.length;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _shimmerCtrl, _glowCtrl, _frameCtrl, _particleCtrl,
      ]),
      builder: (context, _) {
        final shimmerP = _shimmerCtrl.value;
        final glowP = _glowCtrl.value;

        return Stack(
          children: [
            // Layer 1: Rich base gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A0A10),
                      Color(0xFF110D1A),
                      Color(0xFF0F0B16),
                      Color(0xFF0A0A10),
                    ],
                    stops: [0, 0.35, 0.65, 1],
                  ),
                ),
              ),
            ),

            // Layer 2: Diagonal shimmer sweep
            Positioned.fill(
              child: CustomPaint(
                painter: _DiagonalShimmerPainter(shimmerP),
              ),
            ),

            // Layer 3: Radial glow behind character (breathing)
            Center(
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: context.sq(380),
                  height: context.sq(380),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6B3FA0).withValues(
                          alpha: 0.18 + glowP * 0.14,
                        ),
                        const Color(0xFF4A2D7A).withValues(
                          alpha: 0.10 + glowP * 0.08,
                        ),
                        const Color(0xFF2A1650).withValues(
                          alpha: 0.04 + glowP * 0.03,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.35, 0.65, 1],
                    ),
                  ),
                ),
              ),
            ),

            // Layer 4: Secondary warm glow (offset, larger)
            Center(
              child: Transform.translate(
                offset: Offset(0, 20 + glowP * 10),
                child: Container(
                  width: context.sq(300),
                  height: context.sq(300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF006E).withValues(
                          alpha: 0.06 + (1 - glowP) * 0.06,
                        ),
                        const Color(0xFFFF006E).withValues(
                          alpha: 0.02,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: Floating particles
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ParticlePainter(_particleCtrl.value),
                ),
              ),
            ),

            // Layer 6: Frame image — with radial fade
            Center(
              child: Transform.scale(
                scale: 1.0 + glowP * 0.03,
                child: SizedBox(
                  width: context.sq(260),
                  height: context.sq(260),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return RadialGradient(
                        center: Alignment.center,
                        radius: 0.6,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.45, 0.75, 1],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Current frame
                        Opacity(
                          opacity: _transitioning
                              ? (1 - Curves.easeIn.transform(
                                  _frameCtrl.value)).clamp(0.0, 1.0)
                              : 1.0,
                          child: Transform.scale(
                            scale: _transitioning
                                ? 1.0 + _frameCtrl.value * 0.08
                                : 1.0,
                            child: Image.asset(
                              _frames[_currentFrame],
                              width: context.sq(230),
                              height: context.sq(230),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Next frame
                        if (_transitioning)
                          Opacity(
                            opacity: Curves.easeOut
                                .transform(_frameCtrl.value)
                                .clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.88 +
                                  Curves.easeOutBack.transform(
                                    _frameCtrl.value) * 0.12,
                              child: Image.asset(
                                _frames[_nextFrame],
                                width: context.sq(230),
                                height: context.sq(230),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Layer 7: Vignette overlay
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFF0A0A10).withValues(alpha: 0.7),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),

            // Message text
            Positioned(
              bottom: context.h(160),
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    _messages[msgIndex],
                    key: ValueKey(msgIndex),
                    style: TextStyle(
                      color: white.withValues(alpha: 0.55),
                      fontSize: context.fontSize(13),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),

            // Running boy GIF — rides above the loading bar, synced to shimmer
            Positioned(
              left: context.w(50),
              right: context.w(50),
              bottom: context.h(52),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final gifSize = context.sq(72);
                  final boyX = shimmerP * barWidth - gifSize / 2;
                  return SizedBox(
                    height: gifSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: boyX.clamp(-gifSize / 2, barWidth - gifSize / 2),
                          bottom: 0,
                          child: Image.asset(
                            'assets/png/running_boy.gif',
                            width: gifSize,
                            height: gifSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Loading bar
            Positioned(
              left: context.w(50),
              right: context.w(50),
              bottom: context.h(44),
              child: _LoadingBar(progress: shimmerP),
            ),
          ],
        );
      },
    );
  }
}

// ── Diagonal shimmer sweep ─────────────────────────────────────────────────
// Two diagonal bands sweep from top-left to bottom-right at different speeds.
class _DiagonalShimmerPainter extends CustomPainter {
  _DiagonalShimmerPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Rotate canvas 25° for diagonal sweep
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-25 * pi / 180);
    canvas.translate(-size.width / 2, -size.height / 2);

    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    // Primary shimmer band — wide, visible
    _drawBand(
      canvas, size, diagonal,
      progress,
      bandWidth: diagonal * 0.35,
      color: const Color(0xFF6B3FA0),
      intensity: 0.14,
    );

    // Secondary shimmer band
    _drawBand(
      canvas, size, diagonal,
      (progress + 0.4) % 1.0,
      bandWidth: diagonal * 0.22,
      color: const Color(0xFFFF006E),
      intensity: 0.08,
    );

    // Tertiary shimmer band — warm accent
    _drawBand(
      canvas, size, diagonal,
      (progress + 0.7) % 1.0,
      bandWidth: diagonal * 0.18,
      color: const Color(0xFF9B6DFF),
      intensity: 0.06,
    );

    canvas.restore();
  }

  void _drawBand(
    Canvas canvas, Size size, double diagonal,
    double p, {
    required double bandWidth,
    required Color color,
    required double intensity,
  }) {
    final totalTravel = diagonal + bandWidth;
    final centerY = -bandWidth / 2 + totalTravel * p;

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, centerY - bandWidth / 2),
        Offset(0, centerY + bandWidth / 2),
        [
          Colors.transparent,
          color.withValues(alpha: intensity * 0.5),
          color.withValues(alpha: intensity),
          color.withValues(alpha: intensity * 0.5),
          Colors.transparent,
        ],
        [0, 0.2, 0.5, 0.8, 1],
      );

    canvas.drawRect(
      Rect.fromLTWH(-diagonal, centerY - bandWidth / 2, diagonal * 3, bandWidth),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DiagonalShimmerPainter old) =>
      old.progress != progress;
}

// ── Floating particles ─────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(77);
    // Soft glowing dots that drift upward
    for (var i = 0; i < 25; i++) {
      final baseX = rng.nextDouble();
      final baseY = rng.nextDouble();
      final speed = 0.12 + rng.nextDouble() * 0.3;
      final phase = rng.nextDouble() * 2 * pi;
      final radius = 1.2 + rng.nextDouble() * 3.0;

      // Drift upward + slight horizontal sway
      final y = (baseY - progress * speed) % 1.0;
      final x = baseX + sin(progress * 2 * pi + phase) * 0.02;

      // Fade based on vertical position (fade at edges)
      final fadeY = y < 0.1 ? y / 0.1 : (y > 0.9 ? (1 - y) / 0.1 : 1.0);
      final opacity = (0.15 + rng.nextDouble() * 0.25) * fadeY;

      // Alternate between purple and warm tones
      final color = i.isEven
          ? const Color(0xFF9B6DFF).withValues(alpha: opacity)
          : const Color(0xFFFF80AB).withValues(alpha: opacity * 0.7);

      final paint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}

// ── Loading bar ───────────────────────────────────────────────────────────
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: ClipRRect(
        borderRadius: context.radiusAll(2),
        child: CustomPaint(
          size: Size.infinite,
          painter: _LoadingBarPainter(progress),
        ),
      ),
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  _LoadingBarPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle track
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: 0.04),
    );
    // Gradient segment
    final segmentWidth = size.width * 0.4;
    final totalTravel = size.width + segmentWidth;
    final startX = -segmentWidth + totalTravel * progress;
    final gradient = ui.Gradient.linear(
      Offset(startX, 0),
      Offset(startX + segmentWidth, 0),
      [
        Colors.transparent,
        const Color(0xFF6B3FA0),
        const Color(0xFFFF006E),
        Colors.transparent,
      ],
      [0, 0.3, 0.7, 1],
    );
    canvas.drawRect(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadingBarPainter old) =>
      old.progress != progress;
}
