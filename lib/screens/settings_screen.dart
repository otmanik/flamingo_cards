import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _soundEffects = true;
  bool _vibration = true;
  bool _autoFlip = false;
  int _autoFlipDuration = 5;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? true;
      _soundEffects = prefs.getBool('soundEffects') ?? true;
      _vibration = prefs.getBool('vibration') ?? true;
      _autoFlip = prefs.getBool('autoFlip') ?? false;
      _autoFlipDuration = prefs.getInt('autoFlipDuration') ?? 5;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('soundEffects', _soundEffects);
    await prefs.setBool('vibration', _vibration);
    await prefs.setBool('autoFlip', _autoFlip);
    await prefs.setInt('autoFlipDuration', _autoFlipDuration);
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'Reset Settings',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to reset all settings to default values?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () {
                  _resetSettings();
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Reset', style: GoogleFonts.poppins()),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
    );
  }

  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _darkMode = false;
      _soundEffects = true;
      _vibration = true;
      _autoFlip = false;
      _autoFlipDuration = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings have been reset to defaults')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: const Color(0xFFFF4081),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Display'),
          SwitchListTile(
            title: Text('Dark Mode', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Enable dark theme throughout the app',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            value: _darkMode,
            onChanged: (newValue) {
              setState(() {
                _darkMode = newValue;
              });
              _saveSettings();
            },
            activeColor: const Color(0xFFFF4081),
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),

          _buildSectionHeader('Feedback'),
          SwitchListTile(
            title: Text('Sound Effects', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Play sounds when flipping cards',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            value: _soundEffects,
            onChanged: (newValue) {
              setState(() {
                _soundEffects = newValue;
              });
              _saveSettings();
            },
            activeColor: const Color(0xFFFF4081),
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: Text('Vibration', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Vibrate when interacting with cards',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            value: _vibration,
            onChanged: (newValue) {
              setState(() {
                _vibration = newValue;
              });
              _saveSettings();
            },
            activeColor: const Color(0xFFFF4081),
            secondary: const Icon(Icons.vibration),
          ),
          const Divider(),

          _buildSectionHeader('Card Behavior'),
          SwitchListTile(
            title: Text('Auto-Flip Cards', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Automatically reveal cards after a delay',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            value: _autoFlip,
            onChanged: (newValue) {
              setState(() {
                _autoFlip = newValue;
              });
              _saveSettings();
            },
            activeColor: const Color(0xFFFF4081),
            secondary: const Icon(Icons.flip),
          ),
          if (_autoFlip)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Auto-flip delay: $_autoFlipDuration seconds',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed:
                        _autoFlipDuration > 1
                            ? () {
                              setState(() {
                                _autoFlipDuration--;
                              });
                              _saveSettings();
                            }
                            : null,
                    color: const Color(0xFFFF4081),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed:
                        _autoFlipDuration < 10
                            ? () {
                              setState(() {
                                _autoFlipDuration++;
                              });
                              _saveSettings();
                            }
                            : null,
                    color: const Color(0xFFFF4081),
                  ),
                ],
              ),
            ),
          const Divider(),

          _buildSectionHeader('About'),
          ListTile(
            title: Text('App Version', style: GoogleFonts.poppins()),
            subtitle: Text(
              _appVersion,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: Text('Privacy Policy', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Read our privacy policy',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            leading: const Icon(Icons.privacy_tip_outlined),
            onTap: () => _launchUrl('https://yourapp.com/privacy'),
            trailing: const Icon(Icons.open_in_new, size: 16),
          ),
          ListTile(
            title: Text('Terms of Service', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Read our terms of service',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            leading: const Icon(Icons.description_outlined),
            onTap: () => _launchUrl('https://yourapp.com/terms'),
            trailing: const Icon(Icons.open_in_new, size: 16),
          ),
          const Divider(),

          // Reset button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ElevatedButton.icon(
              onPressed: _showResetConfirmation,
              icon: const Icon(Icons.restore),
              label: Text('Reset All Settings', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          // Footer with copyright
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                '© 2025 Flamingo Cards. All rights reserved.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF4081),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
