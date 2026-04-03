import 'package:flutter/material.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_interaction_buttons.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_user_info_section.dart';

/// Overlay with staggered entrance — user info slides
/// in from the left, interaction buttons from the right.
class VideoFeedViewOverlaySection extends StatefulWidget {
  const VideoFeedViewOverlaySection({
    required this.profileImageUrl,
    required this.username,
    required this.description,
    required this.isBookmarked,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    super.key,
  });
  final String profileImageUrl;
  final String username;
  final String description;
  final bool isBookmarked;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  @override
  State<VideoFeedViewOverlaySection> createState() =>
      _VideoFeedViewOverlaySectionState();
}

class _VideoFeedViewOverlaySectionState
    extends State<VideoFeedViewOverlaySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _userInfoAnim;
  late Animation<double> _buttonsAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _userInfoAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0,
        0.6,
        curve: Curves.easeOut,
      ),
    );
    _buttonsAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.2,
        0.8,
        curve: Curves.easeOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Slide from left + fade
              Transform.translate(
                offset: Offset(
                  -30 * (1 - _userInfoAnim.value),
                  0,
                ),
                child: Opacity(
                  opacity: _userInfoAnim.value,
                  child: VideoFeedViewUserInfoSection(
                    profileImageUrl:
                        widget.profileImageUrl,
                    username: widget.username,
                    description: widget.description,
                  ),
                ),
              ),
              // Slide from right + fade
              Transform.translate(
                offset: Offset(
                  30 * (1 - _buttonsAnim.value),
                  0,
                ),
                child: Opacity(
                  opacity: _buttonsAnim.value,
                  child:
                      VideoFeedViewInteractionButtons(
                    isLiked: widget.isLiked,
                    isBookmarked: widget.isBookmarked,
                    likeCount: widget.likeCount,
                    commentCount: widget.commentCount,
                    shareCount: widget.shareCount,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
