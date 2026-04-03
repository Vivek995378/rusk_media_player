import 'package:get_it/get_it.dart';
import 'package:rusk_media_player/core/init/router/app_router.dart';
import 'package:rusk_media_player/features/video_feed/data/repository_impl/video_feed_repository_impl.dart';
import 'package:rusk_media_player/features/video_feed/domain/repositories/video_feed_repository.dart';
import 'package:rusk_media_player/features/video_feed/domain/usecases/fetch_more_videos_usecase.dart';
import 'package:rusk_media_player/features/video_feed/domain/usecases/fetch_videos_usecase.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  getIt
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerLazySingleton<VideoFeedRepository>(
      VideoFeedRepositoryImpl.new,
    )
    ..registerLazySingleton<FetchVideosUseCase>(
      () => FetchVideosUseCase(
        repository: getIt<VideoFeedRepository>(),
      ),
    )
    ..registerLazySingleton<FetchMoreVideosUseCase>(
      () => FetchMoreVideosUseCase(
        repository: getIt<VideoFeedRepository>(),
      ),
    )
    ..registerFactory<VideoFeedCubit>(
      () => VideoFeedCubit(
        fetchVideosUseCase: getIt<FetchVideosUseCase>(),
        fetchMoreVideosUseCase: getIt<FetchMoreVideosUseCase>(),
      ),
    );
}
