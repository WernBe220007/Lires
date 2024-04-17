import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences _preferences;
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

}