import 'package:hive_flutter/hive_flutter.dart';

abstract final class LocalStorage {
  static const _boxName = 'app_settings';
  static const _hintsShownKey = 'feature_hints_shown';

  static late Box<dynamic> _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static bool get featureHintsShown =>
      _box.get(_hintsShownKey, defaultValue: false) as bool;

  static Future<void> setFeatureHintsShown() =>
      _box.put(_hintsShownKey, true);
}
