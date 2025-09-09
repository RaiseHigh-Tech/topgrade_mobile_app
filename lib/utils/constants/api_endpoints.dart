class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://9a6fcab3fdbf.ngrok-free.app/';

  // Authentication Endpoints
  static const String signup = 'auth/signup';
  static const String signin = 'auth/signin';
  static const String requestPhoneOtp = 'auth/request-phone-otp';
  static const String phoneSignin = 'auth/phone-signin';
  static const String requestOtp = 'auth/request-otp';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String refreshToken = 'auth/refresh';

  // Complete URLs
  static const String signupUrl = '${baseUrl}auth/signup';
  static const String signinUrl = '${baseUrl}auth/signin';
  static const String requestPhoneOtpUrl = '${baseUrl}auth/request-phone-otp';
  static const String phoneSigninUrl = '${baseUrl}auth/phone-signin';
  static const String requestOtpUrl = '${baseUrl}auth/request-otp';
  static const String verifyOtpUrl = '${baseUrl}auth/verify-otp';
  static const String resetPasswordUrl = '${baseUrl}auth/reset-password';
  static const String refreshTokenUrl = '${baseUrl}auth/refresh';
}
