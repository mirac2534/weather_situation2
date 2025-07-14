import 'package:flutter/material.dart';
import 'package:hava_durumu/screens/splash_page.dart';
import 'package:hava_durumu/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bildirim sistemini başlatır
  await NotificationService.init();

  // Kesin alarm izni talep eder (Android 12+)
  await requestExactAlarmPermission();

  // Zaman dilimlerini başlatır ve İstanbul saatine ayarlar
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  // Android 13+ için runtime bildirim izni kontrolü ve isteği
  final permissionStatus = await Permission.notification.status;
  if (permissionStatus != PermissionStatus.granted) {
    await Permission.notification.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

// Kullanıcıdan kesin alarm izni talep eden fonksiyon
Future<void> requestExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  if (status != PermissionStatus.granted) {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  } else {
    print("Exact alarm izni zaten verilmiş.");
  }
}
