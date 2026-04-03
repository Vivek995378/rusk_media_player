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
  VideoPlayerController? _oldController;
  String? _currentVideoId;
  bool _isPlaying = false;
  Key _playerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _oldController = widget.controller;
    _currentVideoId = widget.videoId;
    _addControllerListener();
  }

  void _addControllerListener() {
    if (widget.controller != null) {
      _isBuffering =
          widget.controller!.value.isBuffering;
      _isPlaying =
          widget.controller!.value.isPlaying;
      widget.controller!
          .addListener(_onControllerUpdate);
    }
  }

  @override
  void didUpdateWidget(
    VideoFeedViewOptimizedVideoPlayer oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final videoIdChanged =
        widget.videoId != _currentVideoId;
    final controllerChanged =
        widget.controller != _oldController;
    if (videoIdChanged || controllerChanged) {
      _oldController
          ?.removeListener(_onControllerUpdate);
      _oldController = widget.controller;
      _currentVideoId = widget.videoId;
      _playerKey = UniqueKey();
      _addControllerListener();
      final shouldUpdateBuffering =
          widget.controller?.value.isBuffering ?? false;
      if (mounted &&
          _isBuffering != shouldUpdateBuffering) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(
              () => _isBuffering = shouldUpdateBuffering,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _oldController?.removeListener(_onControllerUpdate);
    _oldController = null;
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final controller = widget.controller;
    if (controller == null ||
        widget.videoId != _currentVideoId) {
      return;
    }
    if (controller.value.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isBuffering = false);
        }
      });
      return;
    }
    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;
    var shouldShowBuffering = isBuffering;
    if ((isPlaying &&
            controller.value.position > Duration.zero) ||
        (controller.value.position > Duration.zero &&
            controller.value.duration.inMilliseconds >
                0)) {
      shouldShowBuffering = false;
    }
    if (_isBuffering != shouldShowBuffering ||
        _isPlaying != isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isBuffering = shouldShowBuffering;
            _isPlaying = isPlaying;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.hasError ||
        controller.value.duration.inMilliseconds == 0) {
      return const VideoFeedPremiumLoader();
    }

    return SizedBox.expand(
      child: FittedBox(
        key: _playerKey,
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: Stack(
            children: [
              VideoPlayer(controller),
              if (_isBuffering)
                const VideoFeedViewBufferingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
