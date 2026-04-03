enum RouterEnum {
  dashboardView('/dashboard_view'),
  videoFeedView('/video_feed_view'),
  profileView('/profile_view');

  const RouterEnum(this.routeName);
  final String routeName;
}
