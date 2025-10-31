import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartparking_mobile_application/rating-and-review/models/review.entity.dart';
import 'package:smartparking_mobile_application/shared/services/http-common.dart';

class ReviewService extends ApiClient {
  ReviewService() {
    resourceEndPoint = '/reviews';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Review>> getAllByDriverId(int driverId) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/driver/$driverId');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((item) => Review.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error loading data: ${response.reasonPhrase}');
    }
  }

  Future<List<Review>> getAllByParkingId(int parkingId) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/parking/$parkingId');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((item) => Review.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error loading data: ${response.reasonPhrase}');
    }
  }
}
