import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';

class VideoFeedViewSnapPhysics extends ScrollPhysics {
  const VideoFeedViewSnapPhysics({super.parent});

  @override
  VideoFeedViewSnapPhysics applyTo(ScrollPhysics? ancestor) {
    return VideoFeedViewSnapPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring {
    return const SpringDescription(
      mass: AppSizes.springMass,
      stiffness: AppSizes.springStiffness,
      damping: AppSizes.springDamping,
    );
  }

  @override
  double get minFlingVelocity => AppSizes.minFlingVelocity;

  @override
  double get minFlingDistance => AppSizes.minFlingDistance;
}
