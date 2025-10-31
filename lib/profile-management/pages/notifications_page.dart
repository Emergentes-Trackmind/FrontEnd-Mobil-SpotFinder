import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, String>> _items = [
    {
      'title': 'Reserva confirmada',
      'subtitle': 'Tu reserva para hoy a las 10:00 está confirmada',
    },
    {'title': 'Recordatorio', 'subtitle': 'Tu reserva comienza en 30 minutos'},
    {
      'title': 'Oferta especial',
      'subtitle': '20% de descuento en tu próxima reserva',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
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
