import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../session.dart';

class ApiService {
  // Dynamically choose URL based on platform
  static String get baseUrl {
    // For Android Emulator: use 10.0.2.2
    // For iOS Simulator: use 127.0.0.1 or localhost
    // For Physical Device: replace with your computer's IP address (e.g., 192.168.1.100)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android Emulator
      // return 'http://192.168.8.100:3000/api'; // Use this for physical device
    }
    return 'http://127.0.0.1:3000/api'; // iOS Simulator / Desktop
  }

  // Timeout duration for all HTTP requests
  static const Duration timeoutDuration = Duration(seconds: 10);

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
    String role,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'role': role,
            }),
          )
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check:\n'
                '1. Backend server is running\n'
                '2. Network connection is active\n'
                '3. Correct IP address is configured',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the response has the expected structure
        if (data['success'] == true && data['data'] != null) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Invalid credentials');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Request failed');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
        'Cannot connect to server. Please check:\n'
        '1. Backend server is running (node server.js)\n'
        '2. Firewall settings allow connection\n'
        '3. Using correct IP: $baseUrl',
      );
    } on TimeoutException {
      throw Exception('Connection timeout - server not responding');
    } on FormatException {
      throw Exception('Invalid response format from server');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<dynamic>> getMembers() async {
    final url = Uri.parse('$baseUrl/members');
    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return body['data'];
        }
        return [];
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching members: $e');
    }
  }

  static Future<Map<String, dynamic>> saveTransaction(
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse('$baseUrl/transactions');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final errBody = jsonDecode(response.body);
          throw Exception(errBody['message'] ?? 'Transaction failed');
        } catch (_) {
          throw Exception('Transaction failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Network error saving transaction: $e');
    }
  }

  static Future<Map<String, dynamic>> registerMember(
    Map<String, dynamic> memberData,
  ) async {
    final url = Uri.parse('$baseUrl/members');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(memberData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to register member: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error registering member: $e');
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    // Route to correct dashboard endpoint by role
    final bool isManager = AppSession.role == 'manager';
    final path = isManager
        ? '/reports/manager-dashboard'
        : '/reports/field-visitor-dashboard';
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return body['data'] as Map<String, dynamic>;
        }
        // Legacy shape fallback
        return body;
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching dashboard stats: $e');
    }
  }

  static Future<List<dynamic>> getYearlyAnalysis() async {
    final url = Uri.parse('$baseUrl/reports/yearly');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load yearly analysis');
      }
    } catch (e) {
      throw Exception('Network error fetching yearly analysis: $e');
    }
  }

  static Future<List<dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error fetching products: $e');
    }
  }

  static Future<List<dynamic>> getTransactions({
    String? memberId,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (memberId != null) queryParams['memberId'] = memberId;
    if (type != null) queryParams['type'] = type;

    final url = Uri.parse(
      '$baseUrl/transactions',
    ).replace(queryParameters: queryParams);
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return body['data'];
        }
        return [];
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching transactions: $e');
    }
  }

  static Future<List<dynamic>> getNotifications() async {
    final url = Uri.parse('$baseUrl/notifications');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return body['data'];
        }
        return [];
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching notifications: $e');
    }
  }

  static Future<List<dynamic>> getNotes() async {
    final url = Uri.parse('$baseUrl/notes');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return body['data'];
        }
        return [];
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching notes: $e');
    }
  }

  static Future<Map<String, dynamic>> createNote({
    required String title,
    required String noteText,
    String? category,
  }) async {
    final url = Uri.parse('$baseUrl/notes');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'noteText': noteText,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body;
        }
        throw Exception(body['message'] ?? 'Failed to create note');
      } else {
        throw Exception('Failed to create note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error creating note: $e');
    }
  }

  static Future<Map<String, dynamic>> updateNote({
    required String noteId,
    String? title,
    String? noteText,
    String? category,
  }) async {
    final url = Uri.parse('$baseUrl/notes/$noteId');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          if (title != null) 'title': title,
          if (noteText != null) 'noteText': noteText,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body;
        }
        throw Exception(body['message'] ?? 'Failed to update note');
      } else {
        throw Exception('Failed to update note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error updating note: $e');
    }
  }

  static Future<void> deleteNote(String noteId) async {
    final url = Uri.parse('$baseUrl/notes/$noteId');
    try {
      final response = await http.delete(url, headers: await _getHeaders());

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete note');
      }
    } catch (e) {
      throw Exception('Network error deleting note: $e');
    }
  }

  // Helper to add Auth headers
  static Future<Map<String, String>> _getHeaders() async {
    // Basic headers
    final headers = {'Content-Type': 'application/json'};

    // Add Token if available in Session
    // We need to import session.dart at top of file first
    // Assuming we can access AppSession.token
    // Ideally we should inject session or pass it, but for this static class:
    // We will add the import in a separate step or just assume the user updates it logic?
    // Let's rely on AppSession being accessible if we import it.
    // NOTE: We need to make sure AppSession import is added to this file.

    // For now, we'll implement the logic, and I will add the import next.
    if (AppSession.token != null) {
      headers['Authorization'] = 'Bearer ${AppSession.token}';
    }

    return headers;
  }
}
