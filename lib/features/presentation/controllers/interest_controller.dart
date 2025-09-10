import 'package:get/get.dart';

class InterestController extends GetxController {
  // Single selected interest index (-1 means no selection)
  final RxInt _selectedInterestIndex = (-1).obs;
  
  // Getter for selected index
  int get selectedInterestIndex => _selectedInterestIndex.value;
  
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
}