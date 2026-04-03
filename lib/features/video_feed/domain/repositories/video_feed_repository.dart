import 'package:fpdart/fpdart.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';

abstract interface class VideoFeedRepository {
  Future<Either<String, List<VideoEntity>>> fetchVideos();
  Future<Either<String, List<VideoEntity>>> fetchMoreVideos();
}
