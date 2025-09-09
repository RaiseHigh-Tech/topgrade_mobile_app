/// Verify OTP Response Model
/// Model for handling OTP verification API responses

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

  /// Convert VerifyOtpResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }

  /// Check if this is a successful OTP verification response
  bool get isOtpVerificationSuccess => success;

  @override
  String toString() {
    return 'VerifyOtpResponseModel(success: $success, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerifyOtpResponseModel &&
        other.success == success &&
        other.message == message;
  }

  @override
  int get hashCode {
    return success.hashCode ^ message.hashCode;
  }
}