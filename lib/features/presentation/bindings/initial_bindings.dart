import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/network/dio_client.dart';
import '../../data/source/remote_source.dart';
import '../controllers/theme_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() async {
    Get.put(XThemeController(), permanent: true);
    Get.put(await SharedPreferences.getInstance(), permanent: true);
    Get.put(DioClient(), permanent: true);
    Get.put(RemoteSourceImpl(dio: Get.find<DioClient>()), permanent: true);
  }
}
