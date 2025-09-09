/// API Endpoints and URLs
/// Authentication API endpoints extracted from AUTH_API_DOCUMENTATION.md

class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://your-domain.com/';

  // Authentication Endpoints
  static const String signup = 'auth/signup';
  static const String signin = 'auth/signin';
  static const String requestPhoneOtp = 'auth/request-phone-otp';
  static const String phoneSignin = 'auth/phone-signin';
  static const String requestOtp = 'auth/request-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String refreshToken = 'auth/refresh';

  // Complete URLs
  static const String signupUrl = '${baseUrl}signup';
  static const String signinUrl = '${baseUrl}signin';
  static const String requestPhoneOtpUrl = '${baseUrl}request-phone-otp';
  static const String phoneSigninUrl = '${baseUrl}phone-signin';
  static const String requestOtpUrl = '${baseUrl}request-otp';
  static const String resetPasswordUrl = '${baseUrl}reset-password';
  static const String refreshTokenUrl = '${baseUrl}refresh';
}
