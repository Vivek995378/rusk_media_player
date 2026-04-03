import 'package:flutter/material.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_premium_loader.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_shimmer_loading.dart';
import 'package:video_player/video_player.dart';

class VideoFeedViewOptimizedVideoPlayer extends StatefulWidget {
  const VideoFeedViewOptimizedVideoPlayer({
    required this.controller,
    required this.videoId,
    super.key,
  });
  final VideoPlayerController? controller;
  final String videoId;

  @override
  State<VideoFeedViewOptimizedVideoPlayer> createState() =>
      _VideoFeedViewOptimizedVideoPlayerState();
}

class _VideoFeedViewOptimizedVideoPlayerState
    extends State<VideoFeedViewOptimizedVideoPlayer> {
  bool _isBuffering = false;
  VideoPlayerController? _trackedController;
  Key _playerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _attachListener(widget.controller);
  }

  @override
  void didUpdateWidget(VideoFeedViewOptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != _trackedController ||
        widget.videoId != oldWidget.videoId) {
      _detachListener();
      _playerKey = UniqueKey();
      _isBuffering = false;
      _attachListener(widget.controller);
    }
  }

  @override
  void dispose() {
    _detachListener();
    super.dispose();
  }

  void _attachListener(VideoPlayerController? ctrl) {
    _trackedController = ctrl;
    ctrl?.addListener(_onUpdate);
    // Sync initial state
    if (ctrl != null && mounted) {
      _isBuffering = ctrl.value.isBuffering && !ctrl.value.isPlaying;
    }
  }

  void _detachListener() {
    _trackedController?.removeListener(_onUpdate);
    _trackedController = null;
  }

  void _onUpdate() {
    if (!mounted) return;
    final ctrl = widget.controller;
    if (ctrl == null || ctrl != _trackedController) return;
    if (ctrl.value.hasError) {
      if (_isBuffering) setState(() => _isBuffering = false);
      return;
    }

    // Show buffering indicator only when:
    // - actively buffering AND playing (mid-playback stall)
    // - NOT during initial load (that's handled by the loader widget)
    final showBuf = ctrl.value.isBuffering &&
        ctrl.value.isPlaying &&
        ctrl.value.position > const Duration(milliseconds: 500);

    if (showBuf != _isBuffering) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isBuffering = showBuf);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    // Show full loading screen until controller is ready
    if (ctrl == null ||
        !ctrl.value.isInitialized ||
        ctrl.value.hasError ||
        ctrl.value.duration.inMilliseconds == 0) {
      return const VideoFeedPremiumLoader();
    }

    return SizedBox.expand(
      child: FittedBox(
        key: _playerKey,
        fit: BoxFit.cover,
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: Stack(
            children: [
              VideoPlayer(ctrl),
              if (_isBuffering)
                const VideoFeedViewBufferingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
