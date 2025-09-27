class PhoneSigninResponseModel {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final bool? hasAreaOfIntrest;

  PhoneSigninResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.hasAreaOfIntrest,
  });

  /// Factory method to create PhoneSigninResponseModel from JSON
  factory PhoneSigninResponseModel.fromJson(Map<String, dynamic> json) {
    return PhoneSigninResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      hasAreaOfIntrest: json['has_area_of_intrest'],
    );
  }

  /// Check if response contains authentication tokens
  bool get hasTokens => accessToken != null && refreshToken != null;

  /// Check if this is a successful phone signin response
  bool get isPhoneSigninSuccess => success && hasTokens;
}
