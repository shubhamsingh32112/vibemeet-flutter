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
  
  // Stream Chat Configuration
  // TODO: Get this from your Stream Dashboard (should match STREAM_API_KEY in backend .env)
  // This is the public API key (safe to expose in client)
  static const String streamApiKey = 'd536t7g4q75v';
}

