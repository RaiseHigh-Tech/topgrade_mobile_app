import 'package:get/get.dart';
import '../../data/model/program_details_response_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class CourseDetailsController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = true.obs;
  var programDetails = Rx<ProgramDetailsResponseModel?>(null);
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // Arguments from navigation
  late String programType;
  late int programId;

  @override
  void onInit() {
    super.onInit();

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      programType = args['programType'] ?? 'program';
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
        programType: programType,
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


  // Get static skills data (will be replaced with API data later)
  List<String> get staticSkills => [
    'Typography',
    'Grid Systems',
    'Color Theory',
    'Visual Hierarchy',
    'Brand Identity',
  ];

  // Get static reviews data (will be replaced with API data later)
  List<ReviewModel> get staticReviews => [
    ReviewModel(
      id: 1,
      userName: 'Sarah Johnson',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108755-2616b612b593?w=150&h=150&fit=crop&crop=face',
      rating: 5.0,
      reviewText:
          'Excellent course! The instructor explains complex typography concepts in a very clear and practical way.',
      reviewDate: DateTime.now().subtract(Duration(days: 7)),
    ),
    ReviewModel(
      id: 2,
      userName: 'Michael Chen',
      userAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      rating: 4.5,
      reviewText:
          'Great content and hands-on projects. Really helped me improve my design skills.',
      reviewDate: DateTime.now().subtract(Duration(days: 14)),
    ),
    ReviewModel(
      id: 3,
      userName: 'Emily Rodriguez',
      userAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      rating: 5.0,
      reviewText:
          'The best typography course I\'ve taken. Highly recommend for both beginners and advanced designers.',
      reviewDate: DateTime.now().subtract(Duration(days: 21)),
    ),
  ];
}

// Static review model for demo purposes
class ReviewModel {
  final int id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String reviewText;
  final DateTime reviewDate;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
  });
}
