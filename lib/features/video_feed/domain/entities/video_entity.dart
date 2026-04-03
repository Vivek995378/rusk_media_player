import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  const VideoEntity({
    required this.id,
    required this.username,
    required this.description,
    required this.videoUrl,
    required this.profileImageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.timestamp,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  final String id;
  final String username;
  final String description;
  final String videoUrl;
  final String profileImageUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime timestamp;
  final bool isLiked;
  final bool isBookmarked;

  VideoEntity copyWith({
    String? id,
    String? username,
    String? description,
    String? videoUrl,
    String? profileImageUrl,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    DateTime? timestamp,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return VideoEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [
        id, username, description, videoUrl, profileImageUrl,
        likeCount, commentCount, shareCount, timestamp,
        isLiked, isBookmarked,
      ];
}
