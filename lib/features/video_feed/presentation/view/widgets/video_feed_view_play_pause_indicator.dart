import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class VideoFeedViewPlayPauseIndicator extends StatefulWidget {
  const VideoFeedViewPlayPauseIndicator({super.key});

  @override
  State<VideoFeedViewPlayPauseIndicator> createState() =>
      VideoFeedViewPlayPauseIndicatorState();
}

class VideoFeedViewPlayPauseIndicatorState
    extends State<VideoFeedViewPlayPauseIndicator>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _pulse;

  bool _isPlaying = true;
  bool _visible = false;

  void show({required bool isPlaying}) {
    _isPlaying = isPlaying;
    _visible = true;

    _controller?.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.playPauseIndicator,
    );

    _scale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOut),
    );

    _pulse = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOut),
    );

    setState(() {});

    _controller!.forward().then((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        await _controller!.reverse();
        setState(() => _visible = false);
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || _controller == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, _) {
          return Opacity(
            opacity: _opacity.value.clamp(0, 1),
            child: Transform.scale(
              scale: _scale.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// 🔥 Ripple pulse (subtle premium effect)
                  Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: context.sq(AppSizes.playPauseContainerSize),
                      height: context.sq(AppSizes.playPauseContainerSize),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                  /// 🎯 Main container (clean glass style)
                  Container(
                    width: context.sq(AppSizes.playPauseContainerSize),
                    height: context.sq(AppSizes.playPauseContainerSize),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                      border: Border.all(
                        color: white.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: context.sq(20),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: white,
                      size: context.sq(AppSizes.playPauseIconSize),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}