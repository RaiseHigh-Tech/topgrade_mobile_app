class RequestAccessResponseModel {
  final bool success;
  final String message;

  RequestAccessResponseModel({
    required this.success,
    required this.message,
  });

  factory RequestAccessResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestAccessResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
