import 'package:dio/dio.dart';
import 'package:topgrade/utils/constants/api_endpoints.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/network/dio_client.dart';
import '../model/signin_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/reset_password_response_model.dart';
import '../model/verify_otp_response_model.dart';
import '../model/area_of_interest_response_model.dart';
import '../model/categories_response_model.dart';
import '../model/programs_filter_response_model.dart';
import '../model/landing_response_model.dart';
import '../model/bookmarks_response_model.dart';
import '../model/my_learnings_response_model.dart';
import '../model/progress_update_response_model.dart';
import '../model/program_details_response_model.dart';
import '../model/carousel_response_model.dart';
import '../model/phone_signin_response_model.dart';
import '../model/profile_status_response_model.dart';
import '../model/profile_update_response_model.dart';
import '../model/request_access_response_model.dart';
import '../model/notification_response_model.dart';

abstract class RemoteSource {
  final DioClient dio;
  RemoteSource({required this.dio});

  Future<SigninResponseModel> signin({
    required String email,
    required String password,
  });

  Future<SignupResponseModel> signup({
    required String fullname,
    required String phoneNumber,
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

  Future<PhoneSigninResponseModel> phoneSignin({
    required String phoneNumber,
    required String firebaseToken,
  });

  Future<ProfileStatusResponseModel> getProfileStatus();

  Future<ProfileUpdateResponseModel> updateProfile({
    required String email,
    required String fullname,
  });

  Future<AreaOfInterestResponseModel> addAreaOfInterest({
    required String areaOfIntrest,
  });

  Future<CategoriesResponseModel> getCategories();

  Future<ProgramsFilterResponseModel> getFilteredPrograms({
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

  Future<Map<String, dynamic>> addBookmark({required int programId});

  Future<Map<String, dynamic>> removeBookmark({required int programId});

  Future<MyLearningsResponseModel> getMyLearnings({String? status});

  // Carousel endpoints
  Future<CarouselResponseModel> getCarouselData();

  Future<ProgramDetailsResponseModel> getProgramDetails({
    required int programId,
  });

  // Request Access endpoints
  Future<RequestAccessResponseModel> requestProgramAccess({
    required int programId,
  });

  Future<ProgressUpdateResponseModel> updateLearningProgress({
    required int topicId,
    required int purchaseId,
    required int watchTimeSeconds,
  });

  // Notification endpoints
  Future<Map<String, dynamic>> registerFcmToken({
    required String token,
    required String deviceType,
    String? deviceId,
  });

  Future<NotificationResponseModel> getNotifications({
    int limit = 20,
    int offset = 0,
  });

  Future<Map<String, dynamic>> markNotificationAsRead({
    required int notificationId,
  });

  Future<Map<String, dynamic>> markAllNotificationsAsRead();

  Future<Map<String, dynamic>> deleteFcmToken({
    required String token,
  });

  Future<FcmTokenResponseModel> getFcmTokens();
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
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.signupUrl,
        data: {
          'fullname': fullname,
          'phone_number': phoneNumber,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return SignupResponseModel.fromJson(response.data);
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
              // Bad request - validation errors or passwords don't match
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 409:
              // Conflict - user already exists
              final message =
                  responseData['message'] ??
                  'User with this email already exists';
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
  Future<ResetPasswordResponseModel> requestPasswordResetOtp({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.requestOtpUrl,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return ResetPasswordResponseModel.fromJson(response.data);
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
              // Bad request - invalid email format
              final message =
                  responseData['message'] ?? 'Invalid email address';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message =
                  responseData['message'] ?? 'User not found with this email';
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
              // Bad request - validation errors, passwords don't match, invalid OTP
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message =
                  responseData['message'] ??
                  'User with this email does not exist';
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
  Future<VerifyOtpResponseModel> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyOtpUrl,
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return VerifyOtpResponseModel.fromJson(response.data);
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
              // Bad request - invalid OTP format
              final message = responseData['message'] ?? 'Invalid OTP';
              throw ResponseException(message: message);
            case 401:
              // Invalid OTP
              final message = responseData['message'] ?? 'Invalid OTP';
              throw ResponseException(message: message);
            case 404:
              // User not found
              final message =
                  responseData['message'] ??
                  'User with this email does not exist';
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
  Future<PhoneSigninResponseModel> phoneSignin({
    required String phoneNumber,
    required String firebaseToken,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.phoneSigninUrl,
        data: {
          'phoneNumber': phoneNumber,
          'firebaseToken': firebaseToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PhoneSigninResponseModel.fromJson(response.data);
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
              // Unauthorized - invalid Firebase token
              final message = 
                  responseData['message'] ?? 'Invalid authentication token';
              throw ResponseException(message: message);
            case 403:
              // Forbidden - Firebase token verification failed
              final message = 
                  responseData['message'] ?? 'Phone number verification failed';
              throw ResponseException(message: message);
            case 404:
              // Not found - endpoint issue
              final message = responseData['message'] ?? 'Service not found';
              throw ResponseException(message: message);
            case 409:
              // Conflict - possible duplicate entry
              final message = 
                  responseData['message'] ?? 'User conflict error';
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
  Future<ProfileStatusResponseModel> getProfileStatus() async {
    try {
      final response = await dio.get(
        ApiEndpoints.profileStatusUrl,
      );

      if (response.statusCode == 200) {
        return ProfileStatusResponseModel.fromJson(response.data);
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
              // Unauthorized - invalid or expired token
              final message = responseData['message'] ?? 'Authentication required';
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
  Future<ProfileUpdateResponseModel> updateProfile({
    required String email,
    required String fullname,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.profileUpdateUrl,
        data: {
          'email': email,
          'fullname': fullname,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProfileUpdateResponseModel.fromJson(response.data);
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
              // Unauthorized - invalid or expired token
              final message = responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 409:
              // Conflict - email already exists
              final message = responseData['message'] ?? 'Email already in use';
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
              final message =
                  responseData['detail'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 422:
              // Validation error
              final message =
                  responseData['detail']?[0]?['msg'] ?? 'Validation error';
              throw ResponseException(message: message);
            case 500:
              // Server error
              final message =
                  responseData['message'] ?? 'Internal server error';
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
              final message =
                  responseData['message'] ?? 'Invalid request parameters';
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
              final message =
                  responseData['message'] ?? 'Landing data not found';
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
              final message =
                  responseData['message'] ?? 'Authentication required';
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
  Future<Map<String, dynamic>> addBookmark({required int programId}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addBookmarkUrl,
        data: {'program_id': programId},
      );

      if (response.statusCode == 200) {
        return response.data;
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
              final message =
                  responseData['message'] ?? 'Invalid request parameters';
              throw ResponseException(message: message);
            case 401:
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              final message = responseData['message'] ?? 'Program not found';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> removeBookmark({required int programId}) async {
    try {
      final response = await dio.delete(
        ApiEndpoints.removeBookmarkUrl,
        data: {'program_id': programId},
      );

      if (response.statusCode == 200) {
        return response.data;
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
              final message =
                  responseData['message'] ?? 'Invalid request parameters';
              throw ResponseException(message: message);
            case 401:
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              final message = responseData['message'] ?? 'Bookmark not found';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
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
              final message =
                  responseData['message'] ?? 'Authentication required';
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
  Future<CarouselResponseModel> getCarouselData() async {
    try {
      final response = await dio.get(ApiEndpoints.carouselUrl);

      if (response.statusCode == 200) {
        return CarouselResponseModel.fromJson(response.data);
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
              // No carousel data found
              final message =
                  responseData['message'] ?? 'No carousel data found';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProgramDetailsResponseModel> getProgramDetails({
    required int programId,
  }) async {
    try {
      final url = '${ApiEndpoints.baseUrl}api/program/$programId/details';

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
              final message =
                  responseData['message'] ?? 'Authentication required';
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

  @override
  Future<RequestAccessResponseModel> requestProgramAccess({
    required int programId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.requestAccessUrl,
        data: {'program_id': programId},
      );

      if (response.statusCode == 200) {
        return RequestAccessResponseModel.fromJson(response.data);
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
              // Bad request - missing program_id or duplicate enquiry
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 401:
              // Unauthorized
              final message =
                  responseData['detail'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              // Program not found
              final message = responseData['message'] ?? 'Program not found';
              throw ResponseException(message: message);
            case 500:
              // Server error
              final message =
                  responseData['message'] ?? 'Internal server error';
              throw ServerException(message: message);
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
  Future<ProgressUpdateResponseModel> updateLearningProgress({
    required int topicId,
    required int purchaseId,
    required int watchTimeSeconds,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.updateProgressUrl,
        data: {
          'topic_id': topicId,
          'purchase_id': purchaseId,
          'watch_time_seconds': watchTimeSeconds,
        },
      );

      if (response.statusCode == 200) {
        return ProgressUpdateResponseModel.fromJson(response.data);
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
              // Bad request
              final message = responseData['message'] ?? 'Invalid request data';
              throw ResponseException(message: message);
            case 401:
              // Unauthorized
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 403:
              // Forbidden - not purchased
              final message =
                  responseData['message'] ??
                  'Access denied - content not purchased';
              throw ResponseException(message: message);
            case 404:
              // Topic or purchase not found
              final message =
                  responseData['message'] ?? 'Topic or purchase not found';
              throw ResponseException(message: message);
            case 500:
              // Server error
              throw ServerException(message: 'Internal server error');
            default:
              final message =
                  responseData['message'] ?? 'Failed to update progress';
              throw ResponseException(message: message);
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
  Future<Map<String, dynamic>> registerFcmToken({
    required String token,
    required String deviceType,
    String? deviceId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'token': token,
        'device_type': deviceType,
      };

      if (deviceId != null) {
        data['device_id'] = deviceId;
      }

      final response = await dio.post(
        ApiEndpoints.registerFcmTokenUrl,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
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
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 401:
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<NotificationResponseModel> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.notificationsUrl,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        return NotificationResponseModel.fromJson(response.data);
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
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> markNotificationAsRead({
    required int notificationId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.markNotificationReadUrl,
        data: {'notification_id': notificationId},
      );

      if (response.statusCode == 200) {
        return response.data;
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
              final message = responseData['message'] ?? 'Invalid request';
              throw ResponseException(message: message);
            case 401:
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              final message =
                  responseData['message'] ?? 'Notification not found';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await dio.post(ApiEndpoints.markAllReadUrl);

      if (response.statusCode == 200) {
        return response.data;
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
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> deleteFcmToken({
    required String token,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiEndpoints.deleteFcmTokenUrl}?token=$token',
      );

      if (response.statusCode == 200) {
        return response.data;
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
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 404:
              final message = responseData['message'] ?? 'Token not found';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FcmTokenResponseModel> getFcmTokens() async {
    try {
      final response = await dio.get(ApiEndpoints.fcmTokensUrl);

      if (response.statusCode == 200) {
        return FcmTokenResponseModel.fromJson(response.data);
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
              final message =
                  responseData['message'] ?? 'Authentication required';
              throw ResponseException(message: message);
            case 500:
              throw ServerException(message: 'Internal server error');
            default:
              throw ServerException(message: 'Unexpected error occurred');
          }
        } else {
          throw ServerException(
            message: 'Network error: Please check your connection',
          );
        }
      }
      throw ServerException(message: e.toString());
    }
  }
}
