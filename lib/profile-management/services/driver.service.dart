import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/services/http-common.dart';

class DriverService extends ApiClient {
  DriverService() {
    resourceEndPoint = '/profiles/driver';
  }

  /// Use this to update profile using the backend endpoint that expects
  /// the profile payload in the request body (PUT /profiles)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/profiles');
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      uri,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error updating profile: ${response.reasonPhrase}');
    }
  }
}