import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/weather_utils.dart';
import '../providers/app_settings.dart';
import '../services/weather_service.dart';
import 'weather_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // รายการเมืองที่นิยม (ใช้ข้อมูลจาก WeatherService)
  final List<String> _popularCities = [
    'Bangkok',
    'Chiang Mai',
    'Phuket',
    'Tokyo',
    'Singapore',
    'Seoul',
  ];

  List<Map<String, dynamic>> _popularLocations = [];
  bool _isLoadingPopular = true;

  @override
  void initState() {
    super.initState();
    _loadPopularLocations();
  }

  Future<void> _loadPopularLocations() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPopular = true;
    });

    try {
      List<Map<String, dynamic>> locations = [];

      for (String city in _popularCities) {
        try {
          final weatherData = await WeatherService.getCurrentWeather(city);
          // เพิ่ม icon และ color จาก WeatherUtils
          weatherData['icon'] = WeatherUtils.getWeatherIcon(
            weatherData['iconCode'],
          );
          weatherData['color'] = WeatherUtils.getWeatherColor(
            weatherData['colorCode'],
          );
          locations.add(weatherData);
        } catch (e) {
          print('Error loading weather for $city: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _popularLocations = locations;
        _isLoadingPopular = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPopular = false;
      });
      print('Error loading popular locations: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final weatherData = await WeatherService.getCurrentWeather(query.trim());
      // เพิ่ม icon และ color
      weatherData['icon'] = WeatherUtils.getWeatherIcon(
        weatherData['iconCode'],
      );
      weatherData['color'] = WeatherUtils.getWeatherColor(
        weatherData['colorCode'],
      );

      if (!mounted) return;
      setState(() {
        _searchResults = [weatherData];
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('City not found or error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _popularLocations;
    }
    return _searchResults;
  }

  void _navigateToWeatherDetail(Map<String, dynamic> locationData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailScreen(locationData: locationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Location',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      // Trigger search for any non-empty input (including 1 or 2 letters)
                      if (value.trim().isNotEmpty) {
                        _searchLocation(value);
                      }
                    },
                    onSubmitted: (value) => _searchLocation(value),
                    decoration: InputDecoration(
                      hintText: 'Search city or location...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: _isSearching
                          ? Padding(
                              padding: EdgeInsets.all(15),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue[600],
                                ),
                              ),
                            )
                          : Icon(Icons.search, color: Colors.grey[500]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500]),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Current Location
          GestureDetector(
            onTap: () async {
              try {
                final currentLocationData =
                    await WeatherService.getCurrentWeather('Bangkok');
                currentLocationData['icon'] = WeatherUtils.getWeatherIcon(
                  currentLocationData['iconCode'],
                );
                currentLocationData['color'] = WeatherUtils.getWeatherColor(
                  currentLocationData['colorCode'],
                );
                _navigateToWeatherDetail(currentLocationData);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading current location')),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use Current Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Bangkok, Thailand',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Consumer<AppSettings>(builder: (context, settings, _) {
                    return Text(
                      WeatherUtils.formatTemperature(32, unit: settings.temperatureUnit),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Popular Locations / Search Results
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Popular Locations'
                        : 'Search Results',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(child: _buildLocationsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList() {
    if (_isLoadingPopular && _searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue[600]),
            SizedBox(height: 16),
            Text(
              'Loading popular locations...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final locations = _filteredLocations;

    if (locations.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No locations found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              'Try searching for a different city',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No locations available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return GestureDetector(
          onTap: () => _navigateToWeatherDetail(location),
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: location['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    location['icon'],
                    color: location['color'],
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        location['country'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        location['condition'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Consumer<AppSettings>(builder: (context, settings, _) {
                  return Column(
                    children: [
                      Text(
                        WeatherUtils.formatTemperature(location['temp'], unit: settings.temperatureUnit),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
