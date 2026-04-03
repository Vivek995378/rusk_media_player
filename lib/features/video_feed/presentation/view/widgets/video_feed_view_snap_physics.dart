import 'package:flutter/material.dart';

/// Smooth, TikTok/Reels-style scroll physics for the vertical video feed.
///
/// Extends [PageScrollPhysics] to get proper page-snapping behaviour,
/// then overrides the spring for a buttery-smooth settle and lowers
/// fling thresholds so even a light swipe commits to the next page.
class VideoFeedViewSnapPhysics extends PageScrollPhysics {
  const VideoFeedViewSnapPhysics({super.parent});

  @override
  VideoFeedViewSnapPhysics applyTo(ScrollPhysics? ancestor) {
    return VideoFeedViewSnapPhysics(
      parent: buildParent(ancestor),
    );
  }

  /// Soft spring → smooth deceleration with a gentle settle.
  /// - Lower mass  = faster response to user input.
  /// - Moderate stiffness = snaps without feeling harsh.
  /// - Higher damping = no overshoot / bounce at the end.
  @override
  SpringDescription get spring {
    return const SpringDescription(
      mass: 0.4,
      stiffness: 100,
      damping: 16,
    );
  }

  /// A light flick is enough to move to the next video.
  @override
  double get minFlingVelocity => 80;

  /// A small drag distance commits to the page change.
  @override
  double get minFlingDistance => 30;

  /// Drag threshold as a fraction of the viewport.
  /// 15% drag = commit to next page (default is ~50%).
  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}
