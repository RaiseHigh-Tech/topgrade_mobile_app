import 'package:get/get.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../data/source/remote_source.dart';
import '../routes/routes.dart';

class AuthController extends GetxController {
  late RemoteSourceImpl remoteSource;
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  Future<void> login() async {
    try {
      _isLoading.value = true;
      await remoteSource
          .demoLogin(email: "dhinesh.tech2001@gmail.com", password: "12345")
          .then((response) {
            _isLoading.value = false;
            // Response is DemoModel
            // You may access reponse here like
            // print(response.name);
            Get.toNamed(XRoutes.home);
          });
    } on ResponseException catch (e) {
      // use instance of ResponseException instead of toast messages
      print(e.message);
    } on ServerException catch (e) {
      // use instance of ServerException instead of toast messages
      print(e.message);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    remoteSource = Get.find<RemoteSourceImpl>();
  }
}
