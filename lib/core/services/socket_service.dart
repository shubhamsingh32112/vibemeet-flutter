import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';

/// Singleton Socket.IO service for real-time creator availability
/// and per-second call billing.
///
/// Lifecycle:
///   1. [connect] with a Firebase ID token (auth handshake)
///   2. [requestAvailability] with a list of creator Firebase UIDs
///   3. Listen via callbacks for availability + billing events
///   4. [disconnect] when no longer needed
///
/// The service automatically re-sends the last availability request
/// on reconnect so the UI stays fresh without manual intervention.
class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;
  List<String> _lastRequestedIds = [];

  // ── Availability callbacks ──────────────────────────────────────────────
  void Function(Map<String, String>)? onAvailabilityBatch;
  void Function(String creatorId, String status)? onCreatorStatus;

  // ── Billing callbacks ──────────────────────────────────────────────────
  void Function(Map<String, dynamic>)? onBillingStarted;
  void Function(Map<String, dynamic>)? onBillingUpdate;
  void Function(Map<String, dynamic>)? onBillingSettled;
  void Function(Map<String, dynamic>)? onCallForceEnd;
  void Function(Map<String, dynamic>)? onBillingError;

  // ── Creator data sync callback ──────────────────────────────────────────
  /// Fired when the backend emits `creator:data_updated` after:
  /// - Billing settlement (call ended → earnings changed)
  /// - Task reward claim (coins changed)
  void Function(Map<String, dynamic>)? onCreatorDataUpdated;

  bool get isConnected => _isConnected;

  // ── Connect ─────────────────────────────────────────────────────────────
  void connect(String firebaseToken) {
    if (_socket != null) {
      debugPrint('🔌 [SOCKET] Already initialised, skipping connect');
      return;
    }

    debugPrint('🔌 [SOCKET] Connecting to ${AppConstants.socketUrl}...');

    _socket = io.io(
      AppConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': firebaseToken})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ [SOCKET] Connected');
      _isConnected = true;

      // Re-request availability on (re)connect
      if (_lastRequestedIds.isNotEmpty) {
        debugPrint(
          '📡 [SOCKET] Auto-requesting availability for ${_lastRequestedIds.length} creator(s)',
        );
        _socket!.emit('availability:get', {'creatorIds': _lastRequestedIds});
      }
    });

    _socket!.on('availability:batch', (data) {
      debugPrint('📡 [SOCKET] Received availability:batch');
      if (data is Map) {
        final map = Map<String, String>.from(
          data.map((key, value) => MapEntry(key.toString(), value.toString())),
        );
        onAvailabilityBatch?.call(map);
      }
    });

    _socket!.on('creator:status', (data) {
      debugPrint('📡 [SOCKET] Received creator:status: $data');
      if (data is Map) {
        final creatorId = data['creatorId']?.toString();
        final status = data['status']?.toString();
        if (creatorId != null && status != null) {
          onCreatorStatus?.call(creatorId, status);
        }
      }
    });

    // ── Billing events ──────────────────────────────────────────────────
    _socket!.on('billing:started', (data) {
      debugPrint('💰 [SOCKET] billing:started: $data');
      if (data is Map) {
        onBillingStarted?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('billing:update', (data) {
      if (data is Map) {
        onBillingUpdate?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('billing:settled', (data) {
      debugPrint('💰 [SOCKET] billing:settled: $data');
      if (data is Map) {
        onBillingSettled?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('call:force-end', (data) {
      debugPrint('🚨 [SOCKET] call:force-end: $data');
      if (data is Map) {
        onCallForceEnd?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('billing:error', (data) {
      debugPrint('❌ [SOCKET] billing:error: $data');
      if (data is Map) {
        onBillingError?.call(Map<String, dynamic>.from(data));
      }
    });

    // ── Creator data sync event ──────────────────────────────────────────
    _socket!.on('creator:data_updated', (data) {
      debugPrint('📊 [SOCKET] creator:data_updated: $data');
      if (data is Map) {
        onCreatorDataUpdated?.call(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 [SOCKET] Disconnected');
      _isConnected = false;
    });

    _socket!.onReconnect((_) {
      debugPrint('🔌 [SOCKET] Reconnected');
      _isConnected = true;

      // Re-hydrate availability after reconnect
      if (_lastRequestedIds.isNotEmpty) {
        _socket!.emit('availability:get', {'creatorIds': _lastRequestedIds});
      }
    });

    _socket!.onError((error) {
      debugPrint('❌ [SOCKET] Error: $error');
    });

    _socket!.connect();
  }

  // ── Request Availability ────────────────────────────────────────────────
  /// Emit [availability:get] with the given creator Firebase UIDs.
  /// If the socket is not yet connected the IDs are queued and will be
  /// sent automatically when the connection is established.
  void requestAvailability(List<String> creatorIds) {
    if (creatorIds.isEmpty) return;

    _lastRequestedIds = creatorIds;

    if (!_isConnected || _socket == null) {
      debugPrint(
        '⏳ [SOCKET] Not connected yet — availability request queued (${creatorIds.length} IDs)',
      );
      return;
    }

    debugPrint(
      '📡 [SOCKET] Emitting availability:get for ${creatorIds.length} creator(s)',
    );
    _socket!.emit('availability:get', {'creatorIds': creatorIds});
  }

  // ── Billing Emitters ────────────────────────────────────────────────────

  /// Notify the backend that a call has started (triggers billing loop).
  void emitCallStarted({
    required String callId,
    required String creatorFirebaseUid,
    required String creatorMongoId,
  }) {
    if (_socket == null || !_isConnected) {
      debugPrint('⚠️ [SOCKET] Cannot emit call:started — not connected');
      return;
    }
    debugPrint('💰 [SOCKET] Emitting call:started for $callId');
    _socket!.emit('call:started', {
      'callId': callId,
      'creatorFirebaseUid': creatorFirebaseUid,
      'creatorMongoId': creatorMongoId,
    });
  }

  /// Notify the backend that a call has ended (triggers settlement).
  void emitCallEnded({required String callId}) {
    if (_socket == null || !_isConnected) {
      debugPrint('⚠️ [SOCKET] Cannot emit call:ended — not connected');
      return;
    }
    debugPrint('💰 [SOCKET] Emitting call:ended for $callId');
    _socket!.emit('call:ended', {'callId': callId});
  }

  // ── Disconnect ──────────────────────────────────────────────────────────
  void disconnect() {
    debugPrint('🔌 [SOCKET] Disconnecting...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _lastRequestedIds = [];
  }
}
