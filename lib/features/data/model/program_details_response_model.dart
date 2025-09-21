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
  final bool isFreeTrail;
  final bool isIntro;
  final bool isLocked;
  final String videoUrl;

  TopicModel({
    required this.id,
    required this.topicTitle,
    required this.isFreeTrail,
    required this.isIntro,
    required this.isLocked,
    required this.videoUrl,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? 0,
      topicTitle: json['topic_title'] ?? '',
      isFreeTrail: json['is_free_trail'] ?? false,
      isIntro: json['is_intro'] ?? false,
      isLocked: json['is_locked'] ?? false,
      videoUrl: json['video_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_title': topicTitle,
      'is_free_trail': isFreeTrail,
      'is_intro': isIntro,
      'is_locked': isLocked,
      'video_url': videoUrl,
    };
  }
}