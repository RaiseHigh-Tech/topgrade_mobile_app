import 'package:dio/dio.dart';
import 'package:topgrade/utils/constants/api_endpoints.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/network/dio_client.dart';
import '../model/signin_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/reset_password_response_model.dart';
import '../model/phone_otp_response_model.dart';
import '../model/phone_signin_response_model.dart';

abstract class RemoteSource {
  final DioClient dio;
  RemoteSource({required this.dio});

  Future<SigninResponseModel> signin({
    required String email,
    required String password,
  });

  Future<SignupResponseModel> signup({
    required String fullname,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<ResetPasswordResponseModel> requestPasswordResetOtp({
    required String email,
  });

  Future<ResetPasswordResponseModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  Future<PhoneOtpResponseModel> requestPhoneOtp({
    required String phoneNumber,
  });

  Future<PhoneSigninResponseModel> phoneSignin({
    required String phoneNumber,
    required String otp,
  });
}

class RemoteSourceImpl extends RemoteSource {
  RemoteSourceImpl({required super.dio});

  @override
  Future<SigninResponseModel> signin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.signinUrl,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return SigninResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: "Unexpected response code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          switch (statusCode) {
            case 400:
              // Bad request - validation errors
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 401:
              // Unauthorized - invalid credentials
              final message =
                  responseData['message'] ?? 'Invalid email or password';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message = responseData['message'] ?? 'User not found';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          // Network error
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      // Other exceptions
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SignupResponseModel> signup({
    required String fullname,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.signupUrl,
        data: {
          'fullname': fullname,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return SignupResponseModel.fromJson(response.data);
      } else {
        throw ServerException(message: "Unexpected response code: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          switch (statusCode) {
            case 400:
              // Bad request - validation errors or passwords don't match
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 409:
              // Conflict - user already exists
              final message = responseData['message'] ?? 'User with this email already exists';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          // Network error
          throw ServerException(message: 'Network error: Please check your connection');
        }
      }
      // Other exceptions
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ResetPasswordResponseModel> requestPasswordResetOtp({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.requestOtpUrl,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return ResetPasswordResponseModel.fromJson(response.data);
      } else {
        throw ServerException(message: "Unexpected response code: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          switch (statusCode) {
            case 400:
              // Bad request - invalid email format
              final message = responseData['message'] ?? 'Invalid email address';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message = responseData['message'] ?? 'User not found with this email';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          // Network error
          throw ServerException(message: 'Network error: Please check your connection');
        }
      }
      // Other exceptions
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resetPasswordUrl,
        data: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return ResetPasswordResponseModel.fromJson(response.data);
      } else {
        throw ServerException(message: "Unexpected response code: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          switch (statusCode) {
            case 400:
              // Bad request - validation errors, passwords don't match, invalid OTP
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 401:
              // Invalid or expired OTP
              final message = responseData['message'] ?? 'Invalid or expired OTP';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message = responseData['message'] ?? 'User not found';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          // Network error
          throw ServerException(message: 'Network error: Please check your connection');
        }
      }
      // Other exceptions
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PhoneOtpResponseModel> requestPhoneOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.requestPhoneOtpUrl,
        data: {
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        return PhoneOtpResponseModel.fromJson(response.data);
      } else {
        throw ServerException(message: "Unexpected response code: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          switch (statusCode) {
            case 400:
              // Bad request - invalid phone number format
              final message = responseData['message'] ?? 'Phone number must be exactly 10 digits';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          // Network error
          throw ServerException(message: 'Network error: Please check your connection');
        }
      }
      // Other exceptions
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PhoneSigninResponseModel> phoneSignin({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.phoneSigninUrl,
        data: {
          'phone_number': phoneNumber,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        return PhoneSigninResponseModel.fromJson(response.data);
      } else {
        throw ServerException(message: "Unexpected response code: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final responseData = e.response!.data;

          switch (statusCode) {
            case 400:
              // Bad request - invalid phone number or OTP format
              final message = responseData['message'] ?? 'Invalid phone number or OTP';
              throw ResponseException(message: message);
            case 401:
              // Invalid or expired OTP
              final message = responseData['message'] ?? 'Invalid or expired OTP';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          // Network error
          throw ServerException(message: 'Network error: Please check your connection');
        }
      }
      // Other exceptions
      throw ServerException(message: e.toString());
    }
  }
}
