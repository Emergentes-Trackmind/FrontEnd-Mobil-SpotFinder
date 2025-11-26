import 'package:flutter/material.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';
import 'package:smartparking_mobile_application/profile-management/services/notification.service.dart';

// Displays notifications fetched from the backend

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _service = NotificationService();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('notifications.title'))),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          ],
        )
            : _items.isEmpty
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(tr('notifications.empty')),
            )
          ],
        )
            : ListView.separated(
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final it = _items[index];
            // Normalize item to a Map<String, dynamic> for field extraction
            final Map<String, dynamic> itMap = it is Map
                ? Map<String, dynamic>.from(it)
                : {'message': it?.toString() ?? ''};

            final title = (itMap['title'] ?? itMap['subject'] ?? itMap['type'] ?? '').toString();
            final subtitle = (itMap['message'] ?? itMap['body'] ?? itMap['text'] ?? itMap['description'] ?? itMap['createdAt'] ?? itMap['created_at'] ?? '').toString();
            return ListTile(
              title: Text(title.isNotEmpty ? title : tr('notifications.title')),
              subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
              trailing: const Icon(Icons.circle, size: 10, color: Colors.purple),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _service.fetch(page: 1, size: 20);
      setState(() {
        _items = items;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
