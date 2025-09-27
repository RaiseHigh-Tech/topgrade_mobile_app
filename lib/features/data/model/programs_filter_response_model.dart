import 'program_model.dart';

class ProgramsFilterResponseModel {
  final bool success;
  final FiltersAppliedModel filtersApplied;
  final StatisticsModel statistics;
  final List<ProgramModel> programs;

  ProgramsFilterResponseModel({
    required this.success,
    required this.filtersApplied,
    required this.statistics,
    required this.programs,
  });

  factory ProgramsFilterResponseModel.fromJson(Map<String, dynamic> json) {
    return ProgramsFilterResponseModel(
      success: json['success'] ?? false,
      filtersApplied: FiltersAppliedModel.fromJson(json['filters_applied'] ?? {}),
      statistics: StatisticsModel.fromJson(json['statistics'] ?? {}),
      programs: (json['programs'] as List<dynamic>?)
              ?.map((item) => ProgramModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class FiltersAppliedModel {
  final String? programType;
  final String? categoryId;
  final bool? isBestSeller;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  FiltersAppliedModel({
    this.programType,
    this.categoryId,
    this.isBestSeller,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.search,
    this.sortBy,
    this.sortOrder,
  });

  factory FiltersAppliedModel.fromJson(Map<String, dynamic> json) {
    return FiltersAppliedModel(
      programType: json['program_type'],
      categoryId: json['category_id']?.toString(),
      isBestSeller: json['is_best_seller'],
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      minRating: json['min_rating']?.toDouble(),
      search: json['search'],
      sortBy: json['sort_by'],
      sortOrder: json['sort_order'],
    );
  }
}

class StatisticsModel {
  final int totalCount;
  final int regularProgramsCount;
  final int advancedProgramsCount;

  StatisticsModel({
    required this.totalCount,
    required this.regularProgramsCount,
    required this.advancedProgramsCount,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalCount: json['total_count'] ?? 0,
      regularProgramsCount: json['regular_programs_count'] ?? 0,
      advancedProgramsCount: json['advanced_programs_count'] ?? 0,
    );
  }
}