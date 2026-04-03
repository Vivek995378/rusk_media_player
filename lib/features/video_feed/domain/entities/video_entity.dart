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

  @override
  List<Object?> get props => [
        id, username, description, videoUrl, profileImageUrl,
        likeCount, commentCount, shareCount, timestamp,
        isLiked, isBookmarked,
      ];
}
