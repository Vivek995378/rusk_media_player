import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rusk_media_player/core/utils/constants/enums/router_enum.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/video_feed_view.dart';

final _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        RouterEnum.videoFeedView.routeName,
    routes: [
      GoRoute(
        path: RouterEnum
            .videoFeedView.routeName,
        builder: (context, state) =>
        const VideoFeedView(),
      ),
    ],
  );
}
