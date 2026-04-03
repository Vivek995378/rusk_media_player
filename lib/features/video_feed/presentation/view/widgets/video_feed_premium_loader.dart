import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/robot_eyes_loader.dart';

class VideoFeedPremiumLoader extends StatefulWidget {
  const VideoFeedPremiumLoader({super.key});

  @override
  State<VideoFeedPremiumLoader> createState() => _VideoFeedPremiumLoaderState();
}

class _VideoFeedPremiumLoaderState extends State<VideoFeedPremiumLoader>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _messageFadeController;

  int _currentMessageIndex = 0;
  String _displayedText = '';

  static const _messages = [
    AppStrings.loaderCurating,
    AppStrings.loaderBoosting,
    AppStrings.loaderPersonalising,
    AppStrings.loaderAlmostLive,
  ];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: AppDurations.loaderMain,
    )..repeat();

    _messageFadeController = AnimationController(
      vsync: this,
      duration: AppDurations.loaderMessageFade,
    )..value = 1.0;

    _startTypewriter();
  }

  Future<void> _startTypewriter() async {
    while (mounted) {
      final fullText = _messages[_currentMessageIndex];

      for (var i = 0; i <= fullText.length; i++) {
        if (!mounted) return;
        setState(() => _displayedText = fullText.substring(0, i));
        await Future<void>.delayed(AppDurations.loaderTypingDelay);
      }

      await Future<void>.delayed(AppDurations.loaderMessagePause);
      if (!mounted) return;

      await _messageFadeController.reverse();
      if (!mounted) return;

      setState(() {
        _displayedText = '';
        _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
      });

      await _messageFadeController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
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
                  color: black.withValues(alpha: 0.6),
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
                      transparent,
                      white.withValues(alpha: 0.08),
                      transparent,
                    ],
                  ).createShader(rect);
                },
                child: const ColoredBox(color: black),
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
              bottom: context.h(100),
              left: context.w(24),
              right: context.w(24),
              child: FadeTransition(
                opacity: _messageFadeController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          _displayedText,
                          fontWeight: FontWeight.w600,
                          color: white,
                          letterSpacing: 0.4,
                        ),
                        const _BlinkingCursor(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      opacity: _displayedText == _messages[_currentMessageIndex]
                          ? 0.5
                          : 0.0,
                      duration: AppDurations.loaderMessageFade,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _LoadingBarWithRunner(progress: progress),
            ),
          ],
        );
      },
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

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
      duration: AppDurations.cursorBlink,
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
      child: AppText(
        AppStrings.cursor,
        style: AppTextStyle.bodyMedium,
        fontWeight: FontWeight.w600,
        color: loaderOrange,
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
    for (var layer = 0; layer < AppSizes.premiumParticleLayers; layer++) {
      final depth = 0.5 + layer * 0.3;
      final opacityBase = 0.05 + layer * 0.05;
      for (var i = 0; i < AppSizes.premiumParticlesPerLayer; i++) {
        final x = rng.nextDouble();
        final speed = depth * (0.2 + rng.nextDouble());
        final y = 1.0 -
            (progress * speed + x + sin(progress * pi * 2) * 0.05) % 1.0;
        final paint = Paint()
          ..color = accentPink.withValues(alpha: opacityBase);
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

class _LoadingBarWithRunner extends StatelessWidget {
  const _LoadingBarWithRunner({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.h(56),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final gifSize = context.sq(48);
          final boyX =
              (progress * barWidth - gifSize / 2).clamp(0.0, barWidth - gifSize);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: context.h(3),
                child: ClipRRect(
                  borderRadius: context.radiusAll(2),
                  child: CustomPaint(
                    painter: _LoadingBarPainter(progress),
                  ),
                ),
              ),
              Positioned(
                left: boyX,
                bottom: context.h(2),
                child: Image.asset(
                  'assets/gifs/running_boy.gif',
                  width: gifSize,
                  height: gifSize,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ],
          );
        },
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
      colors: [transparent, accentPink, accentOrange, transparent],
    ).createShader(Rect.fromLTWH(startX, 0, segmentWidth, size.height));
    canvas.drawRect(
      Rect.fromLTWH(startX, 0, segmentWidth, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
