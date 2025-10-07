import 'package:get/get.dart';
import '../../data/model/programs_filter_response_model.dart';
import '../../data/model/program_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class ProgramsController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = false.obs;
  var programs = <ProgramModel>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var statistics =
      StatisticsModel(
        totalCount: 0,
        regularProgramsCount: 0,
        advancedProgramsCount: 0,
      ).obs;
  var filtersApplied = FiltersAppliedModel().obs;

  // Filter parameters
  var selectedCategoryId = Rxn<int>();
  var selectedProgramType = Rxn<String>();
  var selectedIsBestSeller = Rxn<bool>();
  var selectedMinPrice = Rxn<double>();
  var selectedMaxPrice = Rxn<double>();
  var selectedMinRating = Rxn<double>();
  var searchQuery = ''.obs;
  var selectedSortBy = 'most_relevant'.obs;
  var selectedSortOrder = 'asc'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFilteredPrograms();
  }

  Future<void> fetchFilteredPrograms() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getFilteredPrograms(
        categoryId: selectedCategoryId.value,
        isBestSeller: selectedIsBestSeller.value,
        minPrice: selectedMinPrice.value,
        maxPrice: selectedMaxPrice.value,
        minRating: selectedMinRating.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        sortBy: selectedSortBy.value,
        sortOrder: selectedSortOrder.value,
      );

      if (response.success) {
        programs.value = response.programs;
        statistics.value = response.statistics;
        filtersApplied.value = response.filtersApplied;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch programs';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Filter methods
  void filterByCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    fetchFilteredPrograms();
  }

  void filterByProgramType(String? programType) {
    selectedProgramType.value = programType;
    fetchFilteredPrograms();
  }

  void filterByBestSeller(bool? isBestSeller) {
    selectedIsBestSeller.value = isBestSeller;
    fetchFilteredPrograms();
  }

  void filterByPriceRange(double? minPrice, double? maxPrice) {
    selectedMinPrice.value = minPrice;
    selectedMaxPrice.value = maxPrice;
    fetchFilteredPrograms();
  }

  void filterByRating(double? minRating) {
    selectedMinRating.value = minRating;
    fetchFilteredPrograms();
  }

  void searchPrograms(String query) {
    searchQuery.value = query;
    fetchFilteredPrograms();
  }

  void sortPrograms(String sortBy, {String sortOrder = 'asc'}) {
    selectedSortBy.value = sortBy;
    selectedSortOrder.value = sortOrder;
    fetchFilteredPrograms();
  }

  // Clear all filters
  void clearAllFilters() {
    selectedCategoryId.value = null;
    selectedProgramType.value = null;
    selectedIsBestSeller.value = null;
    selectedMinPrice.value = null;
    selectedMaxPrice.value = null;
    selectedMinRating.value = null;
    searchQuery.value = '';
    selectedSortBy.value = 'most_relevant';
    selectedSortOrder.value = 'asc';
    fetchFilteredPrograms();
  }

  // Retry function for error handling
  void retry() {
    fetchFilteredPrograms();
  }

  // Helper method to check if any filters are applied
  bool get hasActiveFilters {
    return selectedCategoryId.value != null ||
        selectedProgramType.value != null ||
        selectedIsBestSeller.value != null ||
        selectedMinPrice.value != null ||
        selectedMaxPrice.value != null ||
        selectedMinRating.value != null ||
        searchQuery.value.isNotEmpty;
  }

  // Get display text for current filters
  String get activeFiltersText {
    List<String> activeFilters = [];

    if (selectedCategoryId.value != null) {
      activeFilters.add('Category filtered');
    }
    if (selectedProgramType.value != null) {
      activeFilters.add('Type: ${selectedProgramType.value}');
    }
    if (selectedIsBestSeller.value == true) {
      activeFilters.add('Best sellers only');
    }
    if (selectedMinRating.value != null) {
      activeFilters.add('Rating: ${selectedMinRating.value}+');
    }
    if (searchQuery.value.isNotEmpty) {
      activeFilters.add('Search: "${searchQuery.value}"');
    }

    return activeFilters.isEmpty
        ? 'No filters applied'
        : activeFilters.join(', ');
  }
}
