class ApiEndpoints {
  // Base URL
  // static const String baseUrl = 'https://280wgvdh-8000.inc1.devtunnels.ms/';
  static const String baseUrl = 'https://www.topgradeinnovation.com/'; 

  // Complete URLs
  static const String signupUrl = '${baseUrl}api/auth/signup';
  static const String signinUrl = '${baseUrl}api/auth/signin';
  static const String phoneSigninUrl = '${baseUrl}api/auth/phone-signin';
  static const String profileStatusUrl = '${baseUrl}api/auth/profile-status';
  static const String profileUpdateUrl = '${baseUrl}api/auth/profile-update';
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
  
  // Learning Progress endpoints
  static const String updateProgressUrl = '${baseUrl}api/learning/update-progress';
  
  // Request Access endpoints
  static const String requestAccessUrl = '${baseUrl}api/request-program';
  
  // Notification endpoints
  static const String registerFcmTokenUrl = '${baseUrl}api/notifications/register-fcm-token';
  static const String notificationsUrl = '${baseUrl}api/notifications/notifications';
  static const String markNotificationReadUrl = '${baseUrl}api/notifications/mark-notification-read';
  static const String markAllReadUrl = '${baseUrl}api/notifications/mark-all-read';
  static const String deleteFcmTokenUrl = '${baseUrl}api/notifications/fcm-token';
  static const String fcmTokensUrl = '${baseUrl}api/notifications/fcm-tokens';
  
  // Web URLs
  static const String privacyPolicyUrl = '${baseUrl}privacy-app/';
  static const String termsAndConditionsUrl = '${baseUrl}terms-app/';
}
