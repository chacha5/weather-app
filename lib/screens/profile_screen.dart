import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/app_settings.dart';
import 'signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> searchHistory = [
    {
      'location': 'Bangkok, Thailand',
      'date': '2024-01-15',
      'weather': 'Sunny, 32°C',
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFFF9800),
    },
    {
      'location': 'Tokyo, Japan',
      'date': '2024-01-12',
      'weather': 'Rainy, 18°C',
      'icon': Icons.grain_rounded,
      'color': Color(0xFF42A5F5),
    },
    {
      'location': 'Singapore',
      'date': '2024-01-10',
      'weather': 'Cloudy, 29°C',
      'icon': Icons.cloud_rounded,
      'color': Color(0xFF90A4AE),
    },
    {
      'location': 'Chiang Mai, Thailand',
      'date': '2024-01-08',
      'weather': 'Clear, 25°C',
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFFFA726),
    },
  ];

  bool _isUpdatingProfile = false;

  Future<String?> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid-${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() {});
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    String? newPhotoUrl;

    // Show dialog to collect new name / photo URL, but do NOT perform async
    // updates or call ScaffoldMessenger from the dialog's (possibly deactivated)
    // context. Instead return the result via Navigator.pop and handle updates
    // using this State's context which remains valid.
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text('Edit Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final url = await _pickAndUploadImage();
                      if (url != null) {
                        setState(() {
                          newPhotoUrl = url;
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: newPhotoUrl != null
                          ? NetworkImage(newPhotoUrl!) as ImageProvider
                          : (user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null),
                      child: (user?.photoURL == null && newPhotoUrl == null)
                          ? Icon(Icons.camera_alt_outlined)
                          : null,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newName = nameController.text.trim();
                    Navigator.pop(dialogContext, {
                      'newName': newName,
                      'newPhotoUrl': newPhotoUrl,
                    });
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // If user cancelled the dialog, result will be null.
    if (result == null) return;

    // Perform async updates here using this State's context (safe)
    setState(() => _isUpdatingProfile = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user. Please sign in again.');
      }
      final newName = (result['newName'] as String?)?.trim() ?? '';
      final newPhoto = result['newPhotoUrl'] as String?;
      if (newName.isNotEmpty) {
        await currentUser.updateDisplayName(newName);
      }
      if (newPhoto != null) {
        await currentUser.updatePhotoURL(newPhoto);
      }
      await currentUser.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated: ${refreshed?.displayName ?? ''}'),
        ),
      );
      setState(() {});
    } catch (e) {
      print('Error updating profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      // Profile Avatar and Info (from Firebase user if available)
                      Builder(
                        builder: (context) {
                          final user = FirebaseAuth.instance.currentUser;
                          final displayName =
                              user?.displayName ?? 'Chanutda Krutngam';
                          final photoUrl = user?.photoURL;
                          final email = user?.email ?? '';

                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : NetworkImage(
                                          'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTyNudMZKVVyGRSH520mMVwKTB_arROrVrO24byb_mdbHVK2HPr7MICN4Z9xsrgAh4mfw-KrvfOu--wJG3K9vwSBswvv35WMDfqNgSiSA',
                                        ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                // Limit width so long names don't expand the header
                                width: 220,
                                child: Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (email.isNotEmpty) ...[
                                SizedBox(height: 6),
                                Text(
                                  email,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextButton(
                                  onPressed: _isUpdatingProfile
                                      ? null
                                      : _editProfile,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'Edit profile',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Bangkok, Thailand',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Stats Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '15',
                      'Cities',
                      Color(0xFF42A5F5),
                      Icons.location_city_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '42',
                      'Days',
                      Color(0xFF66BB6A),
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '8',
                      'Alerts',
                      Color(0xFFFF9800),
                      Icons.notifications_outlined,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Recent Searches
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Searches',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 16),
                  ...searchHistory.take(3).map((history) {
                    return _buildHistoryItem(history);
                  }),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Settings Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE3F2FD), width: 1),
                    ),
                    child: Column(
                      children: [
                        Consumer<AppSettings>(
                          builder: (context, settings, _) =>
                              _buildPreferenceItem(
                                'Temperature Unit',
                                settings.temperatureUnit,
                                Icons.thermostat_outlined,
                                Color(0xFFEF5350),
                                onTap: () => settings.toggleTemperatureUnit(),
                                isFirst: true,
                              ),
                        ),
                        Divider(height: 1, color: Color(0xFFE3F2FD)),
                        Consumer<AppSettings>(
                          builder: (context, settings, _) =>
                              _buildPreferenceItem(
                                'Wind Speed Unit',
                                settings.windSpeedUnit,
                                Icons.air_outlined,
                                Color(0xFF29B6F6),
                                onTap: () => settings.toggleWindSpeedUnit(),
                              ),
                        ),
                        Divider(height: 1, color: Color(0xFFE3F2FD)),
                        Consumer<AppSettings>(
                          builder: (context, settings, _) =>
                              _buildPreferenceItem(
                                'Time Format',
                                settings.timeFormat,
                                Icons.access_time_outlined,
                                Color(0xFFAB47BC),
                                onTap: () => settings.toggleTimeFormat(),
                              ),
                        ),
                        Divider(height: 1, color: Color(0xFFE3F2FD)),
                        Consumer<AppSettings>(
                          builder: (context, settings, _) =>
                              _buildPreferenceItem(
                                'Push Notifications',
                                settings.pushNotifications
                                    ? 'Enabled'
                                    : 'Disabled',
                                Icons.notifications_outlined,
                                Color(0xFF66BB6A),
                                onTap: () => settings.togglePushNotifications(),
                                isLast: true,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showLogoutDialog();
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFFFEBEE), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: Color(0xFFEF5350),
                            size: 22,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Color(0xFFEF5350),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFEF5350).withOpacity(0.5),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String count,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE3F2FD), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> history) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE3F2FD), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: history['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(history['icon'], color: history['color'], size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history['location'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  history['weather'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            history['date'].substring(5),
            style: GoogleFonts.poppins(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Perform Firebase sign out
              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                // ignore errors for now, optionally show a snackbar
                print('Error signing out: $e');
              }

              // Call optional callback
              if (widget.onLogout != null) {
                widget.onLogout!();
              }

              // Navigate to SignInScreen and remove previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (ctx) => SignInScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Color(0xFFEF5350),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
