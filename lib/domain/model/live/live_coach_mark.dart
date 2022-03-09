import 'package:shared_preferences/shared_preferences.dart';

class LiveCoachMark {

  static const KEY_IS_SHOW_COACH = 'is_show_coach';

  static Future<bool> isShowCoachMark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_IS_SHOW_COACH);
  }

  static void saveShowCoachMark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_IS_SHOW_COACH, true);
  }

  static void initShowCoachMark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_IS_SHOW_COACH, false);
  }
}