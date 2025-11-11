import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/app_state.dart';
import '../../shared/i18n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _reminders = true;
  bool _offers = false;
  bool _updates = true;
  String _language = 'Español';
  String _theme = 'Claro';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders = prefs.getBool('pref_reminders') ?? _reminders;
      _offers = prefs.getBool('pref_offers') ?? _offers;
      _updates = prefs.getBool('pref_updates') ?? _updates;
      _language = prefs.getString('language') ?? _language;
      _theme = prefs.getString('theme') ?? _theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            tr('settings.notifications'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Recordatorios de reserva'),
            value: _reminders,
            onChanged: (v) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pref_reminders', v);
              setState(() => _reminders = v);
            },
          ),
          SwitchListTile(
            title: Text(tr('settings.offers')),
            value: _offers,
            onChanged: (v) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pref_offers', v);
              setState(() => _offers = v);
            },
          ),
          SwitchListTile(
            title: Text(tr('settings.updates')),
            value: _updates,
            onChanged: (v) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pref_updates', v);
              setState(() => _updates = v);
            },
          ),
          const SizedBox(height: 12),
          Text(
            tr('settings.preferences'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: Text(tr('settings.language')),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder:
                    (ctx) => SimpleDialog(
                  title: Text(tr('settings.select_language')),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, 'Español'),
                      child: Text(tr('language.spanish')),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, 'English'),
                      child: Text(tr('language.english')),
                    ),
                  ],
                ),
              );
              if (selected != null) {
                await AppState.setLanguage(selected);
                if (!mounted) return;
                setState(() => _language = selected);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('settings.saved_language'))),
                );
              }
            },
          ),
          ListTile(
            title: Text(tr('settings.theme')),
            subtitle: Text(_theme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder:
                    (ctx) => SimpleDialog(
                  title: Text(tr('settings.select_theme')),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, 'Claro'),
                      child: Text(tr('theme.light')),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, 'Oscuro'),
                      child: Text(tr('theme.dark')),
                    ),
                  ],
                ),
              );
              if (selected != null) {
                await AppState.setTheme(selected);
                if (!mounted) return;
                setState(() => _theme = selected);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(tr('settings.saved_theme'))));
              }
            },
          ),
        ],
      ),
    );
  }
}
