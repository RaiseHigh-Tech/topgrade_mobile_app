class VerifyOtpResponseModel {
  final bool success;
  final String message;

  VerifyOtpResponseModel({
    required this.success,
    required this.message,
  });

  /// Factory method to create VerifyOtpResponseModel from JSON
  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  /// Check if this is a successful OTP verification response
  bool get isOtpVerificationSuccess => success;
}