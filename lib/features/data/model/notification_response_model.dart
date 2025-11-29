class NotificationResponseModel {
  final bool success;
  final String message;
  final List<NotificationModel> notifications;
  final int count;
  final int unreadCount;
  final bool hasMore;

  NotificationResponseModel({
    required this.success,
    this.message = '',
    required this.notifications,
    required this.count,
    required this.unreadCount,
    required this.hasMore,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final notificationsList = data['notifications'] as List<dynamic>? ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return NotificationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      notifications: notificationsList
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: pagination['total_count'] ?? 0,
      unreadCount: pagination['unread_count'] ?? 0,
      hasMore: pagination['has_more'] ?? false,
    );
  }

  // Getter for backward compatibility with pagination
  int? get next => hasMore ? 1 : null;
  int? get previous => null;
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    this.imageUrl,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? 'general',
      imageUrl: json['image_url'],
      data: json['data'] is Map ? json['data'] as Map<String, dynamic> : null,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(
        json['sent_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'image_url': imageUrl,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}

class UnreadCountResponseModel {
  final bool success;
  final int unreadCount;

  UnreadCountResponseModel({
    required this.success,
    required this.unreadCount,
  });

  factory UnreadCountResponseModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponseModel(
      success: json['success'] ?? false,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class FcmTokenResponseModel {
  final bool success;
  final String message;
  final List<FcmTokenModel>? tokens;

  FcmTokenResponseModel({
    required this.success,
    required this.message,
    this.tokens,
  });

  factory FcmTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tokens: (json['tokens'] as List<dynamic>?)
          ?.map((e) => FcmTokenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FcmTokenModel {
  final int id;
  final String token;
  final String deviceType;
  final String? deviceId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;

  FcmTokenModel({
    required this.id,
    required this.token,
    required this.deviceType,
    this.deviceId,
    required this.isActive,
    required this.createdAt,
    this.lastUsed,
  });

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      id: json['id'] ?? 0,
      token: json['token'] ?? '',
      deviceType: json['device_type'] ?? 'android',
      deviceId: json['device_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastUsed:
          json['last_used'] != null ? DateTime.parse(json['last_used']) : null,
    );
  }
}
