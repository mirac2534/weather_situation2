import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> scheduleDailyWeatherNotification({
    required String cityName,
    required TimeOfDay time,
  }) async {
    final weather = await _fetchWeather(cityName);
    if (weather == null) return;

    final durum = weather['durum'];
    final sicaklik = weather['sicaklik'];
    final oneri = _generateSuggestion(durum);

    await _notificationsPlugin.zonedSchedule(
      0,
      ' $cityName için Hava Durumu',
      'Bugün $durum, sıcaklık $sicaklik°C. $oneri',
      _nextNotificationTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_channel',
          'Hava Durumu Bildirimleri',
          channelDescription: 'Günlük hava durumu bildirimi',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextNotificationTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<Map<String, dynamic>?> _fetchWeather(String city) async {
    const apiKey =
        "apikey 4I8DBYg8ETDeJrEZwwa0Pl:3Ht4IwjahVH2H75O2ecEDa"; // 🔑 Burayı kendi API anahtarınla değiştir!
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&lang=tr&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          'durum': jsonData['weather'][0]['description'],
          'sicaklik': jsonData['main']['temp'].round(),
        };
      }
    } catch (e) {
      print("🔴 Hava verisi alınamadı: $e");
    }
    return null;
  }

  static String _generateSuggestion(String durum) {
    final lower = durum.toLowerCase();

    if (lower.contains('yağmur')) return 'Şemsiyeni almayı unutma!';
    if (lower.contains('güneş') || lower.contains('açık'))
      return 'Güneş gözlüğü takmayı unutma!';
    if (lower.contains('kar')) return 'Kalın giyinmeyi unutma!';
    if (lower.contains('bulut')) return 'Hafif serin olabilir.';
    if (lower.contains('fırtına') || lower.contains('gök gürültüsü'))
      return 'Dışarı çıkarken dikkatli ol!';
    if (lower.contains('sis') || lower.contains('pus'))
      return 'Trafikte dikkatli ol!';
    return 'Hava durumuna dikkat et!';
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
