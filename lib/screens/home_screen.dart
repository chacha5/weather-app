import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
// Import weather detail to add as a nav tab
import 'weather_detail_screen.dart';
import 'weather_map_screen.dart';

// ใส่ใน home_screen.dart แทนที่ _WeatherHomeContent
class WeatherHomeContent extends StatelessWidget {
  const WeatherHomeContent({super.key});

  String _formatTemp(BuildContext context, int celsius) {
    final settings = Provider.of<AppSettings>(context);
    final isF = settings.temperatureUnit.contains('Fahrenheit');
    if (isF) {
      final f = (celsius * 9 / 5 + 32).round();
      return '$f°';
    }
    return '$celsius°';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Header
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF42A5F5).withOpacity(0.8),
                    Color(0xFF2196F3).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Location only
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Bangkok',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Thailand',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Current Weather
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wb_sunny_rounded,
                            size: 64,
                            color: Colors.yellow[300],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          _formatTemp(context, 32),
                          style: GoogleFonts.poppins(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 0.8,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          'Sunny',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Feels like ${_formatTemp(context, 36)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Weather Details Cards
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<AppSettings>(
                      builder: (context, settings, _) {
                        return _buildWeatherCard(
                          Icons.air_rounded,
                          'Wind Speed',
                          // Format wind speed according to settings
                          // Assume the model provides wind speed in m/s (12 m/s used as placeholder)
                          WeatherUtils.formatWindSpeed(
                            12.0,
                            unit: settings.windSpeedUnit,
                          ),
                          Color(0xFF2196F3),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildWeatherCard(
                      Icons.water_drop_rounded,
                      'Humidity',
                      '68%',
                      Color(0xFF00BCD4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildWeatherCard(
                      Icons.wb_sunny_outlined,
                      'UV Index',
                      '8 High',
                      Color(0xFFFF9800),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildWeatherCard(
                      Icons.visibility_rounded,
                      'Visibility',
                      '10 km',
                      Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Interactive Weather Map - tap opens Weather Detail for a sample location
            GestureDetector(
              onTap: () {
                // previously pushed WeatherDetailScreen with sampleLocation;
                // now open the full WeatherMapScreen instead
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherMapScreen()),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
                          ),
                        ),
                        child: CustomPaint(
                          painter: MapPatternPainter(),
                          child: Container(),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 60,
                        child: WeatherMarker(
                          temp: _formatTemp(context, 30),
                          icon: Icons.cloud_rounded,
                          color: Color(0xFF90A4AE),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        right: 80,
                        child: WeatherMarker(
                          temp: _formatTemp(context, 32),
                          icon: Icons.wb_sunny_rounded,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 100,
                        child: WeatherMarker(
                          temp: _formatTemp(context, 28),
                          icon: Icons.grain_rounded,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 16,
                                color: Color(0xFF2196F3),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Bangkok Area',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fullscreen,
                            size: 18,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // 7-Day Forecast
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Forecast',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...[
                    'Today',
                    'Tomorrow',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ].asMap().entries.map((entry) {
                    int index = entry.key;
                    String day = entry.value;
                    return _buildForecastItem(
                      day,
                      index == 0
                          ? Icons.wb_sunny_rounded
                          : index == 1
                          ? Icons.cloud_rounded
                          : Icons.wb_cloudy_rounded,
                      _formatTemp(context, 32 - index),
                      _formatTemp(context, 24 - index),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Color(0xFF64748B),
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(
    String day,
    IconData icon,
    String high,
    String low,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(icon, color: Color(0xFFFF9800), size: 20),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  high,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  ' / ',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF94A3B8),
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  low,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Weather Marker Widget
class WeatherMarker extends StatelessWidget {
  final String temp;
  final IconData icon;
  final Color color;

  const WeatherMarker({
    super.key,
    required this.temp,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 4),
          Text(
            temp,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Map Pattern
class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF81D4FA).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 10; i++) {
      double x = (size.width / 10) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i < 10; i++) {
      double y = (size.height / 10) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// The full-screen map was moved to a dedicated file `weather_map_screen.dart`.
// See that file for the real map implementation using flutter_map / OSM.

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// App scaffold with BottomNavigationBar
class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Resolve fallback pages dynamically to avoid import cycles
    final pages = <Widget>[
      WeatherHomeContent(),
      // Map tab shows full WeatherMapScreen
      WeatherMapScreen(),
      // If the screens are available in the project, instantiate them; otherwise use placeholders
      _resolvePage(1),
      _resolvePage(2),
      _resolvePage(3),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _resolvePage(int index) {
    switch (index) {
      case 1:
        try {
          return SearchScreen();
        } catch (_) {
          return Center(child: Text('Search'));
        }
      case 2:
        try {
          return NotificationScreen();
        } catch (_) {
          return Center(child: Text('Notifications'));
        }
      case 3:
        try {
          return ProfileScreen();
        } catch (_) {
          return Center(child: Text('Profile'));
        }
      default:
        return WeatherHomeContent();
    }
  }
}

// Simple wrapper tab which shows WeatherDetailScreen with sample data so the map can be a nav tab
class WeatherDetailTab extends StatelessWidget {
  const WeatherDetailTab({super.key});

  Map<String, dynamic> get _sampleLocation => {
    'name': 'Bangkok',
    'country': 'Thailand',
    'temp': '32°C',
    'condition': 'Sunny',
    'feelsLike': '36°C',
    'humidity': 68,
    'windSpeed': 12.0,
    'visibility': 10,
    'pressure': 1013,
    'description': 'Clear sky',
    'iconCode': '01d',
    'colorCode': 'sunny',
  };

  @override
  Widget build(BuildContext context) {
    return WeatherDetailScreen(locationData: _sampleLocation);
  }
}

// HomeScaffold: provides BottomNavigationBar and hosts main tabs
// HomeScaffold already defined earlier in this file (kept there).
