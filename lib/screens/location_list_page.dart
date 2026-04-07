import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings.dart';
import '../utils/weather_utils.dart';
import '../services/weather_service.dart';
import 'weather_detail_screen.dart';

class LocationListPage extends StatefulWidget {
  const LocationListPage({super.key});

  @override
  State<LocationListPage> createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  List<Map<String, dynamic>> savedLocations = [];
  bool isLoading = true;
  String? errorMessage;

  // รายการสถานที่ยนิยม
  final List<String> popularCities = [
    'Bangkok',
    'Chiang Mai',
    'Phuket',
    'Pattaya',
    'Tokyo',
    'Singapore',
    'Seoul',
    'Hong Kong',
    'Kuala Lumpur',
    'Manila',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // โหลดข้อมูลสถานที่ที่บันทึกไว้
      List<Map<String, dynamic>> locations = [];
      
      for (String city in popularCities.take(6)) {
        try {
          final weatherData = await WeatherService.getCurrentWeather(city);
          locations.add(weatherData);
        } catch (e) {
          print('Error loading weather for $city: $e');
        }
      }

      setState(() {
        savedLocations = locations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load weather data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadSavedLocations();
  }

  void _navigateToWeatherDetail(Map<String, dynamic> locationData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailScreen(locationData: locationData),
      ),
    );
  }

  void _addNewLocation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddLocationSheet(),
    );
  }

  Widget _buildAddLocationSheet() {
    final TextEditingController controller = TextEditingController();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Add New Location',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter city name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue[600]!),
                    ),
                  ),
                  onSubmitted: (value) => _searchAndAddLocation(value),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: popularCities.length,
              itemBuilder: (context, index) {
                final city = popularCities[index];
                final isAlreadyAdded = savedLocations.any((loc) => 
                  loc['name'].toString().toLowerCase() == city.toLowerCase());
                
                return ListTile(
                  leading: Icon(Icons.location_city, color: Colors.grey[600]),
                  title: Text(city),
                  subtitle: Text('Tap to add'),
                  trailing: isAlreadyAdded 
                    ? Icon(Icons.check, color: Colors.green)
                    : Icon(Icons.add, color: Colors.blue[600]),
                  onTap: isAlreadyAdded ? null : () => _searchAndAddLocation(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAndAddLocation(String cityName) async {
    if (cityName.trim().isEmpty) return;

    try {
      Navigator.pop(context); // ปิด bottom sheet
      
      setState(() {
        isLoading = true;
      });

      final weatherData = await WeatherService.getCurrentWeather(cityName.trim());
      
      // เช็คว่ามีสถานที่นี้แล้วหรือไม่
      final exists = savedLocations.any((loc) => 
        loc['name'].toString().toLowerCase() == weatherData['name'].toString().toLowerCase());
      
      if (!exists) {
        setState(() {
          savedLocations.add(weatherData);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${weatherData['name']} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${weatherData['name']} is already in your list'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('City not found or error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeLocation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Location'),
        content: Text('Are you sure you want to remove ${savedLocations[index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                savedLocations.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Location removed')),
              );
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Locations',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addNewLocation,
            icon: Icon(Icons.add_location, color: Colors.blue[600]),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue[600]),
            SizedBox(height: 16),
            Text(
              'Loading weather data...',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (savedLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No Locations Added',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your favorite cities to see their weather',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewLocation,
              icon: Icon(Icons.add_location),
              label: Text('Add Location'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: savedLocations.length,
      itemBuilder: (context, index) {
        final location = savedLocations[index];
        return _buildLocationCard(location, index);
      },
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location, int index) {
    return GestureDetector(
      onTap: () => _navigateToWeatherDetail(location),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              location['color'].withOpacity(0.8),
              location['color'],
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: location['color'].withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Remove'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeLocation(index);
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Icon(
                    location['icon'],
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Consumer<AppSettings>(builder: (context, settings, _) {
                    return Text(
                      WeatherUtils.formatTemperature(location['temp'], unit: settings.temperatureUnit),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    );
                  }),
                  Text(
                    location['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    location['condition'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}