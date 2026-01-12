import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:topgrade/utils/helpers/snackbars.dart';
import '../../data/model/notification_response_model.dart';
import '../../data/source/remote_source.dart';
import '../../../utils/network/dio_client.dart';

class NotificationController extends GetxController {
  final RemoteSource _remoteSource = RemoteSourceImpl(dio: DioClient());
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Observable variables
  var isLoading = true.obs;
  var notifications = <NotificationModel>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var unreadCount = 0.obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  // Pagination
  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
    fetchNotifications();
    fetchUnreadCount();
  }

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initializeNotifications() async {
    try {
      // Request notification permissions
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await registerFcmToken(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          registerFcmToken(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background message taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check for initial message (app opened from terminated state)
        RemoteMessage? initialMessage =
            await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      } else {
        debugPrint('User declined or has not accepted notification permission');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'topgrade_notifications',
        'TopGrade Notifications',
        description: 'Notifications from TopGrade',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle foreground messages - show local notification
  void _handleForegroundMessage(RemoteMessage message) {

    // Refresh notification list and unread count
    fetchNotifications(refresh: true);
    fetchUnreadCount();

    // Show local notification
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'topgrade_notifications',
      'TopGrade Notifications',
      channelDescription: 'Notifications from TopGrade',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/notification_logo'),
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('@drawable/notification_logo'),
        hideExpandedLargeIcon: false,
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'TopGrade',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {

    final notificationType = message.data['notification_type'] ?? '';
    final notificationId = message.data['notification_id'];

    // Mark as read if notification_id is present
    if (notificationId != null) {
      markNotificationAsRead(int.tryParse(notificationId.toString()) ?? 0);
    }

    // Navigate based on notification type
    _navigateBasedOnType(notificationType, message.data);
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    // You can parse the payload and navigate accordingly
  }

  /// Navigate based on notification type
  void _navigateBasedOnType(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'program':
        final programId = data['program_id'];
        if (programId != null) {
          Get.toNamed('/course-details', arguments: {'programId': programId});
        }
        break;
      case 'certificate':
        // Navigate to certificates page
        break;
      case 'enrollment':
        // Navigate to my learnings
        Get.toNamed('/home');
        break;
      default:
        // Navigate to notifications page
        Get.toNamed('/home');
        break;
    }
  }

  /// Register FCM token with backend
  Future<void> registerFcmToken(String token) async {
    try {
      final deviceType = Platform.isAndroid ? 'android' : 'ios';
      final response = await _remoteSource.registerFcmToken(
        token: token,
        deviceType: deviceType,
      );

      if (response['success'] == true) {
        debugPrint('FCM token registered successfully');
      }
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  /// Fetch notifications with pagination
  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isLoading.value = true;
      } else {
        if (!hasMore.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final offset = (currentPage.value - 1) * _limit;
      final response = await _remoteSource.getNotifications(
        limit: _limit,
        offset: offset,
      );

      if (response.success) {
        if (refresh) {
          notifications.value = response.notifications;
        } else {
          notifications.addAll(response.notifications);
        }

        // Update unread count from response
        unreadCount.value = response.unreadCount;

        // Check if there are more notifications
        hasMore.value = response.hasMore;
        if (response.notifications.isNotEmpty) {
          currentPage.value++;
        }
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to fetch notifications';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Calculate unread count from local notifications
  void fetchUnreadCount() {
    // Calculate unread count from loaded notifications
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _remoteSource.markNotificationAsRead(
        notificationId: notificationId,
      );

      if (response['success'] == true) {
        // Update local notification state
        final index = notifications
            .indexWhere((notification) => notification.id == notificationId);
        if (index != -1) {
          final notification = notifications[index];
          notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            notificationType: notification.notificationType,
            imageUrl: notification.imageUrl,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            readAt: DateTime.now(),
          );
          notifications.refresh();
        }

        // Update unread count locally
        unreadCount.value--;
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _remoteSource.markAllNotificationsAsRead();

      if (response['success'] == true) {
        // Update all local notifications to read
        notifications.value = notifications.map((notification) {
          return NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            notificationType: notification.notificationType,
            imageUrl: notification.imageUrl,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            readAt: DateTime.now(),
          );
        }).toList();

        unreadCount.value = 0;
        Snackbars.successSnackBar('All notifications marked as read');
      }
    } catch (e) {
      Snackbars.errorSnackBar('Failed to mark all as read: ${e.toString()}');
    }
  }

  /// Delete FCM token (on logout)
  Future<void> deleteFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _remoteSource.deleteFcmToken(token: token);
      }
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Retry function for error handling
  void retry() {
    fetchNotifications(refresh: true);
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
    fetchUnreadCount();
  }

  /// Load more notifications
  Future<void> loadMoreNotifications() async {
    await fetchNotifications();
  }

  /// Helper methods
  bool get hasNotifications => notifications.isNotEmpty;
  bool get hasUnreadNotifications => unreadCount.value > 0;
}
