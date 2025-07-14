import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:hava_durumu/models/wheather_model.dart';
import 'package:hava_durumu/services/wheater_service.dart';
import 'package:hava_durumu/widgets/weather_card_combined.dart';
import 'package:hava_durumu/services/favorites_service.dart';
import 'package:hava_durumu/utils/weather_utils.dart';
import 'CityDetailPage.dart';
import 'weeklyPage.dart';
import 'settingPage.dart';
import 'package:hava_durumu/widgets/error_card.dart';

String? _errorMessage;

class HomePage extends StatefulWidget {
  final String city;
  final List<WheatherModel> initialWeather;

  const HomePage({
    super.key,
    required this.city,
    required this.initialWeather,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentTime = '';
  Timer? _timer;
  List<WheatherModel> _weathers = [];
  String? _city;
  String? _loadingCity;
  bool _isLocationLoading = false;
  bool _isEditMode = false;
  final List<String> _editableFavCities = [];
  bool _isEditingPopular = false;
  String? _loadingPopularCity;

  final Map<String, int> _cityUtcOffsets = {
    'İstanbul': 3,
    'London': 1,
    'New York': -4,
    'Tokyo': 9,
    'Paris': 2,
    'Sydney': 10,
    'Dubai': 4,
    'Berlin': 2,
    'Moscow': 3,
  };

  final Map<String, List<WheatherModel>> _weatherCache = {};

  final List<String> globalCities = [
    "New York",
    "London",
    "Paris",
    "Tokyo",
    "Sydney",
    "Dubai",
    "Berlin",
    "Moscow",
  ];

  Future<List<WheatherModel>> getWeather(String cityName) async {
    if (_weatherCache.containsKey(cityName)) {
      return _weatherCache[cityName]!;
    }
    print("API'den veri alınıyor: $cityName");
    final data = await WheaterService().getWeatherData(cityName: cityName);
    _weatherCache[cityName] = data;
    return data;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startClock();

    // SplashPage'ten gelen verileri kullan
    _city = widget.city;
    _weathers = widget.initialWeather;
  }

  void _startClock() {
    _currentTime = DateFormat('HH:mm').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
    });
  }

  Future<void> _initialWeatherData() async {
    try {
      String? cityFromLocation = await WheaterService().getLocation();
      _city = cityFromLocation ??
          await WheaterService.getLastKnownCity() ??
          "İstanbul";
      _weathers =
          await WheaterService().getWeatherData(cityName: _city ?? "İstanbul");
      setState(() {});
    } catch (e) {
      // HATA DURUMUNDA DA YİNE ÖNCEKİ ŞEHRİ DENE
      _city = await WheaterService.getLastKnownCity() ?? "İstanbul";
      _weathers =
          await WheaterService().getWeatherData(cityName: _city ?? "İstanbul");
      setState(() => _errorMessage = "Konum bilgisi alınamadı");
    }
  }

  Future<void> _updateWeatherForCity(String cityName) async {
    try {
      _city = cityName;
      await WheaterService.saveLastKnownCity(_city!);
      _weathers =
          await WheaterService().getWeatherData(cityName: _city ?? "İstanbul");
      setState(() {});
    } catch (e) {
      setState(() => _errorMessage = "Şehir bilgisi alınamadı");
    }
  }

  String getCityTime(String cityName) {
    try {
      final offset = _cityUtcOffsets[cityName] ?? 3;
      final nowUtc = DateTime.now().toUtc();
      final cityTime = nowUtc.add(Duration(hours: offset));
      return DateFormat('HH:mm').format(cityTime);
    } catch (_) {
      return DateFormat('HH:mm').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final today = _weathers.isNotEmpty ? _weathers[0] : null;
    final nextDays = _weathers.length > 2 ? _weathers.sublist(1, 3) : [];

    return AnimatedContainer(
      duration: Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: getBackgroundGradient(today?.durum ?? "bulutlu"),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: deviceHeight * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. SATIR: Ayarlar, Şehir Adı, Konum
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.04,
                      vertical: deviceHeight * 0.013,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            final selectedCity = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CityDetailPage(
                                  city: _city ?? "",
                                  weatherDescription: today?.durum ?? "bulutlu",
                                ),
                              ),
                            );
                            if (selectedCity != null &&
                                selectedCity.isNotEmpty) {
                              await _updateWeatherForCity(selectedCity);
                            }
                          },
                          child: Text(
                            _city ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: deviceWidth * 0.065,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 6)
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            setState(() => _isLocationLoading = true);
                            try {
                              String? cityFromLocation =
                                  await WheaterService().getLocation();
                              final newCity = cityFromLocation ??
                                  await WheaterService.getLastKnownCity() ??
                                  "İstanbul";

                              await WheaterService.saveLastKnownCity(newCity);
                              final newWeather =
                                  await WheaterService().getWeatherData(
                                cityName: newCity,
                              );

                              setState(() {
                                _city = newCity;
                                _weathers = newWeather;
                              });
                            } catch (e) {
                              setState(() =>
                                  _errorMessage = "Konum bilgisi alınamadı");
                            }

