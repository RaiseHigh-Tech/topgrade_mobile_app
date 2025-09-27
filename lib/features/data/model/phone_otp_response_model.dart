class PhoneOtpResponseModel {
  final bool success;
  final String message;
  final bool? userExists;

  PhoneOtpResponseModel({
    required this.success,
    required this.message,
    this.userExists,
  });

  /// Factory method to create PhoneOtpResponseModel from JSON
  factory PhoneOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return PhoneOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userExists: json['user_exists'],
    );
  }

  /// Check if this is a successful OTP request response
  bool get isOtpRequestSuccess => success;
}
