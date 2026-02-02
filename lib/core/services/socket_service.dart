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
  
  // Phase R5: Internal listener registry to prevent clobbering
  final Map<String, List<Function(Map<String, dynamic>)>> _listeners = {};

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
  /// Phase R5: Uses internal registry - multiple listeners supported
  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to incoming_call');
      debugPrint('   💡 Make sure socket connects before registering listeners');
      return;
    }

    // Phase R5: Add to registry instead of replacing
    _listeners.putIfAbsent('incoming_call', () => []).add(callback);
    
    // Only register socket listener once per event
    if (_listeners['incoming_call']!.length == 1) {
      _socket!.on('incoming_call', (data) {
        debugPrint('📞 [SOCKET] Incoming call received');
        debugPrint('   Data: $data');
        final callbacks = _listeners['incoming_call'] ?? [];
        for (final cb in callbacks) {
          cb(data as Map<String, dynamic>);
        }
      });
    }
    debugPrint('✅ [SOCKET] Listener registered for incoming_call (total: ${_listeners['incoming_call']?.length ?? 0})');
  }

  /// Listen to call accepted event (for callers)
  /// Phase R5: Uses internal registry - multiple listeners supported
  void onCallAccepted(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to call_accepted');
      return;
    }

    // Phase R5: Add to registry instead of replacing
    _listeners.putIfAbsent('call_accepted', () => []).add(callback);
    
    // Only register socket listener once per event
    if (_listeners['call_accepted']!.length == 1) {
      _socket!.on('call_accepted', (data) {
        debugPrint('✅ [SOCKET] Call accepted received');
        debugPrint('   Data: $data');
        final callbacks = _listeners['call_accepted'] ?? [];
        for (final cb in callbacks) {
          cb(data as Map<String, dynamic>);
        }
      });
    }
    debugPrint('✅ [SOCKET] Listener registered for call_accepted (total: ${_listeners['call_accepted']?.length ?? 0})');
  }

  /// Listen to call rejected event (for callers)
  /// Phase R5: Uses internal registry - multiple listeners supported
  void onCallRejected(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to call_rejected');
      return;
    }

    // Phase R5: Add to registry instead of replacing (no off() call)
    _listeners.putIfAbsent('call_rejected', () => []).add(callback);
    
    // Only register socket listener once per event
    if (_listeners['call_rejected']!.length == 1) {
      _socket!.on('call_rejected', (data) {
        debugPrint('❌ [SOCKET] Call rejected received');
        debugPrint('   Data: $data');
        final callbacks = _listeners['call_rejected'] ?? [];
        for (final cb in callbacks) {
          cb(data as Map<String, dynamic>);
        }
      });
    }
    debugPrint('✅ [SOCKET] Listener registered for call_rejected (total: ${_listeners['call_rejected']?.length ?? 0})');
  }

  /// Listen to call ended event (for both parties)
  /// Phase R5: Uses internal registry - multiple listeners supported
  void onCallEnded(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to call_ended');
      return;
    }

    // Phase R5: Add to registry instead of replacing (no off() call)
    _listeners.putIfAbsent('call_ended', () => []).add(callback);
    
    // Only register socket listener once per event
    if (_listeners['call_ended']!.length == 1) {
      _socket!.on('call_ended', (data) {
        debugPrint('🔚 [SOCKET] Call ended received');
        debugPrint('   Data: $data');
        final callbacks = _listeners['call_ended'] ?? [];
        for (final cb in callbacks) {
          cb(data as Map<String, dynamic>);
        }
      });
    }
    debugPrint('✅ [SOCKET] Listener registered for call_ended (total: ${_listeners['call_ended']?.length ?? 0})');
  }

  /// Remove all listeners for a specific event
  /// Phase R5: Removes from internal registry, but keeps socket listener active
  /// Use this only when you're sure no other code needs the event
  void off(String event) {
    _listeners.remove(event);
    _socket?.off(event);
    debugPrint('🔇 [SOCKET] Removed listeners for: $event');
  }
  
  /// Phase R5: Remove a specific callback from an event
  /// This allows fine-grained cleanup without affecting other listeners
  void removeListener(String event, Function(Map<String, dynamic>) callback) {
    final callbacks = _listeners[event];
    if (callbacks != null) {
      callbacks.remove(callback);
      if (callbacks.isEmpty) {
        _listeners.remove(event);
        _socket?.off(event);
        debugPrint('🔇 [SOCKET] Removed last listener for: $event');
      } else {
        debugPrint('🔇 [SOCKET] Removed one listener for: $event (remaining: ${callbacks.length})');
      }
    }
  }

  /// Remove all listeners
  void removeAllListeners() {
    _socket?.clearListeners();
    debugPrint('🔇 [SOCKET] Removed all listeners');
  }

  /// Listen to creator status changed event (for users to refresh homepage)
  /// Phase R5: Uses internal registry - multiple listeners supported
  void onCreatorStatusChanged(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to creator_status_changed');
      return;
    }

    // Phase R5: Add to registry instead of replacing
    _listeners.putIfAbsent('creator_status_changed', () => []).add(callback);
    
    // Only register socket listener once per event
    if (_listeners['creator_status_changed']!.length == 1) {
      _socket!.on('creator_status_changed', (data) {
        debugPrint('🔄 [SOCKET] Creator status changed received');
        debugPrint('   Data: $data');
        final callbacks = _listeners['creator_status_changed'] ?? [];
        for (final cb in callbacks) {
          cb(data as Map<String, dynamic>);
        }
      });
    }
    debugPrint('✅ [SOCKET] Listener registered for creator_status_changed (total: ${_listeners['creator_status_changed']?.length ?? 0})');
  }

  /// Listen to coins updated event (single-source-of-truth for balance)
  /// Phase C2: Uses internal registry - multiple listeners supported
  void onCoinsUpdated(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('⚠️  [SOCKET] Socket not initialized, cannot listen to coins_updated');
      return;
    }

    _listeners.putIfAbsent('coins_updated', () => []).add(callback);

    if (_listeners['coins_updated']!.length == 1) {
      _socket!.on('coins_updated', (data) {
        debugPrint('🪙 [SOCKET] coins_updated received');
        debugPrint('   Data: $data');
        final callbacks = _listeners['coins_updated'] ?? [];
        for (final cb in callbacks) {
          cb(data as Map<String, dynamic>);
        }
      });
    }

    debugPrint('✅ [SOCKET] Listener registered for coins_updated (total: ${_listeners['coins_updated']?.length ?? 0})');
  }
}
