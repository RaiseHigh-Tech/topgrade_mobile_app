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

  /// Convert ResetPasswordResponseModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'success': success,
      'message': message,
    };
    
    if (otp != null) data['otp'] = otp;
    
    return data;
  }

  /// Check if response contains OTP
  bool get hasOtp => otp != null;

  /// Check if this is a successful OTP request response
  bool get isOtpRequestSuccess => success && hasOtp;

  /// Check if this is a successful password reset response
  bool get isPasswordResetSuccess => success && !hasOtp;

  @override
  String toString() {
    return 'ResetPasswordResponseModel(success: $success, message: $message, hasOtp: $hasOtp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResetPasswordResponseModel &&
        other.success == success &&
        other.message == message &&
        other.otp == otp;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        otp.hashCode;
  }
}