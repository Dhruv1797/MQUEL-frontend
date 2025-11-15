import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:a2y_app/model/notification_model.dart';
import 'package:a2y_app/constants/api_constants.dart';

class NotificationService {
  static const String baseUrl = ApiConstants.baseApiPath;

  static Future<List<NotificationModel>> getNotifications(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/notifications?userId=$userId');

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        log('Failed to fetch notifications: ${response.statusCode}');
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error fetching notifications: $e');
      throw Exception('Error fetching notifications: $e');
    }
  }

  static Future<bool> clearNotification(int notificationId) async {
    try {
      log('Clearing notification: $notificationId');
      return true;
    } catch (e) {
      log('Error clearing notification: $e');
      return false;
    }
  }
}
