import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

/// A slick, animated volume bar with:
/// - Glassmorphism container with backdrop blur
/// - Gradient fill that shifts color based on level
/// - Glowing edge on the fill top
/// - Animated bouncy thumb dot
/// - Smooth icon morph between volume states
/// - Percentage text with scale pop on change
class VideoFeedViewVolumeBar extends StatefulWidget {
  const VideoFeedViewVolumeBar({
    super.key,
    required this.volume,
  });

  final double volume;

  @override
  State<VideoFeedViewVolumeBar> createState() => _VideoFeedViewVolumeBarState();
}

class _VideoFeedViewVolumeBarState extends State<VideoFeedViewVolumeBar>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _popCtrl;
  late Animation<double> _glowAnim;
  late Animation<double> _popAnim;

  @override
  void initState() {
    super.initState();
    // Continuous subtle glow pulse
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Pop animation for percentage text
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _popAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_popCtrl);
  }

  @override
  void didUpdateWidget(covariant VideoFeedViewVolumeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPct = (oldWidget.volume * 100).round();
    final newPct = (widget.volume * 100).round();
    if (oldPct != newPct) {
      _popCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  IconData get _icon {
    if (widget.volume <= 0) return Icons.volume_off_rounded;
    if (widget.volume < 0.35) return Icons.volume_mute_rounded;
    if (widget.volume < 0.65) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }

  /// Gradient shifts from cool blue (low) → green (mid) → warm white (high).
  List<Color> get _fillColors {
    final v = widget.volume;
    if (v < 0.35) {
      return const [Color(0xFF00B0FF), Color(0xFF448AFF)];
    } else if (v < 0.65) {
      return const [Color(0xFF00E676), Color(0xFF69F0AE)];
    } else {
      return const [Color(0xFF69F0AE), Color(0xFFE0E0E0)];
    }
  }

  Color get _glowColor {
    final v = widget.volume;
    if (v < 0.35) return const Color(0xFF448AFF);
    if (v < 0.65) return const Color(0xFF00E676);
    return const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    final barHeight = context.h(200);
    final barWidth = context.w(6);
    final containerWidth = context.w(44);
    final pct = (widget.volume * 100).round();

    return AnimatedBuilder(
      animation: Listenable.merge([_glowCtrl, _popCtrl]),
      builder: (context, _) {
        return ClipRRect(
          borderRadius: context.radiusAll(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.symmetric(
                vertical: context.h(14),
              ),
              decoration: BoxDecoration(
                color: white.withValues(alpha: 0.08),
                borderRadius: context.radiusAll(22),
                border: Border.all(
                  color: white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon with animated color ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      _icon,
                      key: ValueKey(_icon),
                      color: white.withValues(alpha: 0.9),
                      size: context.sq(20),
                    ),
                  ),
                  SizedBox(height: context.h(10)),

                  // ── Track + fill + glow + thumb ──
                  SizedBox(
                    height: barHeight,
                    width: barWidth,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Track background
                        Container(
                          decoration: BoxDecoration(
                            color: white.withValues(alpha: 0.1),
                            borderRadius: context.radiusAll(3),
                          ),
                        ),

                        // Animated fill
                        TweenAnimationBuilder<double>(
                          tween: Tween(end: widget.volume.clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 80),
                          curve: Curves.easeOut,
                          builder: (context, fillHeight, child) {
                            return FractionallySizedBox(
                              heightFactor: fillHeight,
                              alignment: Alignment.bottomCenter,
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: context.radiusAll(3),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: _fillColors,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _glowColor.withValues(
                                    alpha: 0.5 * _glowAnim.value,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Thumb dot at fill top
                        Positioned(
                          bottom: barHeight * widget.volume.clamp(0.0, 1.0) -
                              context.sq(6),
                          child: Container(
                            width: context.sq(12),
                            height: context.sq(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                  color: _glowColor.withValues(
                                    alpha: 0.6 * _glowAnim.value,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(10)),

                  // ── Percentage with pop ──
                  Transform.scale(
                    scale: _popAnim.value,
                    child: Text(
                      '$pct',
                      style: TextStyle(
                        color: white.withValues(alpha: 0.9),
                        fontSize: context.fontSize(12),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
                      ),
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
