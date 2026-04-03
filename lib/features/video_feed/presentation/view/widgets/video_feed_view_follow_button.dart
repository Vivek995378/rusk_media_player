import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';

class VideoFeedViewFollowButton extends StatefulWidget {
  const VideoFeedViewFollowButton({required this.username, super.key});

  final String username;

  @override
  State<VideoFeedViewFollowButton> createState() =>
      _VideoFeedViewFollowButtonState();
}

class _VideoFeedViewFollowButtonState extends State<VideoFeedViewFollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.followButtonScale,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
    context.read<VideoFeedCubit>().toggleFollow(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<VideoFeedCubit, VideoFeedState, bool>(
      selector: (state) => state.isUserFollowed(widget.username),
      builder: (context, isFollowing) {
        return GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: AppDurations.followButtonContainer,
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: context.w(12),
                vertical: context.h(4),
              ),
              margin: context.paddingLeft(10),
              decoration: BoxDecoration(
                gradient: isFollowing ? null : followButtonGradient,
                color: isFollowing ? white.withValues(alpha: 0.15) : null,
                borderRadius: context.radiusAll(8),
              ),
              child: AppText(
                isFollowing
                    ? AppStrings.followingLabel
                    : AppStrings.followLabel,
                style: AppTextStyle.titleSmall,
                color: MENeutralColors.neutral0,
              ),
            ),
          ),
        );
      },
    );
  }
}
