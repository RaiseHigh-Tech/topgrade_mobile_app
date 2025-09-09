import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:topgrade/utils/constants/fonts.dart';

import 'features/locale/locale.dart';
import 'features/presentation/bindings/initial_bindings.dart';
import 'features/presentation/controllers/onboarding_controller.dart';
import 'features/presentation/routes/routes.dart';
import 'utils/constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Temporarily commented for development - uncomment when ready
  // Check if onboarding is complete.
  // final bool isOnboardingCompleted = await OnboardingController.isOnboardingCompleted();
  // Always show onboarding during development
  
  runApp(const MyApp(initialRoute: XRoutes.onboarding));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: XFonts.lexend,
        fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
      ),
      title: XString.appName,
      getPages: XRoutes.routes,
      initialRoute: initialRoute,
      translations: XLocale(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.rightToLeft,
      initialBinding: InitialBindings(),
    );
  }
}
