import 'package:dio/dio.dart';
import 'package:topgrade/utils/constants/api_endpoints.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/network/dio_client.dart';
import '../model/signin_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/reset_password_response_model.dart';
import '../model/verify_otp_response_model.dart';
import '../model/phone_otp_response_model.dart';
import '../model/phone_signin_response_model.dart';
import '../model/area_of_interest_response_model.dart';
import '../model/categories_response_model.dart';
import '../model/programs_filter_response_model.dart';
import '../model/landing_response_model.dart';
import '../model/bookmarks_response_model.dart';
import '../model/my_learnings_response_model.dart';
import '../model/program_details_response_model.dart';

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

  Future<VerifyOtpResponseModel> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });

  Future<ResetPasswordResponseModel> resetPassword({
    required String email,
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

  Future<AreaOfInterestResponseModel> addAreaOfInterest({
    required String areaOfIntrest,
  });

  Future<CategoriesResponseModel> getCategories();

  Future<ProgramsFilterResponseModel> getFilteredPrograms({
    String? programType,
    int? categoryId,
    bool? isBestSeller,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  Future<LandingResponseModel> getLandingData();

  Future<BookmarksResponseModel> getBookmarks();

  Future<MyLearningsResponseModel> getMyLearnings({String? status});
  
  Future<ProgramDetailsResponseModel> getProgramDetails({
    required String programType,
    required int programId,
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
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resetPasswordUrl,
        data: {
          'email': email,
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
            case 404:
              // User not found
              final message = responseData['message'] ?? 'User with this email does not exist';
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

  @override
  Future<VerifyOtpResponseModel> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyOtpUrl,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        return VerifyOtpResponseModel.fromJson(response.data);
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
              // Bad request - invalid OTP format
              final message = responseData['message'] ?? 'Invalid OTP';
              throw ResponseException(message: message);
            case 401:
              // Invalid OTP
              final message = responseData['message'] ?? 'Invalid OTP';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message = responseData['message'] ?? 'User with this email does not exist';
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
  Future<AreaOfInterestResponseModel> addAreaOfInterest({
    required String areaOfIntrest,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addAreaOfInterestUrl,
        data: {'area_of_intrest': areaOfIntrest},
      );
 
      if (response.statusCode == 200) {
        return AreaOfInterestResponseModel.fromJson(response.data);
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
            case 401:
              // Unauthorized - invalid or missing token
              final message = responseData['detail'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 422:
              // Validation error
              final message = responseData['detail']?[0]?['msg'] ?? 'Validation error';
              throw ResponseException(message: message);
            case 500:
              // Server error
              final message = responseData['message'] ?? 'Internal server error';
              throw ServerException(message: message);
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(message: 'Network error occurred');
        }
      } else {
        throw ServerException(message: 'An unexpected error occurred');
      }
    }
  }

  @override
  Future<CategoriesResponseModel> getCategories() async {
    try {
      final response = await dio.get(ApiEndpoints.categoriesUrl);

      if (response.statusCode == 200) {
        return CategoriesResponseModel.fromJson(response.data);
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
            case 404:
              // Categories not found
              final message = responseData['message'] ?? 'Categories not found';
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
  Future<ProgramsFilterResponseModel> getFilteredPrograms({
    String? programType,
    int? categoryId,
    bool? isBestSeller,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      
      if (programType != null) queryParams['program_type'] = programType;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (isBestSeller != null) queryParams['is_best_seller'] = isBestSeller;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (minRating != null) queryParams['min_rating'] = minRating;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await dio.get(
        ApiEndpoints.programsFilterUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ProgramsFilterResponseModel.fromJson(response.data);
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
              // Bad request - invalid parameters
              final message = responseData['message'] ?? 'Invalid request parameters';
              throw ResponseException(message: message);
            case 404:
              // Programs not found
              final message = responseData['message'] ?? 'No programs found';
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
  Future<LandingResponseModel> getLandingData() async {
    try {
      final response = await dio.get(ApiEndpoints.landingUrl);

      if (response.statusCode == 200) {
        return LandingResponseModel.fromJson(response.data);
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
            case 404:
              // Landing data not found
              final message = responseData['message'] ?? 'Landing data not found';
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
  Future<BookmarksResponseModel> getBookmarks() async {
    try {
      final response = await dio.get(ApiEndpoints.bookmarksUrl);

      if (response.statusCode == 200) {
        return BookmarksResponseModel.fromJson(response.data);
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
            case 401:
              // Unauthorized
              final message = responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              // No bookmarks found
              final message = responseData['message'] ?? 'No bookmarks found';
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
  Future<MyLearningsResponseModel> getMyLearnings({String? status}) async {
    try {
      String url = ApiEndpoints.myLearningsUrl;
      
      // Add status query parameter if provided
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }
      
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return MyLearningsResponseModel.fromJson(response.data);
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
            case 401:
              // Unauthorized
              final message = responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              // No learnings found
              final message = responseData['message'] ?? 'No learnings found';
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
  Future<ProgramDetailsResponseModel> getProgramDetails({
    required String programType,
    required int programId,
  }) async {
    try {
      final url = '${ApiEndpoints.baseUrl}api/program/$programType/$programId/details';
      
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return ProgramDetailsResponseModel.fromJson(response.data);
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
            case 401:
              // Unauthorized
              final message = responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              // Program not found
              final message = responseData['message'] ?? 'Program not found';
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
