import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCacheManager extends CacheManager {
  static const key = 'ruskVideoCache';

  static final VideoCacheManager _instance = VideoCacheManager._();
  factory VideoCacheManager() => _instance;

  VideoCacheManager._()
      : super(
    Config(
      key,
      maxNrOfCacheObjects: 30,
      stalePeriod: const Duration(days: 14),
    ),
  );
}