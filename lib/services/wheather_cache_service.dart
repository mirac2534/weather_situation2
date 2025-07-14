import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wheather_model.dart';

class WeatherCacheService {
  static const _keyPrefix = 'cached_weather_';

  /// Belirli bir şehir için hava durumu verisini cache'e kaydeder
  static Future<void> cacheWeather(
      String city, List<WheatherModel> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = data.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyPrefix + city, jsonString);
  }

  /// Belirli bir şehir için cache'te kayıtlı olan hava durumu verisini alır
  static Future<List<WheatherModel>?> getCachedWeather(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPrefix + city);
    if (jsonString == null) return null;
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => WheatherModel.fromJson(e)).toList();
  }

  /// Tüm cache kayıtlarını temizler (opsiyonel)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
