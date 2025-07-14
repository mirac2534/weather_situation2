import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/models/wheather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WheaterService {
  static const _apiKey = "apikey 4I8DBYg8ETDeJrEZwwa0Pl:3Ht4IwjahVH2H75O2ecEDa";

  // We check to see if the user's location is clear
  Future<String> getLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Konum kapalı");
    }

    // We will check whether the user has given the location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Konum izni vermelisiniz");
      }
    }

    // We have taken the user's position
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // We found the location point from the user position
    final List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // We recorded our city from the location point
    final String? city = placemark[0].administrativeArea;
    if (city == null) throw Exception("Bir sorun oluştu");

    // Save city for offline use
    await saveLastKnownCity(city);

    return city;
  }

  // If the cityName parameter is full, use it
  Future<List<WheatherModel>> getWeatherData(
      {String? cityName, bool forceRefresh = false}) async {
    final String city = cityName ?? await getLocation();

    if (!forceRefresh) {
      final cached = await _getCachedWeather(city);
      if (cached != null) {
        return cached;
      }
    }

    final String url =
        'https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$city';

    const Map<String, dynamic> headers = {
      "authorization": _apiKey,
      "content-type": "application/json"
    };

    final dio = Dio();
    final response = await dio.get(url, options: Options(headers: headers));
    if (response.statusCode != 200) {
      throw Exception("API isteği başarısız");
    }

    final List list = response.data['result'];
    final List<WheatherModel> weatherList =
        list.map((e) => WheatherModel.fromJson(e)).toList();

    // Cache weather data
    await _cacheWeather(city, weatherList);

    return weatherList;
  }

  // Save weather data to SharedPreferences
  Future<void> _cacheWeather(String city, List<WheatherModel> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.map((e) => e.toJson()).toList());
    prefs.setString('weather_$city', jsonString);
    prefs.setInt('weather_time_$city', DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached data if not expired (30 minutes)
  Future<List<WheatherModel>?> _getCachedWeather(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('weather_$city');
    final timestamp = prefs.getInt('weather_time_$city');

    if (jsonString == null || timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > Duration(minutes: 30).inMilliseconds) return null;

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => WheatherModel.fromJson(e)).toList();
  }

  // Save last known city for offline fallback
  static Future<void> saveLastKnownCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);
  }

  // Get last known city if available
  static Future<String?> getLastKnownCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_city');
  }
}
