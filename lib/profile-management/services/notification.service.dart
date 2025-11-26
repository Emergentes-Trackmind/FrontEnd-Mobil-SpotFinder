import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../shared/services/http-common.dart';

class NotificationService extends ApiClient {
  NotificationService() {
    resourceEndPoint = '/notifications';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch notifications for current user with pagination
  Future<List<dynamic>> fetch({int page = 1, int size = 10, String? q, bool? read}) async {
    final params = <String, String>{'page': page.toString(), 'size': size.toString()};
    if (q != null) params['q'] = q;
    if (read != null) params['read'] = read.toString();

    final uri = Uri.parse('$baseUrl$resourceEndPoint').replace(queryParameters: params);
    final headers = await _getHeaders();
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final decoded = json.decode(utf8.decode(resp.bodyBytes));
      // Debug log the response shape (trim long outputs)
      try {
        final preview = decoded is List || decoded is Map ? json.encode(decoded) : decoded.toString();
        debugPrint('Notifications response preview: ${preview.length > 1000 ? preview.substring(0, 1000) + "..." : preview}');
      } catch (_) {}

      // If the backend returns a JSON array, use it directly
      if (decoded is List) {
        return decoded;
      }

      // If the backend returns an object, attempt to locate a list inside common keys
      if (decoded is Map) {
        final candidates = ['content', 'data', 'items', 'notifications', 'results', 'payload', 'list'];
        for (final key in candidates) {
          if (decoded.containsKey(key) && decoded[key] is List) {
            return decoded[key] as List;
          }
        }

        // If the map itself looks like a single notification (has title or message), wrap it
        final singleNotificationKeys = ['title', 'subject', 'message', 'body', 'text', 'description'];
        for (final k in singleNotificationKeys) {
          if (decoded.containsKey(k)) {
            return [decoded];
          }
        }

        return [];
      }

      throw Exception('Unexpected notifications response shape');
    } else if (resp.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error loading notifications: ${resp.statusCode} ${resp.reasonPhrase}');
    }
  }
}
