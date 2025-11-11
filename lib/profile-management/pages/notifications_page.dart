import 'package:flutter/material.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, String>> _items = [
    {
      'title': tr('notifications.confirmed_title'),
      'subtitle': tr('notifications.confirmed_subtitle'),
    },
    {'title': tr('notifications.reminder_title'), 'subtitle': tr('notifications.reminder_subtitle')},
    {
      'title': tr('notifications.offer_title'),
      'subtitle': tr('notifications.offer_subtitle'),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('notifications.title'))),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final it = _items[index];
          return ListTile(
            title: Text(it['title']!),
            subtitle: Text(it['subtitle']!),
            trailing: const Icon(Icons.circle, size: 10, color: Colors.purple),
          );
        },
      ),
    );
  }
}