                            setState(() => _isLocationLoading = false);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.my_location,
                                    color: Colors.white, size: 28),
                              ),
                              if (_isLocationLoading)
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. SATIR: Saat + Animasyon
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: deviceWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            getCityTime(_city ?? 'İstanbul'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: deviceWidth * 0.062,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 6)
                              ],
                            ),
                          ),

                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: today != null
                                  ? SizedBox(
                                      height: deviceHeight * 0.08,
                                      width: deviceWidth * 0.4,
                                      child: Lottie.asset(
                                        'assets/animations/${getWeatherAnimation(today.durum)}',
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                          ),

                          // Sağ boşluk bırakıyoruz ki görünüm ortalansın
                          SizedBox(width: deviceWidth * 0.16),
                        ],
                      )),

                  SizedBox(height: deviceHeight * 0.02),

                  // Günlük özet
                  if (today != null)
                    Column(
                      children: [
                        Text(today.gun,
                            style: const TextStyle(color: Colors.white)),
                        Text(today.durum,
                            style: const TextStyle(color: Colors.white)),
                        Text(
                          "Gündüz: ${double.parse(today.max).round()}°C  Gece: ${double.parse(today.min).round()}°C",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text("Nem: %${double.parse(today.nem).round()}",
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),

                  // Sonraki 2 gün
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: nextDays.map((weather) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: deviceWidth * 0.021),
                          child: WeatherCard(
                            city: _city!,
                            weather: weather,
                            isSmall: true,
                            showCityName: false,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Daha Fazlası butonu
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeeklyPage(
                            weathers: _weathers,
                            city: _city!,
                          ),
                        ),
                      );
                    },
                    child: const Text("Daha Fazlası",
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: deviceHeight * 0.005),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "  Favori Şehirler",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: deviceWidth * 0.048,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 2)
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditMode ? Icons.check : Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditMode = !_isEditMode;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<String>>(
                    future: FavoritesService.getFavorites(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(height: deviceHeight * 0.03);
                      }
                      final favCities = snapshot.data!;
                      return SizedBox(
                        height: deviceHeight * 0.18,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favCities.length,
                          itemBuilder: (context, idx) {
                            final city = favCities[idx];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: deviceWidth * 0.013),
                              child: FutureBuilder<List<WheatherModel>>(
                                future: WheaterService().getWeatherData(
                                    cityName: city, forceRefresh: false),
                                builder: (context, weatherSnap) {
                                  if (!weatherSnap.hasData ||
                                      weatherSnap.data!.isEmpty) {
                                    return SizedBox(width: deviceWidth * 0.22);
                                  }
                                  final weather = weatherSnap.data![0];

                                  final card = Stack(
                                    children: [
                                      AnimatedRotation(
                                        turns: _isEditMode ? 0.02 : 0.0,
                                        duration:
                                            const Duration(milliseconds: 150),
                                        child: WeatherCard(
                                          city: city,
                                          weather: weather,
                                          isSmall: true,
                                          showCityName: true,
                                        ),
                                      ),
                                      if (_isEditMode)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await FavoritesService
                                                  .removeFavorite(city);
                                              setState(() {});
                                            },
                                            child: const Icon(Icons.close,
                                                color: Colors.red, size: 20),
                                          ),
                                        ),
                                    ],
                                  );

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: _isEditMode
                                        ? null
                                        : () async {
                                            setState(() {
                                              _loadingCity = city;
                                            });
                                            await _updateWeatherForCity(city);
                                            setState(() {
                                              _loadingCity = null;
                                            });
                                          },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedScale(
                                          scale:
                                              _loadingCity == city ? 0.97 : 1.0,
                                          duration:
                                              const Duration(milliseconds: 150),
                                          child: card,
                                        ),
                                        if (_loadingCity == city)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: deviceHeight * 0.01),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "  Popüler Şehirler",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: deviceWidth * 0.048,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: deviceHeight * 0.18,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: globalCities.length,
                      itemBuilder: (context, idx) {
                        final city = globalCities[idx];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: deviceWidth * 0.013),
                          child: FutureBuilder<List<WheatherModel>>(
                            future: WheaterService().getWeatherData(
                                cityName: city, forceRefresh: false),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return SizedBox(width: deviceWidth * 0.22);
                              }
                              final weather = snapshot.data![0];
                              return AnimatedScale(
                                scale: _loadingCity == city ? 0.97 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () async {
                                    setState(() {
                                      _loadingCity = city;
                                    });
                                    await _updateWeatherForCity(city);
                                    setState(() {
                                      _loadingCity = null;
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      WeatherCard(
                                        city: city,
                                        weather: weather,
                                        isSmall: true,
                                        showCityName: true,
                                      ),
                                      if (_loadingCity == city)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
