import 'package:equatable/equatable.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';

class VideoFeedState extends Equatable {
  const VideoFeedState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isPaginating = false,
    this.hasMoreVideos = true,
    this.errorMessage = '',
    this.videos = const [],
    this.currentIndex = 0,
    this.preloadedVideoUrls = const {},
    this.likedVideoIds = const {},
    this.tutorialActive = true,
  });

  factory VideoFeedState.initial() => const VideoFeedState();

  final bool isLoading;
  final bool isSuccess;
  final bool isPaginating;
  final bool hasMoreVideos;
  final String errorMessage;
  final List<VideoEntity> videos;
  final int currentIndex;
  final Set<String> preloadedVideoUrls;
  final Set<String> likedVideoIds;
  final bool tutorialActive;

  @override
  List<Object?> get props => [
        isLoading, isSuccess, isPaginating, hasMoreVideos,
        errorMessage, videos, currentIndex, preloadedVideoUrls,
        likedVideoIds, tutorialActive,
      ];

  bool isVideoLiked(String videoId) => likedVideoIds.contains(videoId);

  VideoFeedState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isPaginating,
    bool? hasMoreVideos,
    String? errorMessage,
    List<VideoEntity>? videos,
    int? currentIndex,
    Set<String>? preloadedVideoUrls,
    Set<String>? likedVideoIds,
    bool? tutorialActive,
  }) {
    return VideoFeedState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      errorMessage: errorMessage ?? this.errorMessage,
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      preloadedVideoUrls: preloadedVideoUrls ?? this.preloadedVideoUrls,
      likedVideoIds: likedVideoIds ?? this.likedVideoIds,
      tutorialActive: tutorialActive ?? this.tutorialActive,
    );
  }
}
