import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/user_model.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  try {
    final apiClient = ApiClient();
    final response = await apiClient.get('/user/me');
    
    if (response.statusCode == 200) {
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    }
    return null;
  } catch (e) {
    return null;
  }
});
