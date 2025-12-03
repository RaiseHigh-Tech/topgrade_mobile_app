import 'package:get/get.dart';
import '../../data/model/program_details_response_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';
import '../../../utils/helpers/snackbars.dart';

class CourseDetailsController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = true.obs;
  var programDetails = Rx<ProgramDetailsResponseModel?>(null);
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Arguments from navigation
  late int programId;

  @override
  void onInit() {
    super.onInit();

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      programId = args['programId'] ?? 0;

      if (programId > 0) {
        fetchProgramDetails();
      } else {
        hasError.value = true;
        errorMessage.value = 'Invalid program ID';
        isLoading.value = false;
      }
    } else {
      hasError.value = true;
      errorMessage.value = 'Program details not found';
      isLoading.value = false;
    }
  }

  Future<void> fetchProgramDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getProgramDetails(
        programId: programId,
      );

      if (response.success) {
        programDetails.value = response;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch program details';
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
    fetchProgramDetails();
  }

  // Helper methods
  bool get hasData => programDetails.value != null;
  ProgramDetailsModel? get program => programDetails.value?.program;
  SyllabusModel? get syllabus => programDetails.value?.syllabus;
  bool get isBookmarked => program?.isBookmarked ?? false;
  bool get hasProgramRequested => program?.hasProgramRequested ?? false;

  // Get static skills data (will be replaced with API data later)
  List<String> get staticSkills => [
    'Typography',
    'Grid Systems',
    'Color Theory',
    'Visual Hierarchy',
    'Brand Identity',
  ];

  // Request access related variables
  var isRequestingAccess = false.obs;

  // Request program access method
  Future<void> requestProgramAccess() async {
    try {
      isRequestingAccess.value = true;

      final response = await _remoteSource.requestProgramAccess(
        programId: programId,
      );

      if (response.success) {
        // Show success message from API
        Snackbars.successSnackBar(
          response.message,
          duration: const Duration(seconds: 3),
        );
        
        // Refresh program details to update the request status
        await fetchProgramDetails();
      }
    } catch (e) {
      // Show error message
      Snackbars.errorSnackBar(
        e.toString(),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isRequestingAccess.value = false;
    }
  }

  // Calculate total lectures count from syllabus
  String get totalLecturesText {
    final syllabusData = syllabus;
    if (syllabusData == null) return '0 Lectures';

    final totalTopics = syllabusData.totalTopics;
    return '$totalTopics Lecture${totalTopics != 1 ? 's' : ''}';
  }

  // Description expansion state
  var isDescriptionExpanded = false.obs;

  void toggleDescriptionExpansion() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
}
