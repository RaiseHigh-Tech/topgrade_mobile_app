import 'package:get/get.dart';
import 'my_learnings_controller.dart';
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

  // Get skills from API data
  List<String> get skills => program?.skills ?? [];

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

  // Find resume topic based on progress
  TopicModel? get resumeTopic {
    final syllabusData = syllabus;
    if (syllabusData == null || syllabusData.modules.isEmpty) return null;

    // Try to find progress in MyLearningsController
    try {
      if (Get.isRegistered<MyLearningsController>()) {
        final learningsController = Get.find<MyLearningsController>();
        final learning = learningsController.allLearnings.firstWhereOrNull(
          (l) => l.program.id == programId,
        );

        if (learning != null) {
          int completedTopicsCount = learning.progress.completedTopics;
          
          // Flatten all topics from all modules to find the exact lecture
          List<TopicModel> allTopics = [];
          for (var module in syllabusData.modules) {
            allTopics.addAll(module.topics);
          }

          if (allTopics.isNotEmpty) {
            // If completedTopicsCount is 1, we want the 2nd topic (index 1)
            // If it's already at the end, stay at the last topic
            int resumeIndex = completedTopicsCount;
            if (resumeIndex >= allTopics.length) {
              resumeIndex = allTopics.length - 1;
            }
            return allTopics[resumeIndex];
          }
        }
      }
    } catch (e) {
      // Fallback if data is missing
    }

    // Default: Return the first topic of the first module
    for (var module in syllabusData.modules) {
      if (module.topics.isNotEmpty) {
        return module.topics.first;
      }
    }
    return null;
  }

  // Description expansion state
  var isDescriptionExpanded = false.obs;

  void toggleDescriptionExpansion() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
}
