import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final String _prefsKey = 'saved_map_markers_v1';
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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
            _items = items.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      } catch (e) {
        debugPrint('Failed to load from firestore: $e');
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        try {
          final list = jsonDecode(raw) as List<dynamic>;
          _items = list.map((e) => Map<String, dynamic>.from(e)).toList();
        } catch (e) {
          debugPrint('Failed to decode saved markers: $e');
        }
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteAt(int index) async {
    _items.removeAt(index);
    await _saveAll();
    if (mounted) setState(() {});
  }

  Future<void> _saveAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('user_map_favorites')
            .doc(user.uid)
            .set({'markers': _items});
        return;
      } catch (e) {
        debugPrint('Firestore save failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Places')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No saved places'))
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final it = _items[i];
                final lat = (it['lat'] as num).toDouble();
                final lng = (it['lng'] as num).toDouble();
                final label = (it['label'] as String?) ?? '';
                final temp = it.containsKey('temp') && it['temp'] != null
                    ? '${it['temp']}\u00B0C'
                    : '-';
                return ListTile(
                  title: Text(label.isEmpty ? 'Unnamed' : label),
                  subtitle: Text('$lat, $lng • $temp'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: () {
                          Navigator.pop(context, {'lat': lat, 'lng': lng});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await _deleteAt(i);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
