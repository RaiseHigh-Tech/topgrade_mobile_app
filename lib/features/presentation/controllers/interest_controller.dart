import 'package:get/get.dart';
import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../data/source/remote_source.dart';
import '../../data/model/area_of_interest_response_model.dart';
import '../routes/routes.dart';

class InterestController extends GetxController {
  late RemoteSourceImpl remoteSource;
  
  // Single selected interest index (-1 means no selection)
  final RxInt _selectedInterestIndex = (-1).obs;
  final RxBool _isLoading = false.obs;
  
  // Getter for selected index
  int get selectedInterestIndex => _selectedInterestIndex.value;
  
  // Getter for loading state
  bool get isLoading => _isLoading.value;
  
  // Check if a specific interest is selected
  bool isInterestSelected(int index) {
    return _selectedInterestIndex.value == index;
  }
  
  // Select an interest (radio-style - only one can be selected)
  void selectInterest(int index) {
    _selectedInterestIndex.value = index;
  }
  
  // Get selected interest data
  Map<String, dynamic>? getSelectedInterest(List<Map<String, dynamic>> interests) {
    if (_selectedInterestIndex.value >= 0 && _selectedInterestIndex.value < interests.length) {
      return interests[_selectedInterestIndex.value];
    }
    return null;
  }
  
  // Check if any interest is selected
  bool get hasSelection => _selectedInterestIndex.value >= 0;
  
  // Clear selection
  void clearSelection() {
    _selectedInterestIndex.value = -1;
  }
  
  // Submit selected interest to API
  Future<void> submitInterest(List<Map<String, dynamic>> interests) async {
    try {
      _isLoading.value = true;
      
      // Check if any interest is selected
      if (!hasSelection) {
        Get.snackbar('Error', 'Please select an area of interest');
        return;
      }
      
      // Get selected interest
      final selectedInterest = getSelectedInterest(interests);
      if (selectedInterest == null) {
        Get.snackbar('Error', 'Please select an area of interest');
        return;
      }
      
      // Call API to add area of interest
      final AreaOfInterestResponseModel response = await remoteSource.addAreaOfInterest(
        areaOfIntrest: selectedInterest['title'],
      );
      
      // Check if update was successful
      if (response.isUpdateSuccess) {
        // Navigate to home screen
        Get.offAllNamed(XRoutes.home);
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update area of interest. Please try again.');
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