import 'package:flutter/material.dart';

String getWeatherAnimation(String description) {
  final d = description.toLowerCase().trim();

  if (d.contains("bulutlu") ||
      d.contains("parçalı bulutlu") ||
      d.contains("parçalı az bulutlu") ||
      d.contains("kapalı") ||
      d.contains("few clouds") ||
      d.contains("scattered clouds")) {
    return "cloudy.json";
  }

  if (d.contains("güneşli") ||
      d.contains("sunny") ||
      d.contains("açık") ||
      d.contains("clear")) {
    return "sunny.json";
  }

  if (d.contains("hafif yağmur") ||
      d.contains("hafif yağmurlu") ||
      d.contains("drizzle") ||
      d.contains("light rain") ||
      d.contains("orta şiddetli yağmur")) {
    return "partlyRain.json";
  }

  if (d.contains("yağmur") || d.contains("rain")) {
    return "rainy.json";
  }

  if (d.contains("fırtına") || d.contains("storm")) {
    return "storm.json";
  }

  if (d.contains("kar") || d.contains("snow")) {
    return "snow.json";
  }

  // Bilinmeyen durumlarda varsayılan animasyon
  return "rainy.json";
}

LinearGradient getBackgroundGradient(String weatherMain) {
  final main = weatherMain.toLowerCase();
  List<Color> colors;

  if (main.contains('güneşli') || main.contains('açık')) {
    colors = [Color(0xFF4facfe), Color(0xFFfbd786)];
  } else if (main.contains('bulutlu') || main.contains('parçalı')) {
    colors = [Color(0xFFbdc3c7), Color(0xFF2c3e50)];
  } else if (main.contains('yağmur') || main.contains('sağanak')) {
    colors = [Color(0xFF283e51), Color(0xFF485563)];
  } else if (main.contains('kar') || main.contains('karlı')) {
    colors = [Color(0xFFe0eafc), Color(0xFFcfdef3)];
  } else if (main.contains('fırtına') || main.contains('gök gürültülü')) {
    colors = [Colors.deepPurple, Colors.black];
  } else if (main.contains('sisli') || main.contains('puslu')) {
    colors = [Colors.grey.shade400, Colors.blueGrey];
  } else if (main.contains('hafif yağmur') ||
      main.contains("orta şiddetli yağmur") ||
      main.contains("hafif yağmurlu")) {
    colors = [Color(0xFFa1c4fd), Color(0xFFc2e9fb)];
  } else {
    colors = [Colors.blueGrey, Colors.grey];
  }

  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );
}
