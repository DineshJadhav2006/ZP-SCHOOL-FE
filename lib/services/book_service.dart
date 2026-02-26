import '../config/env_config.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_mobile.dart';

class BookService {
  static Future<List<dynamic>> getBooksByClass(String className) async {
    try {
      final token = await AuthService.getAccessToken();
      final clientId = await AuthService.getClientId();

      if (token == null || clientId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.booksUrl(clientId, className)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['books'] ?? [];
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('Error fetching books: $e');
      rethrow;
    }
  }

  static Future<String?> uploadBookFile(PlatformFile file) async {
    try {
      final token = await AuthService.getAccessToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.bookUploadUrl),
      );

      request.headers['Authorization'] = 'Bearer $token';
      
      if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
        ));
      }

      var response = await request.send();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        return jsonData['fileUrl'];
      }
      
      return null;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  static Future<bool> addBook({
    required String bookName,
    required String className,
    required String subjectName,
    required String bookUrl,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      final clientId = await AuthService.getClientId();

      if (token == null || clientId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.addBookUrl(clientId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'book_name': bookName,
          'class_name': className,
          'subject_name': subjectName,
          'book_url': bookUrl,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding book: $e');
      return false;
    }
  }

  static Future<bool> deleteBook(String bookId) async {
    try {
      final token = await AuthService.getAccessToken();
      final clientId = await AuthService.getClientId();

      if (token == null || clientId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.bookByIdUrl(clientId, bookId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }

  static Future<String?> downloadBook({
    required String bookUrl,
    required String bookName,
    Function(int, int)? onProgress,
  }) async {
    return await downloadBookPlatform(
      bookUrl: bookUrl,
      bookName: bookName,
      onProgress: onProgress,
    );
  }
}
