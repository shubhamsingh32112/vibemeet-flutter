import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/creator_model.dart';
import '../../../shared/models/profile_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/admin_view_provider.dart';
import '../../chat/providers/stream_chat_provider.dart';

// Provider to fetch creators (for users)
final creatorsProvider = FutureProvider<List<CreatorModel>>((ref) async {
  try {
    debugPrint('🔄 [HOME] Fetching creators from API...');
    final apiClient = ApiClient();
    final response = await apiClient.get('/creator');
    
    debugPrint('📥 [HOME] API Response status: ${response.statusCode}');
    debugPrint('📥 [HOME] API Response data: ${response.data}');
    
    if (response.statusCode == 200) {
      final responseData = response.data;
      
      // Check if response has the expected structure
      if (responseData['success'] == true && responseData['data'] != null) {
        final creatorsData = responseData['data']['creators'] as List?;
        
        if (creatorsData == null) {
          debugPrint('⚠️  [HOME] Response data.creators is null');
          return [];
        }
        
        debugPrint('✅ [HOME] Found ${creatorsData.length} creator(s) in response');
        
        final creators = creatorsData
            .map((json) => CreatorModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('✅ [HOME] Parsed ${creators.length} creator model(s)');
        if (creators.isNotEmpty) {
          debugPrint('   Creator names: ${creators.map((c) => c.name).join(", ")}');
          debugPrint('   Creator online statuses: ${creators.map((c) => "${c.name}: ${c.isOnline}").join(", ")}');
        }
        
        return creators;
      } else {
        debugPrint('⚠️  [HOME] Response structure unexpected: success=${responseData['success']}, data=${responseData['data']}');
        return [];
      }
    } else {
      debugPrint('❌ [HOME] API returned non-200 status: ${response.statusCode}');
      return [];
    }
  } catch (e, stackTrace) {
    debugPrint('❌ [HOME] Error fetching creators: $e');
    debugPrint('   Stack trace: $stackTrace');
    return [];
  }
});

// Provider to fetch users (for creators)
final usersProvider = FutureProvider<List<UserProfileModel>>((ref) async {
  try {
    final apiClient = ApiClient();
    final response = await apiClient.get('/user/list');
    
    if (response.statusCode == 200) {
      final usersData = response.data['data']['users'] as List;
      return usersData
          .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    print('❌ [HOME] Failed to fetch users: Status ${response.statusCode}');
    print('   Response: ${response.data}');
    return [];
  } catch (e) {
    print('❌ [HOME] Error fetching users: $e');
    rethrow; // Re-throw to show error in UI
  }
});

// Provider that returns the appropriate list based on user role
final homeFeedProvider = FutureProvider<List<dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  
  if (user == null) {
    return [];
  }
  
  // If user is an admin, check their view mode preference
  if (user.role == 'admin') {
    final adminViewMode = ref.watch(adminViewModeProvider);
    
    // Default to user view if not set
    if (adminViewMode == null || adminViewMode == AdminViewMode.user) {
      // Admin viewing as user: show creators
      final creators = await ref.watch(creatorsProvider.future);
      return creators;
    } else {
      // Admin viewing as creator: show users
      final users = await ref.watch(usersProvider.future);
      return users;
    }
  }
  
  // If user is a creator, show users
  if (user.role == 'creator') {
    final users = await ref.watch(usersProvider.future);
    return users;
  }
  
  // If user is a regular user, show creators
  // Backend filters by isOnline: true, so only online creators are returned
  final creators = await ref.watch(creatorsProvider.future);
  return creators;
});

