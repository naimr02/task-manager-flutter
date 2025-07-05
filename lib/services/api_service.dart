import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.150.93:8000/api';
  static const String webUrl = 'http://192.168.150.93:8000';
  static const bool enableDebugLogs = true;

  // Enhanced debugging method
  static void _debugLog(String message) {
    if (enableDebugLogs && kDebugMode) {
      print('🔍 ApiService: $message');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    _debugLog('Retrieved token: ${token != null ? 'Found' : 'Not found'}');
    return token;
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _debugLog('Token saved successfully');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _debugLog('Token removed');
  }

  static Future<Map<String, String>> getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        _debugLog('Added Bearer token to headers');
      } else {
        _debugLog('⚠️ No token available for authenticated request');
      }
    }

    _debugLog('Headers prepared: ${headers.keys.join(', ')}');
    return headers;
  }

  // Enhanced login method with mobile-specific endpoint
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = '$baseUrl/auth/mobile-login';
      _debugLog('🌐 Attempting login to: $url');
      _debugLog('📧 Email: $email');

      final headers = await getHeaders(requiresAuth: false);
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
        'device_name': 'Flutter App ${Platform.operatingSystem}',
      });

      _debugLog('📤 Request headers: $headers');
      _debugLog('📤 Request body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      _debugLog('📥 Response status: ${response.statusCode}');
      _debugLog('📥 Response headers: ${response.headers}');
      _debugLog('📥 Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      _debugLog('❌ Network connection error: $e');
      throw Exception('Network connection failed. Please check your internet connection.');
    } on HttpException catch (e) {
      _debugLog('❌ HTTP error: $e');
      throw Exception('Server communication error: $e');
    } on FormatException catch (e) {
      _debugLog('❌ Data format error: $e');
      throw Exception('Invalid server response format');
    } catch (e) {
      _debugLog('❌ Unexpected error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Enhanced logout method
  static Future<Map<String, dynamic>> logout() async {
    try {
      final url = '$baseUrl/auth/logout';
      _debugLog('🌐 Attempting logout to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      _debugLog('📥 Logout response: ${response.statusCode}');
      await removeToken();
      return _handleResponse(response);
    } catch (e) {
      _debugLog('❌ Logout error: $e');
      await removeToken(); // Remove token even if logout fails
      throw Exception('Logout error: $e');
    }
  }

  // Enhanced task operations with better error handling
  static Future<Map<String, dynamic>> getTasks() async {
    try {
      final url = '$baseUrl/tasks';
      print('🌐 Fetching tasks from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      print('📥 Tasks Response Status: ${response.statusCode}');
      print('📥 Tasks Response Body: ${response.body}');

      if (response.body.isEmpty) {
        return {'success': true, 'data': []};
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error fetching tasks: $e');
      throw Exception('Failed to fetch tasks: $e');
    }
  }


  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final url = '$baseUrl/tasks';
      _debugLog('🌐 Creating task at: $url');
      _debugLog('📤 Task data: ${jsonEncode(taskData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(),
        body: jsonEncode(taskData),
      ).timeout(const Duration(seconds: 30));

      _debugLog('📥 Create task response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      _debugLog('❌ Error creating task: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  static Future<Map<String, dynamic>> updateTask(int taskId, Map<String, dynamic> taskData) async {
    try {
      final url = '$baseUrl/tasks/$taskId';
      _debugLog('🌐 Updating task at: $url');
      _debugLog('📤 Update data: ${jsonEncode(taskData)}');

      final response = await http.put(
        Uri.parse(url),
        headers: await getHeaders(),
        body: jsonEncode(taskData),
      ).timeout(const Duration(seconds: 30));

      _debugLog('📥 Update task response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      _debugLog('❌ Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int taskId) async {
    try {
      final url = '$baseUrl/tasks/$taskId';
      _debugLog('🌐 Deleting task at: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 15));

      _debugLog('📥 Delete task response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      _debugLog('❌ Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final url = '$baseUrl/categories';
      _debugLog('🌐 Fetching categories from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 30));

      _debugLog('📥 Categories response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      _debugLog('❌ Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Enhanced response handler with detailed error information
  static Map<String, dynamic> _handleResponse(http.Response response) {
    _debugLog('Processing response with status: ${response.statusCode}');

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _debugLog('✅ Request successful');
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        _debugLog('🔒 Authentication error (401)');
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
          'errors': data['errors'] ?? {},
          'statusCode': 401
        };
      } else if (response.statusCode == 422) {
        _debugLog('📋 Validation error (422)');
        return {
          'success': false,
          'message': data['message'] ?? 'Validation failed',
          'errors': data['errors'] ?? {},
          'statusCode': 422
        };
      } else if (response.statusCode >= 500) {
        _debugLog('🔥 Server error (${response.statusCode})');
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
          'errors': {},
          'statusCode': response.statusCode
        };
      } else {
        _debugLog('⚠️ Client error (${response.statusCode})');
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
          'errors': data['errors'] ?? {},
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      _debugLog('❌ Error parsing response: $e');
      return {
        'success': false,
        'message': 'Invalid server response',
        'errors': {},
        'statusCode': response.statusCode
      };
    }
  }
}
