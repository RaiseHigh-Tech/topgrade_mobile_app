import 'package:get/get.dart';

class BottomNavController extends GetxController {
  final RxInt _selectedIndex = 0.obs;
  
  int get selectedIndex => _selectedIndex.value;
  
  void changeTab(int index) {
    _selectedIndex.value = index;
  }
  
  // Tab names
  List<String> get tabNames => ['Home', 'My Learning', 'Chat', 'Profile'];
}