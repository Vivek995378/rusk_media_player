import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class SplashView extends StatefulWidget {
  const SplashView({required this.onComplete, super.key});
  final VoidCallback onComplete;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _exitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;

  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;

  late Animation<double> _taglineOpacity;

  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _runSequence();
  }

  void _initAnimations() {
    _bgController = AnimationController(
      vsync: this,
      duration: AppDurations.splashBackground,
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: AppDurations.splashLogo,
    );
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.95)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_logoController);
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.4),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.1, end: 0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: AppDurations.splashText,
    );
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: AppDurations.splashTagline,
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeIn,
      ),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: AppDurations.splashExit,
    );
    _exitScale = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeIn,
      ),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeIn,
      ),
    );
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(AppDurations.splash);
    await _logoController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _textController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _taglineController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _exitController.forward();
    widget.onComplete();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bgController,
        _logoController,
        _textController,
        _taglineController,
        _exitController,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _exitOpacity.value.clamp(0, 1),
          child: Transform.scale(
            scale: _exitScale.value,
            child: Scaffold(
              body: Stack(
                children: [
                  _AnimatedBackground(progress: _bgController.value),
                  const _ParticleField(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: _logoOpacity.value.clamp(0, 1),
                          child: Transform.scale(
                            scale: _logoScale.value.clamp(0, 2),
                            child: Transform.rotate(
                              angle: _logoRotation.value,
                              child: _LogoIcon(size: context.sq(AppSizes.logoSize)),
                            ),
                          ),
                        ),
                        context.hSpace(24),
                        Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: Opacity(
                            opacity: _textOpacity.value.clamp(0, 1),
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) =>
                                  brandGradient.createShader(bounds),
                              child: AppText(
                                AppStrings.appName,
                                style: AppTextStyle.headlineLarge,
                                letterSpacing: AppSizes.splashTitleLetterSpacing,
                              ),
                            ),
                          ),
                        ),
                        context.hSpace(12),
                        Opacity(
                          opacity: _taglineOpacity.value.clamp(0, 1),
                          child: AppText(
                            AppStrings.appTagline,
                            style: AppTextStyle.bodySmall,
                            color: white.withValues(alpha: 0.6),
                            letterSpacing: AppSizes.splashSubtitleLetterSpacing,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: brandGradient,
        borderRadius: BorderRadius.circular(size * AppSizes.logoCornerRatio),
        boxShadow: [
          BoxShadow(
            color: accentPink.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: white,
        size: size * AppSizes.logoIconRatio,
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(
            cos(progress * 2 * pi),
            sin(progress * 2 * pi),
          ),
          end: Alignment(
            -cos(progress * 2 * pi),
            -sin(progress * 2 * pi),
          ),
          colors: const [splashDark, splashPurpleDark, splashDark],
        ),
      ),
    );
  }
}

class _ParticleField extends StatefulWidget {
  const _ParticleField();

  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splashParticle,
    )..repeat();
    final rng = Random(42);
    _particles = List.generate(
      AppSizes.particleCount,
      (_) => _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.2 + rng.nextDouble() * 0.5,
        size: 1 + rng.nextDouble() * 2,
        opacity: 0.1 + rng.nextDouble() * 0.3,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
  });
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + progress * p.speed) % 1.0;
      final paint = Paint()..color = accentPink.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
