import 'user_model.dart';

class SigninResponseModel {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final String? otp;
  final bool? userExists;
  final bool? hasAreaOfIntrest;
  final UserModel? user;

  SigninResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.otp,
    this.userExists,
    this.hasAreaOfIntrest,
    this.user,
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
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  /// Check if response contains authentication tokens
  bool get hasTokens => accessToken != null && refreshToken != null;

  /// Check if response contains OTP
  bool get hasOtp => otp != null;

  /// Check if this is a successful authentication response
  bool get isAuthSuccess => success && hasTokens;

  /// Check if this is a successful OTP response
  bool get isOtpSuccess => success && hasOtp;
}