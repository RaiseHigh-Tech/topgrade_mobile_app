import 'categories_response_model.dart';
import 'program_model.dart';

class ProgramDetailsResponseModel {
  final bool success;
  final ProgramDetailsModel program;
  final SyllabusModel syllabus;

  ProgramDetailsResponseModel({
    required this.success,
    required this.program,
    required this.syllabus,
  });

  factory ProgramDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return ProgramDetailsResponseModel(
      success: json['success'] ?? false,
      program: ProgramDetailsModel.fromJson(json['program'] ?? {}),
      syllabus: SyllabusModel.fromJson(json['syllabus'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'program': program.toJson(),
      'syllabus': syllabus.toJson(),
    };
  }
}

class ProgramDetailsModel {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final CategoryModel category;
  final String description;
  final String image;
  final String duration;
  final double programRating;
  final bool isBestSeller;
  final bool isBookmarked;
  final int enrolledStudents;
  final PricingModel pricing;

  ProgramDetailsModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.image,
    required this.duration,
    required this.programRating,
    required this.isBestSeller,
    required this.isBookmarked,
    required this.enrolledStudents,
    required this.pricing,
  });

  factory ProgramDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProgramDetailsModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: CategoryModel.fromJson(json['category'] ?? {}),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      duration: json['duration'] ?? '',
      programRating: (json['program_rating'] ?? 0.0).toDouble(),
      isBestSeller: json['is_best_seller'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      enrolledStudents: json['enrolled_students'] ?? 0,
      pricing: PricingModel.fromJson(json['pricing'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'category': category.toJson(),
      'description': description,
      'image': image,
      'duration': duration,
      'program_rating': programRating,
      'is_best_seller': isBestSeller,
      'is_bookmarked': isBookmarked,
      'enrolled_students': enrolledStudents,
      'pricing': pricing.toJson(),
    };
  }
}

class SyllabusModel {
  final int totalModules;
  final int totalTopics;
  final List<ModuleModel> modules;

  SyllabusModel({
    required this.totalModules,
    required this.totalTopics,
    required this.modules,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      totalModules: json['total_modules'] ?? 0,
      totalTopics: json['total_topics'] ?? 0,
      modules: (json['modules'] as List<dynamic>?)
          ?.map((item) => ModuleModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_modules': totalModules,
      'total_topics': totalTopics,
      'modules': modules.map((module) => module.toJson()).toList(),
    };
  }
}

class ModuleModel {
  final int id;
  final String moduleTitle;
  final int topicsCount;
  final List<TopicModel> topics;

  ModuleModel({
    required this.id,
    required this.moduleTitle,
    required this.topicsCount,
    required this.topics,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] ?? 0,
      moduleTitle: json['module_title'] ?? '',
      topicsCount: json['topics_count'] ?? 0,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((item) => TopicModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_title': moduleTitle,
      'topics_count': topicsCount,
      'topics': topics.map((topic) => topic.toJson()).toList(),
    };
  }
}

class TopicModel {
  final int id;
  final String topicTitle;
  final String videoUrl;
  final String? videoDuration;

  TopicModel({
    required this.id,
    required this.topicTitle,
    required this.videoUrl,
    this.videoDuration,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? 0,
      topicTitle: json['topic_title'] ?? '',
      videoUrl: json['video_url'] ?? '',
      videoDuration: json['video_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_title': topicTitle,
      'video_url': videoUrl,
      'video_duration': videoDuration,

    };
  }
}