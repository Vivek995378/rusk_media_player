import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/di/dependency_injector.dart';
import 'package:rusk_media_player/core/init/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  injectionSetup();
  runApp(const AppWidget());
}
