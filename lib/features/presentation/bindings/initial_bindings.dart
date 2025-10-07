import 'package:get/get.dart';

import '../../../utils/network/dio_client.dart';
import '../../data/source/remote_source.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/carousel_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core dependencies
    Get.put(XThemeController(), permanent: true);
    
    // Network dependencies
    Get.put(DioClient(), permanent: true);
    Get.put(RemoteSourceImpl(dio: Get.find<DioClient>()), permanent: true);
    
    // Controllers
    Get.put(OnboardingController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(CarouselController(), permanent: true);
  }
}
