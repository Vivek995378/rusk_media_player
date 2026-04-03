import 'package:flutter/material.dart';
import 'dart:math';

class RobotEyesLoader extends StatefulWidget {
  final double eyeSize;
  final Color eyeColor;

  const RobotEyesLoader({
    Key? key,
    this.eyeSize = 36,
    this.eyeColor = const Color(0xFFFF3D00),
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _blinkAnim = Tween<double>(begin: 1.0, end: 0.05).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _lookController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _lookAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _lookController, curve: Curves.easeInOut),
    );

    _mouthController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _mouthAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeInOut),
    );

    _startBlinkLoop();
  }

  void _startBlinkLoop() async {
    _mouthController.repeat(reverse: true, period: const Duration(milliseconds: 1800));

    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      await _lookController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      _mouthController.stop();
      _mouthController.animateTo(0.6, duration: const Duration(milliseconds: 100));
      await _blinkController.forward();
      await _blinkController.reverse();
      if (!mounted) return;

      await _lookController.reverse();
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      _mouthController.animateTo(0.3, duration: const Duration(milliseconds: 100));
      await _blinkController.forward();
      await _blinkController.reverse();
      if (!mounted) return;

      await _lookController.animateTo(0.5,
          duration: const Duration(milliseconds: 300));
      _mouthController.repeat(
          reverse: true, period: const Duration(milliseconds: 1800));

      await Future.delayed(const Duration(milliseconds: 800));
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
    final pupilSize = size * 0.38;

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
              color: Colors.black,
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
                        color: Colors.white,
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
    final eyeGap = eyeSize * 0.55;
    final mouthMarginTop = eyeSize * 0.55;

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

/// Draws a clean curved robot smile using a cubic bezier path.
/// openAmount 0.0 = flat line, 1.0 = wide open smile arc.
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

    // Control point depth — 0 = flat, h = full arc
    final curveDepth = openAmount * h * 0.85;

    final path = Path()
      ..moveTo(0, h * 0.3)
      ..cubicTo(
        w * 0.25, h * 0.3 + curveDepth, // left control
        w * 0.75, h * 0.3 + curveDepth, // right control
        w, h * 0.3,                      // end point
      );

    // Glow shadow pass
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowAmount * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);

    // Main stroke pass
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