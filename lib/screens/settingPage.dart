import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hava_durumu/services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TimeOfDay? _selectedTime;
  String _selectedCity = "İstanbul";
  List<String> _allCities = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadCitiesFromJson();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final hasTime =
        prefs.containsKey('notif_hour') && prefs.containsKey('notif_minute');
    final city = prefs.getString('default_city') ?? "İstanbul";

    setState(() {
      _selectedTime = hasTime
          ? TimeOfDay(
              hour: prefs.getInt('notif_hour') ?? 8,
              minute: prefs.getInt('notif_minute') ?? 0)
          : null;
      _selectedCity = city;
    });
  }

  Future<void> _saveTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_hour', time.hour);
    await prefs.setInt('notif_minute', time.minute);

    await NotificationService.scheduleDailyWeatherNotification(
      cityName: prefs.getString('default_city') ?? "İstanbul",
      time: time,
    );
  }

  Future<void> _saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_city', city);
  }

  Future<void> _loadCitiesFromJson() async {
    final String jsonString =
        await rootBundle.loadString('lib/models/cities.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _allCities = jsonData.map((e) => e.toString()).toList();
    });
  }

  void _showCitySearchDialog(double fontSize) {
    String filter = '';
    List<String> filteredCities = _allCities;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title:
                  Text("Şehir Seç", style: TextStyle(fontSize: fontSize * 1.2)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Şehir ara...",
                      prefixIcon: Icon(Icons.search, size: fontSize * 1.2),
                    ),
                    style: TextStyle(fontSize: fontSize),
                    onChanged: (value) {
                      setStateDialog(() {
                        filter = value.toLowerCase();
                        filteredCities = _allCities
                            .where(
                                (city) => city.toLowerCase().contains(filter))
                            .take(20)
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    width: double.maxFinite,
                    child: filteredCities.isEmpty
                        ? const Center(child: Text("Sonuç bulunamadı"))
                        : ListView.builder(
                            itemCount: filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = filteredCities[index];
                              return ListTile(
                                title: Text(city,
                                    style: TextStyle(fontSize: fontSize)),
                                onTap: () async {
                                  setState(() => _selectedCity = city);
                                  await _saveCity(city);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Varsayılan şehir güncellendi: $city",
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await NotificationService.cancelAllNotifications();
    await prefs.remove('notif_hour');
    await prefs.remove('notif_minute');
    setState(() => _selectedTime = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tüm bildirimler iptal edildi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final fontSize = deviceWidth * 0.042;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar", style: TextStyle(fontSize: fontSize * 1.2)),
      ),
      body: Padding(
        padding: EdgeInsets.all(deviceWidth * 0.04),
        child: ListView(
          children: [
            // Bildirim Saati
            Card(
              child: ListTile(
                title: Text("🔔 Bildirim Saati",
                    style: TextStyle(fontSize: fontSize)),
                subtitle: Text(
                  _selectedTime != null
                      ? "Seçili: ${_selectedTime!.format(context)}"
                      : "Saat seçin",
                  style: TextStyle(fontSize: fontSize * 0.95),
                ),
                trailing: Icon(Icons.access_time, size: fontSize * 1.3),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime:
                        _selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                    await _saveTime(picked);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Bildirim saati kaydedildi",
                            style: TextStyle(fontSize: fontSize)),
                      ),
                    );
                  }
                },
              ),
            ),

            // Bildirimleri İptal Et
            Card(
              child: ListTile(
                title: Text("📵 Bildirimleri İptal Et",
                    style: TextStyle(fontSize: fontSize)),
                subtitle: Text("Planlanmış tüm bildirimleri kaldır",
                    style: TextStyle(fontSize: fontSize * 0.95)),
                trailing: Icon(Icons.notifications_off, size: fontSize * 1.3),
                onTap: _clearNotifications,
              ),
            ),

            // Varsayılan Şehir
            Card(
              child: ListTile(
                title: Text("🏙 Varsayılan Şehir",
                    style: TextStyle(fontSize: fontSize)),
                subtitle: Text(_selectedCity,
                    style: TextStyle(fontSize: fontSize * 0.95)),
                trailing: Icon(Icons.search, size: fontSize * 1.3),
                onTap: () {
                  if (_allCities.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Şehir verileri yüklenemedi.",
                            style: TextStyle(fontSize: fontSize)),
                      ),
                    );
                  } else {
                    _showCitySearchDialog(fontSize);
                  }
                },
              ),
            ),

            SizedBox(height: deviceWidth * 0.05),
            Center(
              child: Text(
                "v1.0.0 • Miraç Weather",
                style: TextStyle(color: Colors.grey, fontSize: fontSize * 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
