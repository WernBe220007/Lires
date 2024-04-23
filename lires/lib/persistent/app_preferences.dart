import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences _preferences;
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> getDarkMode() async {
    return _preferences.getBool('darkMode') ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    await _preferences.setBool('darkMode', value);
  }

  static bool getDarkModeSync() {
    return _preferences.getBool('darkMode') ?? false;
  }

  static Future<void> clear() async {
    await _preferences.clear();
  }

  static Future<int> getSelectedColor() async {
    return _preferences.getInt('selectedColor') ?? 0;
  }

  static Future<void> setSelectedColor(int value) async {
    await _preferences.setInt('selectedColor', value);
  }

  static int getSelectedColorSync() {
    return _preferences.getInt('selectedColor') ?? 0;
  }
}