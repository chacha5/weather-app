import 'package:flutter/material.dart';

class WeatherUtils {
  // แปลง icon code เป็น IconData
  static IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'partly_cloudy':
        return Icons.wb_cloudy_rounded;
      case 'rain':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'fog':
        return Icons.visibility_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  // แปลง color code เป็น Color
  static Color getWeatherColor(String colorCode) {
    switch (colorCode) {
      case 'orange':
        return Colors.orange;
      case 'grey':
        return Colors.grey;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'lightBlue':
        return Colors.lightBlue;
      case 'blueGrey':
        return Colors.blueGrey;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  // ได้รับข้อความสถานะสภาพอากาศภาษาไทย
  static String getWeatherConditionThai(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'แจ่มใส';
      case 'clouds':
      case 'cloudy':
        return 'มีเมฆ';
      case 'partly cloudy':
        return 'มีเมฆบางส่วน';
      case 'rain':
      case 'light rain':
        return 'ฝนตก';
      case 'drizzle':
        return 'ฝนพรำ';
      case 'thunderstorm':
        return 'พายุฝนฟ้าคะนอง';
      case 'snow':
        return 'หิมะ';
      case 'mist':
      case 'fog':
        return 'หมอก';
      default:
        return condition;
    }
  }

  // แปลงความเร็วลมจาก m/s เป็น km/h
  // แปลงความเร็วลมจาก m/s เป็น km/h หรือ mph ตามหน่วยที่ระบุ
  static String formatWindSpeed(double windSpeed, {String unit = 'Km/h'}) {
    if (unit.toLowerCase().contains('mph')) {
      final mph = (windSpeed * 2.23694).round();
      return '$mph mph';
    }
    final kmh = (windSpeed * 3.6).round();
    return '$kmh km/h';
  }

  // แปลง visibility จาก เมตร เป็น กิโลเมตร
  static String formatVisibility(double visibility) {
    if (visibility >= 1000) {
      return '${(visibility / 1000).toStringAsFixed(1)} km';
    } else {
      return '${visibility.round()} m';
    }
  }

  // แปลงอุณหภูมิ และรองรับการแปลงเป็น Fahrenheit ตามหน่วยที่ระบุ
  // unit: 'Celsius (°C)' หรือ 'Fahrenheit (°F)'
  static String formatTemperature(dynamic temp, {String unit = 'Celsius (°C)'}) {
    int celsius = 0;
    if (temp is String) {
      celsius = int.tryParse(temp.replaceAll(RegExp(r'[^0-9\-]'), '')) ?? 0;
    } else if (temp is double) {
      celsius = temp.round();
    } else if (temp is int) {
      celsius = temp;
    }

    if (unit.toLowerCase().contains('fahrenheit')) {
      final f = (celsius * 9 / 5 + 32).round();
      return '$f°F';
    }
    return '$celsius°C';
  }

  // ได้รับ UV Index level
  static String getUVIndexLevel(int uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  // ได้รับสีของ UV Index
  static Color getUVIndexColor(int uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }

  // จัดรูปแบบเวลา รองรับ 24/12 hour
  // format: '24 Hour' หรือ '12 Hour'
  static String formatTime(DateTime time, {String format = '24 Hour'}) {
    if (format.toLowerCase().contains('12')) {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final ampm = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $ampm';
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // จัดรูปแบบวันที่
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = targetDate.difference(today).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (difference.abs() < 7) {
      return weekDays[date.weekday % 7];
    }
    
    return '${date.day} ${months[date.month - 1]}';
  }

  // คำนวณ AQI (Air Quality Index) color
  static Color getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  // ได้รับคำอธิบาย AQI
  static String getAQIDescription(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  // สร้าง gradient สำหรับ background
  static LinearGradient getWeatherGradient(String colorCode) {
    Color baseColor = getWeatherColor(colorCode);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.8),
        baseColor,
      ],
    );
  }
}