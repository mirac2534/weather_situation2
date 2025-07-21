
# 🌤️ Weather Forecast App

This mobile application, developed with Flutter, provides users with real-time weather data, weekly forecasts, favorite/popular city management, daily notifications, and a clean, animated interface.

---

## 🚀 Features

- Real-time weather and local time display  
- Weekly (7-day) forecast page  
- Add, remove, and edit favorite cities  
- Quick access to popular cities  
- City search with recent history  
- Daily weather notifications  
- Splash screen with animation transitions  

---

## 🧰 Technologies Used

| Area                  | Technology/Package               |
|-----------------------|----------------------------------|
| Mobile Framework      | Flutter                          |
| Programming Language  | Dart                             |
| UI Animations         | [Lottie](https://pub.dev/packages/lottie)             |
| Notification System   | `flutter_local_notifications`, `timezone` |
| Permission Handling   | `permission_handler`, `android_intent_plus` |
| Local Storage         | `shared_preferences`             |
| Date/Time Formatting  | `intl`                           |

---

## 📁 File Structure and Descriptions

### Main Pages

#### `main.dart`
- Entry point of the application.  
- Initializes the splash screen.  
- Sets up timezone and notification system.

#### `splash_page.dart`
- Animated splash screen shown on launch.  
- Loads weather data and cached city info in the background.

#### `home_page.dart`
- Main screen showing current weather, local time, and animations.  
- Displays today’s weather in detail and next 2 days in summary.  
- Lists favorite and popular cities.  
- Includes a “More” button for weekly forecast navigation.

#### `CityDetailPage.dart`
- City search and history screen.  
- Displays recent cities and search results.  
- Allows adding cities to favorites.

#### `weeklyPage.dart`
- 7-day detailed weather forecast screen.  
- Displays day and night temperatures using a chart.

#### `settingPage.dart`
- Allows users to set daily notification time and default city.  
- Displays app version info.

---

### 🔧 Services and Helpers

#### `weather_service.dart`
- Handles API calls for weather data.  
- Includes location detection and default city persistence.

#### `weather_cache_service.dart`
- Caches weather data to reduce unnecessary API requests.

#### `favorites_service.dart`
- Manages favorite cities using `SharedPreferences`.  
- Supports add, remove, and fetch operations.

#### `notification_service.dart`
- Schedules daily weather notifications.  
- Displays context-aware weather tips.

#### `weather_utils.dart`
- Maps weather conditions to corresponding animations and background themes.

---

### 📄 Model

#### `weather_model.dart`
- Data model for weather API responses.  
- Contains fields like day, temperature, humidity, and condition.

---

### 📊 Data

#### `assets/cities.json`
- Provides city names for the search bar.  
- Includes both Turkish and international cities.

---

### 🧩 Widgets

#### `weather_card.dart`
- Displays a weather summary card.  
- Supports both large and small variants via `isSmall` flag.

#### `weather_card_combined.dart`
- Combines multiple weather card details into one widget.

#### `temperature_chart.dart`
- Visualizes daily high/low temperatures using a responsive line chart.

#### `error_card.dart`
- Shows a user-friendly error message in case of failures.

---

### 🎞️ Animations

#### `assets/animations/`
- Contains `.json` files used for dynamic weather animations.
- Example files:
  - `sunny.json`
  - `rainy.json`
  - `cloudy.json`
  - `snow.json`

---

## 📌 Summary

**The Turkey Weather App** enhances everyday decision-making by offering accurate weather updates through an elegant and intuitive interface. With its dynamic visuals, smart notifications, and customizable city features, it stands out as a reliable companion for planning your day.
