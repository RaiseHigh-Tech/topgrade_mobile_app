import 'categories_response_model.dart';

class ProgramModel {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String description;
  final CategoryModel? category;
  final String image;
  final String duration;
  final double programRating;
  final bool isBestSeller;
  final bool isBookmarked;
  final int enrolledStudents;
  final PricingModel pricing;
  final ProgressModel? progress;

  ProgramModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    this.category,
    required this.image,
    required this.duration,
    required this.programRating,
    required this.isBestSeller,
    required this.isBookmarked,
    required this.enrolledStudents,
    required this.pricing,
    this.progress,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] != null 
          ? CategoryModel.fromJson(json['category']) 
          : null,
      image: json['image'] ?? '',
      duration: json['duration'] ?? '',
      programRating: (json['program_rating'] ?? 0.0).toDouble(),
      isBestSeller: json['is_best_seller'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      enrolledStudents: json['enrolled_students'] ?? 0,
      pricing: PricingModel.fromJson(json['pricing'] ?? {}),
      progress: json['progress'] != null 
          ? ProgressModel.fromJson(json['progress']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'category': category?.toJson(),
      'image': image,
      'duration': duration,
      'program_rating': programRating,
      'is_best_seller': isBestSeller,
      'is_bookmarked': isBookmarked,
      'enrolled_students': enrolledStudents,
      'pricing': pricing.toJson(),
      'progress': progress?.toJson(),
    };
  }
}

class PricingModel {
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;
  final double savings;

  PricingModel({
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.savings,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      originalPrice: (json['original_price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0.0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0.0).toDouble(),
      savings: (json['savings'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'discounted_price': discountedPrice,
      'savings': savings,
    };
  }

  bool get isFree => originalPrice == 0.0 && discountedPrice == 0.0;
  
  double get finalPrice => discountedPrice > 0 ? discountedPrice : originalPrice;
}

class ProgressModel {
  final double percentage;
  final String status;
  final String? lastWatchedAt;
  final String? lastWatchedTopic;
  final int? completedTopics;
  final int? totalTopics;

  ProgressModel({
    required this.percentage,
    required this.status,
    this.lastWatchedAt,
    this.lastWatchedTopic,
    this.completedTopics,
    this.totalTopics,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      lastWatchedAt: json['last_watched_at'],
      lastWatchedTopic: json['last_watched_topic'],
      completedTopics: json['completed_topics'],
      totalTopics: json['total_topics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'status': status,
      'last_watched_at': lastWatchedAt,
      'last_watched_topic': lastWatchedTopic,
      'completed_topics': completedTopics,
      'total_topics': totalTopics,
    };
  }

  bool get isCompleted => percentage >= 100.0;
  bool get isInProgress => percentage > 0.0 && percentage < 100.0;
  bool get isNotStarted => percentage == 0.0;
}