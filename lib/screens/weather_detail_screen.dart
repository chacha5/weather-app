import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/weather_utils.dart';
import '../providers/app_settings.dart';
import '../services/weather_service.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Map<String, dynamic> locationData;

  const WeatherDetailScreen({super.key, required this.locationData});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  Map<String, dynamic>? forecastData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    try {
      final forecast = await WeatherService.getForecast(
        widget.locationData['name'],
      );
      setState(() {
        forecastData = forecast;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading forecast: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ WeatherUtils แทน
    final weatherIcon = WeatherUtils.getWeatherIcon(
      widget.locationData['iconCode'],
    );
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient background
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: WeatherUtils.getWeatherGradient(
                    widget.locationData['colorCode'],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        Text(
                          widget.locationData['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.locationData['country'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(weatherIcon, color: Colors.white, size: 60),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  WeatherUtils.formatTemperature(
                                    widget.locationData['temp'],
                                    unit: settings.temperatureUnit,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.locationData['condition'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Weather Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Conditions
                  _buildSectionTitle('Current Conditions'),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildConditionItem(
                                'Feels Like',
                                WeatherUtils.formatTemperature(
                                  widget.locationData['feelsLike'],
                                  unit: settings.temperatureUnit,
                                ),
                                Icons.thermostat,
                                Colors.red,
                              ),
                            ),
                            Expanded(
                              child: _buildConditionItem(
                                'Humidity',
                                '${widget.locationData['humidity']}%',
                                Icons.water_drop,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildConditionItem(
                                'Wind Speed',
                                WeatherUtils.formatWindSpeed(
                                  widget.locationData['windSpeed'],
                                  unit: settings.windSpeedUnit,
                                ),
                                Icons.air,
                                Colors.green,
                              ),
                            ),
                            Expanded(
                              child: _buildConditionItem(
                                'Visibility',
                                WeatherUtils.formatVisibility(
                                  _visibilityToMeters(
                                    widget.locationData['visibility'],
                                  ),
                                ),
                                Icons.visibility,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Hourly Forecast
                  if (!isLoading && forecastData != null) ...[
                    _buildSectionTitle('Hourly Forecast'),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (forecastData!['hourly'] as List).length,
                        itemBuilder: (context, index) {
                          return _buildHourlyItem(
                            (forecastData!['hourly'] as List)[index],
                            index,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // 7-Day Forecast
                    _buildSectionTitle('7-Day Forecast'),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: (forecastData!['daily'] as List).map<Widget>((
                          day,
                        ) {
                          final index = (forecastData!['daily'] as List)
                              .indexOf(day);
                          return _buildDailyForecastItem(day, index);
                        }).toList(),
                      ),
                    ),
                  ],

                  // Show mock data when loading or no forecast data
                  if (isLoading || forecastData == null) ...[
                    _buildSectionTitle('Hourly Forecast'),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return _buildMockHourlyItem(index);
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // Mock 7-Day Forecast
                    _buildSectionTitle('7-Day Forecast'),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: List.generate(7, (index) {
                          return _buildMockDailyForecastItem(index);
                        }),
                      ),
                    ),
                  ],

                  if (isLoading) ...[
                    SizedBox(height: 50),
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading forecast...'),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Additional Info
                  _buildSectionTitle('Additional Information'),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Pressure',
                          '${widget.locationData['pressure']} hPa',
                        ),
                        _buildInfoRow(
                          'Description',
                          widget.locationData['description'],
                        ),
                        _buildInfoRow(
                          'Wind Speed',
                          WeatherUtils.formatWindSpeed(
                            widget.locationData['windSpeed'],
                          ),
                        ),
                        _buildInfoRow(
                          'Visibility',
                          WeatherUtils.formatVisibility(
                            _visibilityToMeters(
                              widget.locationData['visibility'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildConditionItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // For actual forecast data
  Widget _buildHourlyItem(Map<String, dynamic> hourData, int index) {
    final settings = Provider.of<AppSettings>(context);
    final time = hourData['time'] as DateTime;
    final icon = WeatherUtils.getWeatherIcon(hourData['iconCode']);
    final color = WeatherUtils.getWeatherColor(hourData['iconCode']);

    // Constrain each horizontal card to the parent's fixed height to avoid overflow
    return SizedBox(
      width: 70,
      height: 120,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: index == 0 ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              index == 0
                  ? 'Now'
                  : WeatherUtils.formatTime(time, format: settings.timeFormat),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: index == 0 ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Icon(
              icon,
              color: index == 0 ? Colors.white : Colors.grey[700],
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              WeatherUtils.formatTemperature(
                hourData['temp'],
                unit: settings.temperatureUnit,
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: index == 0 ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // For mock data when loading
  Widget _buildMockHourlyItem(int index) {
    final settings = Provider.of<AppSettings>(context);
    final hours = [
      'Now',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
    ];
    final temps = _generateHourlyTemps(widget.locationData);
    final icons = _generateHourlyIcons(widget.locationData);

    return SizedBox(
      width: 70,
      height: 120,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: index == 0
              ? WeatherUtils.getWeatherColor(widget.locationData['colorCode'])
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hours[index],
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: index == 0 ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Icon(
              icons[index],
              color: index == 0 ? Colors.white : Colors.grey[700],
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              WeatherUtils.formatTemperature(
                temps[index],
                unit: settings.temperatureUnit,
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: index == 0 ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecastItem(Map<String, dynamic> dailyData, int index) {
    final settings = Provider.of<AppSettings>(context);
    final date = dailyData['date'] as DateTime;
    final icon = WeatherUtils.getWeatherIcon(dailyData['iconCode']);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: index < 6
            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              WeatherUtils.formatDate(date),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 20),
                SizedBox(width: 8),
                Text(
                  dailyData['condition'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${WeatherUtils.formatTemperature(dailyData['low'], unit: settings.temperatureUnit)}/${WeatherUtils.formatTemperature(dailyData['high'], unit: settings.temperatureUnit)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockDailyForecastItem(int index) {
    final settings = Provider.of<AppSettings>(context);
    final days = ['Today', 'Tomorrow', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final conditions = _generateDailyConditions();
    final highs = _generateDailyHighs(widget.locationData);
    final lows = _generateDailyLows(widget.locationData);
    final icons = _generateDailyIcons();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: index < 6
            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              days[index],
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(icons[index], color: Colors.grey[600], size: 20),
                SizedBox(width: 8),
                Text(
                  conditions[index],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${WeatherUtils.formatTemperature(lows[index], unit: settings.temperatureUnit)}/${WeatherUtils.formatTemperature(highs[index], unit: settings.temperatureUnit)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Safely convert incoming visibility (expected as km or string) to meters.
  // Keeps original behaviour (assumes incoming value is in km) but avoids null/type errors.
  double _visibilityToMeters(dynamic rawVisibility) {
    if (rawVisibility == null) return 0;
    if (rawVisibility is num) {
      return rawVisibility.toDouble() * 1000;
    }
    if (rawVisibility is String) {
      final parsed = double.tryParse(
        rawVisibility.replaceAll(RegExp(r'[^0-9\.-]'), ''),
      );
      if (parsed != null) return parsed * 1000;
    }
    return 0;
  }

  // Helper methods for generating mock data
  List<String> _generateHourlyTemps(Map<String, dynamic> locationData) {
    int baseTemp = int.parse(
      locationData['temp'].toString().replaceAll('°C', ''),
    );
    return List.generate(8, (index) => '${baseTemp + (index - 4).abs()}°');
  }

  List<IconData> _generateHourlyIcons(Map<String, dynamic> locationData) {
    final weatherIcon = WeatherUtils.getWeatherIcon(locationData['iconCode']);
    return [
      weatherIcon,
      weatherIcon,
      Icons.wb_cloudy,
      Icons.wb_cloudy,
      Icons.cloud,
      Icons.cloud,
      Icons.nights_stay,
      Icons.nights_stay,
    ];
  }

  List<String> _generateDailyConditions() {
    return [
      'Sunny',
      'Partly Cloudy',
      'Cloudy',
      'Rainy',
      'Sunny',
      'Cloudy',
      'Clear',
    ];
  }

  List<String> _generateDailyHighs(Map<String, dynamic> locationData) {
    int baseTemp = int.parse(
      locationData['temp'].toString().replaceAll('°C', ''),
    );
    return List.generate(7, (index) => '${baseTemp - index}°');
  }

  List<String> _generateDailyLows(Map<String, dynamic> locationData) {
    int baseTemp = int.parse(
      locationData['temp'].toString().replaceAll('°C', ''),
    );
    return List.generate(7, (index) => '${baseTemp - 8 - index}°');
  }

  List<IconData> _generateDailyIcons() {
    return [
      Icons.wb_sunny,
      Icons.wb_cloudy,
      Icons.cloud,
      Icons.grain,
      Icons.wb_sunny,
      Icons.cloud,
      Icons.wb_sunny,
    ];
  }
}
