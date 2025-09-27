import 'program_model.dart';

class MyLearningsResponseModel {
  final bool success;
  final StatisticsModel statistics;
  final String? filterApplied;
  final List<LearningModel> learnings;

  MyLearningsResponseModel({
    required this.success,
    required this.statistics,
    this.filterApplied,
    required this.learnings,
  });

  factory MyLearningsResponseModel.fromJson(Map<String, dynamic> json) {
    return MyLearningsResponseModel(
      success: json['success'] ?? false,
      statistics: StatisticsModel.fromJson(json['statistics'] ?? {}),
      filterApplied: json['filter_applied'],
      learnings: (json['learnings'] as List<dynamic>?)
          ?.map((item) => LearningModel.fromJson(item))
          .toList() ?? [],
    );
  }
}

class StatisticsModel {
  final int totalCourses;
  final int completedCourses;
  final int inProgressCourses;
  final double completionRate;

  StatisticsModel({
    required this.totalCourses,
    required this.completedCourses,
    required this.inProgressCourses,
    required this.completionRate,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalCourses: json['total_courses'] ?? 0,
      completedCourses: json['completed_courses'] ?? 0,
      inProgressCourses: json['in_progress_courses'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
    );
  }
}

class LearningModel {
  final int purchaseId;
  final ProgramModel program;
  final DateTime purchaseDate;
  final ProgressModel progress;

  LearningModel({
    required this.purchaseId,
    required this.program,
    required this.purchaseDate,
    required this.progress,
  });

  factory LearningModel.fromJson(Map<String, dynamic> json) {
    return LearningModel(
      purchaseId: json['purchase_id'] ?? 0,
      program: ProgramModel.fromJson(json['program'] ?? {}),
      purchaseDate: DateTime.tryParse(json['purchase_date'] ?? '') ?? DateTime.now(),
      progress: ProgressModel.fromJson(json['progress'] ?? {}),
    );
  }
}

class ProgressModel {
  final double percentage;
  final String status;
  final int completedModules;
  final int totalModules;
  final String estimatedCompletion;

  ProgressModel({
    required this.percentage,
    required this.status,
    required this.completedModules,
    required this.totalModules,
    required this.estimatedCompletion,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      completedModules: json['completed_modules'] ?? 0,
      totalModules: json['total_modules'] ?? 0,
      estimatedCompletion: json['estimated_completion'] ?? '',
    );
  }
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'onprogress';
}