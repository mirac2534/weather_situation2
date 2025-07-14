import 'package:flutter/material.dart';
import 'package:hava_durumu/models/wheather_model.dart';
import 'package:lottie/lottie.dart';
import 'package:hava_durumu/utils/weather_utils.dart';

class WeatherCard extends StatelessWidget {
  final String city;
  final WheatherModel weather;
  final bool isSmall;
  final bool showCityName;

  const WeatherCard({
    Key? key,
    required this.city,
    required this.weather,
    this.isSmall = false,
    this.showCityName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    if (!isSmall) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: deviceHeight * 0.012,
          horizontal: deviceWidth * 0.015,
        ),
        padding: EdgeInsets.all(deviceWidth * 0.038),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(deviceWidth * 0.06),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/${getWeatherAnimation(weather.durum)}',
              width: deviceWidth * 0.26,
              height: deviceWidth * 0.26,
              fit: BoxFit.contain,
            ),
            SizedBox(height: deviceHeight * 0.012),
            Text(
              weather.gun,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: deviceWidth * 0.05,
                shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
              ),
            ),
            SizedBox(height: deviceHeight * 0.008),
            Text(
              weather.durum,
              style: TextStyle(
                color: Colors.white,
                fontSize: deviceWidth * 0.043,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
            SizedBox(height: deviceHeight * 0.008),
            Text(
              'Gündüz: ${double.parse(weather.max).round()}°C  Gece: ${double.parse(weather.min).round()}°C',
              style: TextStyle(
                color: Colors.white,
                fontSize: deviceWidth * 0.038,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
            SizedBox(height: deviceHeight * 0.005),
            Text(
              'Nem: %${double.parse(weather.nem).round()}',
              style: TextStyle(
                color: Colors.white,
                fontSize: deviceWidth * 0.035,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: deviceHeight * 0.008,
        horizontal: deviceWidth * 0.010,
      ),
      padding: EdgeInsets.all(deviceWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(deviceWidth * 0.042),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCityName)
            Padding(
              padding: EdgeInsets.only(bottom: deviceHeight * 0.003),
              child: Text(
                city,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: deviceWidth * 0.032,
                  shadows: const [Shadow(color: Colors.white, blurRadius: 2)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Lottie.asset(
            'assets/animations/${getWeatherAnimation(weather.durum)}',
            width: deviceWidth * 0.13,
            height: deviceWidth * 0.13,
            fit: BoxFit.contain,
          ),
          SizedBox(height: deviceHeight * 0.004),
          Text(
            '${double.parse(weather.derece.isNotEmpty ? weather.derece : weather.max).round()}°C',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: deviceWidth * 0.038,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}
