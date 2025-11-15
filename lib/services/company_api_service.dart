import 'package:a2y_app/model/companyModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:a2y_app/constants/api_constants.dart';

class CompanyService {
  static const String baseUrl = ApiConstants.baseApiPath;

  static Future<List<CompanyModel>> getCompanies() async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(
        Uri.parse('$baseUrl/api/client/get'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CompanyModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching companies: $e');
    }
  }

  static Future<bool> editCompanyCooldown({
    required String clientId,
    required String cooldownPeriod1,
    required String cooldownPeriod2,
    required String cooldownPeriod3,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/client/edit'),
      );

      final authHeaders = await ApiConstants.getAuthHeaders();
      request.headers.addAll(authHeaders);

      request.fields['clientId'] = clientId;
      request.fields['cooldownPeriod1'] = cooldownPeriod1;
      request.fields['cooldownPeriod2'] = cooldownPeriod2;
      request.fields['cooldownPeriod3'] = cooldownPeriod3;

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to edit company cooldown: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error editing company cooldown: $e');
    }
  }
}
