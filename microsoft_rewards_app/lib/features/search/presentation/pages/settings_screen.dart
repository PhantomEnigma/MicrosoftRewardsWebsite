import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../notifications/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _sendDailyReminder = false;
  bool _keepScreenOn = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
    setState(() {
      _darkMode = themeMode == ThemeMode.dark;
      _sendDailyReminder = prefs.getBool('send_daily_reminder') ?? false;
      _keepScreenOn = prefs.getBool('keep_screen_on') ?? false;
      _selectedTime = TimeOfDay(
        hour: prefs.getInt('reminder_hour') ?? 19,
        minute: prefs.getInt('reminder_minute') ?? 0,
      );
    });
  }

  Future<void> _saveReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('send_daily_reminder', value);
    setState(() => _sendDailyReminder = value);

    if (value) {
      await NotificationService.scheduleDailyReminder(hour: _selectedTime.hour, minute: _selectedTime.minute);
    } else {
      await NotificationService.cancelReminder();
    }
  }

  Future<void> _saveKeepScreenOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('keep_screen_on', value);
    setState(() => _keepScreenOn = value);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('reminder_hour', picked.hour);
      prefs.setInt('reminder_minute', picked.minute);
      setState(() => _selectedTime = picked);

      if (_sendDailyReminder) {
        await NotificationService.scheduleDailyReminder(hour: picked.hour, minute: picked.minute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              themeProvider.toggleTheme(value);
            },
          ),
          SwitchListTile(
            title: const Text("Send Daily Reminder"),
            value: _sendDailyReminder,
            onChanged: _saveReminder,
          ),
          if (_sendDailyReminder)
            ListTile(
              title: const Text("Reminder Time"),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
          SwitchListTile(
            title: const Text("Keep Screen On"),
            value: _keepScreenOn,
            onChanged: _saveKeepScreenOn,
          ),
        ],
      ),
    );
  }
}
