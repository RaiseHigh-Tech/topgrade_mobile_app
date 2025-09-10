/// Phone Signin Response Model
/// Model for handling phone signin API responses

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

  /// Convert PhoneSigninResponseModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'success': success,
      'message': message,
    };
    
    if (accessToken != null) data['access_token'] = accessToken;
    if (refreshToken != null) data['refresh_token'] = refreshToken;
    if (hasAreaOfIntrest != null) data['has_area_of_intrest'] = hasAreaOfIntrest;
    
    return data;
  }

  /// Check if response contains authentication tokens
  bool get hasTokens => accessToken != null && refreshToken != null;

  /// Check if this is a successful phone signin response
  bool get isPhoneSigninSuccess => success && hasTokens;

  @override
  String toString() {
    return 'PhoneSigninResponseModel(success: $success, message: $message, hasTokens: $hasTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoneSigninResponseModel &&
        other.success == success &&
        other.message == message &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.hasAreaOfIntrest == hasAreaOfIntrest;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        hasAreaOfIntrest.hashCode;
  }
}