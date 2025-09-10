/// Area of Interest Response Model
/// Model for handling area of interest API responses

class AreaOfInterestResponseModel {
  final bool success;
  final String message;
  final String? areaOfIntrest;

  AreaOfInterestResponseModel({
    required this.success,
    required this.message,
    this.areaOfIntrest,
  });

  /// Factory method to create AreaOfInterestResponseModel from JSON
  factory AreaOfInterestResponseModel.fromJson(Map<String, dynamic> json) {
    return AreaOfInterestResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      areaOfIntrest: json['area_of_intrest'],
    );
  }

  /// Convert AreaOfInterestResponseModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'success': success,
      'message': message,
    };
    
    if (areaOfIntrest != null) data['area_of_intrest'] = areaOfIntrest;
    
    return data;
  }

  /// Check if this is a successful area of interest update response
  bool get isUpdateSuccess => success;

  @override
  String toString() {
    return 'AreaOfInterestResponseModel(success: $success, message: $message, areaOfIntrest: $areaOfIntrest)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaOfInterestResponseModel &&
        other.success == success &&
        other.message == message &&
        other.areaOfIntrest == areaOfIntrest;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        areaOfIntrest.hashCode;
  }
}