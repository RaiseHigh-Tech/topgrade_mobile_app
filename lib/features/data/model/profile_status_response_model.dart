class ProfileStatusResponseModel {
  final bool hasEmail;
  final bool hasName;
  final bool hasAreaOfInterest;
  final bool isProfileComplete;
  final UserData? user;

  ProfileStatusResponseModel({
    required this.hasEmail,
    required this.hasName,
    required this.hasAreaOfInterest,
    required this.isProfileComplete,
    this.user,
  });

  factory ProfileStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatusResponseModel(
      hasEmail: json['hasEmail'] ?? false,
      hasName: json['hasName'] ?? false,
      hasAreaOfInterest: json['hasAreaOfInterest'] ?? false,
      isProfileComplete: json['isProfileComplete'] ?? false,
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasEmail': hasEmail,
      'hasName': hasName,
      'hasAreaOfInterest': hasAreaOfInterest,
      'isProfileComplete': isProfileComplete,
      'user': user?.toJson(),
    };
  }
}

class UserData {
  final String email;
  final String fullname;
  final String phoneNumber;
  final String areaOfIntrest;

  UserData({
    required this.email,
    required this.fullname,
    required this.phoneNumber,
    required this.areaOfIntrest,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
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
