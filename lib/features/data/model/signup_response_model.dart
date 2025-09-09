class SignupResponseModel {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;

  SignupResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
  });

  /// Factory method to create SignupResponseModel from JSON
  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  /// Convert SignupResponseModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'success': success,
      'message': message,
    };
    
    if (accessToken != null) data['access_token'] = accessToken;
    if (refreshToken != null) data['refresh_token'] = refreshToken;
    
    return data;
  }

  /// Check if response contains authentication tokens
  bool get hasTokens => accessToken != null && refreshToken != null;

  /// Check if this is a successful signup response
  bool get isSignupSuccess => success && hasTokens;

  @override
  String toString() {
    return 'SignupResponseModel(success: $success, message: $message, hasTokens: $hasTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignupResponseModel &&
        other.success == success &&
        other.message == message &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode;
  }
}