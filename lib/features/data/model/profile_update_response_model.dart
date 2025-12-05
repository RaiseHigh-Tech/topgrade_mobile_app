class ProfileUpdateResponseModel {
  final bool success;
  final String message;
  final bool hasAreaOfInterest;
  final UserProfileData? user;

  ProfileUpdateResponseModel({
    required this.success,
    required this.message,
    required this.hasAreaOfInterest,
    this.user,
  });

  factory ProfileUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      hasAreaOfInterest: json['hasAreaOfInterest'] ?? false,
      user: json['user'] != null ? UserProfileData.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'hasAreaOfInterest': hasAreaOfInterest,
      'user': user?.toJson(),
    };
  }
}

class UserProfileData {
  final String email;
  final String fullname;
  final String phoneNumber;
  final String areaOfIntrest;

  UserProfileData({
    required this.email,
    required this.fullname,
    required this.phoneNumber,
    required this.areaOfIntrest,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      areaOfIntrest: json['area_of_intrest'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullname': fullname,
      'phone_number': phoneNumber,
      'area_of_intrest': areaOfIntrest,
    };
  }
}
