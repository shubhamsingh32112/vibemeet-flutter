import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/socket_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../agora_logic.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? firebaseUser;
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final int? resendToken;
  final String? phoneNumber;

  AuthState({
    this.firebaseUser,
    this.user,
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.resendToken,
    this.phoneNumber,
  });

  bool get isAuthenticated => firebaseUser != null && user != null;

  AuthState copyWith({
    User? firebaseUser,
    UserModel? user,
    bool? isLoading,
    String? error,
    String? verificationId,
    int? resendToken,
    String? phoneNumber,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  FirebaseAuth? _auth;
  final ApiClient _apiClient = ApiClient();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isInitializing = false;

  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitializing) {
      debugPrint('⏳ [AUTH] Already initializing, skipping...');
      return;
    }
    _isInitializing = true;
    
    debugPrint('🔧 [AUTH] Initializing AuthNotifier...');
    
    try {
      // Check if Firebase is already initialized
      try {
        _auth = FirebaseAuth.instance;
        debugPrint('✅ [AUTH] Firebase Auth instance retrieved');
        _init();
        _isInitializing = false;
        return;
      } catch (e) {
        // Firebase not initialized yet, try to initialize
        debugPrint('⚠️  [AUTH] Firebase not initialized, waiting...');
        debugPrint('   Error: $e');
      }
      
      // Wait for Firebase to be initialized (should be done in main())
      // Give it a moment
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Try again
      try {
        _auth = FirebaseAuth.instance;
        debugPrint('✅ [AUTH] Firebase Auth instance retrieved after wait');
        _init();
      } catch (e) {
        debugPrint('❌ [AUTH] Firebase Auth still not available: $e');
        debugPrint('   💡 Please run: flutterfire configure');
        state = state.copyWith(error: 'Firebase initialization required. Please run: flutterfire configure');
      }
    } finally {
      _isInitializing = false;
      debugPrint('🏁 [AUTH] Initialization complete');
    }
  }

  Future<void> _init() async {
    if (_auth == null) return;
    
    debugPrint('🔐 [AUTH] Setting up auth state listener...');
    _auth!.authStateChanges().listen((user) async {
      if (user != null) {
        debugPrint('👤 [AUTH] Auth state changed: User logged in');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        debugPrint('   📱 Phone: ${user.phoneNumber ?? "N/A"}');
        debugPrint('   🆔 UID: ${user.uid}');
        await _syncUserToBackend(user);
      } else {
        debugPrint('🚪 [AUTH] Auth state changed: User logged out');
        state = AuthState();
      }
    });
  }

  Future<void> _syncUserToBackend(User firebaseUser) async {
    try {
      // Determine auth method for logging context
      final authMethod = firebaseUser.providerData
          .where((p) => p.providerId == 'google.com')
          .isNotEmpty
          ? 'GOOGLE'
          : firebaseUser.providerData
                  .where((p) => p.providerId == 'phone')
                  .isNotEmpty
              ? 'PHONE'
              : 'OTHER';
      
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [AUTH] Starting backend sync');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   🔐 Auth Method: $authMethod');
      debugPrint('   🆔 Firebase UID: ${firebaseUser.uid}');
      debugPrint('   📧 Email: ${firebaseUser.email ?? "N/A"}');
      debugPrint('   📱 Phone: ${firebaseUser.phoneNumber ?? "N/A"}');
      
      state = state.copyWith(isLoading: true, error: null);
      
      debugPrint('🎫 [AUTH] Requesting Firebase ID token...');
      final tokenStartTime = DateTime.now();
      final token = await firebaseUser.getIdToken();
      final tokenDuration = DateTime.now().difference(tokenStartTime);
      
      if (token == null) {
        debugPrint('❌ [AUTH] Failed to get authentication token');
        debugPrint('   ⏱️  Token request duration: ${tokenDuration.inMilliseconds}ms');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get authentication token',
        );
        return;
      }
      debugPrint('✅ [AUTH] Firebase ID token retrieved');
      debugPrint('   ⏱️  Token request duration: ${tokenDuration.inMilliseconds}ms');
      debugPrint('   📏 Token length: ${token.length} characters');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAuthToken, token);
      debugPrint('💾 [AUTH] Token saved to local storage');

      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('📡 [AUTH] Sending login request to backend...');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   🌐 Base URL: ${AppConstants.baseUrl}');
      debugPrint('   🌐 Endpoint: /auth/login');
      debugPrint('   🌐 Full URL: ${AppConstants.baseUrl}/auth/login');
      debugPrint('   🔑 Auth token: Present (${token.length} chars)');
      debugPrint('   💡 Make sure backend is running and accessible');
      final apiStartTime = DateTime.now();
      final response = await _apiClient.post('/auth/login');
      final apiDuration = DateTime.now().difference(apiStartTime);
      debugPrint('📥 [AUTH] Backend response received');
      debugPrint('   ⏱️  API call duration: ${apiDuration.inMilliseconds}ms');
      debugPrint('   🔢 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        
        // Check if this is a creator login (flat structure) or regular user (nested structure)
        UserModel user;
        if (responseData.containsKey('user')) {
          // Regular user login - nested structure
          final userData = responseData['user'] as Map<String, dynamic>;
          user = UserModel.fromJson(userData);
          debugPrint('👤 [AUTH] Regular user login detected');
        } else {
          // Creator login - flat structure with creator details
          // Map creator fields to UserModel
          final creatorData = responseData;
          user = UserModel(
            id: creatorData['id'] as String,
            email: creatorData['email'] as String?,
            phone: creatorData['phone'] as String?,
            gender: creatorData['gender'] as String?,
            username: creatorData['name'] as String?, // Use creator name as username
            avatar: creatorData['photo'] as String?, // Use creator photo as avatar
            categories: creatorData['categories'] != null
                ? List<String>.from(creatorData['categories'] as List)
                : null,
            usernameChangeCount: creatorData['usernameChangeCount'] as int? ?? 0,
            coins: creatorData['coins'] as int? ?? 0,
            role: creatorData['role'] as String? ?? 'creator',
            createdAt: creatorData['createdAt'] != null
                ? DateTime.parse(creatorData['createdAt'] as String)
                : null,
            updatedAt: creatorData['updatedAt'] != null
                ? DateTime.parse(creatorData['updatedAt'] as String)
                : null,
          );
          debugPrint('🎭 [AUTH] Creator login detected');
          debugPrint('   👤 Creator Name: ${creatorData['name']}');
          debugPrint('   💰 Price: ${creatorData['price']}');
        }
        
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('✅ [AUTH] Backend sync successful');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   🆔 User ID: ${user.id}');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        debugPrint('   📱 Phone: ${user.phone ?? "N/A"}');
        debugPrint('   🪙 Coins: ${user.coins}');
        debugPrint('   👤 Role: ${user.role ?? "N/A"}');
        debugPrint('   📅 Created: ${user.createdAt}');
        debugPrint('   🔄 Updated: ${user.updatedAt}');
        
        await prefs.setString(AppConstants.keyUserId, user.id);
        if (user.email != null) {
          await prefs.setString(AppConstants.keyUserEmail, user.email!);
        }
        if (user.phone != null) {
          await prefs.setString(AppConstants.keyUserPhone, user.phone!);
        }
        await prefs.setInt(AppConstants.keyUserCoins, user.coins);
        debugPrint('💾 [AUTH] User data saved to local storage');
        debugPrint('   ✅ User ID saved');
        debugPrint('   ✅ Email saved: ${user.email != null}');
        debugPrint('   ✅ Phone saved: ${user.phone != null}');
        debugPrint('   ✅ Coins saved: ${user.coins}');

        state = state.copyWith(
          firebaseUser: firebaseUser,
          user: user,
          isLoading: false,
        );
        debugPrint('✅ [AUTH] User authenticated and synced successfully');
        debugPrint('   🎉 Ready for app usage');
        
        // Check and request video permissions if needed (once per login)
        try {
          debugPrint('📋 [AUTH] Checking video permissions...');
          final hasPermissions = await AgoraLogic.checkAndRequestPermissionsIfNeeded();
          if (hasPermissions) {
            debugPrint('✅ [AUTH] Video permissions granted');
          } else {
            debugPrint('⚠️  [AUTH] Video permissions not granted - user will be prompted when making a call');
          }
        } catch (e) {
          debugPrint('⚠️  [AUTH] Permission check error (non-critical): $e');
          // Don't fail login if permission check fails
        }
        
        // Connect to Socket.IO for real-time events
        try {
          await SocketService().connect();
          debugPrint('🔌 [AUTH] Socket.IO connected for real-time events');
        } catch (e) {
          debugPrint('⚠️  [AUTH] Failed to connect Socket.IO: $e');
          // Don't fail login if socket connection fails
        }
      } else {
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('❌ [AUTH] Backend sync failed');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   🔢 Status Code: ${response.statusCode}');
        debugPrint('   📦 Response Data: ${response.data}');
        debugPrint('   📋 Response Headers: ${response.headers}');
        debugPrint('   💡 Check backend logs for more details');
        
        String errorMsg = 'Failed to sync user: Server returned status ${response.statusCode}';
        if (response.data != null) {
          try {
            final errorData = response.data as Map<String, dynamic>?;
            if (errorData != null && errorData.containsKey('error')) {
              errorMsg = '${errorData['error']}';
            }
          } catch (_) {
            // Ignore parsing errors
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('❌ [AUTH] Backend sync error');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   Error: $e');
      debugPrint('   Type: ${e.runtimeType}');
      if (e is DioException) {
        debugPrint('   Dio Error Type: ${e.type}');
        debugPrint('   Dio Error Message: ${e.message}');
        if (e.response != null) {
          debugPrint('   Response Status: ${e.response?.statusCode}');
          debugPrint('   Response Data: ${e.response?.data}');
        }
      }
      
      // Create a more descriptive error message
      String errorMessage = e.toString();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError) {
          // Check for specific connection error types
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('no route to host') || 
              errorString.contains('socketexception') ||
              errorString.contains('errno: 113')) {
            errorMessage = 'Network error, no connection please try again.';
          } else {
            errorMessage = 'Network error, no connection please try again.';
          }
        } else if (e.type == DioExceptionType.connectionTimeout || 
                   e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Network error, no connection please try again.';
        } else if (e.response != null) {
          errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage ?? "Unknown error"}';
        } else {
          errorMessage = 'Network error, no connection please try again.';
        }
      } else if (e.toString().toLowerCase().contains('socket') || 
                 e.toString().toLowerCase().contains('connection') ||
                 e.toString().toLowerCase().contains('network')) {
        errorMessage = 'Network error, no connection please try again.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      debugPrint('   💾 Error state updated with message: $errorMessage');
    }
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📱 [PHONE AUTH] Starting phone number authentication');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   📞 Phone number: $phoneNumber');
      debugPrint('   ⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      
      if (_auth == null) {
        debugPrint('❌ [PHONE AUTH] Firebase not initialized');
        debugPrint('   💡 Please ensure Firebase is properly configured');
        state = state.copyWith(error: 'Firebase not initialized');
        return;
      }
      
      debugPrint('✅ [PHONE AUTH] Firebase Auth instance available');
      state = state.copyWith(isLoading: true, error: null);
      debugPrint('🔄 [PHONE AUTH] Requesting phone verification from Firebase...');
      debugPrint('   📡 Calling verifyPhoneNumber()...');
      
      await _auth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('✅ [PHONE AUTH] Auto-verification completed');
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('   🔑 Credential received automatically');
          debugPrint('   🆔 Verification ID: ${credential.verificationId ?? "N/A"}');
          debugPrint('   🔢 SMS Code: ${credential.smsCode ?? "N/A"}');
          debugPrint('   🔄 Signing in with credential...');
          
          if (_auth != null) {
            try {
              final startTime = DateTime.now();
              final userCredential = await _auth!.signInWithCredential(credential);
              final duration = DateTime.now().difference(startTime);
              
              debugPrint('✅ [PHONE AUTH] Sign in successful');
              debugPrint('   ⏱️  Duration: ${duration.inMilliseconds}ms');
              debugPrint('   🆔 UID: ${userCredential.user?.uid}');
              debugPrint('   📱 Phone: ${userCredential.user?.phoneNumber}');
              debugPrint('   ✉️  Email: ${userCredential.user?.email ?? "N/A"}');
              debugPrint('   ✉️  Email verified: ${userCredential.user?.emailVerified ?? false}');
              debugPrint('   📅 Created: ${userCredential.user?.metadata.creationTime}');
              debugPrint('   🔄 Last sign in: ${userCredential.user?.metadata.lastSignInTime}');
              debugPrint('   💡 Backend sync will be handled by auth state listener');
            } catch (e) {
              debugPrint('❌ [PHONE AUTH] Sign in error during auto-verification');
              debugPrint('   Error: $e');
              if (e is FirebaseAuthException) {
                debugPrint('   Code: ${e.code}');
                debugPrint('   Message: ${e.message}');
              }
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('❌ [PHONE AUTH] Verification failed');
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('   Code: ${e.code}');
          debugPrint('   Message: ${e.message ?? "No message"}');
          debugPrint('   Details: ${e.toString()}');
          
          // Common error codes with helpful messages
          switch (e.code) {
            case 'invalid-phone-number':
              debugPrint('   💡 The phone number format is invalid');
              debugPrint('   💡 Expected format: +[country code][number]');
              debugPrint('   💡 Example: +1234567890');
              break;
            case 'too-many-requests':
              debugPrint('   💡 Too many verification attempts');
              debugPrint('   💡 Please wait before requesting a new code');
              break;
            case 'quota-exceeded':
              debugPrint('   💡 SMS quota exceeded');
              debugPrint('   💡 Please try again later');
              break;
            case 'missing-phone-number':
              debugPrint('   💡 Phone number is required');
              break;
            case 'captcha-check-failed':
              debugPrint('   💡 reCAPTCHA verification failed');
              break;
            default:
              debugPrint('   💡 Check Firebase Console for more details');
          }
          
          state = state.copyWith(
            isLoading: false,
            error: e.message ?? 'Verification failed',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('✅ [PHONE AUTH] Verification code sent successfully');
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('   🆔 Verification ID: $verificationId');
          debugPrint('   🔄 Resend token: ${resendToken ?? "Not provided"}');
          debugPrint('   📱 Phone: $phoneNumber');
          debugPrint('   ⏰ Sent at: ${DateTime.now().toIso8601String()}');
          debugPrint('   💡 Code will expire in ~10 minutes');
          debugPrint('   💡 User should receive SMS with 6-digit code');
          
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: phoneNumber,
            error: null,
          );
          debugPrint('💾 [PHONE AUTH] Verification ID stored in state');
          debugPrint('   ✅ Ready for OTP input screen');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('⏱️  [PHONE AUTH] Auto-retrieval timeout');
          debugPrint('───────────────────────────────────────────────────────');
          debugPrint('   🆔 Verification ID: $verificationId');
          debugPrint('   ⏰ Timeout at: ${DateTime.now().toIso8601String()}');
          debugPrint('   💡 Auto-retrieval failed, user must enter code manually');
        },
        timeout: const Duration(seconds: 60),
      );
      
      debugPrint('✅ [PHONE AUTH] verifyPhoneNumber() call completed');
      debugPrint('   ⏳ Waiting for verification response...');
    } catch (e) {
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('❌ [PHONE AUTH] Unexpected error');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   Error: $e');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Stack trace:');
      debugPrint('   ${StackTrace.current}');
      
      if (e is FirebaseAuthException) {
        debugPrint('   Firebase Error Code: ${e.code}');
        debugPrint('   Firebase Error Message: ${e.message}');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔵 [GOOGLE AUTH] Starting Google sign in');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   ⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      
      if (_auth == null) {
        debugPrint('❌ [GOOGLE AUTH] Firebase not initialized');
        debugPrint('   💡 Please ensure Firebase is properly configured');
        state = state.copyWith(error: 'Firebase not initialized');
        return;
      }
      
      debugPrint('✅ [GOOGLE AUTH] Firebase Auth instance available');
      debugPrint('✅ [GOOGLE AUTH] GoogleSignIn instance available');
      state = state.copyWith(isLoading: true, error: null);
      
      // Check if user is already signed in to Google
      debugPrint('🔄 [GOOGLE AUTH] Checking for existing Google sign in...');
      final currentGoogleUser = await _googleSignIn.signInSilently();
      if (currentGoogleUser != null) {
        debugPrint('   ℹ️  Found existing Google sign in');
        debugPrint('   📧 Email: ${currentGoogleUser.email}');
      } else {
        debugPrint('   ℹ️  No existing Google sign in found');
      }
      
      // Trigger the Google Sign In flow
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [GOOGLE AUTH] Requesting Google sign in...');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   📱 Opening Google sign-in dialog...');
      final startTime = DateTime.now();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final dialogDuration = DateTime.now().difference(startTime);
      debugPrint('   ⏱️  Dialog duration: ${dialogDuration.inMilliseconds}ms');
      
      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('⚠️  [GOOGLE AUTH] User canceled Google sign in');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   💡 User closed the sign-in dialog');
        debugPrint('   💡 No authentication performed');
        state = state.copyWith(isLoading: false);
        return;
      }
      
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('✅ [GOOGLE AUTH] Google sign in successful');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   📧 Email: ${googleUser.email}');
      debugPrint('   👤 Display Name: ${googleUser.displayName ?? "N/A"}');
      debugPrint('   🆔 Google ID: ${googleUser.id}');
      debugPrint('   🖼️  Photo URL: ${googleUser.photoUrl ?? "N/A"}');
      debugPrint('   🌐 Server Auth Code: ${googleUser.serverAuthCode != null ? "Present" : "Not provided"}');
      
      // Obtain the auth details from the request
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [GOOGLE AUTH] Getting authentication tokens...');
      debugPrint('───────────────────────────────────────────────────────');
      final authStartTime = DateTime.now();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final authDuration = DateTime.now().difference(authStartTime);
      debugPrint('   ⏱️  Token retrieval duration: ${authDuration.inMilliseconds}ms');
      debugPrint('   🔑 Access Token: ${googleAuth.accessToken != null ? "Present (${googleAuth.accessToken!.length} chars)" : "Not provided"}');
      debugPrint('   🆔 ID Token: ${googleAuth.idToken != null ? "Present (${googleAuth.idToken!.length} chars)" : "Not provided"}');
      
      // Create a new credential
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔑 [GOOGLE AUTH] Creating Firebase credential...');
      debugPrint('───────────────────────────────────────────────────────');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('   ✅ Credential created successfully');
      debugPrint('   🔐 Provider: ${credential.providerId}');
      
      // Sign in to Firebase with the Google credential
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [GOOGLE AUTH] Signing in to Firebase...');
      debugPrint('───────────────────────────────────────────────────────');
      final firebaseStartTime = DateTime.now();
      final userCredential = await _auth!.signInWithCredential(credential);
      final firebaseDuration = DateTime.now().difference(firebaseStartTime);
      
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('✅ [GOOGLE AUTH] Firebase sign in successful');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   ⏱️  Firebase sign in duration: ${firebaseDuration.inMilliseconds}ms');
      debugPrint('   🆔 UID: ${userCredential.user?.uid}');
      debugPrint('   📧 Email: ${userCredential.user?.email ?? "N/A"}');
      debugPrint('   ✉️  Email verified: ${userCredential.user?.emailVerified ?? false}');
      debugPrint('   👤 Display Name: ${userCredential.user?.displayName ?? "N/A"}');
      debugPrint('   🖼️  Photo URL: ${userCredential.user?.photoURL ?? "N/A"}');
      debugPrint('   📱 Phone: ${userCredential.user?.phoneNumber ?? "N/A"}');
      debugPrint('   📅 Created: ${userCredential.user?.metadata.creationTime}');
      debugPrint('   🔄 Last sign in: ${userCredential.user?.metadata.lastSignInTime}');
      
      // Safely access providerData to avoid type cast errors
      try {
        final providers = userCredential.user?.providerData
            .map((p) => p.providerId)
            .join(", ") ?? "N/A";
        debugPrint('   🔗 Providers: $providers');
      } catch (e) {
        debugPrint('   🔗 Providers: Error accessing provider data (non-critical): $e');
      }
      
      if (userCredential.user != null) {
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('✅ [GOOGLE AUTH] Firebase authentication complete');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   📧 User Email: ${userCredential.user?.email}');
        debugPrint('   🆔 Firebase UID: ${userCredential.user?.uid}');
        debugPrint('   ✅ Authentication: Complete');
        debugPrint('   🔄 Backend sync will be handled by auth state listener');
        debugPrint('   💡 Auth state listener will automatically sync user to backend');
        
        // Don't manually call _syncUserToBackend here - the auth state listener
        // will handle it automatically when it detects the user is signed in.
        // This prevents duplicate sync calls and race conditions.
        
        // Clear loading state - backend sync will happen via auth state listener
        state = state.copyWith(
          isLoading: false,
          error: null, // Clear any previous errors
        );
        
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('✅ [GOOGLE AUTH] Sign-in flow complete');
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('   🎉 User signed in successfully');
        debugPrint('   🔄 Backend sync in progress via auth state listener');
      } else {
        debugPrint('⚠️  [GOOGLE AUTH] User credential is null');
        debugPrint('   ❌ Cannot proceed');
        state = state.copyWith(
          isLoading: false,
          error: 'User credential is null',
        );
      }
    } catch (e) {
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('❌ [GOOGLE AUTH] Sign in error');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('   Error: $e');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Full error string: ${e.toString()}');
      
      // Check if user is actually authenticated despite the error
      // This handles cases where Firebase has internal errors but authentication succeeds
      final currentUser = _auth?.currentUser;
      if (currentUser != null) {
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('⚠️  [GOOGLE AUTH] Error occurred but user is authenticated');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   🆔 Firebase UID: ${currentUser.uid}');
        debugPrint('   📧 Email: ${currentUser.email ?? "N/A"}');
        debugPrint('   💡 This is likely a non-critical Firebase internal error');
        debugPrint('   💡 User authentication succeeded, backend sync will continue');
        debugPrint('   💡 Clearing error state to allow normal flow');
        
        // User is authenticated, so clear the error and let auth state listener handle sync
        state = state.copyWith(
          isLoading: false,
          error: null, // Clear error since user is actually authenticated
        );
        return;
      }
      
      String errorMessage = e.toString();
      
      if (e is FirebaseAuthException) {
        debugPrint('   Firebase Error Code: ${e.code}');
        debugPrint('   Firebase Error Message: ${e.message}');
        debugPrint('   Firebase Error Details: ${e.toString()}');
        errorMessage = '${e.code}: ${e.message ?? e.toString()}';
        
        // Common error codes with helpful messages
        switch (e.code) {
          case 'account-exists-with-different-credential':
            debugPrint('   💡 An account already exists with a different credential');
            debugPrint('   💡 User may need to sign in with the original method');
            break;
          case 'invalid-credential':
            debugPrint('   💡 The credential is invalid or expired');
            break;
          case 'operation-not-allowed':
            debugPrint('   💡 Google sign-in is not enabled in Firebase Console');
            debugPrint('   💡 Enable it in Authentication > Sign-in method');
            break;
          case 'user-disabled':
            debugPrint('   💡 This user account has been disabled');
            break;
          case 'user-not-found':
            debugPrint('   💡 No user record found');
            break;
          default:
            debugPrint('   💡 Check Firebase Console for more details');
        }
      } else if (e is DioException) {
        debugPrint('   DioException Type: ${e.type}');
        debugPrint('   DioException Message: ${e.message}');
        if (e.response != null) {
          debugPrint('   Response Status: ${e.response?.statusCode}');
          debugPrint('   Response Data: ${e.response?.data}');
        }
        errorMessage = e.message ?? e.toString();
      } else if (e.toString().contains('sign_in_canceled') || 
                 e.toString().contains('SignInCanceledException')) {
        debugPrint('   💡 User canceled the Google sign-in process');
        // Don't set error for user cancellation
        state = state.copyWith(isLoading: false);
        return;
      } else if (e.toString().contains('PigeonUserDetails') || 
                 e.toString().contains('type \'List<Object?>\' is not a subtype')) {
        // This is a known Firebase internal type cast error that sometimes occurs
        // even when authentication succeeds. Check if user is actually authenticated.
        debugPrint('   💡 Firebase internal type cast error detected');
        debugPrint('   💡 This is a known issue with Firebase SDK');
        debugPrint('   💡 Checking if user is actually authenticated...');
        
        if (currentUser != null) {
          debugPrint('   ✅ User is authenticated despite the error');
          debugPrint('   💡 Ignoring this non-critical error');
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
          return;
        }
      } else {
        debugPrint('   Stack trace:');
        debugPrint('   ${StackTrace.current}');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      debugPrint('   💾 Error state updated');
      debugPrint('   📤 Error will be displayed to user');
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🚪 [AUTH] Starting sign out...');
      
      if (_auth != null) {
        final currentUser = _auth!.currentUser;
        if (currentUser != null) {
          debugPrint('   🆔 Signing out user: ${currentUser.uid}');
          debugPrint('   📧 Email: ${currentUser.email ?? "N/A"}');
        }
        
        await _auth!.signOut();
        debugPrint('✅ [AUTH] Firebase sign out successful');
      }
      
      // Sign out from Google as well
      try {
        await _googleSignIn.signOut();
        debugPrint('✅ [AUTH] Google sign out successful');
      } catch (e) {
        debugPrint('⚠️  [AUTH] Google sign out error (non-critical): $e');
      }
      
      // Disconnect Socket.IO
      try {
        SocketService().disconnect();
        debugPrint('🔌 [AUTH] Socket.IO disconnected');
      } catch (e) {
        debugPrint('⚠️  [AUTH] Socket disconnect error (non-critical): $e');
      }
      
      debugPrint('🗑️  [AUTH] Clearing local storage...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ [AUTH] Local storage cleared');
      
      state = AuthState();
      debugPrint('✅ [AUTH] Sign out completed');
    } catch (e) {
      debugPrint('❌ [AUTH] Sign out error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshUser() async {
    debugPrint('🔄 [AUTH] Refreshing user data...');
    
    if (_auth != null) {
      final user = _auth!.currentUser;
      if (user != null) {
        debugPrint('   🆔 Current user: ${user.uid}');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        await _syncUserToBackend(user);
      } else {
        debugPrint('⚠️  [AUTH] No current user to refresh');
      }
    } else {
      debugPrint('❌ [AUTH] Firebase Auth not initialized');
    }
  }

  Future<void> verifyOtp(String verificationId, String otp) async {
    try {
      debugPrint('🔐 [OTP] Starting OTP verification...');
      debugPrint('   🆔 Verification ID: $verificationId');
      debugPrint('   🔢 OTP: $otp');
      
      if (_auth == null) {
        debugPrint('❌ [OTP] Firebase not initialized');
        state = state.copyWith(error: 'Firebase not initialized');
        return;
      }
      
      state = state.copyWith(isLoading: true, error: null);
      
      // Create credential from verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      debugPrint('🔑 [OTP] Credential created, signing in...');
      
      UserCredential? userCredential;
      try {
        userCredential = await _auth!.signInWithCredential(credential);
      } catch (signInError) {
        // Sometimes Firebase throws an internal error but still signs in
        // Check if user is actually signed in
        final currentUser = _auth!.currentUser;
        if (currentUser != null) {
          debugPrint('⚠️  [OTP] Sign in had error but user is authenticated');
          debugPrint('   🆔 UID: ${currentUser.uid}');
          debugPrint('   📱 Phone: ${currentUser.phoneNumber}');
          debugPrint('   ⚠️  Original error (ignored): $signInError');
          
          // Clear verification data
          state = state.copyWith(
            verificationId: null,
            resendToken: null,
            phoneNumber: null,
            isLoading: false,
          );
          
          // Auth state listener will handle backend sync
          return;
        } else {
          // Re-throw if user is not signed in
          rethrow;
        }
      }
      
      debugPrint('✅ [OTP] Sign in successful');
      debugPrint('   🆔 UID: ${userCredential.user?.uid}');
      debugPrint('   📱 Phone: ${userCredential.user?.phoneNumber}');
      
      if (userCredential.user != null) {
        // Clear verification data
        state = state.copyWith(
          verificationId: null,
          resendToken: null,
          phoneNumber: null,
          isLoading: false,
        );
        
        // Don't call _syncUserToBackend here - let the auth state listener handle it
        // This prevents duplicate calls and race conditions
      }
    } catch (e) {
      // Check if user is actually authenticated despite the error
      final currentUser = _auth?.currentUser;
      if (currentUser != null) {
        debugPrint('⚠️  [OTP] Error occurred but user is authenticated');
        debugPrint('   🆔 UID: ${currentUser.uid}');
        debugPrint('   📱 Phone: ${currentUser.phoneNumber}');
        debugPrint('   ⚠️  Error (non-critical): $e');
        
        // Clear verification data and mark as not loading
        // Auth state listener will handle backend sync
        state = state.copyWith(
          verificationId: null,
          resendToken: null,
          phoneNumber: null,
          isLoading: false,
          error: null, // Don't show error if user is authenticated
        );
        return;
      }
      
      // User is not authenticated, show the error
      debugPrint('❌ [OTP] Verification error');
      if (e is FirebaseAuthException) {
        debugPrint('   Code: ${e.code}');
        debugPrint('   Message: ${e.message}');
        debugPrint('   Details: ${e.toString()}');
        
        String errorMessage = e.message ?? e.toString();
        
        // Common error codes with user-friendly messages
        switch (e.code) {
          case 'invalid-verification-code':
            debugPrint('   💡 Invalid OTP code. Please check and try again.');
            errorMessage = 'Invalid verification code. Please check and try again.';
            break;
          case 'session-expired':
            debugPrint('   💡 Verification session expired. Please request a new code.');
            errorMessage = 'Verification code expired. Please request a new code.';
            // Clear verification state for expired sessions
            state = state.copyWith(
              verificationId: null,
              resendToken: null,
              phoneNumber: null,
              isLoading: false,
              error: errorMessage,
            );
            return;
          case 'invalid-verification-id':
            debugPrint('   💡 Invalid verification ID. Please request a new code.');
            errorMessage = 'Invalid verification session. Please request a new code.';
            // Clear verification state for invalid sessions
            state = state.copyWith(
              verificationId: null,
              resendToken: null,
              phoneNumber: null,
              isLoading: false,
              error: errorMessage,
            );
            return;
          default:
            errorMessage = e.message ?? 'Verification failed. Please try again.';
        }
        
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      } else {
        debugPrint('   Error: $e');
        debugPrint('   Stack trace: ${StackTrace.current}');
        
        state = state.copyWith(
          isLoading: false,
          error: 'Verification failed. Please try again.',
        );
      }
    }
  }

  void clearVerificationState() {
    debugPrint('🗑️  [AUTH] Clearing verification state');
    state = state.copyWith(
      verificationId: null,
      resendToken: null,
      phoneNumber: null,
      error: null,
    );
  }
}
