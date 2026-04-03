import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/robot_eyes_loader.dart';

class VideoFeedPremiumLoader extends StatefulWidget {
  const VideoFeedPremiumLoader({super.key});

  @override
  State<VideoFeedPremiumLoader> createState() => _VideoFeedPremiumLoaderState();
}

class _VideoFeedPremiumLoaderState extends State<VideoFeedPremiumLoader>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _typewriterController;
  late AnimationController _messageFadeController;

  int _currentMessageIndex = 0;
  String _displayedText = '';
  bool _isDeleting = false;

  final List<_LoaderMessage> _messages = [
    const _LoaderMessage(
      icon: '',
      text: 'Curating your feed...',
      subtext: '',
    ),
    const _LoaderMessage(
      icon: '',
      text: 'Boosting stream quality',
      subtext: '',
    ),
    const _LoaderMessage(
      icon: '',
      text: 'Personalising for you',
      subtext: '',
    ),
    const _LoaderMessage(
      icon: '',
      text: 'Almost live!',
      subtext: '',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );

    _messageFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 1.0;

    _startTypewriter();
  }

  void _startTypewriter() async {
    while (mounted) {
      final fullText = _messages[_currentMessageIndex].text;

      // Type out
      _isDeleting = false;
      for (int i = 0; i <= fullText.length; i++) {
        if (!mounted) return;
        setState(() => _displayedText = fullText.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 55));
      }

      // Pause at full text
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;

      // Fade out
      await _messageFadeController.reverse();
      if (!mounted) return;

      // Delete instantly, move to next message
      setState(() {
        _displayedText = '';
        _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
      });

      // Fade in
      await _messageFadeController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _typewriterController.dispose();
    _messageFadeController.dispose();
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

            // ── Typewriter message block ──
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _messageFadeController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon + typing text row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _messages[_currentMessageIndex].icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _displayedText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                        // Blinking cursor
                        _BlinkingCursor(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Subtext — fades in after main text is done
                    AnimatedOpacity(
                      opacity: _displayedText ==
                          _messages[_currentMessageIndex].text
                          ? 0.5
                          : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _messages[_currentMessageIndex].subtext,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _LoadingBar(progress: progress),
            ),
          ],
        );
      },
    );
  }
}

class _LoaderMessage {
  const _LoaderMessage({
    required this.icon,
    required this.text,
    required this.subtext,
  });

  final String icon;
  final String text;
  final String subtext;
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _cursorController,
      child: const Text(
        '|',
        style: TextStyle(
          color: Color(0xFFFF3D00),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
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
        child: const RobotEyesLoader(),
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
      colors: [
        Colors.transparent,
        Colors.pink,
        Colors.orange,
        Colors.transparent
      ],
    ).createShader(Rect.fromLTWH(startX, 0, segmentWidth, size.height));
    canvas.drawRect(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}