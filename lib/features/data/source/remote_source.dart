import 'package:dio/dio.dart';
import 'package:topgrade/utils/constants/api_endpoints.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/network/dio_client.dart';
import '../model/signin_response_model.dart';

abstract class RemoteSource {
  final DioClient dio;
  RemoteSource({required this.dio});

  Future<SigninResponseModel> signin({
    required String email,
    required String password,
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
}
