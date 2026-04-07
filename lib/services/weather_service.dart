import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // ดึงข้อมูลอากาศย้อนหลัง (One Call Timemachine)
  static Future<Map<String, dynamic>> getWeatherHistory({
    required double lat,
    required double lon,
    required int dt,
  }) async {
    final url =
        'https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=$lat&lon=$lon&dt=$dt&appid=${WeatherService.apiKey}&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'current': data['data'] != null && data['data'].isNotEmpty
              ? data['data'][0]
              : null,
          'hourly': data['data'] ?? [],
        };
      } else {
        throw Exception(
          'Failed to load weather history: statusCode=${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching weather history: $e');
    }
  }

  static const String apiKey =
      "57312beadc14b10c182d83a54b5b4a07"; // ใส่ API Key ของคุณ
  static const String baseUrl = "https://api.openweathermap.org/data/2.5";
  // Fetch current weather by coordinates (lat, lon)
  static Future<Map<String, dynamic>> getCurrentWeatherByCoords({
    required double lat,
    required double lon,
  }) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _formatWeatherData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  // ดึงข้อมูลสภาพอากาศจาก OpenWeather API
  static Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    final url = '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _formatWeatherData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  // ดึงข้อมูลพยากรณ์อากาศ 5 วัน
  static Future<Map<String, dynamic>> getForecast(String cityName) async {
    final url = '$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _formatForecastData(data);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast data: $e');
    }
  }

  // จัดรูปแบบข้อมูลสภาพอากาศปัจจุบัน
  static Map<String, dynamic> _formatWeatherData(Map<String, dynamic> data) {
    return {
      'name': data['name'],
      'country': data['sys']['country'],
      'temp': data['main']['temp'].round(),
      'feelsLike': data['main']['feels_like'].round(),
      'condition': data['weather'][0]['main'],
      'description': data['weather'][0]['description'],
      'humidity': data['main']['humidity'],
      'windSpeed': data['wind']['speed'],
      'pressure': data['main']['pressure'],
      'visibility': data['visibility'] / 1000, // Convert to km
      'iconCode': _getWeatherIconCode(data['weather'][0]['main']),
      'colorCode': _getWeatherColorCode(data['weather'][0]['main']),
    };
  }

  // จัดรูปแบบข้อมูลพยากรณ์อากาศ
  static Map<String, dynamic> _formatForecastData(Map<String, dynamic> data) {
    List<Map<String, dynamic>> hourlyForecast = [];
    List<Map<String, dynamic>> dailyForecast = [];

    // Process hourly data (first 8 hours)
    for (int i = 0; i < 8 && i < data['list'].length; i++) {
      final item = data['list'][i];
      hourlyForecast.add({
        'time': DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
        'temp': item['main']['temp'].round(),
        'condition': item['weather'][0]['main'],
        'iconCode': _getWeatherIconCode(item['weather'][0]['main']),
      });
    }

    // Process daily data (group by day)
    Map<String, List<Map<String, dynamic>>> dailyGroups = {};
    for (var item in data['list']) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!dailyGroups.containsKey(dateKey)) {
        dailyGroups[dateKey] = [];
      }
      dailyGroups[dateKey]!.add(item);
    }

    // Calculate daily averages
    dailyGroups.forEach((dateKey, items) {
      if (dailyForecast.length < 7) {
        final temps = items
            .map((item) => item['main']['temp'] as double)
            .toList();
        final conditions = items
            .map((item) => item['weather'][0]['main'] as String)
            .toList();
        final mostCommonCondition = _getMostCommonCondition(conditions);

        dailyForecast.add({
          'date': DateTime.parse(dateKey),
          'high': temps.reduce((a, b) => a > b ? a : b).round(),
          'low': temps.reduce((a, b) => a < b ? a : b).round(),
          'condition': mostCommonCondition,
          'iconCode': _getWeatherIconCode(mostCommonCondition),
        });
      }
    });

    return {'hourly': hourlyForecast, 'daily': dailyForecast};
  }

  // Helper methods - ส่งกลับเป็น String แทน Icons/Colors
  static String _getWeatherIconCode(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'sunny';
      case 'clouds':
      case 'cloudy':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
        return 'rain';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snow';
      case 'mist':
      case 'fog':
        return 'fog';
      default:
        return 'sunny';
    }
  }

  static String _getWeatherColorCode(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'orange';
      case 'clouds':
      case 'cloudy':
        return 'grey';
      case 'rain':
      case 'drizzle':
        return 'blue';
      case 'thunderstorm':
        return 'purple';
      case 'snow':
        return 'lightBlue';
      case 'mist':
      case 'fog':
        return 'blueGrey';
      default:
        return 'blue';
    }
  }

  static String _getMostCommonCondition(List<String> conditions) {
    Map<String, int> frequency = {};
    for (String condition in conditions) {
      frequency[condition] = (frequency[condition] ?? 0) + 1;
    }

    String mostCommon = conditions[0];
    int maxCount = 0;
    frequency.forEach((condition, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = condition;
      }
    });

    return mostCommon;
  }
}
