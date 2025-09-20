import 'package:get/get.dart';
import '../../data/model/bookmarks_response_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class BookmarksController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());

  // Observable variables
  var isLoading = true.obs;
  var bookmarks = <BookmarkModel>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _remoteSource.getBookmarks();
      
      if (response.success) {
        bookmarks.value = response.bookmarks;
        count.value = response.count;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch bookmarks';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching bookmarks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Retry function for error handling
  void retry() {
    fetchBookmarks();
  }

  // Helper methods
  bool get hasBookmarks => bookmarks.isNotEmpty;
  
  // Refresh bookmarks
  Future<void> refreshBookmarks() async {
    await fetchBookmarks();
  }
}