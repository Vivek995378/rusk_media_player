import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusk_media_player/features/video_feed/data/services/video_preload_service.dart';
import 'package:rusk_media_player/features/video_feed/domain/usecases/fetch_more_videos_usecase.dart';
import 'package:rusk_media_player/features/video_feed/domain/usecases/fetch_videos_usecase.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';

class VideoFeedCubit extends Cubit<VideoFeedState> {
  VideoFeedCubit({
    required FetchVideosUseCase fetchVideosUseCase,
    required FetchMoreVideosUseCase fetchMoreVideosUseCase,
    required VideoPreloadService preloadService,
  })  : _fetchVideosUseCase = fetchVideosUseCase,
        _fetchMoreVideosUseCase = fetchMoreVideosUseCase,
        _preloadService = preloadService,
        super(VideoFeedState.initial()) {
    loadVideos();
  }

  final FetchVideosUseCase _fetchVideosUseCase;
  final FetchMoreVideosUseCase _fetchMoreVideosUseCase;
  final VideoPreloadService _preloadService;
  bool _isPreloadingMore = false;

  void toggleLike(String videoId) {
    final updated = Set<String>.from(state.likedVideoIds);
    if (updated.contains(videoId)) {
      updated.remove(videoId);
    } else {
      updated.add(videoId);
    }
    emit(state.copyWith(likedVideoIds: updated));
  }

  void toggleFollow(String username) {
    final updated = Set<String>.from(state.followedUsernames);
    if (updated.contains(username)) {
      updated.remove(username);
    } else {
      updated.add(username);
    }
    emit(state.copyWith(followedUsernames: updated));
  }

  Future<void> loadVideos() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final result = await _fetchVideosUseCase();
    result.fold(
      (error) => emit(
        state.copyWith(isLoading: false, isSuccess: false, errorMessage: error),
      ),
      (videos) {
        final hasMore = videos.length == 2;
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            videos: videos,
            hasMoreVideos: hasMore,
            currentIndex: 0,
            errorMessage: '',
          ),
        );
        if (videos.isNotEmpty) _preloadNext();
      },
    );
  }

  Future<void> loadMoreVideos() async {
    if (state.isPaginating || !state.hasMoreVideos) return;
    emit(state.copyWith(isPaginating: true, errorMessage: ''));
    final result = await _fetchMoreVideosUseCase();
    result.fold(
      (error) =>
          emit(state.copyWith(isPaginating: false, errorMessage: error)),
      (moreVideos) {
        final hasMore = moreVideos.length == 2;
        emit(
          state.copyWith(
            videos: [...state.videos, ...moreVideos],
            isPaginating: false,
            hasMoreVideos: hasMore,
            errorMessage: '',
          ),
        );
        _preloadNext();
      },
    );
  }

  Future<void> onPageChanged(int newIndex) async {
    emit(state.copyWith(currentIndex: newIndex));
    await _preloadNext();
    if (!_isPreloadingMore &&
        state.hasMoreVideos &&
        newIndex >= state.videos.length - 2) {
      _isPreloadingMore = true;
      await loadMoreVideos();
      _isPreloadingMore = false;
    }
  }

  Future<void> _preloadNext() async {
    if (state.videos.isEmpty) return;
    final urls = state.videos
        .skip(state.currentIndex + 1)
        .take(2)
        .map((v) => v.videoUrl)
        .toList();
    final newUrls = await _preloadService.preloadUrls(urls);
    if (newUrls.isNotEmpty) {
      final updated = Set<String>.from(state.preloadedVideoUrls)
        ..addAll(newUrls);
      emit(state.copyWith(preloadedVideoUrls: updated));
    }
  }

  Future<File> getCachedVideoFile(String videoUrl) =>
      _preloadService.getCachedVideoFile(videoUrl);

  @override
  Future<void> close() {
    _preloadService.dispose();
    return super.close();
  }
}
