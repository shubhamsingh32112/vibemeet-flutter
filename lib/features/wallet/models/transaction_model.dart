/**
 * 🚨 NAMING CONVENTIONS:
 * - Users: coins, balance, credits, debits
 * - Creators: earnings, earnedAmount, totalEarned (NOT coins, NOT balance)
 */
class TransactionModel {
  final String id;
  final String transactionId;
  final String type; // 'credit' or 'debit'
  // For users: coins (credits/debits)
  // For creators: earnedAmount (earnings)
  final int amount; // Unified field name
  final String source; // 'manual', 'payment_gateway', 'admin', 'video_call'
  final String? description;
  final String? callId;
  final String status;
  final DateTime createdAt;
  final String? durationFormatted; // For creator transactions
  final String? callerUsername; // For creator transactions

  TransactionModel({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.source,
    this.description,
    this.callId,
    required this.status,
    required this.createdAt,
    this.durationFormatted,
    this.callerUsername,
  });

  // Getter for backward compatibility and clarity
  int get coins => amount; // For users
  int get earnedAmount => amount; // For creators

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Handle both "coins" (users) and "earnedAmount" (creators)
    final rawAmount = json['earnedAmount'] ?? json['coins'] ?? 0;
    int parsedAmount;
    if (rawAmount is int) {
      parsedAmount = rawAmount;
    } else if (rawAmount is num) {
      parsedAmount = rawAmount.toInt();
    } else {
      parsedAmount = 0;
    }

    String _toString(dynamic value, String fallback) {
      if (value is String && value.isNotEmpty) return value;
      return fallback;
    }

    return TransactionModel(
      id: _toString(json['id'], ''),
      transactionId: _toString(json['transactionId'], ''),
      type: _toString(json['type'], 'credit'),
      amount: parsedAmount,
      // For creators, "source" is always "video_call"; for users it may be 'manual', 'payment_gateway', etc.
      source: _toString(json['source'], 'unknown'),
      description: json['description'] as String?,
      callId: json['callId'] as String?,
      // Creator transactions currently don't include "status" – default to 'completed'
      status: _toString(json['status'], 'completed'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      durationFormatted: json['durationFormatted'] as String?,
      callerUsername: json['callerUsername'] as String?,
    );
  }
}

class TransactionSummary {
  final int totalCredits;
  final int totalDebits;
  final int netChange;
  final int currentBalance;

  TransactionSummary({
    required this.totalCredits,
    required this.totalDebits,
    required this.netChange,
    required this.currentBalance,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    }

    return TransactionSummary(
      // For regular users, these come from /user/transactions summary.
      // For creators, these fields may be missing entirely – we default to 0.
      totalCredits: _toInt(json['totalCredits']),
      totalDebits: _toInt(json['totalDebits']),
      // netChange is only defined for users; for creators we can fall back to totalEarned if present.
      netChange: _toInt(json['netChange'] ?? json['totalEarned']),
      // currentBalance only exists for users; creators don't have a wallet balance here.
      currentBalance: _toInt(json['currentBalance']),
    );
  }
}

class TransactionResponse {
  final List<TransactionModel> transactions;
  final TransactionSummary? summary;
  final Map<String, dynamic>? pagination;

  TransactionResponse({
    required this.transactions,
    this.summary,
    this.pagination,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions: (json['transactions'] as List)
          .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] != null
          ? TransactionSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      pagination: json['pagination'] as Map<String, dynamic>?,
    );
  }
}
