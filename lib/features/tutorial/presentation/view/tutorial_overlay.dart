import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;

  late AnimationController _fadeCtrl;
  late AnimationController _handCtrl;
  late AnimationController _stepTransitionCtrl;
  late AnimationController _autoAdvanceCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _stepFadeAnim;
  late Animation<double> _stepSlideAnim;

  static const _titles = [
    'Tap to Mute / Unmute',
    'Double Tap to Like',
    'Hold to Pause',
    'Hold & Drag for Volume',
    'Swipe to Navigate',
    'Hold & Drag to Seek',
  ];

  static const _descriptions = [
    'Single tap anywhere on the\nvideo to toggle sound',
    'Double tap to show love!\nKeep tapping to stack hearts',
    'Press and hold to pause\nRelease to resume playback',
    'Hold and slide up to increase\nSlide down to decrease volume',
    'Swipe up for next video\nSwipe down for previous',
    'Hold then drag left or right\nto rewind or fast-forward',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _handCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _stepTransitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _stepFadeAnim = CurvedAnimation(
      parent: _stepTransitionCtrl,
      curve: Curves.easeOut,
    );
    _stepSlideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _stepTransitionCtrl, curve: Curves.easeOutCubic),
    );

    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _stepTransitionCtrl.forward();
    });

    // Auto-advance: 3s per step
    _autoAdvanceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _autoAdvanceCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _nextStep();
      }
    });
    // Start first countdown after entry animation
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _autoAdvanceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _handCtrl.dispose();
    _stepTransitionCtrl.dispose();
    _autoAdvanceCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    _autoAdvanceCtrl.reset();
    if (_currentStep < _titles.length - 1) {
      _stepTransitionCtrl.reset();
      _handCtrl
        ..reset()
        ..repeat();
      setState(() => _currentStep++);
      _stepTransitionCtrl.forward();
      _autoAdvanceCtrl.forward();
    } else {
      _fadeCtrl.reverse().then((_) => widget.onComplete());
    }
  }

  void _skip() {
    _autoAdvanceCtrl.stop();
    _fadeCtrl.reverse().then((_) => widget.onComplete());
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentStep == _titles.length - 1;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: transparent,
        child: Stack(
          children: [
            // Dark overlay
            Positioned.fill(
              child: Container(color: black.withValues(alpha: 0.78)),
            ),

            // Center: hand + feedback animation area
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _handCtrl,
                builder: (context, _) {
                  return _buildGestureDemo(context);
                },
              ),
            ),

            // Info card with guide boy inside
            Positioned(
              left: context.w(20),
              right: context.w(20),
              bottom: context.h(200),
              child: AnimatedBuilder(
                animation: _stepTransitionCtrl,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _stepSlideAnim.value),
                    child: Opacity(
                      opacity: _stepFadeAnim.value.clamp(0.0, 1.0),
                      child: _InfoCard(
                        title: _titles[_currentStep],
                        description: _descriptions[_currentStep],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Step dots
            Positioned(
              left: 0,
              right: 0,
              bottom: context.h(60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_titles.length, (i) {
                  final isActive = i == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: context.w(4)),
                    width: isActive ? context.w(24) : context.w(8),
                    height: context.h(8),
                    decoration: BoxDecoration(
                      borderRadius: context.radiusAll(4),
                      color: isActive
                          ? accentPink
                          : white.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),

            // Skip
            Positioned(
              top: context.safeTop + context.h(16),
              right: context.w(20),
              child: GestureDetector(
                onTap: _skip,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(16),
                    vertical: context.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.12),
                    borderRadius: context.radiusAll(20),
                    border: Border.all(color: white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: white.withValues(alpha: 0.8),
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),

            // Next / Let's Go
            Positioned(
              left: context.w(24),
              right: context.w(24),
              bottom: context.h(100),
              child: GestureDetector(
                onTap: _nextStep,
                child: AnimatedBuilder(
                  animation: _autoAdvanceCtrl,
                  builder: (context, _) {
                    final remaining =
                        (3 * (1 - _autoAdvanceCtrl.value)).ceil();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.symmetric(
                        vertical: context.h(14),
                        horizontal: context.w(20),
                      ),
                      decoration: BoxDecoration(
                        gradient: isLast ? brandGradient : null,
                        color: isLast ? null : accentPink,
                        borderRadius: context.radiusAll(28),
                        boxShadow: [
                          BoxShadow(
                            color: accentPink.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? "Let's Go!" : 'Next',
                            style: TextStyle(
                              color: white,
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          if (!isLast) ...[
                            const Spacer(),
                            // Circular countdown
                            SizedBox(
                              width: context.sq(24),
                              height: context.sq(24),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: 1 - _autoAdvanceCtrl.value,
                                    strokeWidth: 2,
                                    color: white.withValues(alpha: 0.9),
                                    backgroundColor:
                                        white.withValues(alpha: 0.2),
                                  ),
                                  Text(
                                    '$remaining',
                                    style: TextStyle(
                                      color: white,
                                      fontSize: context.fontSize(11),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build the correct gesture demo per step ──────────────────────────────
  Widget _buildGestureDemo(BuildContext context) {
    final p = _handCtrl.value;
    final handSize = context.sq(100);
    switch (_currentStep) {
      case 0:
        return _MuteDemoAnim(progress: p, handSize: handSize);
      case 1:
        return _DoubleTapDemoAnim(progress: p, handSize: handSize);
      case 2:
        return _HoldPauseDemoAnim(progress: p, handSize: handSize);
      case 3:
        return _VolumeDragDemoAnim(progress: p, handSize: handSize);
      case 4:
        return _SwipeDemoAnim(progress: p, handSize: handSize);
      case 5:
        return _SeekDemoAnim(progress: p, handSize: handSize);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Info card with guide boy ───────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: context.w(20),
        right: context.w(20),
        top: context.h(16),
        bottom: context.h(20),
      ),
      decoration: BoxDecoration(
        color: surfaceElevated.withValues(alpha: 0.95),
        borderRadius: context.radiusAll(20),
        border: Border.all(
          color: accentPink.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: accentPink.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Guide boy
          Image.asset(
            'assets/png/ic_guide_boy.png',
            width: context.w(60),
            height: context.h(80),
            fit: BoxFit.contain,
          ),
          SizedBox(width: context.w(14)),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: white,
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: context.h(6)),
                Text(
                  description,
                  style: TextStyle(
                    color: white.withValues(alpha: 0.6),
                    fontSize: context.fontSize(13),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable hand widget ───────────────────────────────────────────────────
class _Hand extends StatelessWidget {
  const _Hand({
    required this.size,
    this.rotation = 0,
    this.opacity = 1,
    this.scale = 1,
  });
  final double size;
  final double rotation;
  final double opacity;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            'assets/png/guide_hand.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ── Feedback icon bubble ──────────────────────────────────────────────────
class _FeedbackIcon extends StatelessWidget {
  const _FeedbackIcon({
    required this.icon,
    required this.color,
    required this.opacity,
    required this.scale,
    this.size = 48,
  });
  final IconData icon;
  final Color color;
  final double opacity;
  final double scale;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale.clamp(0.0, 3.0),
        child: Icon(
          icon,
          color: color,
          size: size,
          shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 16)],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 0: Single tap → mute / unmute
// Timeline (3s loop):
//   0.00–0.15  hand fades in + moves down (tap)
//   0.15–0.25  hand presses (scale down), mute icon pops
//   0.25–0.40  hand lifts, mute icon stays
//   0.40–0.50  pause
//   0.50–0.65  hand taps again
//   0.65–0.75  hand presses, unmute icon pops
//   0.75–0.90  hand lifts, unmute icon stays
//   0.90–1.00  fade out everything, reset
// ═══════════════════════════════════════════════════════════════════════════
class _MuteDemoAnim extends StatelessWidget {
  const _MuteDemoAnim({required this.progress, required this.handSize});
  final double progress;
  final double handSize;

  @override
  Widget build(BuildContext context) {
    final p = progress;

    // Hand
    double handOpacity = 0;
    double handY = 0;
    double handScale = 1;

    // First tap: 0.0–0.40
    if (p < 0.15) {
      handOpacity = (p / 0.15).clamp(0.0, 1.0);
      handY = 20 * (1 - p / 0.15);
    } else if (p < 0.25) {
      handOpacity = 1;
      handScale = 1 - 0.15 * ((p - 0.15) / 0.10);
    } else if (p < 0.40) {
      handOpacity = 1;
      handScale = 0.85 + 0.15 * ((p - 0.25) / 0.15);
    }
    // Second tap: 0.50–0.90
    else if (p < 0.50) {
      handOpacity = 1;
    } else if (p < 0.65) {
      handOpacity = 1;
      handY = 20 * (1 - (p - 0.50) / 0.15);
    } else if (p < 0.75) {
      handOpacity = 1;
      handScale = 1 - 0.15 * ((p - 0.65) / 0.10);
    } else if (p < 0.90) {
      handOpacity = 1;
      handScale = 0.85 + 0.15 * ((p - 0.75) / 0.15);
    } else {
      handOpacity = 1 - ((p - 0.90) / 0.10).clamp(0.0, 1.0);
    }

    // Mute icon: visible 0.20–0.50
    double muteOpacity = 0;
    double muteScale = 0;
    if (p >= 0.20 && p < 0.50) {
      final t = ((p - 0.20) / 0.08).clamp(0.0, 1.0);
      muteOpacity = t;
      muteScale = 0.3 + t * 0.9;
      if (p > 0.42) {
        muteOpacity = 1 - ((p - 0.42) / 0.08).clamp(0.0, 1.0);
      }
    }

    // Unmute icon: visible 0.70–1.0
    double unmuteOpacity = 0;
    double unmuteScale = 0;
    if (p >= 0.70 && p < 1.0) {
      final t = ((p - 0.70) / 0.08).clamp(0.0, 1.0);
      unmuteOpacity = t;
      unmuteScale = 0.3 + t * 0.9;
      if (p > 0.88) {
        unmuteOpacity = 1 - ((p - 0.88) / 0.10).clamp(0.0, 1.0);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Mute icon (above hand)
        Transform.translate(
          offset: const Offset(0, -80),
          child: _FeedbackIcon(
            icon: Icons.volume_off_rounded,
            color: white,
            opacity: muteOpacity,
            scale: muteScale,
            size: 56,
          ),
        ),
        // Unmute icon (above hand)
        Transform.translate(
          offset: const Offset(0, -80),
          child: _FeedbackIcon(
            icon: Icons.volume_up_rounded,
            color: const Color(0xFF00E676),
            opacity: unmuteOpacity,
            scale: unmuteScale,
            size: 56,
          ),
        ),
        // Hand
        Transform.translate(
          offset: Offset(0, handY),
          child: _Hand(
            size: handSize,
            opacity: handOpacity,
            scale: handScale,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 1: Double tap → heart + count
// Timeline (3s loop):
//   0.00–0.10  hand appears
//   0.10–0.18  first tap down
//   0.18–0.24  first tap up
//   0.24–0.30  second tap down → heart #1 pops
//   0.30–0.50  heart #1 floats up, +1 text
//   0.50–0.58  third tap down
//   0.58–0.64  third tap up
//   0.64–0.70  fourth tap down → heart #2 pops
//   0.70–0.90  heart #2 floats up, +2 text
//   0.90–1.00  fade out
// ═══════════════════════════════════════════════════════════════════════════
class _DoubleTapDemoAnim extends StatelessWidget {
  const _DoubleTapDemoAnim({required this.progress, required this.handSize});
  final double progress;
  final double handSize;

  @override
  Widget build(BuildContext context) {
    final p = progress;

    // Hand
    double handOpacity = 0;
    double handScale = 1;
    double handY = 0;

    if (p < 0.10) {
      handOpacity = (p / 0.10).clamp(0.0, 1.0);
    } else if (p < 0.90) {
      handOpacity = 1;
      // Tap pulses at: 0.10, 0.24, 0.50, 0.64
      for (final tapCenter in [0.14, 0.27, 0.54, 0.67]) {
        final dist = (p - tapCenter).abs();
        if (dist < 0.04) {
          final t = 1 - (dist / 0.04);
          handScale = 1 - t * 0.18;
          handY = t * 10;
        }
      }
    } else {
      handOpacity = 1 - ((p - 0.90) / 0.10).clamp(0.0, 1.0);
    }

    // Heart #1: appears at 0.27, floats up until 0.50
    double h1Opacity = 0;
    double h1Scale = 0;
    double h1Y = 0;
    if (p >= 0.27 && p < 0.52) {
      final t = ((p - 0.27) / 0.25).clamp(0.0, 1.0);
      h1Opacity = t < 0.15 ? (t / 0.15) : (t > 0.7 ? (1 - t) / 0.3 : 1);
      h1Scale = t < 0.2 ? 0.3 + Curves.easeOutBack.transform(t / 0.2) * 0.9 : 1.2;
      h1Y = -t * 60;
    }

    // +1 text
    double t1Opacity = 0;
    double t1Y = 0;
    if (p >= 0.30 && p < 0.52) {
      final t = ((p - 0.30) / 0.22).clamp(0.0, 1.0);
      t1Opacity = t < 0.3 ? t / 0.3 : (t > 0.7 ? (1 - t) / 0.3 : 1);
      t1Y = -t * 40;
    }

    // Heart #2: appears at 0.67, floats up until 0.90
    double h2Opacity = 0;
    double h2Scale = 0;
    double h2Y = 0;
    if (p >= 0.67 && p < 0.92) {
      final t = ((p - 0.67) / 0.25).clamp(0.0, 1.0);
      h2Opacity = t < 0.15 ? (t / 0.15) : (t > 0.7 ? (1 - t) / 0.3 : 1);
      h2Scale = t < 0.2 ? 0.3 + Curves.easeOutBack.transform(t / 0.2) * 0.9 : 1.2;
      h2Y = -t * 60;
    }

    // +2 text
    double t2Opacity = 0;
    double t2Y = 0;
    if (p >= 0.70 && p < 0.92) {
      final t = ((p - 0.70) / 0.22).clamp(0.0, 1.0);
      t2Opacity = t < 0.3 ? t / 0.3 : (t > 0.7 ? (1 - t) / 0.3 : 1);
      t2Y = -t * 40;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Heart #1
        Transform.translate(
          offset: Offset(0, -70 + h1Y),
          child: _FeedbackIcon(
            icon: Icons.favorite,
            color: const Color(0xFFFF1744),
            opacity: h1Opacity,
            scale: h1Scale,
            size: 64,
          ),
        ),
        // +1
        Transform.translate(
          offset: Offset(40, -60 + t1Y),
          child: Opacity(
            opacity: t1Opacity.clamp(0.0, 1.0),
            child: Text(
              '+1',
              style: TextStyle(
                color: white,
                fontSize: context.fontSize(20),
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
                shadows: const [Shadow(color: Color(0x88000000), blurRadius: 8)],
              ),
            ),
          ),
        ),
        // Heart #2
        Transform.translate(
          offset: Offset(0, -70 + h2Y),
          child: _FeedbackIcon(
            icon: Icons.favorite,
            color: const Color(0xFFFF1744),
            opacity: h2Opacity,
            scale: h2Scale,
            size: 64,
          ),
        ),
        // +2
        Transform.translate(
          offset: Offset(40, -60 + t2Y),
          child: Opacity(
            opacity: t2Opacity.clamp(0.0, 1.0),
            child: Text(
              '+2',
              style: TextStyle(
                color: white,
                fontSize: context.fontSize(20),
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
                shadows: const [Shadow(color: Color(0x88000000), blurRadius: 8)],
              ),
            ),
          ),
        ),
        // Hand
        Transform.translate(
          offset: Offset(0, handY),
          child: _Hand(
            size: handSize,
            opacity: handOpacity,
            scale: handScale,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 2: Long press hold → pause, release → resume
// Timeline (3s loop):
//   0.00–0.10  hand fades in
//   0.10–0.20  hand presses down (hold)
//   0.20–0.55  holding — pause icon visible, dim overlay
//   0.55–0.65  hand lifts — resume icon pops
//   0.65–0.85  resume icon visible
//   0.85–1.00  fade out
// ═══════════════════════════════════════════════════════════════════════════
class _HoldPauseDemoAnim extends StatelessWidget {
  const _HoldPauseDemoAnim({required this.progress, required this.handSize});
  final double progress;
  final double handSize;

  @override
  Widget build(BuildContext context) {
    final p = progress;

    double handOpacity = 0;
    double handScale = 1;
    double handY = 0;
    bool isHolding = false;

    if (p < 0.10) {
      handOpacity = (p / 0.10).clamp(0.0, 1.0);
    } else if (p < 0.20) {
      handOpacity = 1;
      final t = (p - 0.10) / 0.10;
      handScale = 1 - t * 0.12;
      handY = t * 8;
    } else if (p < 0.55) {
      handOpacity = 1;
      handScale = 0.88;
      handY = 8;
      isHolding = true;
    } else if (p < 0.65) {
      handOpacity = 1;
      final t = (p - 0.55) / 0.10;
      handScale = 0.88 + t * 0.12;
      handY = 8 * (1 - t);
    } else if (p < 0.85) {
      handOpacity = 1;
    } else {
      handOpacity = 1 - ((p - 0.85) / 0.15).clamp(0.0, 1.0);
    }

    // Pause icon: 0.22–0.55
    double pauseOpacity = 0;
    double pauseScale = 0;
    if (p >= 0.22 && p < 0.55) {
      final t = ((p - 0.22) / 0.08).clamp(0.0, 1.0);
      pauseOpacity = t;
      pauseScale = 0.3 + Curves.easeOutBack.transform(t) * 0.8;
      if (p > 0.48) {
        pauseOpacity = 1 - ((p - 0.48) / 0.07).clamp(0.0, 1.0);
      }
    }

    // Resume icon: 0.60–0.85
    double resumeOpacity = 0;
    double resumeScale = 0;
    if (p >= 0.60 && p < 0.85) {
      final t = ((p - 0.60) / 0.08).clamp(0.0, 1.0);
      resumeOpacity = t;
      resumeScale = 0.3 + Curves.easeOutBack.transform(t) * 0.8;
      if (p > 0.78) {
        resumeOpacity = 1 - ((p - 0.78) / 0.07).clamp(0.0, 1.0);
      }
    }

    // Dim overlay when holding
    final dimOpacity = isHolding ? 0.15 : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dim
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: black.withValues(alpha: dimOpacity),
            ),
          ),
        ),
        // Pause icon
        Transform.translate(
          offset: const Offset(0, -90),
          child: _FeedbackIcon(
            icon: Icons.pause_rounded,
            color: accentPink,
            opacity: pauseOpacity,
            scale: pauseScale,
            size: 64,
          ),
        ),
        // Resume icon
        Transform.translate(
          offset: const Offset(0, -90),
          child: _FeedbackIcon(
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF00E676),
            opacity: resumeOpacity,
            scale: resumeScale,
            size: 64,
          ),
        ),
        // Hand
        Transform.translate(
          offset: Offset(0, handY),
          child: _Hand(
            size: handSize,
            opacity: handOpacity,
            scale: handScale,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 3: Hold + drag up/down → volume
// Timeline (3s loop):
//   0.00–0.10  hand fades in, rotated 30°
//   0.10–0.18  hand presses down (hold start)
//   0.18–0.45  hand drags UP → volume bar fills up on right
//   0.45–0.55  pause at top
//   0.55–0.82  hand drags DOWN → volume bar empties
//   0.82–0.90  pause at bottom
//   0.90–1.00  fade out
// ═══════════════════════════════════════════════════════════════════════════
class _VolumeDragDemoAnim extends StatelessWidget {
  const _VolumeDragDemoAnim({required this.progress, required this.handSize});
  final double progress;
  final double handSize;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    const handRotation = -30 * pi / 180; // -30 degrees (tilt right)

    double handOpacity = 0;
    double handScale = 1;
    double handY = 0;
    double volumeLevel = 0.3; // start at 30%

    if (p < 0.10) {
      handOpacity = (p / 0.10).clamp(0.0, 1.0);
    } else if (p < 0.18) {
      handOpacity = 1;
      handScale = 1 - ((p - 0.10) / 0.08) * 0.08;
    } else if (p < 0.45) {
      // Drag up
      handOpacity = 1;
      handScale = 0.92;
      final t = Curves.easeInOut.transform(((p - 0.18) / 0.27).clamp(0.0, 1.0));
      handY = -t * 80;
      volumeLevel = 0.3 + t * 0.7; // 30% → 100%
    } else if (p < 0.55) {
      handOpacity = 1;
      handScale = 0.92;
      handY = -80;
      volumeLevel = 1.0;
    } else if (p < 0.82) {
      // Drag down
      handOpacity = 1;
      handScale = 0.92;
      final t = Curves.easeInOut.transform(((p - 0.55) / 0.27).clamp(0.0, 1.0));
      handY = -80 + t * 80;
      volumeLevel = 1.0 - t * 0.8; // 100% → 20%
    } else if (p < 0.90) {
      handOpacity = 1;
      handScale = 0.92;
      volumeLevel = 0.2;
    } else {
      handOpacity = 1 - ((p - 0.90) / 0.10).clamp(0.0, 1.0);
      volumeLevel = 0.2;
    }

    // Volume bar visibility
    final barOpacity = p >= 0.15 && p < 0.92
        ? (p < 0.20 ? ((p - 0.15) / 0.05).clamp(0.0, 1.0) : (p > 0.87 ? ((0.92 - p) / 0.05).clamp(0.0, 1.0) : 1.0))
        : 0.0;

    final volIcon = volumeLevel > 0.6
        ? Icons.volume_up_rounded
        : (volumeLevel > 0.3 ? Icons.volume_down_rounded : Icons.volume_mute_rounded);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Mini volume bar on right
        Positioned(
          right: context.w(40),
          child: Opacity(
            opacity: barOpacity.clamp(0.0, 1.0),
            child: _MiniVolumeBar(
              volume: volumeLevel,
              icon: volIcon,
              barHeight: context.h(140),
            ),
          ),
        ),
        // Hand (rotated 30°)
        Transform.translate(
          offset: Offset(-20, handY),
          child: _Hand(
            size: handSize,
            opacity: handOpacity,
            scale: handScale,
            rotation: handRotation,
          ),
        ),
      ],
    );
  }
}

// Mini volume bar for the tutorial demo
class _MiniVolumeBar extends StatelessWidget {
  const _MiniVolumeBar({
    required this.volume,
    required this.icon,
    required this.barHeight,
  });
  final double volume;
  final IconData icon;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final fillColors = volume > 0.6
        ? const [Color(0xFF69F0AE), Color(0xFFE0E0E0)]
        : (volume > 0.3
            ? const [Color(0xFF00E676), Color(0xFF69F0AE)]
            : const [Color(0xFF00B0FF), Color(0xFF448AFF)]);

    return Container(
      width: context.w(36),
      padding: context.paddingVertical(10),
      decoration: BoxDecoration(
        color: black.withValues(alpha: 0.5),
        borderRadius: context.radiusAll(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white, size: context.sq(18)),
          SizedBox(height: context.h(6)),
          SizedBox(
            height: barHeight,
            width: context.w(5),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.1),
                    borderRadius: context.radiusAll(3),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: volume.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: context.radiusAll(3),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: fillColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: fillColors.last.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(6)),
          Text(
            '${(volume * 100).round()}',
            style: TextStyle(
              color: white,
              fontSize: context.fontSize(10),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 4: Swipe up (next) / swipe down (previous)
// Timeline (3s loop):
//   0.00–0.10  hand fades in, rotated 30°
//   0.10–0.40  hand swipes UP + "Next" label floats
//   0.40–0.50  pause
//   0.50–0.60  hand reappears at center
//   0.60–0.90  hand swipes DOWN + "Previous" label floats
//   0.90–1.00  fade out
// ═══════════════════════════════════════════════════════════════════════════
class _SwipeDemoAnim extends StatelessWidget {
  const _SwipeDemoAnim({required this.progress, required this.handSize});
  final double progress;
  final double handSize;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    const handRotation = -30 * pi / 180; // -30 degrees (tilt right)

    double handOpacity = 0;
    double handY = 0;

    // Swipe up labels
    double nextOpacity = 0;
    double nextY = 0;
    // Swipe down labels
    double prevOpacity = 0;
    double prevY = 0;

    if (p < 0.10) {
      handOpacity = (p / 0.10).clamp(0.0, 1.0);
    } else if (p < 0.40) {
      // Swipe up
      handOpacity = 1;
      final t = Curves.easeInOut.transform(((p - 0.10) / 0.30).clamp(0.0, 1.0));
      handY = -t * 120;
      if (t > 0.3) {
        handOpacity = 1 - ((t - 0.3) / 0.7).clamp(0.0, 1.0);
      }
      nextOpacity = (t * 2).clamp(0.0, 1.0);
      if (t > 0.6) nextOpacity = 1 - ((t - 0.6) / 0.4).clamp(0.0, 1.0);
      nextY = -t * 30;
    } else if (p < 0.50) {
      handOpacity = 0;
    } else if (p < 0.60) {
      handOpacity = ((p - 0.50) / 0.10).clamp(0.0, 1.0);
    } else if (p < 0.90) {
      // Swipe down
      handOpacity = 1;
      final t = Curves.easeInOut.transform(((p - 0.60) / 0.30).clamp(0.0, 1.0));
      handY = t * 120;
      if (t > 0.3) {
        handOpacity = 1 - ((t - 0.3) / 0.7).clamp(0.0, 1.0);
      }
      prevOpacity = (t * 2).clamp(0.0, 1.0);
      if (t > 0.6) prevOpacity = 1 - ((t - 0.6) / 0.4).clamp(0.0, 1.0);
      prevY = t * 30;
    } else {
      handOpacity = 0;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // "Next" label
        Transform.translate(
          offset: Offset(0, -60 + nextY),
          child: Opacity(
            opacity: nextOpacity.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(8),
              ),
              decoration: BoxDecoration(
                color: accentPink.withValues(alpha: 0.8),
                borderRadius: context.radiusAll(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward_rounded, color: white, size: context.sq(16)),
                  SizedBox(width: context.w(4)),
                  Text(
                    'Next Video',
                    style: TextStyle(
                      color: white,
                      fontSize: context.fontSize(13),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // "Previous" label
        Transform.translate(
          offset: Offset(0, 60 + prevY),
          child: Opacity(
            opacity: prevOpacity.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF448AFF).withValues(alpha: 0.8),
                borderRadius: context.radiusAll(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward_rounded, color: white, size: context.sq(16)),
                  SizedBox(width: context.w(4)),
                  Text(
                    'Previous Video',
                    style: TextStyle(
                      color: white,
                      fontSize: context.fontSize(13),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Hand
        Transform.translate(
          offset: Offset(0, handY),
          child: _Hand(
            size: handSize,
            opacity: handOpacity,
            rotation: handRotation,
          ),
        ),
      ],
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// STEP 5: Hold + drag left/right → seek backward / forward
// Timeline (5s loop):
//   0.00–0.10  hand fades in, presses down (hold)
//   0.10–0.18  hold confirmed — progress bar expands
//   0.18–0.45  hand drags RIGHT → bar fills forward, time tooltip moves right
//   0.45–0.55  pause at right
//   0.55–0.62  hand repositions to center
//   0.62–0.88  hand drags LEFT → bar rewinds, time tooltip moves left
//   0.88–1.00  fade out
// ═══════════════════════════════════════════════════════════════════════════
class _SeekDemoAnim extends StatelessWidget {
  const _SeekDemoAnim({required this.progress, required this.handSize});
  final double progress;
  final double handSize;

  @override
  Widget build(BuildContext context) {
    final p = progress;

    double handOpacity = 0;
    double handScale = 1;
    double handX = 0;

    // Seek progress: 0.3 → 0.8 (forward), then 0.8 → 0.2 (rewind)
    double seekProgress = 0.3;
    double barExpandFactor = 0;
    double tooltipX = 0;
    double tooltipOpacity = 0;

    if (p < 0.10) {
      handOpacity = (p / 0.10).clamp(0.0, 1.0);
    } else if (p < 0.18) {
      // Press down
      handOpacity = 1;
      handScale = 1 - ((p - 0.10) / 0.08) * 0.10;
      barExpandFactor = ((p - 0.10) / 0.08).clamp(0.0, 1.0);
    } else if (p < 0.45) {
      // Drag right → seek forward
      handOpacity = 1;
      handScale = 0.90;
      barExpandFactor = 1;
      final t = Curves.easeInOut.transform(((p - 0.18) / 0.27).clamp(0.0, 1.0));
      handX = t * 100;
      seekProgress = 0.3 + t * 0.5; // 0.3 → 0.8
      tooltipOpacity = (t * 3).clamp(0.0, 1.0);
      tooltipX = handX;
    } else if (p < 0.55) {
      // Pause at right
      handOpacity = 1;
      handScale = 0.90;
      barExpandFactor = 1;
      handX = 100;
      seekProgress = 0.8;
      tooltipOpacity = 1;
      tooltipX = 100;
    } else if (p < 0.62) {
      // Reposition to center
      handOpacity = ((0.62 - p) / 0.07).clamp(0.0, 1.0);
      barExpandFactor = 1;
      seekProgress = 0.8;
    } else if (p < 0.88) {
      // Drag left → rewind
      handOpacity = ((p - 0.62) / 0.06).clamp(0.0, 1.0);
      handScale = 0.90;
      barExpandFactor = 1;
      final t = Curves.easeInOut.transform(((p - 0.62) / 0.26).clamp(0.0, 1.0));
      handX = -t * 100;
      seekProgress = 0.8 - t * 0.6; // 0.8 → 0.2
      tooltipOpacity = (t * 3).clamp(0.0, 1.0);
      tooltipX = handX;
    } else {
      handOpacity = 1 - ((p - 0.88) / 0.12).clamp(0.0, 1.0);
      barExpandFactor = 1 - ((p - 0.88) / 0.12).clamp(0.0, 1.0);
      seekProgress = 0.2;
    }

    // Format time for tooltip (assume 30s total for demo)
    final totalMs = 30000;
    final currentMs = (seekProgress * totalMs).round();
    final currentSec = currentMs ~/ 1000;
    final timeStr =
        '${(currentSec ~/ 60).toString().padLeft(2, '0')}:${(currentSec % 60).toString().padLeft(2, '0')} / 00:30';

    final barHeight = 3.0 + 5.0 * barExpandFactor;
    final screenW = context.screenWidth;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Mini progress bar at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: context.h(60),
          child: Opacity(
            opacity: (barExpandFactor * 2).clamp(0.0, 1.0),
            child: SizedBox(
              height: barHeight,
              child: CustomPaint(
                painter: _SeekBarPainter(
                  progress: seekProgress.clamp(0.0, 1.0),
                  expandFactor: barExpandFactor,
                ),
              ),
            ),
          ),
        ),

        // Time tooltip that follows the hand
        Positioned(
          bottom: context.h(80),
          left: (screenW / 2 + tooltipX - context.w(50))
              .clamp(0.0, screenW - context.w(100)),
          child: Opacity(
            opacity: tooltipOpacity.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(10),
                vertical: context.h(5),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: context.radiusAll(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                timeStr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.fontSize(11),
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),

        // Seek direction arrow
        if (p >= 0.18 && p < 0.55)
          Opacity(
            opacity: ((p - 0.18) / 0.08).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(handX * 0.3, -80),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fast_forward_rounded,
                    color: accentPink,
                    size: context.sq(28),
                    shadows: [
                      Shadow(
                        color: accentPink.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    '+${((seekProgress - 0.3) * 30).round()}s',
                    style: TextStyle(
                      color: accentPink,
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (p >= 0.62 && p < 0.88)
          Opacity(
            opacity: ((p - 0.62) / 0.06).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(handX * 0.3, -80),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fast_rewind_rounded,
                    color: const Color(0xFF448AFF),
                    size: context.sq(28),
                    shadows: [
                      Shadow(
                        color: const Color(0xFF448AFF).withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    '-${((0.8 - seekProgress) * 30).round()}s',
                    style: TextStyle(
                      color: const Color(0xFF448AFF),
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Hand
        Transform.translate(
          offset: Offset(handX, 0),
          child: _Hand(
            size: handSize,
            opacity: handOpacity,
            scale: handScale,
          ),
        ),
      ],
    );
  }
}

class _SeekBarPainter extends CustomPainter {
  const _SeekBarPainter({required this.progress, required this.expandFactor});
  final double progress;
  final double expandFactor;

  @override
  void paint(Canvas canvas, Size size) {
    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.height / 2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
    // Fill
    if (progress > 0) {
      final fw = size.width * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fw, size.height),
          Radius.circular(size.height / 2),
        ),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF006E), Color(0xFFFB5607)],
          ).createShader(Rect.fromLTWH(0, 0, fw, size.height)),
      );
    }
    // Handle
    if (expandFactor > 0 && progress > 0) {
      canvas.drawCircle(
        Offset(size.width * progress, size.height / 2),
        (size.height * 1.8) * expandFactor,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_SeekBarPainter old) =>
      old.progress != progress || old.expandFactor != expandFactor;
}
