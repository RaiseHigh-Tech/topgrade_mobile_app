class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://a001cb2a9b2e.ngrok-free.app/';

  // Complete URLs
  static const String signupUrl = '${baseUrl}api/auth/signup';
  static const String signinUrl = '${baseUrl}api/auth/signin';
  static const String requestPhoneOtpUrl = '${baseUrl}api/auth/request-phone-otp';
  static const String phoneSigninUrl = '${baseUrl}api/auth/phone-signin';
  static const String requestOtpUrl = '${baseUrl}api/auth/request-otp';
  static const String verifyOtpUrl = '${baseUrl}api/auth/verify-otp';
  static const String resetPasswordUrl = '${baseUrl}api/auth/reset-password';
  static const String refreshTokenUrl = '${baseUrl}api/auth/refresh';
  
  // Interest endpoints
  static const String addAreaOfInterestUrl = '${baseUrl}api/add-area-of-interest';
}
