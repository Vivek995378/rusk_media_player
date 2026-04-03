import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:video_player/video_player.dart';

class VideoFeedViewVolumeGesture extends StatefulWidget {
  const VideoFeedViewVolumeGesture({
    required this.controller,
    required this.child,
    super.key,
  });

  final VideoPlayerController? controller;
  final Widget child;

  @override
  State<VideoFeedViewVolumeGesture> createState() =>
      _VideoFeedViewVolumeGestureState();
}

class _VideoFeedViewVolumeGestureState
    extends State<VideoFeedViewVolumeGesture>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  double _volume = 1;
  double _dragStartY = 0;
  double _startVolume = 1;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (widget.controller == null) return;
    _isDragging = true;
    _dragStartY = details.localPosition.dy;
    _startVolume = _volume;
    _fadeController.forward();
    setState(() {});
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDragging || widget.controller == null) return;
    final dy = _dragStartY - details.localPosition.dy;
    final sensitivity = context.screenHeight * 0.5;
    final newVolume = (_startVolume + dy / sensitivity).clamp(0.0, 1.0);
    _volume = newVolume;
    widget.controller!.setVolume(_volume);
    setState(() {});
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _isDragging = false;
    _fadeController.reverse();
    setState(() {});
  }

  IconData get _volumeIcon {
    if (_volume <= 0) return Icons.volume_off_rounded;
    if (_volume < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            right: context.w(16),
            top: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: _VolumeBar(volume: _volume, icon: _volumeIcon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({required this.volume, required this.icon});

  final double volume;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final barHeight = context.h(180);
    return Container(
      width: context.w(36),
      padding: context.paddingVertical(10),
      decoration: BoxDecoration(
        color: black.withValues(alpha: 0.55),
        borderRadius: context.radiusAll(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white, size: context.sq(20)),
          SizedBox(height: context.h(8)),
          SizedBox(
            height: barHeight,
            width: context.w(4),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: context.radiusAll(2),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: volume,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: context.radiusAll(2),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFF00E676),
                          Color(0xFF69F0AE),
                          white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            '${(volume * 100).round()}',
            style: TextStyle(
              color: white,
              fontSize: context.fontSize(11),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
