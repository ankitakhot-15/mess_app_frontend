import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/utils/storage_service.dart';

class TrackingRepository {
  /// Returns the tracking `data` map, or null if unavailable.
  Future<Map<String, dynamic>?> track(String orderId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.customerTracking(orderId)}',
      );
      final token = StorageService.token;
      if (token == null || token.isEmpty) {
        debugPrint('[TRACK] Cannot request tracking without an auth token.');
        return null;
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.timeout);

      debugPrint('[TRACK] status=${response.statusCode} body=${response.body}');

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) return null;

      final data = body['data'];
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('[TRACK] error: $e');
      return null;
    }
  }
}
