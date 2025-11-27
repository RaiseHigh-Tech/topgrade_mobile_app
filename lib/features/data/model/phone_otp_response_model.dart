class PhoneOtpResponseModel {
  final bool success;
  final String message;
  final String? verificationId;

  PhoneOtpResponseModel({
    required this.success,
    required this.message,
    this.verificationId,
  });

  factory PhoneOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return PhoneOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      verificationId: json['verificationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'verificationId': verificationId,
    };
  }

  bool get isOtpSentSuccess => success;
}
