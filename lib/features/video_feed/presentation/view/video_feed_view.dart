import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';
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
  late PreloadPageController _pageController;
  bool _isAppActive = true;
  static const int _loopMultiplier = 10000;
  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = {};
  final Set<String> _initializingControllers = {};
  bool _isTransitioning = false;

  int _getActualIndex(int pageIndex) {
    if (_videos.isEmpty) return 0;
    return pageIndex % _videos.length;
  }

  int get _initialPage => _videos.isEmpty ? 0 : (_loopMultiplier ~/ 2) * _videos.length;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirstVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;
    if (_isAppActive && !wasActive) {
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive) {
      _pauseAllControllers();
    }
  }

  void _initializeFirstVideos() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);
        _pageController.dispose();
        _pageController = PreloadPageController(initialPage: _initialPage);
        await _preloadInitialControllers();
        await _playController(_videos[0].id);
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _preloadInitialControllers() async {
    if (_videos.isEmpty) return;
    final futures = <Future<void>>[];
    for (var i = 0; i < _videos.length.clamp(0, 3); i++) {
      futures.add(_getOrCreateController(_videos[i]));
    }
    await Future.wait(futures);
  }

  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty) return;
    await _pauseAllControllers();
    final actualPage = _getActualIndex(_currentPage);
    final videoId = _videos[actualPage].id;
    final controller = _getController(videoId);
    if (controller != null &&
        (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future<void>.delayed(AppDurations.controllerCleanupDelay);
    }
    await _getOrCreateController(_videos[actualPage]);
    await _playController(videoId);
    if (mounted) setState(() {});
  }

  VideoPlayerController? _getController(String videoId) =>
      _controllerCache[videoId];

  void _touchController(String videoId) {
    _accessOrder
      ..remove(videoId)
      ..add(videoId);
  }

  Future<VideoPlayerController?> _getOrCreateController(
    VideoEntity video,
  ) async {
    if (_controllerCache.containsKey(video.id)) {
      _touchController(video.id);
      return _controllerCache[video.id];
    }
    if (_initializingControllers.contains(video.id)) {
      return null;
    }
    _initializingControllers.add(video.id);
    try {
      final videoFile = await context
          .read<VideoFeedCubit>()
          .getCachedVideoFile(video.videoUrl);
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(VideoFeedViewVolumeGesture.globalVolume);
      if (!mounted) {
        await controller.dispose();
        return null;
      }
      _controllerCache[video.id] = controller;
      _touchController(video.id);
      _enforceCacheLimit();
      if (mounted) setState(() {});
      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    } finally {
      _initializingControllers.remove(video.id);
    }
  }

  Future<void> _playController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      try {
        await controller.setVolume(VideoFeedViewVolumeGesture.globalVolume);
        await controller.play();
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  Future<void> _pauseController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null && controller.value.isInitialized) {
      try {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
        await controller.seekTo(Duration.zero);
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  Future<void> _pauseAllControllers() async {
    final futures = _controllerCache.entries
        .where((e) => e.value.value.isInitialized && e.value.value.isPlaying)
        .map((e) async {
      try {
        await e.value.pause();
        await e.value.seekTo(Duration.zero);
      } catch (_) {}
    });
    await Future.wait(futures);
  }

  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;
    _disposingControllers.add(videoId);
    try {
      final controller = _controllerCache.remove(videoId);
      _accessOrder.remove(videoId);
      if (controller != null) {
        try {
          if (controller.value.isInitialized) await controller.pause();
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  void _enforceCacheLimit() {
    final actualPage = _getActualIndex(_currentPage);
    while (_controllerCache.length > AppSizes.maxControllerCache &&
        _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      if (oldestId != _videos[actualPage].id) {
        _removeController(oldestId);
      } else {
        _accessOrder
          ..removeAt(0)
          ..add(oldestId);
      }
    }
  }

  Future<void> _disposeAllControllers() async {
    _pageController.dispose();
    final futures = _controllerCache.keys.map(_removeController);
    await Future.wait(futures);
    _controllerCache.clear();
    _accessOrder.clear();
  }

  void _preloadAdjacentControllers(int currentPage) {
    if (_videos.isEmpty) return;
    final nextIndex = (currentPage + 1) % _videos.length;
    final prevIndex = (currentPage - 1 + _videos.length) % _videos.length;
    if (!_controllerCache.containsKey(_videos[nextIndex].id)) {
      _getOrCreateController(_videos[nextIndex]);
    }
    if (!_controllerCache.containsKey(_videos[prevIndex].id)) {
      _getOrCreateController(_videos[prevIndex]);
    }
  }

  void _handlePageChange(int newPage) {
    if (_videos.isEmpty || _isTransitioning) return;

    final actualNewPage = _getActualIndex(newPage);
    final actualPreviousPage = _getActualIndex(_currentPage);

    if (actualNewPage == actualPreviousPage) return;

    _isTransitioning = true;
    _currentPage = newPage;

    final previousVideoId = _videos[actualPreviousPage].id;
    final currentVideoId = _videos[actualNewPage].id;

    _pauseController(previousVideoId);

    final currentController = _getController(currentVideoId);
    if (currentController != null && currentController.value.isInitialized) {
      _playController(currentVideoId);
      _isTransitioning = false;
      if (mounted) setState(() {});
    } else {
      _getOrCreateController(_videos[actualNewPage]).then((controller) {
        if (!mounted) return;
        if (controller != null && _getActualIndex(_currentPage) == actualNewPage) {
          _playController(currentVideoId);
        }
        _isTransitioning = false;
        if (mounted) setState(() {});
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preloadAdjacentControllers(actualNewPage);
      context.read<VideoFeedCubit>().onPageChanged(actualNewPage);
      _cleanupDistantControllers(actualNewPage);
    });
  }

  void _cleanupDistantControllers(int currentPage) {
    const keepRange = 2;
    final idsToRemove = <String>[];

    for (final entry in _controllerCache.entries) {
      final videoIndex = _videos.indexWhere((v) => v.id == entry.key);
      if (videoIndex == -1 ||
          (videoIndex < currentPage - keepRange ||
              videoIndex > currentPage + keepRange)) {
        idsToRemove.add(entry.key);
      }
    }

    for (final id in idsToRemove) {
      _removeController(id);
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
          final hadNoVideos = _videos.isEmpty;
          setState(() => _videos = state.videos);
          if (hadNoVideos && _videos.isNotEmpty) {
            _pageController.dispose();
            _pageController = PreloadPageController(initialPage: _initialPage);
            _preloadInitialControllers();
          }
        },
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videos.isEmpty ? 0 : _videos.length * _loopMultiplier,
          preloadPagesCount: 2,
          physics: const VideoFeedViewSnapPhysics(),
          onPageChanged: _handlePageChange,
          itemBuilder: (context, index) {
            final actualIndex = _getActualIndex(index);
            return RepaintBoundary(
              child: VideoFeedViewItem(
                key: ValueKey('${_videos[actualIndex].id}_$index'),
                controller: _getController(_videos[actualIndex].id),
                videoItem: _videos[actualIndex],
              ),
            );
          },
        ),
      ),
    );
  }
}
