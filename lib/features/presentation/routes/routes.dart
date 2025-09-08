import 'package:get/get.dart';

import '../views/auth/signin_screen.dart';
import '../views/home/home_screen.dart';
import '../views/onboarding/onboarding_screen.dart';

class XRoutes {
  XRoutes._();
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';

  static List<GetPage> routes = [
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: login, page: () => const SigninScreen()),
  ];
}
