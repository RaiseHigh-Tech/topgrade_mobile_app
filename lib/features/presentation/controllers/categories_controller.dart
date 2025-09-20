import 'package:get/get.dart';
import '../../data/model/categories_response_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class CategoriesController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = true.obs;
  var categories = <CategoryModel>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Computed property for display categories (with "All" at the beginning)
  List<String> get displayCategories {
    List<String> result = ["All"];
    result.addAll(categories.map((cat) => cat.name).toList());
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getCategories();
      
      if (response.success) {
        categories.value = response.categories;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch categories';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Retry function for error handling
  void retry() {
    fetchCategories();
  }

  // Get category ID by name
  int? getCategoryIdByName(String categoryName) {
    try {
      final category = categories.firstWhere((cat) => cat.name == categoryName);
      return category.id;
    } catch (e) {
      return null;
    }
  }

  // Get category name by ID
  String? getCategoryNameById(int categoryId) {
    try {
      final category = categories.firstWhere((cat) => cat.id == categoryId);
      return category.name;
    } catch (e) {
      return null;
    }
  }
}