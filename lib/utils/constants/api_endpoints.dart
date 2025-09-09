class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://9a6fcab3fdbf.ngrok-free.app/';

  // Complete URLs
  static const String signupUrl = '${baseUrl}auth/signup';
  static const String signinUrl = '${baseUrl}auth/signin';
  static const String requestPhoneOtpUrl = '${baseUrl}auth/request-phone-otp';
  static const String phoneSigninUrl = '${baseUrl}auth/phone-signin';
  static const String requestOtpUrl = '${baseUrl}auth/request-otp';
  static const String resetPasswordUrl = '${baseUrl}auth/reset-password';
  static const String refreshTokenUrl = '${baseUrl}auth/refresh';
}
