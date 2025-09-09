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

  /// Convert PhoneOtpResponseModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'success': success, 'message': message};

    if (userExists != null) data['user_exists'] = userExists;

    return data;
  }

  /// Check if this is a successful OTP request response
  bool get isOtpRequestSuccess => success;

  @override
  String toString() {
    return 'PhoneOtpResponseModel(success: $success, message: $message, userExists: $userExists)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoneOtpResponseModel &&
        other.success == success &&
        other.message == message &&
        other.userExists == userExists;
  }

  @override
  int get hashCode {
    return success.hashCode ^ message.hashCode ^ userExists.hashCode;
  }
}
