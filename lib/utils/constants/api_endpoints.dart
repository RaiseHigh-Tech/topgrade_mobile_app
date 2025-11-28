class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://0323b7271e46.ngrok-free.app/';

  // Complete URLs
  static const String signupUrl = '${baseUrl}api/auth/signup';
  static const String signinUrl = '${baseUrl}api/auth/signin';
  static const String phoneSigninUrl = '${baseUrl}api/auth/phone-signin';
  static const String requestOtpUrl = '${baseUrl}api/auth/request-otp';
  static const String verifyOtpUrl = '${baseUrl}api/auth/verify-otp';
  static const String resetPasswordUrl = '${baseUrl}api/auth/reset-password';
  static const String refreshTokenUrl = '${baseUrl}api/auth/refresh';

  // Interest endpoints
  static const String addAreaOfInterestUrl =
      '${baseUrl}api/add-area-of-interest';

  // Categories endpoints
  static const String categoriesUrl = '${baseUrl}api/categories';

  // Programs endpoints
  static const String programsFilterUrl = '${baseUrl}api/programs/filter';

  // Landing endpoints
  static const String landingUrl = '${baseUrl}api/landing';

  // Carousel endpoints
  static const String carouselUrl = '${baseUrl}api/carousel';

  // Bookmarks endpoints
  static const String bookmarksUrl = '${baseUrl}api/bookmarks';
  static const String addBookmarkUrl = '${baseUrl}api/bookmark';
  static const String removeBookmarkUrl = '${baseUrl}api/bookmark';

  // My Learnings endpoints
  static const String myLearningsUrl = '${baseUrl}api/my-learnings';

  // Purchase endpoints
  static const String purchaseUrl = '${baseUrl}api/purchase';
  
  // Learning Progress endpoints
  static const String updateProgressUrl = '${baseUrl}api/learning/update-progress';
}
