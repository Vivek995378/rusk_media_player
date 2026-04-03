import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/di/dependency_injector.dart';
import 'package:rusk_media_player/core/init/router/app_router.dart';
import 'package:rusk_media_player/features/splash/presentation/view/splash_view.dart';
import 'package:rusk_media_player/features/tutorial/presentation/view/tutorial_overlay.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  bool _splashDone = false;
  bool _tutorialDone = false;
  static const _tutorialKey = 'tutorial_seen_v1';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: surfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _checkTutorialSeen();
  }

  Future<void> _checkTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_tutorialKey) ?? false;
    if (seen && mounted) {
      setState(() => _tutorialDone = true);
      // Tutorial already seen — mark cubit as inactive immediately
      // (will be done after BlocProvider is ready, so we defer)
    }
  }

  Future<void> _onTutorialComplete(BuildContext blocContext) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
    if (mounted) {
      setState(() => _tutorialDone = true);
      blocContext.read<VideoFeedCubit>().setTutorialActive(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => getIt<VideoFeedCubit>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: surfaceDark,
          textTheme: GoogleFonts.onestTextTheme(
            ThemeData.dark().textTheme,
          ),
          colorScheme: const ColorScheme.dark(
            primary: accentPink,
          ),
        ),
        routerConfig: getIt<AppRouter>().router,
        builder: (context, child) {
          if (!_splashDone) {
            return SplashView(
              onComplete: () {
                if (mounted) {
                  setState(() => _splashDone = true);
                  if (_tutorialDone) {
                    context.read<VideoFeedCubit>().setTutorialActive(false);
                  }
                }
              },
            );
          }
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (!_tutorialDone)
                TutorialOverlay(
                  onComplete: () => _onTutorialComplete(context),
                ),
            ],
          );
        },
      ),
    );
  }
}
