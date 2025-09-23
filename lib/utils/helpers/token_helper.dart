import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token Helper for managing authentication tokens securely
class TokenHelper {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Save tokens to secure storage
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Get access token from secure storage
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Get refresh token from secure storage
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Check if user is logged in (has valid access token)
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Clear all tokens from storage
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Get authorization header with bearer token
  static Future<String?> getAuthorizationHeader() async {
    final accessToken = await getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      return 'Bearer $accessToken';
    }
    return null;
  }

  /// Check if tokens exist (both access and refresh)
  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && 
           accessToken.isNotEmpty && 
           refreshToken != null && 
           refreshToken.isNotEmpty;
  }
  
  /// Update only the access token (keep refresh token unchanged)
  static Future<void> updateAccessToken(String newAccessToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
  }
  
  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }
  
  /// Get all stored tokens as a map
  static Future<Map<String, String?>> getAllTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}