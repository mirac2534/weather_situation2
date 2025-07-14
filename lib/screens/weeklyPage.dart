import 'package:flutter/material.dart';
import '../models/wheather_model.dart';
import '../widgets/temperature_chart.dart';
import '../utils/weather_utils.dart';

class WeeklyPage extends StatelessWidget {
  final List<WheatherModel> weathers;
  final String city;

  const WeeklyPage({Key? key, required this.weathers, required this.city})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Geri tuşu ve şehir adı aynı hizada
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        city,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: deviceWidth * 0.06,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Geri tuşunun simetriği kadar boşluk bırakmak için boş Icon
                    Opacity(
                      opacity: 0,
                      child: Icon(Icons.arrow_back),
                    ),
                  ],
                ),
              ),
              SizedBox(height: deviceHeight * 0.005),
              // Alt başlık
              Text(
                "7 Günlük Hava Sıcaklığı",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: deviceWidth * 0.045,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: getBackgroundGradient(weathers[0].durum),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: deviceHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Sıcaklık Grafiği",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: deviceWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.015),
                    SizedBox(
                      height: deviceHeight * 0.60, // Grafik alanı %60
                      child: TemperatureChart(weathers: weathers),
                    ),
                    SizedBox(height: deviceHeight * 0.02),
                    Text(
                      "Turuncu: Gündüz / Mavi: Gece",
                      style: TextStyle(
                        fontSize: deviceWidth * 0.038,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
