class SigninResponseModel {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final String? otp;
  final bool? userExists;
  final bool? hasAreaOfIntrest;

  SigninResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.otp,
    this.userExists,
    this.hasAreaOfIntrest,
  });

  /// Factory method to create SigninResponseModel from JSON
  factory SigninResponseModel.fromJson(Map<String, dynamic> json) {
    return SigninResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      otp: json['otp'],
      userExists: json['user_exists'],
      hasAreaOfIntrest: json['has_area_of_intrest'],
    );
  }

  /// Convert SigninResponseModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'success': success,
      'message': message,
    };
    
    if (accessToken != null) data['access_token'] = accessToken;
    if (refreshToken != null) data['refresh_token'] = refreshToken;
    if (otp != null) data['otp'] = otp;
    if (userExists != null) data['user_exists'] = userExists;
    if (hasAreaOfIntrest != null) data['has_area_of_intrest'] = hasAreaOfIntrest;
    
    return data;
  }

  /// Check if response contains authentication tokens
  bool get hasTokens => accessToken != null && refreshToken != null;

  /// Check if response contains OTP
  bool get hasOtp => otp != null;

  /// Check if this is a successful authentication response
  bool get isAuthSuccess => success && hasTokens;

  /// Check if this is a successful OTP response
  bool get isOtpSuccess => success && hasOtp;

  @override
  String toString() {
    return 'SigninResponseModel(success: $success, message: $message, hasTokens: $hasTokens, hasOtp: $hasOtp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SigninResponseModel &&
        other.success == success &&
        other.message == message &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.otp == otp &&
        other.userExists == userExists &&
        other.hasAreaOfIntrest == hasAreaOfIntrest;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        otp.hashCode ^
        userExists.hashCode ^
        hasAreaOfIntrest.hashCode;
  }
}