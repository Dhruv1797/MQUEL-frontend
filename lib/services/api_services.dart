import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:a2y_app/model/person_model.dart';
import 'package:a2y_app/constants/api_constants.dart';

class PeopleApiService {
  static const String baseUrl = '${ApiConstants.baseApiPath}/api/excel';
  static const String baseUrling = '${ApiConstants.baseApiPath}/api';
  static const Map<String, String> headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Future<List<PersonData>> fetchAttendees({
    required int orgId,
    required int clientId,
  }) async {
    try {
      final url =
          '$baseUrling/excel/getClientsForOrganization?orgId=$orgId&clientId=$clientId';

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((e) => PersonData.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('Failed to fetch attendees: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching attendees: $e');
      return [];
    }
  }

  static Future<List<PersonData>> fetchFilteredPeople({
    required String field,
    required String value,
    required int clientId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      String encodedValue = Uri.encodeComponent(value);

      String apiUrl =
          '$baseUrling/excel/filter'
          '?field=$field'
          '&value=$encodedValue'
          '&clientId=$clientId'
          '&startDate=$startDate'
          '&endDate=$endDate';

      log("api url : $apiUrl");

      print('Fetching filtered people from: $apiUrl');

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.post(Uri.parse(apiUrl), headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((item) => PersonData.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to fetch filtered people: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching filtered people: $e');
      throw Exception('Error fetching filtered people: $e');
    }
  }

  static Future<List<PersonData>> fetchPersonas({
    required int clientId,
    required String company,
  }) async {
    try {
      final url =
          '$baseUrling/persona/$clientId/search/company?company=${Uri.encodeComponent(company)}';

      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((e) => PersonData.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('Failed to fetch personas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching personas: $e');
      return [];
    }
  }

  static Future<List<PersonData>> fetchPeople({int? clientId}) async {
    try {
      String url = baseUrl;
      if (clientId != null) {
        url = '$url?clientId=$clientId';
      }

      final headers = await ApiConstants.getAuthHeaders();

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((e) => PersonData.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('Failed to fetch people: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching people: $e');
      return [];
    }
  }

  static Future<bool> updatePerson({
    required int id,
    required String name,
    required String designation,
    required String organization,
    required String email,
    required String mobile,
    required String attended,
    required String assignedUnassigned,
    required int clientId,
  }) async {
    try {
      final requestBody = {
        "clientId": clientId,
        "id": id,
        "sheetName": null,
        "name": name,
        "designation": designation,
        "organization": organization,
        "email": email,
        "mobile": mobile,
        "attended": attended,
        "assignedUnassigned": assignedUnassigned,
        "eventName": null,
        "eventDate": null,
        "meetingDone": null,
        "createdAt": null,
        "updatedAt": null,
        "isFocused": false,
        "coolDownTime": null,
      };

      final headers = await ApiConstants.getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrling/excel'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Update failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating person: $e');
      return false;
    }
  }

  static Future<String> uploadFile(
    PlatformFile file,
    int clientId,
    int selectedTabIndex,
    bool isFromCompany,
  ) async {
    try {
      String baseUrl;
      Uri uri;

      if (isFromCompany) {
        baseUrl = '${ApiConstants.baseApiPath}/api/excel';
        uri = Uri.parse('$baseUrl/upload?clientId=$clientId');
      } else if (selectedTabIndex == 0) {
        baseUrl = '${ApiConstants.baseApiPath}/api/excel';
        uri = Uri.parse('$baseUrl/upload?clientId=$clientId');
      } else if (selectedTabIndex == 1) {
        baseUrl = '${ApiConstants.baseApiPath}/api/persona';
        uri = Uri.parse('$baseUrl/upload?clientId=$clientId');
      } else {
        return 'Invalid tab index: $selectedTabIndex';
      }

      final request = http.MultipartRequest('POST', uri);

      final authHeaders = await ApiConstants.getAuthHeaders();
      request.headers.addAll(authHeaders);

      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      } else {
        return 'No file data available';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint('Upload successful: $responseBody');
        return responseBody;
      } else {
        debugPrint('Upload failed (${response.statusCode}): $responseBody');
        return 'Upload failed (status ${response.statusCode})\n$responseBody';
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return 'Error uploading file: $e';
    }
  }

  static Future<bool> deletePerson(int personId) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.delete(
        Uri.parse('$baseUrl/$personId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Person deleted successfully');
        return true;
      } else {
        debugPrint('Failed to delete person: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting person: $e');
      return false;
    }
  }
}
