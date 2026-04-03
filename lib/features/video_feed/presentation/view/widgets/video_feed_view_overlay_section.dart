import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_interaction_buttons.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_user_info_section.dart';

class VideoFeedViewOverlaySection extends StatefulWidget {
  const VideoFeedViewOverlaySection({
    required this.profileImageUrl,
    required this.username,
    required this.description,
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    super.key,
  });

  final String profileImageUrl;
  final String username;
  final String description;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  @override
  State<VideoFeedViewOverlaySection> createState() =>
      _VideoFeedViewOverlaySectionState();
}

class _VideoFeedViewOverlaySectionState
    extends State<VideoFeedViewOverlaySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _userInfoAnim;
  late final Animation<double> _buttonsAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.overlayAnimation,
    );
    _userInfoAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _buttonsAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Transform.translate(
                  offset: Offset(-30 * (1 - _userInfoAnim.value), 0),
                  child: Opacity(
                    opacity: _userInfoAnim.value,
                    child: VideoFeedViewUserInfoSection(
                      profileImageUrl: widget.profileImageUrl,
                      username: widget.username,
                      description: widget.description,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(30 * (1 - _buttonsAnim.value), 0),
                child: Opacity(
                  opacity: _buttonsAnim.value,
                  child: VideoFeedViewInteractionButtons(
                    isLiked: widget.isLiked,
                    onLikeTap: widget.onLikeTap,
                    onCommentTap: widget.onCommentTap,
                    onShareTap: widget.onShareTap,
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
