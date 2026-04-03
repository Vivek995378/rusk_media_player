import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';

class RobotEyesLoader extends StatefulWidget {
  const RobotEyesLoader({
    super.key,
    this.eyeSize = AppSizes.loaderEyeSize,
    this.eyeColor = loaderOrange,
  });

  final double eyeSize;
  final Color eyeColor;

  @override
  State<RobotEyesLoader> createState() => _RobotEyesLoaderState();
}

class _RobotEyesLoaderState extends State<RobotEyesLoader>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _glowController;
  late AnimationController _lookController;
  late AnimationController _mouthController;

  late Animation<double> _blinkAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _lookAnim;
  late Animation<double> _mouthAnim;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: AppDurations.robotBlink,
      vsync: this,
    );
    _blinkAnim = Tween<double>(begin: 1.0, end: 0.05).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: AppDurations.robotGlow,
      vsync: this,
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _lookController = AnimationController(
      duration: AppDurations.robotLook,
      vsync: this,
    );
    _lookAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _lookController, curve: Curves.easeInOut),
    );

    _mouthController = AnimationController(
      duration: AppDurations.robotMouth,
      vsync: this,
    );
    _mouthAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeInOut),
    );

    _startBlinkLoop();
  }

  Future<void> _startBlinkLoop() async {
    _mouthController.repeat(
      reverse: true,
      period: AppDurations.robotMouthLoop,
    );

    while (mounted) {
      await Future<void>.delayed(AppDurations.robotBlinkDelay);
      if (!mounted) return;

      await _lookController.forward();
      await Future<void>.delayed(AppDurations.robotLookDelay);
      if (!mounted) return;

      _mouthController.stop();
      _mouthController.animateTo(
        0.6,
        duration: const Duration(milliseconds: 100),
      );
      await _blinkController.forward();
      await _blinkController.reverse();
      if (!mounted) return;

      await _lookController.reverse();
      await Future<void>.delayed(AppDurations.robotLookDelay);
      if (!mounted) return;

      _mouthController.animateTo(
        0.3,
        duration: const Duration(milliseconds: 100),
      );
      await _blinkController.forward();
      await _blinkController.reverse();
      if (!mounted) return;

      await _lookController.animateTo(0.5, duration: AppDurations.robotLookCenter);
      _mouthController.repeat(
        reverse: true,
        period: AppDurations.robotMouthLoop,
      );

      await Future<void>.delayed(AppDurations.robotBlinkCenterDelay);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _glowController.dispose();
    _lookController.dispose();
    _mouthController.dispose();
    super.dispose();
  }

  Widget _buildEye() {
    final size = widget.eyeSize;
    final pupilSize = size * AppSizes.loaderPupilRatio;

    return AnimatedBuilder(
      animation: Listenable.merge([_blinkAnim, _glowAnim, _lookAnim]),
      builder: (context, child) {
        final pupilOffset = (_lookAnim.value - 0.5) * size * 0.28;

        return Transform.scale(
          scaleY: _blinkAnim.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: black,
              borderRadius: BorderRadius.circular(size * 0.22),
              border: Border.all(
                color: widget.eyeColor.withValues(alpha: _glowAnim.value),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.eyeColor.withValues(alpha: _glowAnim.value * 0.6),
                  blurRadius: 10 * _glowAnim.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(pupilOffset, 0),
                  child: Container(
                    width: pupilSize,
                    height: pupilSize,
                    decoration: BoxDecoration(
                      color: widget.eyeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.eyeColor.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: size * 0.18,
                  right: size * 0.18,
                  child: Transform.translate(
                    offset: Offset(pupilOffset * 0.5, 0),
                    child: Container(
                      width: pupilSize * 0.28,
                      height: pupilSize * 0.28,
                      decoration: const BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMouth() {
    final eyeSize = widget.eyeSize;
    final mouthWidth = eyeSize * 2.1;
    final mouthHeight = eyeSize * 0.7;

    return AnimatedBuilder(
      animation: Listenable.merge([_mouthAnim, _glowAnim]),
      builder: (context, child) {
        return SizedBox(
          width: mouthWidth,
          height: mouthHeight,
          child: CustomPaint(
            painter: _MouthPainter(
              openAmount: _mouthAnim.value,
              glowAmount: _glowAnim.value,
              color: widget.eyeColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eyeSize = widget.eyeSize;
    final eyeGap = eyeSize * AppSizes.loaderEyeGap;
    final mouthMarginTop = eyeSize * AppSizes.loaderMouthMargin;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEye(),
            SizedBox(width: eyeGap),
            _buildEye(),
          ],
        ),
        SizedBox(height: mouthMarginTop),
        _buildMouth(),
      ],
    );
  }
}

class _MouthPainter extends CustomPainter {
  const _MouthPainter({
    required this.openAmount,
    required this.glowAmount,
    required this.color,
  });

  final double openAmount;
  final double glowAmount;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final curveDepth = openAmount * h * 0.85;

    final path = Path()
      ..moveTo(0, h * 0.3)
      ..cubicTo(
        w * 0.25,
        h * 0.3 + curveDepth,
        w * 0.75,
        h * 0.3 + curveDepth,
        w,
        h * 0.3,
      );

    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowAmount * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);

    final mainPaint = Paint()
      ..color = color.withValues(alpha: 0.9 + glowAmount * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(_MouthPainter old) =>
      old.openAmount != openAmount ||
      old.glowAmount != glowAmount ||
      old.color != color;
}
