import 'package:fpdart/fpdart.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/domain/repositories/video_feed_repository.dart';

class FetchVideosUseCase {
  FetchVideosUseCase({required VideoFeedRepository repository})
      : _repository = repository;
  final VideoFeedRepository _repository;

  Future<Either<String, List<VideoEntity>>> call() =>
      _repository.fetchVideos();
}
