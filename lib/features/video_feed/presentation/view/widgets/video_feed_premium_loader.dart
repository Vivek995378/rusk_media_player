import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class VideoFeedPremiumLoader extends StatefulWidget {
  const VideoFeedPremiumLoader({super.key});

  @override
  State<VideoFeedPremiumLoader> createState() => _VideoFeedPremiumLoaderState();
}

class _VideoFeedPremiumLoaderState extends State<VideoFeedPremiumLoader>
    with TickerProviderStateMixin {
  late AnimationController _mainController;

  final List<String> messages = [
    'Preparing your experience ✨',
    'Buffering magic...',
    'Almost there 👀',
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, _) {
        final progress = _mainController.value;
        return Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment(-1 + progress * 2, 0),
                    end: Alignment(1 + progress * 2, 0),
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ).createShader(rect);
                },
                child: const ColoredBox(color: Colors.black),
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _PremiumParticlePainter(progress),
              ),
            ),
            Center(child: _PlayButton(progress: progress)),
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.6 + 0.4 * sin(progress * pi * 2),
                  child: Text(
                    messages[(progress * messages.length).floor() %
                        messages.length],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 80,
              child: _LoadingBar(progress: progress),
            ),
          ],
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pulse = 1 + (sin(progress * pi * 2) * 0.08);
    final rotation = sin(progress * pi * 2) * 0.05;
    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: pulse,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.4),
                blurRadius: 30 + pulse * 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class _PremiumParticlePainter extends CustomPainter {
  _PremiumParticlePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    for (var layer = 0; layer < 3; layer++) {
      final depth = 0.5 + layer * 0.3;
      final opacityBase = 0.05 + layer * 0.05;
      for (var i = 0; i < 10; i++) {
        final x = rng.nextDouble();
        final speed = depth * (0.2 + rng.nextDouble());
        final y = 1.0 -
            (progress * speed + x + sin(progress * pi * 2) * 0.05) % 1.0;
        final paint = Paint()
          ..color = Colors.pink.withValues(alpha: opacityBase);
        canvas.drawCircle(
          Offset(x * size.width, y * size.height),
          1.5 + layer * 1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: CustomPaint(painter: _LoadingBarPainter(progress)),
      ),
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  _LoadingBarPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final segmentWidth = size.width * 0.35;
    final startX = -segmentWidth + (size.width + segmentWidth) * progress;
    final gradient = const LinearGradient(
      colors: [Colors.transparent, Colors.pink, Colors.orange, Colors.transparent],
    ).createShader(Rect.fromLTWH(startX, 0, segmentWidth, size.height));
    canvas.drawRect(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
