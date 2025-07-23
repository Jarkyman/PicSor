import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  static const String keyNotifications = 'notifications_enabled';
  static const String keyThemeMode = 'theme_mode';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(keyNotifications) ?? true;
      final themeStr = prefs.getString(keyThemeMode) ?? 'system';
      _themeMode = _themeFromString(themeStr);
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifications, value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, _themeToString(mode));
    setState(() => _themeMode = mode);
  }

  ThemeMode _themeFromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  void _rateApp() async {
    const url =
        'https://apps.apple.com/app/idYOUR_APP_ID'; // Replace with your app store link
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out PicSor! Download it here: https://apps.apple.com/app/idYOUR_APP_ID',
      ),
    ); // Replace with your app link
  }

  void _openPrivacyPolicy() async {
    const url =
        'https://yourdomain.com/privacy'; // Replace with your privacy policy URL
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.title(context)),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: _setNotifications,
            title: Text('Notifications', style: AppTextStyles.label(context)),
            secondary: Icon(
              Icons.notifications_active,
              size: Scale.of(context, 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6, size: Scale.of(context, 24)),
            title: Text('Theme', style: AppTextStyles.label(context)),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              onChanged: (mode) {
                if (mode != null) _setThemeMode(mode);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System', style: AppTextStyles.body(context)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light', style: AppTextStyles.body(context)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark', style: AppTextStyles.body(context)),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.star_rate, size: Scale.of(context, 24)),
            title: Text('Rate the app', style: AppTextStyles.label(context)),
            onTap: _rateApp,
          ),
          ListTile(
            leading: Icon(Icons.share, size: Scale.of(context, 24)),
            title: Text('Share PicSor', style: AppTextStyles.label(context)),
            onTap: _shareApp,
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, size: Scale.of(context, 24)),
            title: Text('Privacy Policy', style: AppTextStyles.label(context)),
            onTap: _openPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}
