import 'package:get/get.dart';
import '../../data/model/my_learnings_response_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class MyLearningsController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = true.obs;
  var allLearnings = <LearningModel>[].obs;
  var inProgressLearnings = <LearningModel>[].obs;
  var completedLearnings = <LearningModel>[].obs;
  var statistics =
      StatisticsModel(
        totalCourses: 0,
        completedCourses: 0,
        inProgressCourses: 0,
        completionRate: 0.0,
      ).obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllLearnings();
  }

  Future<void> fetchAllLearnings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getMyLearnings();

      if (response.success) {
        allLearnings.value = response.learnings;
        statistics.value = response.statistics;

        // Filter learnings by status
        inProgressLearnings.value =
            response.learnings
                .where((learning) => learning.progress.isInProgress)
                .toList();

        completedLearnings.value =
            response.learnings
                .where((learning) => learning.progress.isCompleted)
                .toList();
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch learnings';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInProgressLearnings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getMyLearnings(status: 'onprogress');

      if (response.success) {
        inProgressLearnings.value = response.learnings;
        statistics.value = response.statistics;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch in-progress learnings';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompletedLearnings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getMyLearnings(status: 'completed');

      if (response.success) {
        completedLearnings.value = response.learnings;
        statistics.value = response.statistics;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch completed learnings';
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
    fetchAllLearnings();
  }

  // Helper methods
  bool get hasLearnings => allLearnings.isNotEmpty;
  bool get hasInProgressLearnings => inProgressLearnings.isNotEmpty;
  bool get hasCompletedLearnings => completedLearnings.isNotEmpty;

  // Refresh learnings
  Future<void> refreshLearnings() async {
    await fetchAllLearnings();
  }

  // Get learnings by status
  List<LearningModel> getLearningsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'onprogress':
      case 'in progress':
        return inProgressLearnings;
      case 'completed':
        return completedLearnings;
      default:
        return allLearnings;
    }
  }
}
