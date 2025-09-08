import 'package:get/get.dart';

import '../views/auth/signin_screen.dart';
import '../views/home/home_screen.dart';

class XRoutes {
  XRoutes._();
  static const String home = '/splash';
  static const String login = '/login';

  static List<GetPage> routes = [
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: login, page: () => SigninScreen()),
  ];
}
