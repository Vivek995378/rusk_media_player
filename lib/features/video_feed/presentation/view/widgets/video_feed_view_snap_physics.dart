import 'package:flutter/material.dart';

/// Snappy scroll physics for the vertical video feed.
/// Lower thresholds + higher velocity = instant-feeling
/// page transitions like TikTok / Reels.
class VideoFeedViewSnapPhysics
    extends ScrollPhysics {
  const VideoFeedViewSnapPhysics({super.parent});

  @override
  VideoFeedViewSnapPhysics applyTo(
    ScrollPhysics? ancestor,
  ) {
    return VideoFeedViewSnapPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  SpringDescription get spring {
    return const SpringDescription(
      mass: 0.3,
      stiffness: 300,
      damping: 22,
    );
  }

  /// Lower velocity threshold so even a light flick
  /// triggers a page change.
  @override
  double get minFlingVelocity => 50;

  /// Lower distance threshold so a small drag commits
  /// to the next page.
  @override
  double get minFlingDistance => 20;
}
