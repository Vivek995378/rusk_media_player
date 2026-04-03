import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPreloadService {
  VideoPreloadService({required BaseCacheManager cacheManager})
      : _cacheManager = cacheManager;

  final BaseCacheManager _cacheManager;
  final _preloadQueue = Queue<String>();
  final _preloadedFiles = <String, File>{};
  static const _maxPreloadedFiles = 10;

  Set<String> get preloadedUrls => _preloadedFiles.keys.toSet();

  Future<File> getCachedVideoFile(String videoUrl) async {
    if (_preloadedFiles.containsKey(videoUrl)) {
      return _preloadedFiles[videoUrl]!;
    }
    final fileInfo = await _cacheManager.getFileFromCache(videoUrl);
    final file =
        fileInfo?.file ?? await _cacheManager.getSingleFile(videoUrl);
    _preloadedFiles[videoUrl] = file;
    _evictOldPreloads();
    return file;
  }

  Future<Set<String>> preloadUrls(List<String> urls) async {
    final newlyPreloaded = <String>{};
    for (final url in urls) {
      if (_preloadedFiles.containsKey(url) || _preloadQueue.contains(url)) {
        continue;
      }
      _preloadQueue.add(url);
      try {
        await getCachedVideoFile(url);
        newlyPreloaded.add(url);
      } catch (e) {
        debugPrint('Error preloading video: $e');
      } finally {
        _preloadQueue.remove(url);
      }
    }
    return newlyPreloaded;
  }

  void _evictOldPreloads() {
    while (_preloadedFiles.length > _maxPreloadedFiles) {
      _preloadedFiles.remove(_preloadedFiles.keys.first);
    }
  }

  void dispose() {
    _preloadQueue.clear();
    _preloadedFiles.clear();
  }
}
