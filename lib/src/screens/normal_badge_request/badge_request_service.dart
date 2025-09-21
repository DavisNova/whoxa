import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class BadgeRequestService {
  // Replace with your actual base URL in production
  final String baseUrl;

  BadgeRequestService({required this.baseUrl});

  Future<Map<String, dynamic>> submitBadgeRequest({
    required String fullName,
    required File idImage,
    String? token,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/request-subscription-vip-user');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add text field
      request.fields['full_name'] = fullName;

      // Add file
      final fileExtension = idImage.path.split('.').last.toLowerCase();
      final mimeType = fileExtension == 'png'
          ? 'image/png'
          : fileExtension == 'pdf'
              ? 'application/pdf'
              : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          idImage.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Add auth token if provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to submit badge request',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
