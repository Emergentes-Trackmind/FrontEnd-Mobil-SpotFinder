import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';
  final String resourceEndPoint = '/authentication';

  Future<Map<String, dynamic>> logIn(String email, String password) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/sign-in');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error signing in: ${response.body}');
    }
  }

  /// Sing up with optional userType: 'driver' or 'parking-owner'
  Future<Map<String, dynamic>> singUp(
    Map<String, dynamic> userData, {
    String userType = 'driver',
  }) async {
    final endpoint =
        userType == 'parking-owner'
            ? 'sign-up/parking-owner'
            : 'sign-up/driver';
    final uri = Uri.parse('$baseUrl$resourceEndPoint/$endpoint');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error signing up: ${response.body}');
    }
  }
}
