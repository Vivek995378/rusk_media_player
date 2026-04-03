import 'package:fpdart/fpdart.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/features/video_feed/data/datasources/static_video_data.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/domain/repositories/video_feed_repository.dart';

class VideoFeedRepositoryImpl implements VideoFeedRepository {
  int _currentOffset = 0;

  @override
  Future<Either<String, List<VideoEntity>>> fetchVideos() async {
    try {
      _currentOffset = 0;
      final allVideos = StaticVideoData.videos;
      final end = AppSizes.paginationPageSize.clamp(0, allVideos.length);
      final batch = allVideos.sublist(0, end);
      _currentOffset = end;
      await Future<void>.delayed(AppDurations.networkDelay);
      return Right(batch);
    } catch (e) {
      return const Left('Failed to fetch videos');
    }
  }

  @override
  Future<Either<String, List<VideoEntity>>> fetchMoreVideos() async {
    try {
      final allVideos = StaticVideoData.videos;
      if (_currentOffset >= allVideos.length) {
        return const Right([]);
      }
      final end = (_currentOffset + AppSizes.paginationPageSize)
          .clamp(0, allVideos.length);
      final batch = allVideos.sublist(_currentOffset, end);
      _currentOffset = end;
      await Future<void>.delayed(AppDurations.networkDelay);
      return Right(batch);
    } catch (e) {
      return const Left('Failed to fetch more videos');
    }
  }
}
