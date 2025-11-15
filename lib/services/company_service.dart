import 'dart:convert';
import 'package:a2y_app/model/company_model.dart';
import 'package:http/http.dart' as http;
import 'package:a2y_app/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class CompanyService {
  static const String baseUrl = '${ApiConstants.baseApiPath}/api';

  static String _maskAuth(String? auth) {
    if (auth == null) return '';
    if (auth.length < 16) return auth;
    return '${auth.substring(0, 16)}...${auth.substring(auth.length - 6)}';
  }

  static void _logRequest({
    required String label,
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final maskedHeaders = Map<String, String>.from(headers);
    if (maskedHeaders.containsKey('Authorization')) {
      maskedHeaders['Authorization'] = _maskAuth(
        maskedHeaders['Authorization'],
      );
    }
    debugPrint('--- API REQUEST [$label] ---');
    debugPrint('Base: ${ApiConstants.baseApiPath}');
    debugPrint('Path: ${uri.path}');
    debugPrint('Method: $method');
    debugPrint('URL: ${uri.toString()}');
    debugPrint('Query Params: ${uri.queryParameters}');
    debugPrint('Headers: $maskedHeaders');
    if (body != null) debugPrint('Body: $body');
    debugPrint('----------------------------');
  }

  static void _logResponse({
    required String label,
    required Uri uri,
    required http.Response response,
    required Duration duration,
  }) {
    debugPrint('=== API RESPONSE [$label] ===');
    debugPrint('URL: ${uri.toString()}');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Duration: ${duration.inMilliseconds} ms');
    debugPrint('Resp Headers: ${response.headers}');
    debugPrint('Body length: ${response.bodyBytes.length} bytes');
    final preview = response.body.length > 512
        ? '${response.body.substring(0, 512)}...'
        : response.body;
    debugPrint('Body preview: $preview');
    debugPrint('============================');
  }

  static Future<List<Company>> getAllCompanies({int? clientId}) async {
    try {
      String url = '$baseUrl/companies/excel/getAll';
      if (clientId != null) {
        url = '$url?clientId=$clientId';
      }

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.post(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Company.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching companies: $e');
    }
  }

  static Future<List<Company>> getFilteredCompanies(
    String field,
    String value, {
    int? clientId,
  }) async {
    try {
      String url =
          '$baseUrl/companies/excel/filter?field=$field&value=${Uri.encodeComponent(value)}';

      if (clientId != null) {
        url += '&clientId=$clientId';
      }

      print(' CompanyService.getFilteredCompanies() called:');
      print('   Field: $field');
      print('   Value: $value');
      print('   Client ID: $clientId');
      print('   Full URL: $url');

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.post(Uri.parse(url), headers: headers);

      print('    Response Status: ${response.statusCode}');
      print('    Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Company> companies = jsonData
            .map((json) => Company.fromJson(json))
            .toList();

        print('    Successfully parsed ${companies.length} companies');

        if (companies.isNotEmpty) {
          print('    Sample companies:');
          for (int i = 0; i < companies.length && i < 3; i++) {
            print('      - ${companies[i].accountName}');
          }
          if (companies.length > 3) {
            print('      ... and ${companies.length - 3} more');
          }
        }

        return companies;
      } else {
        print('    API Error: ${response.statusCode}');
        print('    Response Body: ${response.body}');
        throw Exception(
          'Failed to load filtered companies: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('    Exception in getFilteredCompanies: $e');
      throw Exception('Error fetching filtered companies: $e');
    }
  }

  static Future<Company?> getCompanyById(int id) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(
        Uri.parse('$baseUrl/companies/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return Company.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching company: $e');
    }
  }

  static Future<Map<String, dynamic>> getCompaniesExcelPaginated({
    required int clientId,
    required int page,
    required int size,
  }) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';
      headers['Content-Type'] = 'application/json';

      final uri = Uri.parse('$baseUrl/companies/excel/getAllPaginated').replace(
        queryParameters: {
          'clientId': clientId.toString(),
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      _logRequest(
        label: 'POST /api/companies/excel/getAllPaginated',
        method: 'POST',
        uri: uri,
        headers: headers,
        body: const {},
      );

      final sw = Stopwatch()..start();
      final resp = await http.post(
        uri,
        headers: headers,
        body: json.encode({}),
      );
      sw.stop();

      _logResponse(
        label: 'POST /api/companies/excel/getAllPaginated',
        uri: uri,
        response: resp,
        duration: sw.elapsed,
      );

      if (resp.statusCode != 200) {
        throw Exception('Failed to load companies (status ${resp.statusCode})');
      }
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('!!! API ERROR (companies paginated): $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAttendeesExcelPaginated({
    required int clientId,
    required int page,
    required int size,
  }) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final uri = Uri.parse('$baseUrl/excel/paginated').replace(
        queryParameters: {
          'clientId': clientId.toString(),
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      _logRequest(
        label: 'GET /api/excel/paginated',
        method: 'GET',
        uri: uri,
        headers: headers,
      );

      final sw = Stopwatch()..start();
      final resp = await http.get(uri, headers: headers);
      sw.stop();

      _logResponse(
        label: 'GET /api/excel/paginated',
        uri: uri,
        response: resp,
        duration: sw.elapsed,
      );

      if (resp.statusCode != 200) {
        throw Exception('Failed to load attendees (status ${resp.statusCode})');
      }
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('!!! API ERROR (attendees paginated): $e');
      rethrow;
    }
  }

  static String getApiFieldMapping(String uiField) {
    switch (uiField) {
      case 'accountName':
        return 'company';
      case 'aeNam':
        return 'aename';
      case 'segment':
        return 'city';
      case 'focusedOrAssigned':
        return 'focusedorassigned';
      case 'accountStatus':
        return 'accountstatus';
      case 'pipelineStatus':
        return 'pipelinestatus';
      case 'accountCategory':
        return 'accountcategory';
      default:
        return uiField;
    }
  }

  static Future<void> testFilterAPI() async {
    try {
      print('Testing Filter API with sample data...');

      final testCompanies = await getFilteredCompanies(
        'company',
        'Indusind Bank',
        clientId: 1,
      );

      print('Test Result: ${testCompanies.length} companies found');
    } catch (e) {
      print('Test Failed: $e');
    }
  }
}
