import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:topgrade/utils/constants/fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/locale/locale.dart';
import 'features/presentation/bindings/initial_bindings.dart';
import 'features/presentation/controllers/onboarding_controller.dart';
import 'features/presentation/routes/routes.dart';
import 'utils/constants/strings.dart';
import 'utils/helpers/token_helper.dart';

// Preload fonts to prevent text disappearing in release builds
Future<void> _preloadFonts() async {
  try {
    await Future.wait([
      // Preload Lexend font variants
      rootBundle.load('assets/fonts/Lexend-Regular.ttf'),
      rootBundle.load('assets/fonts/Lexend-Medium.ttf'),
      rootBundle.load('assets/fonts/Lexend-SemiBold.ttf'),
      rootBundle.load('assets/fonts/Lexend-Bold.ttf'),
    ]);
  } catch (e) {
    print('Font preloading failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Preload custom fonts to prevent text disappearing in release builds
  await _preloadFonts();

  final bool isOnboardingCompleted =
      await OnboardingController.isOnboardingCompleted();
  String initialRoute;

  if (!isOnboardingCompleted) {
    initialRoute = XRoutes.onboarding;
  } else {
    // Check if user is already logged in
    final bool isLoggedIn = await TokenHelper.isLoggedIn();

    if (isLoggedIn) {
      // User has valid tokens, go to home
      initialRoute = XRoutes.home;
    } else {
      // User needs to login
      initialRoute = XRoutes.login;
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
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
        fontFamilyFallback: const ['Roboto', 'Arial', 'sans-serif'],
        // Ensure text is visible even if custom font fails
        textTheme: const TextTheme().apply(
          fontFamily: XFonts.lexend,
          fontFamilyFallback: ['Roboto', 'Arial', 'sans-serif'],
        ),
        // Force Material3 text scaling
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
