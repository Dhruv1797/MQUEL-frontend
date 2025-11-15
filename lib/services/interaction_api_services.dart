import 'dart:convert';
import 'package:a2y_app/model/interaction_history_model.dart';
import 'package:http/http.dart' as http;
import 'package:a2y_app/constants/api_constants.dart';

class InteractionApiServices {
  static const String baseUrl = ApiConstants.baseApiPath;

  static Future<List<InteractionHistory>> getInteractionHistory({
    required String participantName,
    required String organization,
    required int clientId,
  }) async {
    try {
      final encodedName = Uri.encodeComponent(participantName);
      final encodedOrg = Uri.encodeComponent(organization);

      final url =
          '$baseUrl/api/history/get?participantName=$encodedName&organization=$encodedOrg&clientId=$clientId';

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => InteractionHistory.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load interaction history: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching interaction history: $e');
    }
  }
}
