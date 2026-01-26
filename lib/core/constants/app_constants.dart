class AppConstants {
  static const String appName = 'eazy talks';
  
  // Backend API Base URL
  // For USB debugging on physical device, use your desktop's local IP address
  // Current detected IP: 192.168.1.11
  // To find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
  // Look for "IPv4 Address" under your active network adapter
  static const String baseUrl = 'http://192.168.1.11:3000/api/v1';
  
  // Alternative configurations:
  // For Android emulator: 'http://10.0.2.2:3000/api/v1'
  // For iOS simulator: 'http://localhost:3000/api/v1'
  // For ADB WiFi: 'http://YOUR_DESKTOP_IP:3000/api/v1'
  
  // SharedPreferences keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserCoins = 'user_coins';
  
  // Agora Configuration
  // TODO: Replace with your Agora App ID from Agora Console
  static const String agoraAppId = 'e356cca3a60448f1b3dd91baa93dfa40';
}
