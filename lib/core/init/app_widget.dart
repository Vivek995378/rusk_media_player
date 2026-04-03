import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/di/dependency_injector.dart';
import 'package:rusk_media_player/core/init/router/app_router.dart';
import 'package:rusk_media_player/features/splash/presentation/view/splash_view.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: surfaceDark,
        systemNavigationBarIconBrightness:
            Brightness.light,
      ),
    );
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
          textTheme: GoogleFonts.onestTextTheme(),
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
                  setState(
                    () => _splashDone = true,
                  );
                }
              },
            );
          }
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
