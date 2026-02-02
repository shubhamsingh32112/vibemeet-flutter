import '../../../core/api/api_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient();

  // Get user transaction history
  Future<TransactionResponse> getUserTransactions({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiClient.get(
        '/user/transactions?page=$page&limit=$limit',
      );
      
      if (response.statusCode == 200) {
        return TransactionResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load transactions: ${response.data['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get creator transaction history (earnings)
  Future<TransactionResponse> getCreatorTransactions({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiClient.get(
        '/creator/transactions?page=$page&limit=$limit',
      );
      
      if (response.statusCode == 200) {
        return TransactionResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load transactions: ${response.data['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
