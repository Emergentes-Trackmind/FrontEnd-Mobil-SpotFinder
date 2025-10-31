import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartparking_mobile_application/shared/services/http-common.dart';

class ParkingService extends ApiClient {
  ParkingService() {
    resourceEndPoint = '/parkings';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getParkingSpotsByParkingId(int parkingId) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/$parkingId/spots');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      print('No data available');
      return [];
    } else {
      throw Exception('Error loading data: ${response.reasonPhrase}');
    }
  }
}