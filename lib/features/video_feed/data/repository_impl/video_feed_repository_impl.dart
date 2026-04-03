import 'package:fpdart/fpdart.dart';
import 'package:rusk_media_player/features/video_feed/data/datasources/static_video_data.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/domain/repositories/video_feed_repository.dart';

class VideoFeedRepositoryImpl implements VideoFeedRepository {
  @override
  Future<Either<String, List<VideoEntity>>> fetchVideos() async {
    try {
      // Load all videos upfront — circular scrolling handles infinite loop
      final videos = List<VideoEntity>.from(StaticVideoData.videos);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return Right(videos);
    } catch (e) {
      return const Left('Failed to fetch videos');
    }
  }

  @override
  Future<Either<String, List<VideoEntity>>> fetchMoreVideos() async {
    // No pagination needed — all videos loaded upfront, circular scroll wraps
    return const Right([]);
  }
}
