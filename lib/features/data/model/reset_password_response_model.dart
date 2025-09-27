class ResetPasswordResponseModel {
  final bool success;
  final String message;
  final String? otp;

  ResetPasswordResponseModel({
    required this.success,
    required this.message,
    this.otp,
  });

  /// Factory method to create ResetPasswordResponseModel from JSON
  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      otp: json['otp'],
    );
  }

  /// Check if response contains OTP
  bool get hasOtp => otp != null;

  /// Check if this is a successful OTP request response (Step 1)
  bool get isOtpRequestSuccess => success && !hasOtp;

  /// Check if this is a successful password reset response (Step 3)
  bool get isPasswordResetSuccess => success;
}