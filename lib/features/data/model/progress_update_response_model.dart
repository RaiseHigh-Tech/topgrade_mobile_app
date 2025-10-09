class ProgressUpdateResponseModel {
  final bool success;
  final String message;
  final TopicProgressModel topicProgress;
  final CourseProgressModel courseProgress;

  ProgressUpdateResponseModel({
    required this.success,
    required this.message,
    required this.topicProgress,
    required this.courseProgress,
  });

  factory ProgressUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return ProgressUpdateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      topicProgress: TopicProgressModel.fromJson(json['topic_progress'] ?? {}),
      courseProgress: CourseProgressModel.fromJson(json['course_progress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'topic_progress': topicProgress.toJson(),
      'course_progress': courseProgress.toJson(),
    };
  }
}

class TopicProgressModel {
  final int topicId;
  final String topicTitle;
  final String status;
  final double completionPercentage;
  final int watchTimeSeconds;
  final int totalDurationSeconds;
  final bool isCompleted;
  final String lastWatchedAt;

  TopicProgressModel({
    required this.topicId,
    required this.topicTitle,
    required this.status,
    required this.completionPercentage,
    required this.watchTimeSeconds,
    required this.totalDurationSeconds,
    required this.isCompleted,
    required this.lastWatchedAt,
  });

  factory TopicProgressModel.fromJson(Map<String, dynamic> json) {
    return TopicProgressModel(
      topicId: json['topic_id'] ?? 0,
      topicTitle: json['topic_title'] ?? '',
      status: json['status'] ?? '',
      completionPercentage: (json['completion_percentage'] ?? 0.0).toDouble(),
      watchTimeSeconds: json['watch_time_seconds'] ?? 0,
      totalDurationSeconds: json['total_duration_seconds'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      lastWatchedAt: json['last_watched_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic_id': topicId,
      'topic_title': topicTitle,
      'status': status,
      'completion_percentage': completionPercentage,
      'watch_time_seconds': watchTimeSeconds,
      'total_duration_seconds': totalDurationSeconds,
      'is_completed': isCompleted,
      'last_watched_at': lastWatchedAt,
    };
  }
}

class CourseProgressModel {
  final double completionPercentage;
  final int completedTopics;
  final int inProgressTopics;
  final int totalTopics;
  final bool isCompleted;
  final int totalWatchTimeSeconds;

  CourseProgressModel({
    required this.completionPercentage,
    required this.completedTopics,
    required this.inProgressTopics,
    required this.totalTopics,
    required this.isCompleted,
    required this.totalWatchTimeSeconds,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      completionPercentage: (json['completion_percentage'] ?? 0.0).toDouble(),
      completedTopics: json['completed_topics'] ?? 0,
      inProgressTopics: json['in_progress_topics'] ?? 0,
      totalTopics: json['total_topics'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      totalWatchTimeSeconds: json['total_watch_time_seconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completion_percentage': completionPercentage,
      'completed_topics': completedTopics,
      'in_progress_topics': inProgressTopics,
      'total_topics': totalTopics,
      'is_completed': isCompleted,
      'total_watch_time_seconds': totalWatchTimeSeconds,
    };
  }
}