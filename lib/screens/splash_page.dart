import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Gerekli import
import 'package:lottie/lottie.dart';
import 'package:hava_durumu/screens/home_page.dart';
import 'package:hava_durumu/services/wheater_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Status bar ve navigation bar'ı gizle
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(vsync: this);
    _loadAndAnimate();
  }

  Future<void> _loadAndAnimate() async {
    // 1. Lottie dosyasını yükle, kompozisyonu al
    final composition = await LottieComposition.fromByteData(
      await DefaultAssetBundle.of(context)
          .load('assets/animations/loadingAnimation.json'),
    );
    _controller.duration = composition.duration;
    _controller.repeat(); // Kesin döngü

    // 2. Verileri al
    final start = DateTime.now();
    String? city = await WheaterService().getLocation();
    city ??= await WheaterService.getLastKnownCity() ?? "İstanbul";
    final weatherList = await WheaterService().getWeatherData(cityName: city);
    final elapsed = DateTime.now().difference(start);
    if (elapsed < const Duration(seconds: 6)) {
      await Future.delayed(const Duration(seconds: 6) - elapsed);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(city: city!, initialWeather: weatherList),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.7;
    final h = MediaQuery.of(context).size.height * 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/loadingAnimation.json',
          controller: _controller,
          width: w,
          height: h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
