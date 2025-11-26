import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://spotfinderback-eaehduf4ehh7hjah.eastus2-01.azurewebsites.net/api/v1';
  String? _token;
  String? resourceEndPoint;

  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> get([Map<String, dynamic>? queryParams]) async {
    Uri uri = Uri.parse('$baseUrl$resourceEndPoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      // Ensure all values are strings for Uri
      final filtered = <String, String>{};
      queryParams.forEach((k, v) {
        if (v != null) filtered[k] = v.toString();
      });
      uri = uri.replace(queryParameters: filtered);
    }

    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error loading data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> post(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint');
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    final decodedBody = response.bodyBytes.isNotEmpty ? json.decode(utf8.decode(response.bodyBytes)) : null;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return decodedBody ?? {};
    } else {
      final bodyPreview = decodedBody != null ? decodedBody.toString() : '(empty body)';
      throw Exception('Error posting data: ${response.statusCode} ${response.reasonPhrase} - $bodyPreview');
    }
  }

  Future<Map<String, dynamic>> put(int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/$id');
    final headers = await _getHeaders();

    final response = await http.put(
      uri,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error updating data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/$id');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else {
      throw Exception('Error fetching resource: ${response.reasonPhrase}');
    }
  }
}
