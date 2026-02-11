import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/creator_model.dart';
import '../../../shared/models/profile_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/admin_view_provider.dart';

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
  
  // If user is a regular user, show ALL creators.
  // Availability (online/busy) is managed via Socket.IO + Redis in real-time.
  final creators = await ref.watch(creatorsProvider.future);
  return creators;
});

// NOTE: The old Stream-Chat-based creatorStatusEventListenerProvider has been
// removed.  Real-time creator availability is now powered by Socket.IO + Redis
// (see availability_provider.dart and socket_service.dart).
