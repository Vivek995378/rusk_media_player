import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_item.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_snap_physics.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_premium_loader.dart';
import 'package:video_player/video_player.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({super.key});
  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView>
    with WidgetsBindingObserver {
  static const int _maxCacheSize = 3;
  static const int _virtualCount = 100000;

  List<VideoEntity> _videos = [];
  int _currentPage = 0;   // real index
  int _virtualPage = 0;
  PreloadPageController _pageController = PreloadPageController();
  bool _isAppActive = true;
  bool _isAutoScrolling = false;
  bool _wasNearEnd = false;

  // Controller cache: videoId → controller
  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _initializingIds = {};
  final Set<String> _disposingIds = {};

  // Show loading screen randomly every 2–3 videos
  int _scrollCount = 0;
  bool _showBrandLoader = false;
  int _nextLoaderAt = 2; // first trigger after 2 scrolls

  int _realIndex(int virtualIndex) {
    if (_videos.isEmpty) return 0;
    return virtualIndex % _videos.length;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirstVideo();
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
      _onAppResumed();
    } else if (!_isAppActive && wasActive) {
      _pauseAll();
    }
  }

  // ── Initialization ────────────────────────────────────────────────────────

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        final mid = _virtualCount ~/ 2;
        final startPage = mid - (mid % state.videos.length);
        setState(() {
          _videos = state.videos;
          _virtualPage = startPage;
          _currentPage = 0;
          _pageController = PreloadPageController(initialPage: startPage);
        });
        await _initController(0, play: !state.tutorialActive);
      }
    });
  }

  Future<void> _onAppResumed() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;
    final videoId = _videos[_currentPage].id;
    final ctrl = _controllerCache[videoId];
    if (ctrl == null || ctrl.value.hasError || !ctrl.value.isInitialized) {
      await _removeController(videoId);
      await _initController(_currentPage, play: true);
    } else if (!ctrl.value.isPlaying) {
      await ctrl.play();
    }
  }

  // ── Controller lifecycle ──────────────────────────────────────────────────

  /// Initialize controller for [realIndex], optionally start playing.
  /// If [play] is true and the video doesn't load within 5s, auto-scroll next.
  Future<void> _initController(int realIndex, {required bool play}) async {
    if (_videos.isEmpty || realIndex >= _videos.length) return;
    final video = _videos[realIndex];

    // Already cached — just play if needed
    if (_controllerCache.containsKey(video.id)) {
      _touch(video.id);
      if (mounted) setState(() {});
      if (play && !context.read<VideoFeedCubit>().state.tutorialActive) {
        await _playController(video.id);
      }
      return;
    }

    // Prevent duplicate initialization
    if (_initializingIds.contains(video.id)) return;
    _initializingIds.add(video.id);

    // 5s timeout — only applies when this is the active video (play=true)
    if (play) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        // If still not initialized after 5s, skip to next
        if (_initializingIds.contains(video.id) ||
            !_controllerCache.containsKey(video.id)) {
          debugPrint('[VideoFeed] timeout for ${video.id}, skipping');
          _initializingIds.remove(video.id);
          _autoScrollToNext();
        }
      });
    }

    try {
      final file = await context
          .read<VideoFeedCubit>()
          .getCachedVideoFile(video.videoUrl);
      if (!mounted || !_initializingIds.contains(video.id)) return;

      final ctrl = VideoPlayerController.file(file);
      await ctrl.initialize();
      if (!mounted || !_initializingIds.contains(video.id)) {
        await ctrl.dispose();
        return;
      }

      await ctrl.setLooping(true);
      ctrl.addListener(() => _onProgress(ctrl, video.id));
      _controllerCache[video.id] = ctrl;
      _touch(video.id);
      _enforceCacheLimit();

      if (mounted) setState(() {});

      if (play && !context.read<VideoFeedCubit>().state.tutorialActive) {
        await _playController(video.id);
      }
    } catch (e) {
      debugPrint('[VideoFeed] init error for ${video.id}: $e');
      // On error, skip to next if this was the active video
      if (play && mounted) _autoScrollToNext();
    } finally {
      _initializingIds.remove(video.id);
    }
  }

  Future<void> _playController(String videoId) async {
    final ctrl = _controllerCache[videoId];
    if (ctrl == null || !ctrl.value.isInitialized || ctrl.value.isPlaying) {
      return;
    }
    try {
      await ctrl.play();
    } catch (e) {
      debugPrint('[VideoFeed] play error: $e');
    }
  }

  Future<void> _pauseAll() async {
    for (final ctrl in List.of(_controllerCache.values)) {
      try {
        if (ctrl.value.isInitialized && ctrl.value.isPlaying) {
          await ctrl.pause();
        }
      } catch (_) {}
    }
  }

  Future<void> _removeController(String videoId) async {
    if (_disposingIds.contains(videoId)) return;
    _disposingIds.add(videoId);
    _initializingIds.remove(videoId); // cancel any in-flight init
    try {
      final ctrl = _controllerCache.remove(videoId);
      _accessOrder.remove(videoId);
      if (ctrl != null) {
        try {
          if (ctrl.value.isInitialized) await ctrl.pause();
          await ctrl.dispose();
        } catch (_) {}
      }
    } finally {
      _disposingIds.remove(videoId);
    }
  }

  void _touch(String videoId) {
    _accessOrder
      ..remove(videoId)
      ..add(videoId);
  }

  void _enforceCacheLimit() {
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.first;
      // Never evict the current video
      if (oldest == _videos[_currentPage].id) {
        if (_accessOrder.length > 1) {
          _removeController(_accessOrder[1]);
        }
        break;
      }
      _removeController(oldest);
    }
  }

  Future<void> _disposeAllControllers() async {
    _pageController.dispose();
    _initializingIds.clear();
    for (final id in List.of(_controllerCache.keys)) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  // ── Progress / auto-scroll ────────────────────────────────────────────────

  void _onProgress(VideoPlayerController ctrl, String videoId) {
    if (!mounted || _isAutoScrolling) return;
    if (_videos.isEmpty) return;
    if (_videos[_currentPage].id != videoId) return;
    final val = ctrl.value;
    if (!val.isInitialized || val.duration == Duration.zero) return;
    final nearEnd = val.position >= val.duration - const Duration(milliseconds: 500);
    final nearStart = val.position < const Duration(milliseconds: 500);
    if (nearEnd) _wasNearEnd = true;
    if (_wasNearEnd && nearStart) {
      _wasNearEnd = false;
      _autoScrollToNext();
    }
  }

  Future<void> _autoScrollToNext() async {
    if (_isAutoScrolling || _videos.isEmpty) return;
    _isAutoScrolling = true;
    await _pageController.animateToPage(
      _virtualPage + 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
    _isAutoScrolling = false;
  }

  // ── Page change ───────────────────────────────────────────────────────────

  Future<void> _handlePageChange(int newVirtual) async {
    if (_videos.isEmpty) return;
    final prevVirtual = _virtualPage;
    final newReal = _realIndex(newVirtual);
    _virtualPage = newVirtual;
    _currentPage = newReal;
    _wasNearEnd = false;

    // Track scrolls and show brand loader randomly every 2–3 videos
    _scrollCount++;
    if (_scrollCount >= _nextLoaderAt && !_showBrandLoader) {
      // Schedule next trigger randomly 2 or 3 scrolls from now
      _nextLoaderAt = _scrollCount + 2 + (DateTime.now().millisecond % 2);
      setState(() => _showBrandLoader = true);
      await _pauseAll();
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _showBrandLoader = false);
          _initController(_currentPage, play: true);
        }
      });
      return;
    }

    // Pause everything immediately
    await _pauseAll();

    // On fast scroll, evict all except destination
    final isFast = (newVirtual - prevVirtual).abs() > 1;
    if (isFast) {
      final keep = _videos[newReal].id;
      for (final id in List.of(_controllerCache.keys)) {
        if (id != keep) await _removeController(id);
      }
    } else {
      // Evict controllers outside the ±1 window
      final prevReal = _realIndex(prevVirtual);
      final nextReal = _realIndex(newVirtual + 1);
      final keep = {
        _videos[newReal].id,
        _videos[prevReal].id,
        _videos[nextReal].id,
      };
      for (final id in List.of(_controllerCache.keys)) {
        if (!keep.contains(id)) await _removeController(id);
      }
    }

    // Init & play current
    await _initController(newReal, play: true);

    // Pre-warm adjacent (fire and forget)
    final nextReal = _realIndex(newVirtual + 1);
    final prevReal = _realIndex(newVirtual - 1);
    if (nextReal != newReal) {
      unawaited(_initController(nextReal, play: false));
    }
    if (prevReal != newReal && prevReal != nextReal) {
      unawaited(_initController(prevReal, play: false));
    }

    if (mounted) {
      await context.read<VideoFeedCubit>().onPageChanged(newReal);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocListener<VideoFeedCubit, VideoFeedState>(
        listenWhen: (p, c) =>
            p.videos != c.videos ||
            p.isLoading != c.isLoading ||
            p.tutorialActive != c.tutorialActive,
        listener: (context, state) {
          if (state.videos.length != _videos.length) {
            setState(() => _videos = state.videos);
          }
          // Tutorial ended → seek to start and play
          if (!state.tutorialActive) {
            final ctrl = _controllerCache[_videos[_currentPage].id];
            ctrl?.seekTo(Duration.zero);
            _initController(_currentPage, play: true);
          }
        },
        child: _videos.isEmpty
            ? const SizedBox.shrink()
            : Stack(
                children: [
                  PreloadPageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    itemCount: _virtualCount,
                    physics: const VideoFeedViewSnapPhysics(),
                    onPageChanged: _handlePageChange,
                    itemBuilder: (context, index) {
                      final realIdx = _realIndex(index);
                      final video = _videos[realIdx];
                      return RepaintBoundary(
                        child: VideoFeedViewItem(
                          key: ValueKey('${video.id}_$index'),
                          controller: _controllerCache[video.id],
                          videoItem: video,
                        ),
                      );
                    },
                  ),
                  // Brand loading screen shown after 2nd scroll
                  if (_showBrandLoader)
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: _showBrandLoader ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: const VideoFeedPremiumLoader(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Fire-and-forget helper
void unawaited(Future<void> future) {
  future.catchError((Object e) => debugPrint('[unawaited] $e'));
}
