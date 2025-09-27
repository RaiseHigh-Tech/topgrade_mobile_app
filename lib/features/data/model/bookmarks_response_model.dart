import 'program_model.dart';

class BookmarksResponseModel {
  final bool success;
  final int count;
  final List<BookmarkModel> bookmarks;

  BookmarksResponseModel({
    required this.success,
    required this.count,
    required this.bookmarks,
  });

  factory BookmarksResponseModel.fromJson(Map<String, dynamic> json) {
    return BookmarksResponseModel(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      bookmarks: (json['bookmarks'] as List<dynamic>?)
              ?.map((item) => BookmarkModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class BookmarkModel {
  final int bookmarkId;
  final ProgramModel program;
  final String bookmarkedDate;

  BookmarkModel({
    required this.bookmarkId,
    required this.program,
    required this.bookmarkedDate,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      bookmarkId: json['bookmark_id'] ?? 0,
      program: ProgramModel.fromJson(json['program'] ?? {}),
      bookmarkedDate: json['bookmarked_date'] ?? '',
    );
  }
}