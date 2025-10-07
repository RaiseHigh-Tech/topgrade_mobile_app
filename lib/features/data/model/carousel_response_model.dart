class CarouselResponseModel {
  final bool success;
  final List<CarouselSlide> data;
  final int totalSlides;

  CarouselResponseModel({
    required this.success,
    required this.data,
    required this.totalSlides,
  });

  factory CarouselResponseModel.fromJson(Map<String, dynamic> json) {
    return CarouselResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => CarouselSlide.fromJson(item))
              .toList() ??
          [],
      totalSlides: json['total_slides'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((slide) => slide.toJson()).toList(),
      'total_slides': totalSlides,
    };
  }
}

class CarouselSlide {
  final int id;
  final String image;

  CarouselSlide({
    required this.id,
    required this.image,
  });

  factory CarouselSlide.fromJson(Map<String, dynamic> json) {
    return CarouselSlide(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
    };
  }
}