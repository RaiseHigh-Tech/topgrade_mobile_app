import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:logger/logger.dart';
import '../helpers/token_helper.dart';
import '../constants/api_endpoints.dart';
import '../../features/presentation/routes/routes.dart' as routes;

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
      printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true));

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d('Error type: ${err.error} \n '
        'Error message: ${err.message}'); //Debug log
    handler.next(err); //Continue with the Error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); //Info log
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('STATUSCODE: ${response.statusCode} \n '
        'STATUSMESSAGE: ${response.statusMessage} \n'
        'HEADERS: ${response.headers} \n'
        'Data: ${response.data}'); // Debug log
    handler.next(response);
  }
}

class AuthInterceptor extends Interceptor {
  static bool _isRefreshing = false;
  static final List<RequestOptions> _requestsQueue = [];
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get access token from storage
    final accessToken = await TokenHelper.getAccessToken();
    
    // Add Authorization header if token exists
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh logic for 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      final refreshToken = await TokenHelper.getRefreshToken();
      
      // If no refresh token exists, redirect to login
      if (refreshToken == null || refreshToken.isEmpty) {
        await _redirectToLogin();
        handler.next(err);
        return;
      }
      
      // If already refreshing, queue the request
      if (_isRefreshing) {
        _requestsQueue.add(err.requestOptions);
        handler.next(err);
        return;
      } 
      
      // Try to refresh the token
      _isRefreshing = true;
      
      try {
        final newAccessToken = await _refreshAccessToken(refreshToken);
        
        if (newAccessToken != null) {
          // Update the original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          // Retry the original request
          final dio = Dio();
          dio.interceptors.add(LoggerInterceptor());
          
          final Response<dynamic> response = await dio.fetch(err.requestOptions);
          
          // Process queued requests with new token
          await _processQueuedRequests(newAccessToken);
          
          handler.resolve(response);
        } else {
          // Refresh failed, redirect to login
          await _redirectToLogin();
          handler.next(err);
        }
      } catch (e) {
        // Refresh failed, redirect to login
        await _redirectToLogin();
        handler.next(err);
      } finally {
        _isRefreshing = false;
        _requestsQueue.clear();
      }
    } else {
      handler.next(err);
    }
  }
  
  /// Refresh access token using refresh token
  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final dio = Dio();
      dio.interceptors.add(LoggerInterceptor());
      
      final response = await dio.post(
        ApiEndpoints.refreshTokenUrl,
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['access_token'];
        
        // Save the new access token
        final currentRefreshToken = await TokenHelper.getRefreshToken();
        if (currentRefreshToken != null) {
          await TokenHelper.saveTokens(newAccessToken, currentRefreshToken);
        }
        
        return newAccessToken;
      } else {
        return null;
      }
    } catch (e) {
      Logger().e('Token refresh failed: $e');
      return null;
    }
  }
  
  /// Process queued requests with new access token
  Future<void> _processQueuedRequests(String newAccessToken) async {
    for (final requestOptions in _requestsQueue) {
      try {
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final dio = Dio();
        dio.interceptors.add(LoggerInterceptor());
        await dio.fetch(requestOptions);
      } catch (e) {
        Logger().e('Failed to process queued request: $e');
      }
    }
  }
  
  /// Redirect user to login screen and clear tokens
  Future<void> _redirectToLogin() async {
    Logger().w('Authentication failed, redirecting to login');
    
    // Clear all stored tokens
    await TokenHelper.clearTokens();
    
    // Navigate to login screen (only if not already on auth pages)
    if (Get.currentRoute != routes.XRoutes.login && 
        Get.currentRoute != routes.XRoutes.signup &&
        Get.currentRoute != routes.XRoutes.signinMobile &&
        Get.currentRoute != routes.XRoutes.resetPassword &&
        Get.currentRoute != routes.XRoutes.onboarding) {
      Get.offAllNamed(routes.XRoutes.login);
    }
  }
}
