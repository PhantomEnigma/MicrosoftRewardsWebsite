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
  bool _sendDailyReminder = false;
  bool _keepScreenOn = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sendDailyReminder = prefs.getBool('send_daily_reminder') ?? false;
      _keepScreenOn = prefs.getBool('keep_screen_on') ?? false;
      _selectedTime = TimeOfDay(
        hour: prefs.getInt('reminder_hour') ?? 19,
        minute: prefs.getInt('reminder_minute') ?? 0,
      );
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() => _selectedTime = pickedTime);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', pickedTime.hour);
      await prefs.setInt('reminder_minute', pickedTime.minute);
      if (_sendDailyReminder) {
        await NotificationService.scheduleDailyReminder(
          hour: pickedTime.hour,
          minute: pickedTime.minute,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
          SwitchListTile(
            title: const Text("Send Daily Reminder"),
            value: _sendDailyReminder,
            onChanged: (value) async {
              setState(() => _sendDailyReminder = value);
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('send_daily_reminder', value);
              if (value) {
                await NotificationService.scheduleDailyReminder(
                  hour: _selectedTime.hour,
                  minute: _selectedTime.minute,
                );
              } else {
                await NotificationService.cancelReminder();
              }
            },
          ),
          ListTile(
            title: const Text("Reminder Time"),
            subtitle: Text(_selectedTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context),
          ),
          SwitchListTile(
            title: const Text("Keep screen on during search"),
            value: _keepScreenOn,
            onChanged: (value) async {
              setState(() => _keepScreenOn = value);
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('keep_screen_on', value);
            },
          ),
        ],
      ),
    );
  }
}
