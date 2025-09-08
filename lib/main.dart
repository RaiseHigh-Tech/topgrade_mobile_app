import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/locale/locale.dart';
import 'features/presentation/bindings/initial_bindings.dart';
import 'features/presentation/routes/routes.dart';
import 'utils/constants/strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      title: XString.appName,
      getPages: XRoutes.routes,
      initialRoute: XRoutes.home,
      translations: XLocale(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      // if you use splash screen instead of initialRoute use XRoutes.splash
      defaultTransition: Transition.rightToLeft,
      initialBinding: InitialBindings(),
    );
  }
}
