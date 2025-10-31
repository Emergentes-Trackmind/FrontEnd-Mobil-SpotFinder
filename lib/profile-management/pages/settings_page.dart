import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/app_state.dart';

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
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Notificaciones',
            style: TextStyle(fontWeight: FontWeight.bold),
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
            title: const Text('Ofertas y promociones'),
            value: _offers,
            onChanged: (v) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pref_offers', v);
              setState(() => _offers = v);
            },
          ),
          SwitchListTile(
            title: const Text('Actualizaciones de la app'),
            value: _updates,
            onChanged: (v) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('pref_updates', v);
              setState(() => _updates = v);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Preferencias',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder:
                    (ctx) => SimpleDialog(
                      title: const Text('Selecciona idioma'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, 'Español'),
                          child: const Text('Español'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, 'English'),
                          child: const Text('English'),
                        ),
                      ],
                    ),
              );
              if (selected != null) {
                await AppState.setLanguage(selected);
                if (!mounted) return;
                setState(() => _language = selected);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Idioma guardado')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_theme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder:
                    (ctx) => SimpleDialog(
                      title: const Text('Selecciona tema'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, 'Claro'),
                          child: const Text('Claro'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, 'Oscuro'),
                          child: const Text('Oscuro'),
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
                ).showSnackBar(const SnackBar(content: Text('Tema guardado')));
              }
            },
          ),
        ],
      ),
    );
  }
}
