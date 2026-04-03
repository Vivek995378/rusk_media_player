import 'package:flutter/foundation.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_volume_gesture.dart';
import 'package:video_player/video_player.dart';

class VideoControllerManager {
  final _cache = <String, VideoPlayerController>{};
  final _accessOrder = <String>[];
  final _disposing = <String>{};

  VideoPlayerController? get(String videoId) => _cache[videoId];

  bool contains(String videoId) => _cache.containsKey(videoId);

  void put(String videoId, VideoPlayerController controller) {
    _cache[videoId] = controller;
    _touch(videoId);
    _enforceCacheLimit();
  }

  void _touch(String videoId) {
    _accessOrder
      ..remove(videoId)
      ..add(videoId);
  }

  Future<void> play(String videoId) async {
    final controller = _cache[videoId];
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isPlaying) {
      return;
    }
    try {
      await controller.setVolume(VideoFeedViewVolumeGesture.globalVolume);
      await controller.play();
    } catch (e) {
      debugPrint('Error playing video: $e');
    }
  }

  Future<void> pauseAll() async {
    for (final controller in List<VideoPlayerController>.from(_cache.values)) {
      try {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  Future<void> remove(String videoId) async {
    if (_disposing.contains(videoId)) return;
    _disposing.add(videoId);
    try {
      final controller = _cache.remove(videoId);
      _accessOrder.remove(videoId);
      if (controller != null) {
        try {
          if (controller.value.isInitialized) await controller.pause();
        } catch (_) {}
        try {
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
      }
    } finally {
      _disposing.remove(videoId);
    }
  }

  void _enforceCacheLimit() {
    while (_cache.length > AppSizes.maxControllerCache &&
        _accessOrder.isNotEmpty) {
      remove(_accessOrder.first);
    }
  }

  Set<String> get cachedIds => _cache.keys.toSet();

  Future<void> disposeAll() async {
    for (final id in List<String>.from(_cache.keys)) {
      await remove(id);
    }
    _cache.clear();
    _accessOrder.clear();
  }
}
