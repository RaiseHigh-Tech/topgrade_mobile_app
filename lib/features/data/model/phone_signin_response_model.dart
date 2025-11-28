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

  factory PhoneSigninResponseModel.fromJson(Map<String, dynamic> json) {
    return PhoneSigninResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      // Support both snake_case (backend) and camelCase (fallback)
      accessToken: json['access_token'] ?? json['accessToken'],
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      hasAreaOfIntrest: json['has_area_of_intrest'] ?? json['hasAreaOfIntrest'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'has_area_of_intrest': hasAreaOfIntrest,
    };
  }

  bool get isAuthSuccess => success;
}
