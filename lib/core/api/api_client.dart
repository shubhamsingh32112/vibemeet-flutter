import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('📤 [API] ${options.method} ${options.baseUrl}${options.path}');
          if (options.data != null) {
            debugPrint('   📦 Request data: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            debugPrint('   🔍 Query params: ${options.queryParameters}');
          }
          
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.keyAuthToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('   🔑 Auth token attached (length: ${token.length})');
          } else {
            debugPrint('   ⚠️  No auth token found');
          }
          
          debugPrint('   📋 Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('📥 [API] Response: ${response.statusCode} ${response.statusMessage}');
          debugPrint('   📍 URL: ${response.requestOptions.uri}');
          if (response.data != null) {
            debugPrint('   📦 Response data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ [API] Request failed');
          debugPrint('   📍 URL: ${error.requestOptions.uri}');
          debugPrint('   🔢 Status: ${error.response?.statusCode}');
          debugPrint('   💬 Message: ${error.message}');
          if (error.response != null) {
            debugPrint('   📦 Error data: ${error.response?.data}');
          }
          
          if (error.response?.statusCode == 401) {
            debugPrint('   🔒 Unauthorized - Token may be expired');
            // Handle token expiry
          }
          
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            debugPrint('   ⏱️  Timeout error - Check network connection');
          }
          
          if (error.type == DioExceptionType.connectionError) {
            debugPrint('   🌐 Connection error - Check if backend is running');
            debugPrint('   💡 Backend URL: ${AppConstants.baseUrl}');
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path) async {
    try {
      debugPrint('🔵 [API] GET request to: $path');
      return await _dio.get(path);
    } catch (e) {
      debugPrint('❌ [API] GET request failed: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      debugPrint('🟢 [API] POST request to: $path');
      if (data != null) {
        debugPrint('   📦 POST data: $data');
      }
      return await _dio.post(path, data: data);
    } catch (e) {
      debugPrint('❌ [API] POST request failed: $e');
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      debugPrint('🟡 [API] PUT request to: $path');
      if (data != null) {
        debugPrint('   📦 PUT data: $data');
      }
      return await _dio.put(path, data: data);
    } catch (e) {
      debugPrint('❌ [API] PUT request failed: $e');
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      debugPrint('🔴 [API] DELETE request to: $path');
      return await _dio.delete(path);
    } catch (e) {
      debugPrint('❌ [API] DELETE request failed: $e');
      rethrow;
    }
  }
}
