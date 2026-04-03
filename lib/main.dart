import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/di/dependency_injector.dart';
import 'package:rusk_media_player/core/init/app_widget.dart';
import 'package:rusk_media_player/core/utils/helpers/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  injectionSetup();
  runApp(const AppWidget());
}
