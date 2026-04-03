import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/video_controller_manager.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_item.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_snap_physics.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_volume_gesture.dart';
import 'package:video_player/video_player.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({super.key});
  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView>
    with WidgetsBindingObserver {
  List<VideoEntity> _videos = [];
  int _currentPage = 0;
  final PreloadPageController _pageController = PreloadPageController();
  bool _isAppActive = true;
  final _controllerManager = VideoControllerManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirstVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _controllerManager.disposeAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;
    if (_isAppActive && !wasActive) {
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive) {
      _controllerManager.pauseAll();
    }
  }

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);
        await _initAndPlayVideo(0);
      }
    });
  }

  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;
    await _controllerManager.pauseAll();
    final videoId = _videos[_currentPage].id;
    final controller = _controllerManager.get(videoId);
    if (controller != null &&
        (controller.value.hasError || !controller.value.isInitialized)) {
      await _controllerManager.remove(videoId);
      await Future<void>.delayed(AppDurations.controllerCleanupDelay);
    }
    await _initAndPlayVideo(_currentPage);
  }

  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length) return;
    final video = _videos[index];
    await _getOrCreateController(video);
    await _controllerManager.play(video.id);
    if (mounted) setState(() {});
  }

  Future<VideoPlayerController?> _getOrCreateController(
    VideoEntity video,
  ) async {
    if (_controllerManager.contains(video.id)) {
      return _controllerManager.get(video.id);
    }
    try {
      final videoFile = await context
          .read<VideoFeedCubit>()
          .getCachedVideoFile(video.videoUrl);
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(VideoFeedViewVolumeGesture.globalVolume);
      _controllerManager.put(video.id, controller);
      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  Future<void> _manageControllerWindow(int currentPage) async {
    if (_videos.isEmpty) return;
    final windowStart = (currentPage - 1).clamp(0, _videos.length - 1);
    final windowEnd = (currentPage + 1).clamp(0, _videos.length - 1);
    final idsToKeep = <String>{};
    for (var i = windowStart; i <= windowEnd; i++) {
      if (i < _videos.length) idsToKeep.add(_videos[i].id);
    }
    for (final id
        in _controllerManager.cachedIds.where((id) => !idsToKeep.contains(id)).toList()) {
      await _controllerManager.remove(id);
    }
    if (currentPage < _videos.length) {
      await _getOrCreateController(_videos[currentPage]);
      if (windowStart < currentPage && windowStart >= 0) {
        await _getOrCreateController(_videos[windowStart]);
      }
      if (windowEnd > currentPage && windowEnd < _videos.length) {
        await _getOrCreateController(_videos[windowEnd]);
      }
    }
  }

  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage >= _videos.length) return;

    if (newPage == _currentPage && _currentPage != 0) return;

    final previousPage = _currentPage;
    _currentPage = newPage;
    final isFastScroll = (newPage - previousPage).abs() > 1;

    _controllerManager.pauseAll();

    try {
      if (isFastScroll) {
        final videoId = _videos[newPage].id;
        for (final id in _controllerManager.cachedIds
            .where((id) => id != videoId)
            .toList()) {
          unawaited(_controllerManager.remove(id));
        }
      }

      await _initAndPlayVideo(newPage);

      unawaited(_manageControllerWindow(newPage));

      if (mounted) {
        unawaited(context.read<VideoFeedCubit>().onPageChanged(newPage));
      }
    } catch (e) {
      debugPrint('Error handling page change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocListener<VideoFeedCubit, VideoFeedState>(
        listenWhen: (p, c) =>
            p.videos != c.videos ||
            p.isLoading != c.isLoading ||
            p.preloadedVideoUrls != c.preloadedVideoUrls,
        listener: (context, state) {
          setState(() => _videos = state.videos);
          _manageControllerWindow(_currentPage);
        },
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videos.length,
          preloadPagesCount: 1,
          physics: const VideoFeedViewSnapPhysics(),
          onPageChanged: _handlePageChange,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: VideoFeedViewItem(
                key: ValueKey(_videos[index].id),
                controller: _controllerManager.get(_videos[index].id),
                videoItem: _videos[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
