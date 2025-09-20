import 'package:get/get.dart';
import '../../data/model/landing_response_model.dart';
import '../../data/model/program_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class LandingController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Landing data
  var topCourse = <ProgramModel>[].obs;
  var recentlyAdded = <ProgramModel>[].obs;
  var featured = <ProgramModel>[].obs;
  var programs = <ProgramModel>[].obs;
  var advancedPrograms = <ProgramModel>[].obs;
  var continueWatching = <ProgramModel>[].obs;
  var counts =
      LandingCountsModel(
        topCourse: 0,
        recentlyAdded: 0,
        featured: 0,
        programs: 0,
        advancedPrograms: 0,
        continueWatching: 0,
      ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchLandingData();
  }

  Future<void> fetchLandingData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getLandingData();

      if (response.success) {
        // Update observable variables
        topCourse.value = response.data.topCourse;
        recentlyAdded.value = response.data.recentlyAdded;
        featured.value = response.data.featured;
        programs.value = response.data.programs;
        advancedPrograms.value = response.data.advancedPrograms;
        continueWatching.value = response.data.continueWatching;
        counts.value = response.counts;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch landing data';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Retry function for error handling
  void retry() {
    fetchLandingData();
  }

  // Helper methods
  bool get hasFeaturedPrograms => featured.isNotEmpty;
  bool get hasTopCourses => topCourse.isNotEmpty;
  bool get hasPrograms => programs.isNotEmpty;
  bool get hasContinueWatching => continueWatching.isNotEmpty;

  // Get programs by type for display
  List<ProgramModel> get suggestionsForYou => featured.take(5).toList();
  List<ProgramModel> get topCourses => topCourse.take(5).toList();
}
