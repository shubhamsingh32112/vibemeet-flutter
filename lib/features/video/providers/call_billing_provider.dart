import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/availability_provider.dart';

// ── State ──────────────────────────────────────────────────────────────────

class CallBillingState {
  final bool isActive;
  final String? callId;

  // User-facing
  final int userCoins;
  final int elapsedSeconds;
  final int remainingSeconds;
  final double pricePerSecond;

  // Creator-facing
  final double creatorEarnings;

  // Force-end
  final bool forceEnded;
  final String? forceEndReason;

  // Settlement
  final bool settled;
  final int? finalCoins;
  final int? totalDeducted;
  final int? totalEarned;
  final int? durationSeconds;

  const CallBillingState({
    this.isActive = false,
    this.callId,
    this.userCoins = 0,
    this.elapsedSeconds = 0,
    this.remainingSeconds = 0,
    this.pricePerSecond = 0,
    this.creatorEarnings = 0,
    this.forceEnded = false,
    this.forceEndReason,
    this.settled = false,
    this.finalCoins,
    this.totalDeducted,
    this.totalEarned,
    this.durationSeconds,
  });

  CallBillingState copyWith({
    bool? isActive,
    String? callId,
    int? userCoins,
    int? elapsedSeconds,
    int? remainingSeconds,
    double? pricePerSecond,
    double? creatorEarnings,
    bool? forceEnded,
    String? forceEndReason,
    bool? settled,
    int? finalCoins,
    int? totalDeducted,
    int? totalEarned,
    int? durationSeconds,
  }) {
    return CallBillingState(
      isActive: isActive ?? this.isActive,
      callId: callId ?? this.callId,
      userCoins: userCoins ?? this.userCoins,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      pricePerSecond: pricePerSecond ?? this.pricePerSecond,
      creatorEarnings: creatorEarnings ?? this.creatorEarnings,
      forceEnded: forceEnded ?? this.forceEnded,
      forceEndReason: forceEndReason ?? this.forceEndReason,
      settled: settled ?? this.settled,
      finalCoins: finalCoins ?? this.finalCoins,
      totalDeducted: totalDeducted ?? this.totalDeducted,
      totalEarned: totalEarned ?? this.totalEarned,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class CallBillingNotifier extends StateNotifier<CallBillingState> {
  final Ref _ref;

  CallBillingNotifier(this._ref) : super(const CallBillingState()) {
    _wireSocketCallbacks();
  }

  void _wireSocketCallbacks() {
    final socketService = _ref.read(socketServiceProvider);

    socketService.onBillingStarted = (data) {
      debugPrint('💰 [BILLING] Started: $data');
      state = CallBillingState(
        isActive: true,
        callId: data['callId'] as String?,
        userCoins: (data['coins'] as num?)?.toInt() ?? 0,
        pricePerSecond: (data['pricePerSecond'] as num?)?.toDouble() ?? 0,
        remainingSeconds: (data['maxSeconds'] as num?)?.toInt() ?? 0,
        creatorEarnings: (data['earnings'] as num?)?.toDouble() ?? 0,
      );
    };

    socketService.onBillingUpdate = (data) {
      if (!state.isActive) return;
      state = state.copyWith(
        userCoins: (data['coins'] as num?)?.toInt() ?? state.userCoins,
        elapsedSeconds:
            (data['elapsedSeconds'] as num?)?.toInt() ?? state.elapsedSeconds,
        remainingSeconds:
            (data['remainingSeconds'] as num?)?.toInt() ?? state.remainingSeconds,
        creatorEarnings:
            (data['earnings'] as num?)?.toDouble() ?? state.creatorEarnings,
      );
    };

    socketService.onBillingSettled = (data) {
      debugPrint('💰 [BILLING] Settled: $data');
      state = state.copyWith(
        isActive: false,
        settled: true,
        finalCoins: (data['finalCoins'] as num?)?.toInt(),
        totalDeducted: (data['totalDeducted'] as num?)?.toInt(),
        totalEarned: (data['totalEarned'] as num?)?.toInt(),
        durationSeconds: (data['durationSeconds'] as num?)?.toInt(),
      );
    };

    socketService.onCallForceEnd = (data) {
      debugPrint('🚨 [BILLING] Force end: $data');
      state = state.copyWith(
        forceEnded: true,
        forceEndReason: data['reason'] as String?,
      );
    };
  }

  /// Reset billing state (call ended, user dismissed dialogs).
  void reset() {
    state = const CallBillingState();
  }

  @override
  void dispose() {
    // Clear callbacks to avoid memory leaks
    try {
      final socketService = _ref.read(socketServiceProvider);
      socketService.onBillingStarted = null;
      socketService.onBillingUpdate = null;
      socketService.onBillingSettled = null;
      socketService.onCallForceEnd = null;
    } catch (_) {}
    super.dispose();
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final callBillingProvider =
    StateNotifierProvider<CallBillingNotifier, CallBillingState>((ref) {
  return CallBillingNotifier(ref);
});
