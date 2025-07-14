import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favorites_service.dart';
import '../utils/weather_utils.dart';

class CityDetailPage extends StatefulWidget {
  final String city;
  final String weatherDescription;

  const CityDetailPage({
    Key? key,
    required this.city,
    required this.weatherDescription,
  }) : super(key: key);

  @override
  _CityDetailPageState createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  final TextEditingController searchController = TextEditingController();
  List<String> allCities = [];
  List<String> cityHistory = [];
  List<String> filteredCities = [];
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadCityHistory();
    _checkFavorite();
  }

  Future<void> _loadCities() async {
    final String response =
        await rootBundle.loadString('lib/models/cities.json');
    final List<dynamic> cities = json.decode(response);

    setState(() {
      allCities = List<String>.from(cities);
      allCities.remove(widget.city);
      filteredCities = [];
    });
  }

  Future<void> _loadCityHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cityHistory = prefs.getStringList('cityHistory') ?? [];
    });
  }

  Future<void> _saveCityHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cityHistory', cityHistory);
  }

  void _onCitySelected(String cityName) async {
    setState(() {
      cityHistory.remove(cityName);
      cityHistory.insert(0, cityName);
      if (cityHistory.length > 8) {
        cityHistory.removeLast();
      }
    });

    await _saveCityHistory();
    Navigator.pop(context, cityName);
  }

  void _removeFromHistory(String cityName) async {
    setState(() {
      cityHistory.remove(cityName);
    });
    await _saveCityHistory();
  }

  void _clearHistory() async {
    setState(() {
      cityHistory.clear();
    });
    await _saveCityHistory();
  }

  Future<void> _checkFavorite() async {
    final favs = await FavoritesService.getFavorites();
    setState(() {
      isFavorite = favs.contains(widget.city);
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await FavoritesService.removeFavorite(widget.city);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Favorilerden çıkarıldı")),
      );
    } else {
      await FavoritesService.addFavorite(widget.city);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Favorilere eklendi")),
      );
    }
    await _checkFavorite();
  }

  void _filterCities(String input) {
    setState(() {
      filteredCities = allCities
          .where((city) => city.toLowerCase().contains(input.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: getBackgroundGradient(widget.weatherDescription),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: Colors.yellow,
                size: deviceWidth * 0.075,
              ),
              onPressed: _toggleFavorite,
              tooltip: isFavorite ? "Favorilerden çıkar" : "Favorilere ekle",
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            deviceWidth * 0.04,
            deviceHeight * 0.08,
            deviceWidth * 0.04,
            deviceHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mevcut Şehir: ${widget.city}',
                style: TextStyle(
                  fontSize: deviceWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                ),
              ),
              SizedBox(height: deviceHeight * 0.025),
              TextField(
                controller: searchController,
                onChanged: _filterCities,
                decoration: InputDecoration(
                  labelText: 'Şehir ara',
                  labelStyle: TextStyle(
                      color: Colors.white, fontSize: deviceWidth * 0.045),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white, size: deviceWidth * 0.06),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(deviceWidth * 0.02),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(deviceWidth * 0.02),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: deviceHeight * 0.015,
                    horizontal: deviceWidth * 0.03,
                  ),
                ),
                style: TextStyle(
                    color: Colors.white, fontSize: deviceWidth * 0.045),
              ),
              SizedBox(height: deviceHeight * 0.025),

              // 🔍 Arama Sonuçları önce geliyor
              if (searchController.text.isNotEmpty)
                Expanded(
                  child: filteredCities.isEmpty
                      ? Center(
                          child: Text(
                            "Şehir bulunamadı",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: deviceWidth * 0.045),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCities.length,
                          itemBuilder: (context, index) {
                            final cityName = filteredCities[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: deviceHeight * 0.004),
                              child: ElevatedButton(
                                onPressed: () => _onCitySelected(cityName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.8),
                                  padding: EdgeInsets.symmetric(
                                    vertical: deviceHeight * 0.012,
                                    horizontal: deviceWidth * 0.04,
                                  ),
                                ),
                                child: Text(
                                  cityName,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: deviceWidth * 0.045,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                )
              else ...[
                Row(
                  children: [
                    Text(
                      "Şehir geçmişi:",
                      style: TextStyle(
                        fontSize: deviceWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearHistory,
                      child: Text(
                        "Tümünü Sil",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: deviceWidth * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
                if (cityHistory.isEmpty)
                  Text(
                    "Henüz bir şehir aratmadın.",
                    style: TextStyle(
                        color: Colors.white, fontSize: deviceWidth * 0.045),
                  ),
                if (cityHistory.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: cityHistory.length,
                      itemBuilder: (context, index) {
                        final cityName = cityHistory[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: deviceHeight * 0.008),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius:
                                BorderRadius.circular(deviceWidth * 0.02),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.location_city,
                                color: Colors.white, size: deviceWidth * 0.06),
                            title: Text(
                              cityName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: deviceWidth * 0.045,
                                shadows: [
                                  const Shadow(
                                      offset: Offset(1, 1),
                                      color: Colors.black,
                                      blurRadius: 2)
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => _removeFromHistory(cityName),
                            ),
                            onTap: () => _onCitySelected(cityName),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
