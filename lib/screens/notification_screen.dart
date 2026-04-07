import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings.dart';
import '../utils/weather_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
    List<Map<String, dynamic>> notifications = [];

  List<Map<String, dynamic>> dailyRecords = [];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    // Build sample notification/daily records using current units
    notifications = [
      {
        'type': 'weather_alert',
        'title': 'High UV Index Alert',
        'message': 'UV index is 8 (High). Consider wearing sunscreen.',
        'time': '2 hours ago',
        'icon': Icons.wb_sunny,
        'color': Color(0xFFFF9800),
        'location': 'Bangkok',
      },
      {
        'type': 'weather_update',
        'title': 'Temperature Rising',
        'message': 'Current temperature: ${WeatherUtils.formatTemperature(32, unit: settings.temperatureUnit)}, feels like ${WeatherUtils.formatTemperature(36, unit: settings.temperatureUnit)}',
        'time': '4 hours ago',
        'icon': Icons.thermostat,
        'color': Color(0xFFEF5350),
        'location': 'Bangkok',
      },
      {
        'type': 'weather_warning',
        'title': 'High Humidity',
        'message': 'Humidity level at 68%. Stay hydrated!',
        'time': '6 hours ago',
        'icon': Icons.water_drop,
        'color': Color(0xFF42A5F5),
        'location': 'Bangkok',
      },
      {
        'type': 'daily_summary',
        'title': 'Daily Weather Summary',
        'message': 'Sunny day with max ${WeatherUtils.formatTemperature(32, unit: settings.temperatureUnit)}, min ${WeatherUtils.formatTemperature(24, unit: settings.temperatureUnit)}',
        'time': '1 day ago',
        'icon': Icons.summarize,
        'color': Color(0xFF66BB6A),
        'location': 'Bangkok',
      },
    ];

    dailyRecords = [
      {
        'date': 'Today',
        'high': WeatherUtils.formatTemperature(32, unit: settings.temperatureUnit),
        'low': WeatherUtils.formatTemperature(24, unit: settings.temperatureUnit),
        'condition': 'Sunny',
        'humidity': '68%',
        'wind': WeatherUtils.formatWindSpeed(3.33, unit: settings.windSpeedUnit),
        'uv': '8',
      },
      {
        'date': 'Yesterday',
        'high': WeatherUtils.formatTemperature(31, unit: settings.temperatureUnit),
        'low': WeatherUtils.formatTemperature(23, unit: settings.temperatureUnit),
        'condition': 'Partly Cloudy',
        'humidity': '72%',
        'wind': WeatherUtils.formatWindSpeed(2.22, unit: settings.windSpeedUnit),
        'uv': '6',
      },
      {
        'date': '2 days ago',
        'high': WeatherUtils.formatTemperature(30, unit: settings.temperatureUnit),
        'low': WeatherUtils.formatTemperature(25, unit: settings.temperatureUnit),
        'condition': 'Cloudy',
        'humidity': '78%',
        'wind': WeatherUtils.formatWindSpeed(4.16, unit: settings.windSpeedUnit),
        'uv': '4',
      },
    ];
    return Scaffold(
      backgroundColor: Color(0xFFF5F9FF),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                height: 48,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2196F3).withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Color(0xFF2196F3),
                  unselectedLabelColor: Color(0xFF64B5F6),
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(child: SizedBox(width: double.infinity, child: Center(child: Text('Alerts')))),
                    Tab(child: SizedBox(width: double.infinity, child: Center(child: Text('Daily Records')))),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    // Alerts Tab
                    ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(notifications[index]);
                      },
                    ),

                    // Daily Records Tab
                    ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      itemCount: dailyRecords.length,
                      itemBuilder: (context, index) {
                        return _buildDailyRecordItem(dailyRecords[index]);
                      },
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

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE3F2FD), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notification['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 22,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 4),
                    Text(
                      notification['location'],
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 4),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRecordItem(Map<String, dynamic> record) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE3F2FD), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record['date'],
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record['condition'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildRecordDetail(
                  'High',
                  record['high'],
                  Color(0xFFEF5350),
                  Icons.arrow_upward,
                ),
              ),
              Expanded(
                child: _buildRecordDetail(
                  'Low',
                  record['low'],
                  Color(0xFF42A5F5),
                  Icons.arrow_downward,
                ),
              ),
              Expanded(
                child: _buildRecordDetail(
                  'UV',
                  record['uv'],
                  Color(0xFFFF9800),
                  Icons.wb_sunny_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRecordDetail(
                  'Humidity',
                  record['humidity'],
                  Color(0xFF29B6F6),
                  Icons.water_drop_outlined,
                ),
              ),
              Expanded(
                child: _buildRecordDetail(
                  'Wind',
                  record['wind'],
                  Color(0xFF66BB6A),
                  Icons.air,
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordDetail(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}