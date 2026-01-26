import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/call_model.dart';

class CallService {
  final ApiClient _apiClient = ApiClient();

  // TASK 2: Initiate call
  // FIX 4: Guard response parsing
  Future<CallModel> initiateCall(String creatorUserId) async {
    debugPrint('📞 [CALL API] Initiating call to creator: $creatorUserId');
    try {
      final response = await _apiClient.post(
        '/calls/initiate',
        data: {
          'creatorUserId': creatorUserId,
        },
      );
      debugPrint('📥 [CALL API] Initiate call response: ${response.statusCode}');

      // Guard: Check if response.data is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: expected Map, got ${response.data.runtimeType}');
      }

      final responseData = response.data as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Guard: Check if data exists and is a Map
        if (responseData['data'] is! Map<String, dynamic>) {
          throw Exception('Invalid data format: expected Map, got ${responseData['data'].runtimeType}');
        }
        final data = responseData['data'] as Map<String, dynamic>;
        final call = CallModel(
          callId: data['callId'] as String,
          channelName: data['channelName'] as String,
          callerUserId: '',
          creatorUserId: creatorUserId,
          status: CallStatus.fromString(data['status'] as String),
        );
        debugPrint('✅ [CALL API] Call initiated successfully');
        debugPrint('   CallId: ${call.callId}');
        debugPrint('   Channel: ${call.channelName}');
        debugPrint('   Status: ${call.status.name}');
        return call;
      } else {
        final error = responseData['error'] as String?;
        final message = responseData['message'] as String?;
        throw Exception(message ?? error ?? 'Failed to initiate call');
      }
    } on DioException catch (e) {
      debugPrint('❌ [CALL API] Initiate call failed: ${e.response?.statusCode}');
      debugPrint('   Error: ${e.message}');
      if (e.response?.statusCode == 409) {
        debugPrint('   Reason: Creator is busy');
        // Creator busy
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          throw Exception(message ?? 'Creator is currently in another call. Please try again later.');
        }
        throw Exception('Creator is currently in another call. Please try again later.');
      }
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'] as String?;
        final message = responseData['message'] as String?;
        throw Exception(message ?? error ?? 'Failed to initiate call');
      }
      throw Exception('Failed to initiate call');
    } catch (e) {
      debugPrint('❌ [CALL API] Initiate call unexpected error: $e');
      rethrow;
    }
  }

  // TASK 4: Accept call (creator only)
  // FIX 4: Guard response parsing
  Future<CallModel> acceptCall(String callId) async {
    debugPrint('✅ [CALL API] Accepting call: $callId');
    try {
      final response = await _apiClient.post('/calls/$callId/accept');
      debugPrint('📥 [CALL API] Accept call response: ${response.statusCode}');

      // Guard: Check if response.data is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: expected Map, got ${response.data.runtimeType}');
      }

      final responseData = response.data as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Guard: Check if data exists and is a Map
        if (responseData['data'] is! Map<String, dynamic>) {
          throw Exception('Invalid data format: expected Map, got ${responseData['data'].runtimeType}');
        }
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final uid = data['uid'] as int? ?? 0;
        debugPrint('✅ [CALL API] Call accepted successfully');
        debugPrint('   Token: ${token.substring(0, 20)}...');
        debugPrint('   UID: $uid');
        
        // Get full call status to get all details
        debugPrint('🔄 [CALL API] Fetching full call status...');
        final callStatus = await getCallStatus(callId);
        debugPrint('✅ [CALL API] Full call status retrieved');
        return callStatus.copyWith(
          token: token,
          uid: uid,
          status: CallStatus.accepted,
        );
      } else {
        final error = responseData['error'] as String?;
        throw Exception(error ?? 'Failed to accept call');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error'] as String?;
        throw Exception(error ?? 'Failed to accept call');
      }
      throw Exception('Failed to accept call');
    }
  }

  // TASK 9: End call
  Future<void> endCall(String callId) async {
    debugPrint('🔚 [CALL API] Ending call: $callId');
    try {
      final response = await _apiClient.post('/calls/$callId/end');
      debugPrint('📥 [CALL API] End call response: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          final duration = data['duration'] as int?;
          final durationFormatted = data['durationFormatted'] as String?;
          debugPrint('✅ [CALL API] Call ended successfully');
          if (duration != null) {
            debugPrint('   Duration: $duration seconds ($durationFormatted)');
          }
        }
      }
    } on DioException catch (e) {
      debugPrint('❌ [CALL API] End call failed: ${e.response?.statusCode}');
      debugPrint('   Error: ${e.message}');
      throw Exception(e.response?.data['error'] ?? 'Failed to end call');
    } catch (e) {
      debugPrint('❌ [CALL API] End call unexpected error: $e');
      rethrow;
    }
  }

  // TASK 10: Reject call (creator only)
  Future<void> rejectCall(String callId) async {
    debugPrint('❌ [CALL API] Rejecting call: $callId');
    try {
      final response = await _apiClient.post('/calls/$callId/reject');
      debugPrint('📥 [CALL API] Reject call response: ${response.statusCode}');
      debugPrint('✅ [CALL API] Call rejected successfully');
    } on DioException catch (e) {
      debugPrint('❌ [CALL API] Reject call failed: ${e.response?.statusCode}');
      debugPrint('   Error: ${e.message}');
      throw Exception(e.response?.data['error'] ?? 'Failed to reject call');
    } catch (e) {
      debugPrint('❌ [CALL API] Reject call unexpected error: $e');
      rethrow;
    }
  }

  // Get call status (for polling)
  // FIX 4: Guard response parsing to prevent type errors
  Future<CallModel> getCallStatus(String callId) async {
    try {
      final response = await _apiClient.get('/calls/$callId/status');
      debugPrint('📊 [CALL API] Get call status response: ${response.statusCode}');

      // Guard: Check if response.data is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: expected Map, got ${response.data.runtimeType}');
      }

      final responseData = response.data as Map<String, dynamic>;

      // FIX 2: Handle 429 explicitly
      if (response.statusCode == 429) {
        debugPrint('⚠️  [CALL API] Rate limited (429)');
        final error = responseData['error'] as String?;
        final message = responseData['message'] as String?;
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: message ?? error ?? 'Too many requests',
        );
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Guard: Check if data exists and is a Map
        if (responseData['data'] is! Map<String, dynamic>) {
          throw Exception('Invalid data format: expected Map, got ${responseData['data'].runtimeType}');
        }
        final data = responseData['data'] as Map<String, dynamic>;
        final call = CallModel.fromJson(data);
        debugPrint('📊 [CALL API] Call status: ${call.status.name}');
        return call;
      } else {
        final error = responseData['error'] as String?;
        throw Exception(error ?? 'Failed to get call status');
      }
    } on DioException catch (e) {
      // Re-throw DioException (including 429) to be handled by caller
      rethrow;
    } catch (e) {
      throw Exception('Failed to get call status: $e');
    }
  }

  // TASK 3: Get incoming calls for creator
  Future<List<CallModel>> getIncomingCalls() async {
    debugPrint('📞 [CALL API] Getting incoming calls for creator...');
    try {
      final response = await _apiClient.get('/calls/incoming');
      debugPrint('📥 [CALL API] Get incoming calls response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final calls = data['calls'] as List<dynamic>;
        final callList = calls.map((call) => CallModel.fromJson(call as Map<String, dynamic>)).toList();
        debugPrint('✅ [CALL API] Found ${callList.length} incoming call(s)');
        for (var call in callList) {
          debugPrint('   - CallId: ${call.callId}, Status: ${call.status.name}');
        }
        return callList;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get incoming calls');
      }
    } on DioException catch (e) {
      debugPrint('❌ [CALL API] Get incoming calls failed: ${e.response?.statusCode}');
      debugPrint('   Error: ${e.message}');
      throw Exception(e.response?.data['error'] ?? 'Failed to get incoming calls');
    } catch (e) {
      debugPrint('❌ [CALL API] Get incoming calls unexpected error: $e');
      rethrow;
    }
  }
}
