import 'program_model.dart';

class LandingResponseModel {
  final bool success;
  final LandingDataModel data;
  final LandingCountsModel counts;

  LandingResponseModel({
    required this.success,
    required this.data,
    required this.counts,
  });

  factory LandingResponseModel.fromJson(Map<String, dynamic> json) {
    return LandingResponseModel(
      success: json['success'] ?? false,
      data: LandingDataModel.fromJson(json['data'] ?? {}),
      counts: LandingCountsModel.fromJson(json['counts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'counts': counts.toJson(),
    };
  }
}

class LandingCountsModel {
  final int topCourse;
  final int recentlyAdded;
  final int featured;
  final int programs;
  final int advancedPrograms;
  final int continueWatching;

  LandingCountsModel({
    required this.topCourse,
    required this.recentlyAdded,
    required this.featured,
    required this.programs,
    required this.advancedPrograms,
    required this.continueWatching,
  });

  factory LandingCountsModel.fromJson(Map<String, dynamic> json) {
    return LandingCountsModel(
      topCourse: json['top_course'] ?? 0,
      recentlyAdded: json['recently_added'] ?? 0,
      featured: json['featured'] ?? 0,
      programs: json['programs'] ?? 0,
      advancedPrograms: json['advanced_programs'] ?? 0,
      continueWatching: json['continue_watching'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_course': topCourse,
      'recently_added': recentlyAdded,
      'featured': featured,
      'programs': programs,
      'advanced_programs': advancedPrograms,
      'continue_watching': continueWatching,
    };
  }
}

class LandingDataModel {
  final List<ProgramModel> topCourse;
  final List<ProgramModel> recentlyAdded;
  final List<ProgramModel> featured;
  final List<ProgramModel> programs;
  final List<ProgramModel> advancedPrograms;
  final List<ProgramModel> continueWatching;

  LandingDataModel({
    required this.topCourse,
    required this.recentlyAdded,
    required this.featured,
    required this.programs,
    required this.advancedPrograms,
    required this.continueWatching,
  });

  factory LandingDataModel.fromJson(Map<String, dynamic> json) {
    return LandingDataModel(
      topCourse: (json['top_course'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
      recentlyAdded: (json['recently_added'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
      featured: (json['featured'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
      programs: (json['programs'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
      advancedPrograms: (json['advanced_programs'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
      continueWatching: (json['continue_watching'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_course': topCourse.map((program) => program.toJson()).toList(),
      'recently_added': recentlyAdded.map((program) => program.toJson()).toList(),
      'featured': featured.map((program) => program.toJson()).toList(),
      'programs': programs.map((program) => program.toJson()).toList(),
      'advanced_programs': advancedPrograms.map((program) => program.toJson()).toList(),
      'continue_watching': continueWatching.map((program) => program.toJson()).toList(),
    };
  }
}

class LandingStatsModel {
  final int totalPrograms;
  final int totalStudents;
  final int totalInstructors;
  final double averageRating;

  LandingStatsModel({
    required this.totalPrograms,
    required this.totalStudents,
    required this.totalInstructors,
    required this.averageRating,
  });

  factory LandingStatsModel.fromJson(Map<String, dynamic> json) {
    return LandingStatsModel(
      totalPrograms: json['total_programs'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
      totalInstructors: json['total_instructors'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_programs': totalPrograms,
      'total_students': totalStudents,
      'total_instructors': totalInstructors,
      'average_rating': averageRating,
    };
  }
}