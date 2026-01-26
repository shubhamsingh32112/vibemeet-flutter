import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

/// Socket.IO service for real-time call notifications
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  /// Get socket instance (creates if not exists)
  IO.Socket? get socket => _socket;

  /// Check if socket is connected
  bool get isConnected => _isConnected && _socket?.connected == true;

  /// Initialize and connect socket
  Future<void> connect() async {
    if (_socket?.connected == true) {
      debugPrint('🔌 [SOCKET] Already connected');
      return;
    }

    try {
      // Get Firebase auth token
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint('❌ [SOCKET] No Firebase user, cannot connect');
        return;
      }

      debugPrint('🔌 [SOCKET] Connecting to server...');
      final token = await firebaseUser.getIdToken();
      
      // Extract base URL (remove /api/v1)
      final baseUrl = AppConstants.baseUrl.replaceAll('/api/v1', '');
      debugPrint('   🌐 Server URL: $baseUrl');
      debugPrint('   🔑 Token: ${token != null ? token.substring(0, 20) : "null"}...');

      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      // Connection event handlers
      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('✅ [SOCKET] Connected: ${_socket!.id}');
        debugPrint('   👤 User: ${firebaseUser.uid}');
        
        // GUARD 3: Socket reconnection ≠ call reconnection
        // On reconnect, we do NOT re-emit incoming_call or auto-join Agora
        // Call state is managed via HTTP endpoints, sockets are just notifications
        debugPrint('   🔄 Reconnected - call state should be checked via HTTP if needed');
      });

      _socket!.onDisconnect((reason) {
        _isConnected = false;
        debugPrint('❌ [SOCKET] Disconnected: $reason');
        debugPrint('   💡 Note: Active calls continue via Agora, socket is just for notifications');
      });

      _socket!.onReconnect((attemptNumber) {
        _isConnected = true;
        debugPrint('🔄 [SOCKET] Reconnected after $attemptNumber attempt(s)');
        debugPrint('   ⚠️  GUARD: Do NOT re-emit incoming_call or auto-join Agora');
        debugPrint('   ✅ Use HTTP GET /calls/active to check call state if needed');
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        debugPrint('❌ [SOCKET] Connection error: $error');
      });

      _socket!.onError((error) {
        debugPrint('❌ [SOCKET] Error: $error');
      });

      // Note: Token refresh is handled automatically by Socket.IO
      // Firebase tokens are long-lived, so manual refresh is not critical

    } catch (e, stackTrace) {
      debugPrint('❌ [SOCKET] Connection failed: $e');
      debugPrint('   Stack: $stackTrace');
      _isConnected = false;
    }
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 [SOCKET] Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      debugPrint('✅ [SOCKET] Disconnected');
    }
  }

  /// Listen to incoming call event (for creators)
  /// ⚠️ IMPORTANT: Register this listener IMMEDIATELY after socket connects
  /// If registered after replay events are emitted, you'll miss them
  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to incoming_call');
      debugPrint('   💡 Make sure socket connects before registering listeners');
      return;
    }

    _socket!.on('incoming_call', (data) {
      debugPrint('📞 [SOCKET] Incoming call received');
      debugPrint('   Data: $data');
      callback(data as Map<String, dynamic>);
    });
    debugPrint('✅ [SOCKET] Listener registered for incoming_call');
  }

  /// Listen to call accepted event (for callers)
  void onCallAccepted(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to call_accepted');
      return;
    }

    _socket!.on('call_accepted', (data) {
      debugPrint('✅ [SOCKET] Call accepted received');
      debugPrint('   Data: $data');
      callback(data as Map<String, dynamic>);
    });
  }

  /// Listen to call rejected event (for callers)
  void onCallRejected(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to call_rejected');
      return;
    }

    _socket!.on('call_rejected', (data) {
      debugPrint('❌ [SOCKET] Call rejected received');
      debugPrint('   Data: $data');
      callback(data as Map<String, dynamic>);
    });
  }

  /// Listen to call ended event (for both parties)
  void onCallEnded(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to call_ended');
      return;
    }

    _socket!.on('call_ended', (data) {
      debugPrint('🔚 [SOCKET] Call ended received');
      debugPrint('   Data: $data');
      callback(data as Map<String, dynamic>);
    });
  }

  /// Remove all listeners for a specific event
  void off(String event) {
    _socket?.off(event);
    debugPrint('🔇 [SOCKET] Removed listeners for: $event');
  }

  /// Remove all listeners
  void removeAllListeners() {
    _socket?.clearListeners();
    debugPrint('🔇 [SOCKET] Removed all listeners');
  }
}
