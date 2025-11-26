import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// Some backends expose the profile resource at `/profiles/{id}` while
  /// others use `/profiles/driver/{id}`. To be resilient, explicitly call
  /// `/profiles/{id}` when loading the driver by id so it matches the PUT
  /// we use in `updateProfile`.
  Future<Map<String, dynamic>> getById(int id) async {
    // Try canonical `/profiles/{id}` first (matches our PUT). If that fails,
    // fall back to `/profiles/driver/{id}` which some backends expose.
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final uriPrimary = Uri.parse('$baseUrl/profiles/$id');
    try {
      final resp = await http.get(uriPrimary, headers: headers);
      if (resp.statusCode == 200) {
        return json.decode(utf8.decode(resp.bodyBytes));
      }
      // If not found, fallthrough to secondary
      if (resp.statusCode != 404) {
        // Non-404 (server error) — still try fallback but keep note
        debugPrint('profiles/$id returned ${resp.statusCode} ${resp.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('profiles/$id fetch failed: $e');
    }

    // Fallback: use configured resource endpoint (e.g. /profiles/driver/{id})
    try {
      return await getByIdFallback(id);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // Helper to call the ApiClient.getById which uses `resourceEndPoint`.
  Future<Map<String, dynamic>> getByIdFallback(int id) async {
    // ApiClient.getById returns Map<String,dynamic> or throws — reuse it.
    return await getByIdUsingApiClient(id);
  }

  // Separate method to avoid name clash and to use the base class implementation
  Future<Map<String, dynamic>> getByIdUsingApiClient(int id) async {
    return await super.getById(id);
  }

  /// Fetch the profile of the current authenticated user (GET /profiles)
  Future<Map<String, dynamic>> getCurrentProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl/profiles');
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(utf8.decode(resp.bodyBytes));
    } else if (resp.statusCode == 404) {
      throw Exception('Profile not found');
    } else {
      throw Exception('Error fetching profile: ${resp.reasonPhrase}');
    }
  }
}