/// Provider that sets up Stream event listener for creator status changes
/// This replaces polling with realtime events
/// IMPORTANT: Only sets up for users (not creators) and only after WebSocket connection
/// 
/// CRITICAL: Must wait for WebSocket connection before calling channel.watch()
/// Otherwise Stream returns 400 "Watch or ChatPresence requires an active websocket connection"
final creatorStatusEventListenerProvider = Provider<StreamSubscription?>((ref) {
  final streamClient = ref.watch(streamChatNotifierProvider);
  final authState = ref.watch(authProvider);
  
  // Only set up listener for authenticated users
  if (streamClient == null || authState.user == null) {
    return null;
  }
  
  // Only regular users need to listen for creator status changes
  // (Creators don't need to see other creators' status - they can't even access /creator endpoint)
  if (authState.user!.role != 'user') {
    return null;
  }
  
  // CRITICAL: Check if Stream Chat WebSocket is connected
  // channel.watch() requires an active WebSocket connection with connection_id
  // connectUser() must complete and websocket must be established
  final currentUser = streamClient.state.currentUser;
  if (currentUser == null) {
    debugPrint('⏳ [HOME] Stream Chat user not connected yet, skipping event listener setup');
    return null;
  }
  
  // Check WebSocket connection status - this is the REAL check
  // wsConnectionStatus must be connected before we can watch channels
  final wsStatus = streamClient.wsConnectionStatus;
  
  debugPrint(
    '🔍 [HOME] WS status: $wsStatus, user: ${currentUser.id}',
  );
  
  // Only proceed if WebSocket is connected
  // This is the critical check - channel.watch() will fail with 400 if not connected
  if (wsStatus != ConnectionStatus.connected) {
    debugPrint('⏳ [HOME] WebSocket not connected yet (status: $wsStatus), skipping channel watch');
    return null;
  }
  
  debugPrint('📡 [HOME] Setting up creator status event listener (WebSocket connected)');
  
  // Set up listener for creator status channel
  // Channel ID: 'creator-status' (system channel)
  final channel = streamClient.channel('messaging', id: 'creator-status');
  
  // Watch channel to receive events (only after WebSocket is connected)
  // Wrap in try-catch to prevent provider crash - presence is non-critical UI feature
  StreamSubscription? subscription;
  
  // Set up event listener first (before watching)
  // This ensures we catch events even if watch() is still in progress
  subscription = channel.on().listen((event) {
    // Check if this is our custom event using event.type (first-class property)
    if (event.type == 'creator_status_changed') {
      // Custom event payload is in event.extraData (typed Map<String, Object?>)
      final creatorId = event.extraData['creator_id'] as String?;
      final isOnline = event.extraData['isOnline'] as bool?;
      
      if (creatorId != null && isOnline != null) {
        debugPrint('📡 [HOME] Creator status changed: $creatorId -> $isOnline');
        // Invalidate providers to refresh the list
        // This only runs for users, so creatorsProvider will work correctly
        ref.invalidate(creatorsProvider);
        ref.invalidate(homeFeedProvider);
      }
    }
  });
  
  // Watch channel - this will fail if WebSocket isn't ready
  // Wrap in try-catch to prevent provider crash - presence is non-critical
  try {
    channel.watch().then((_) {
      debugPrint('✅ [HOME] Creator status channel watched');
    }).catchError((error, stackTrace) {
      // Non-critical error - don't crash the provider
      // The event listener is already set up, so it will work once connection is established
      debugPrint('⚠️  [HOME] Failed to watch creator status channel: $error');
      debugPrint('   Stack: $stackTrace');
      debugPrint('   Note: Event listener is still active and will work once connection is ready');
      // Provider continues to exist, will retry watch on next rebuild if connection improves
    });
  } catch (e, st) {
    // Catch any synchronous errors
    debugPrint('⚠️  [HOME] Error setting up creator status watch: $e');
    debugPrint('   Stack: $st');
    // Event listener is still set up, so it will work once connection is ready
  }
  
  // Clean up subscription when provider is disposed
  ref.onDispose(() {
    debugPrint('🛑 [HOME] Disposing creator status event listener');
    subscription?.cancel();
  });
  
  return subscription;
});
