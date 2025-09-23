import 'package:get/get.dart';
import 'package:flutter/material.dart';
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

  // Loading state for bookmark operations
  var isBookmarkLoading = false.obs;

  // Toggle bookmark for any program
  Future<bool> toggleBookmark({
    required String programType,
    required int programId,
    bool? currentBookmarkStatus,
  }) async {
    if (isBookmarkLoading.value) return false;

    try {
      isBookmarkLoading.value = true;

      final response =
          currentBookmarkStatus == true
              ? await _remoteSource.removeBookmark(
                programType: programType,
                programId: programId,
              )
              : await _remoteSource.addBookmark(
                programType: programType,
                programId: programId,
              );

      if (response['success'] == true) {
        await fetchBookmarks();
        return true;
      }
      return false;
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to ${currentBookmarkStatus == true ? 'remove' : 'add'} bookmark: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      isBookmarkLoading.value = false;
    }
  }

  // Check if a specific program is bookmarked
  bool isProgramBookmarked(int programId, String programType) {
    return bookmarks.any(
      (bookmark) =>
          bookmark.program.id == programId &&
          bookmark.program.type == programType,
    );
  }

  // Refresh bookmarks
  Future<void> refreshBookmarks() async {
    await fetchBookmarks();
  }
}
