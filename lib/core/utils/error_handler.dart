class ErrorHandler {
  static String getHumanReadableError(String error) {
    // Convert Firebase/API errors to human-readable messages
    
    // Check if error already contains the desired message
    if (error.contains('Network error, no connection please try again.')) {
      return 'Network error, no connection please try again.';
    }
    
    // Network errors
    if (error.contains('network') || 
        error.contains('Network') ||
        error.contains('connection') ||
        error.contains('Connection') ||
        error.contains('Failed host lookup') ||
        error.contains('SocketException') ||
        error.contains('no route to host') ||
        error.contains('No route to host') ||
        error.contains('errno: 113')) {
      return 'Network error, no connection please try again.';
    }
    
    // Google Auth specific errors
    if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email using a different sign-in method.';
    }
    if (error.contains('invalid-credential')) {
      return 'The sign-in credential is invalid or expired. Please try again.';
    }
    if (error.contains('operation-not-allowed')) {
      return 'Google sign-in is not enabled. Please contact support.';
    }
    if (error.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    if (error.contains('sign_in_canceled') || error.contains('SignInCanceledException')) {
      return 'Sign-in was canceled. Please try again.';
    }
    if (error.contains('sign_in_failed') || error.contains('SignInException')) {
      return 'Google sign-in failed. Please try again.';
    }
    if (error.contains('platform_exception') && error.contains('google')) {
      return 'Google sign-in error. Please ensure Google Play Services is up to date.';
    }
    
    // Phone Auth errors
    if (error.contains('invalid-verification-code')) {
      return 'Invalid verification code. Please try again.';
    }
    if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (error.contains('invalid-phone-number')) {
      return 'Invalid phone number. Please check and try again.';
    }
    
    // General Auth errors
    if (error.contains('user-not-found')) {
      return 'User not found. Please sign up first.';
    }
    if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please sign in instead.';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (error.contains('expired') || error.contains('token-expired')) {
      return 'Session expired. Please sign in again.';
    }
    if (error.contains('unauthorized') || error.contains('Unauthorized')) {
      return 'Unauthorized. Please sign in again.';
    }
    
    // Backend/API errors
    if (error.contains('DioException') || 
        error.contains('connection error') ||
        error.contains('Failed host lookup') ||
        error.contains('SocketException') ||
        error.contains('connection refused') ||
        error.contains('Cannot reach server')) {
      return 'Network error, no connection please try again.';
    }
    if (error.contains('timeout') || error.contains('Timeout')) {
      return 'Network error, no connection please try again.';
    }
    if (error.contains('500') || error.contains('Internal Server Error')) {
      return 'Server error. Please try again later.';
    }
    if (error.contains('404') || error.contains('Not Found')) {
      return 'Service not found. Please contact support.';
    }
    if (error.contains('Failed to sync user') || error.contains('Failed to sync')) {
      return 'Failed to sync with server. Please check your connection and try again.';
    }
    
    // Check for specific error patterns in the string
    final lowerError = error.toLowerCase();
    if (lowerError.contains('no address associated') || 
        lowerError.contains('hostname') ||
        lowerError.contains('your_desktop_ip') ||
        lowerError.contains('no route to host')) {
      return 'Network error, no connection please try again.';
    }
    
    // Connection refused usually means backend is not running
    if (lowerError.contains('connection refused') || 
        lowerError.contains('errno: 111') ||
        lowerError.contains('errno: 61') ||
        lowerError.contains('errno: 113')) {
      return 'Network error, no connection please try again.';
    }
    
    // Default - show original error for debugging (in development)
    // In production, show generic message
    // For now, show a more helpful message
    if (error.length > 100) {
      // If error is very long, it's probably a stack trace - show generic message
      return 'Something went wrong. Please check the console for details and try again.';
    }
    
    // Try to extract meaningful error message
    if (error.contains(':')) {
      final parts = error.split(':');
      if (parts.length > 1) {
        final lastPart = parts.last.trim();
        if (lastPart.length < 100 && lastPart.isNotEmpty) {
          return lastPart;
        }
      }
    }
    
    return 'Something went wrong: ${error.length > 50 ? "${error.substring(0, 50)}..." : error}';
  }
}
