import 'package:get/get.dart';

import '../views/auth/signin_screen.dart';
import '../views/auth/signin_mobile_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/auth/reset_password_screen.dart';
import '../views/home/home_screen.dart';
import '../views/onboarding/onboarding_screen.dart';

class XRoutes {
  XRoutes._();
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';
  static const String signinMobile = '/signin-mobile';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';

  static List<GetPage> routes = [
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: login, page: () => const SigninScreen()),
    GetPage(name: signinMobile, page: () => const SigninMobileScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: resetPassword, page: () => const ResetPasswordScreen()),
  ];
}
