class AreaOfInterestResponseModel {
  final bool success;
  final String message;
  final String? areaOfIntrest;

  AreaOfInterestResponseModel({
    required this.success,
    required this.message,
    this.areaOfIntrest,
  });

  factory AreaOfInterestResponseModel.fromJson(Map<String, dynamic> json) {
    return AreaOfInterestResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      areaOfIntrest: json['area_of_intrest'],
    );
  }

  bool get isUpdateSuccess => success;
}
