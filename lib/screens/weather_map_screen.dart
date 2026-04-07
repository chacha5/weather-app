import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/weather_service.dart';
import '../utils/weather_utils.dart';
import 'saved_places_screen.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final fm.MapController _mapController = fm.MapController();
  final List<fm.Marker> _markers = [];
  // metadata per marker key "lat,lng" -> {label, temp, icon}
  final Map<String, Map<String, dynamic>> _markerMeta = {};
  final String _prefsKey = 'saved_map_markers_v1';
  // loading flag removed (not used)
  ll.LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadSavedMarkers();
    await _determinePosition();
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 13);
    } else {
      // default center will be set by moving after map controller is ready
      _mapController.move(ll.LatLng(13.7563, 100.5018), 11);
    }
  }

  Future<void> _loadSavedMarkers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('user_map_favorites')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          final data = snapshot.data();
          final items = data?['markers'] as List<dynamic>?;
          if (items != null) {
            for (var m in items) {
              final json = Map<String, dynamic>.from(m);
              final lat = (json['lat'] as num).toDouble();
              final lng = (json['lng'] as num).toDouble();
              // if temp missing, try fetching current weather
              if (!json.containsKey('temp') || json['temp'] == null) {
                try {
                  final weather =
                      await WeatherService.getCurrentWeatherByCoords(
                        lat: lat,
                        lon: lng,
                      );
                  json['temp'] = weather['temp'];
                } catch (e) {
                  debugPrint('Failed to fetch weather for saved marker: $e');
                }
              }
              _markers.add(_markerFromMap(json));
            }
          }
          return;
        }
      } catch (e) {
        debugPrint('Firestore load markers failed: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (var m in list) {
          _markers.add(_markerFromMap(Map<String, dynamic>.from(m)));
        }
      } catch (e) {
        debugPrint('Failed to decode saved markers: $e');
      }
    }
  }

  Future<void> _saveMarkers() async {
    final user = FirebaseAuth.instance.currentUser;
    final data = _markers.map((m) => _markerToMap(m)).toList();
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('user_map_favorites')
            .doc(user.uid)
            .set({'markers': data});
        return;
      } catch (e) {
        debugPrint('Firestore save failed: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  fm.Marker _markerFromMap(Map<String, dynamic> json) {
    final lat = (json['lat'] as num).toDouble();
    final lng = (json['lng'] as num).toDouble();
    final label = json['label'] as String? ?? '';
    final temp = json.containsKey('temp')
        ? (json['temp'] as num?)?.toInt()
        : null;
    final iconCode = json['iconCode'] as String?;
    final point = ll.LatLng(lat, lng);
    final key = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
    _markerMeta[key] = {'label': label, 'temp': temp, 'icon': iconCode};
    return _buildMarker(point, label, temp, iconCode);
  }

  Map<String, dynamic> _markerToMap(fm.Marker m) {
    final lat = m.point.latitude;
    final lng = m.point.longitude;
    final key = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
    final meta = _markerMeta[key] ?? {};
    return {
      'lat': lat,
      'lng': lng,
      'label': meta['label'] ?? '',
      'temp': meta['temp'],
      'iconCode': meta['icon'],
    };
  }

  fm.Marker _buildMarker(
    ll.LatLng point,
    String label,
    int? temp,
    String? iconCode,
  ) {
    return fm.Marker(
      width: 140,
      height: 110,
      point: point,
      child: GestureDetector(
        onTap: () => _showMarkerDetails(point),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(label, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconCode != null) ...[
                      Icon(WeatherUtils.getWeatherIcon(iconCode), size: 16),
                      const SizedBox(width: 6),
                    ],
                    if (temp != null)
                      Text(
                        '${temp}\u00B0C',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _determinePosition() async {
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _currentLocation = ll.LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('Could not determine position: $e');
    }
  }

  void _onMapTap(ll.LatLng latlng) async {
    final name = await _askForMarkerName();
    if (name == null || name.isEmpty) return;
    // fetch current weather for this location
    int? temp;
    String? iconCode;
    try {
      final weather = await WeatherService.getCurrentWeatherByCoords(
        lat: latlng.latitude,
        lon: latlng.longitude,
      );
      temp = weather['temp'] as int?;
      iconCode = weather['iconCode'] as String?;
    } catch (e) {
      debugPrint('Failed to fetch weather for marker: $e');
    }

    final key =
        '${latlng.latitude.toStringAsFixed(6)},${latlng.longitude.toStringAsFixed(6)}';
    _markerMeta[key] = {'label': name, 'temp': temp, 'icon': iconCode};
    final marker = _buildMarker(latlng, name, temp, iconCode);
    setState(() => _markers.add(marker));
    await _saveMarkers();
  }

  Future<void> _showMarkerDetails(ll.LatLng point) async {
    final key =
        '${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}';
    final meta = _markerMeta[key] ?? {'label': '', 'temp': null, 'icon': null};
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (meta['icon'] != null)
                  Icon(
                    WeatherUtils.getWeatherIcon(meta['icon'] as String),
                    size: 28,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meta['label'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  meta['temp'] != null ? '${meta['temp']}\u00B0C' : '-',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _refreshMarker(point);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final newName = await _askForEditName(
                      meta['label'] as String? ?? '',
                    );
                    if (newName != null) {
                      await _editMarkerLabel(point, newName);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _deleteMarker(point);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshMarker(ll.LatLng point) async {
    final key =
        '${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}';
    try {
      final weather = await WeatherService.getCurrentWeatherByCoords(
        lat: point.latitude,
        lon: point.longitude,
      );
      final temp = weather['temp'] as int?;
      final icon = weather['iconCode'] as String?;
      final meta = _markerMeta[key] ?? {};
      meta['temp'] = temp;
      meta['icon'] = icon;
      _markerMeta[key] = meta;
      // replace marker widget
      _replaceMarkerWidget(point, meta['label'] ?? '', temp, icon);
      await _saveMarkers();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to refresh marker: $e');
    }
  }

  Future<void> _editMarkerLabel(ll.LatLng point, String newLabel) async {
    final key =
        '${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}';
    final meta = _markerMeta[key] ?? {};
    meta['label'] = newLabel;
    _markerMeta[key] = meta;
    _replaceMarkerWidget(
      point,
      newLabel,
      meta['temp'] as int?,
      meta['icon'] as String?,
    );
    await _saveMarkers();
    if (mounted) setState(() {});
  }

  Future<void> _deleteMarker(ll.LatLng point) async {
    final idx = _markers.indexWhere(
      (m) =>
          m.point.latitude == point.latitude &&
          m.point.longitude == point.longitude,
    );
    if (idx != -1) {
      _markers.removeAt(idx);
      final key =
          '${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}';
      _markerMeta.remove(key);
      await _saveMarkers();
      if (mounted) setState(() {});
    }
  }

  void _replaceMarkerWidget(
    ll.LatLng point,
    String label,
    int? temp,
    String? icon,
  ) {
    final idx = _markers.indexWhere(
      (m) =>
          m.point.latitude == point.latitude &&
          m.point.longitude == point.longitude,
    );
    if (idx != -1) {
      _markers[idx] = _buildMarker(point, label, temp, icon);
    }
  }

  Future<String?> _askForEditName(String current) async {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<String?> _askForMarkerName() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save place'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map (OSM)'),
        actions: [
          IconButton(
            tooltip: 'Refresh all markers',
            onPressed: () async {
              await _refreshAllMarkers();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Saved places',
            onPressed: () async {
              // open saved places list and await selection
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedPlacesScreen()),
              );
              if (res is Map<String, dynamic> &&
                  res.containsKey('lat') &&
                  res.containsKey('lng')) {
                final lat = (res['lat'] as num).toDouble();
                final lng = (res['lng'] as num).toDouble();
                final target = ll.LatLng(lat, lng);
                _mapController.move(target, 14);
              } else {
                // after returning, reload markers to pick up edits/deletes
                await _reloadMarkersFromStorage();
                if (mounted) setState(() {});
              }
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: fm.FlutterMap(
        mapController: _mapController,
        options: fm.MapOptions(onTap: (tapPos, latlng) => _onMapTap(latlng)),
        children: [
          fm.TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          fm.MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 13);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _refreshAllMarkers() async {
    for (var m in List<fm.Marker>.from(_markers)) {
      final p = m.point;
      await _refreshMarker(p);
      // small delay to avoid hammering API
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  Future<void> _reloadMarkersFromStorage() async {
    _markers.clear();
    _markerMeta.clear();
    await _loadSavedMarkers();
  }
}
