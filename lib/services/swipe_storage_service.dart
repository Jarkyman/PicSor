import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SwipeStorageService {
  static const String keySwipeActions = 'swiped_assets';
  static const String keySwipesLeft = 'swipes_remaining';
  static const String keyLastSwipeDate = 'last_swipe_date';
  static const String keyLastRefill = 'last_refill';

  static Future<Map<String, String>> loadSwipeActions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keySwipeActions);
    if (jsonStr == null) return {};
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<void> saveSwipeActions(Map<String, String> actions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySwipeActions, jsonEncode(actions));
  }

  static Future<int> loadSwipesLeft(int defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keySwipesLeft) ?? defaultValue;
  }

  static Future<void> saveSwipesLeft(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keySwipesLeft, value);
  }

  static Future<String?> loadLastSwipeDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastSwipeDate);
  }

  static Future<void> saveLastSwipeDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastSwipeDate, date);
  }

  static Future<String?> loadLastRefill() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastRefill);
  }

  static Future<void> saveLastRefill(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastRefill, date);
  }
}
