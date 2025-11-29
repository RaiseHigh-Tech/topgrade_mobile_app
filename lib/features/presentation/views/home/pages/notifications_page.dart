import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../../data/model/notification_response_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationController _notificationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _notificationController = Get.put(NotificationController());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _notificationController.loadMoreNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<XThemeController>();

    return Scaffold(
      backgroundColor: themeController.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(XSizes.paddingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: XSizes.textSizeXl,
                          fontWeight: FontWeight.bold,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor,
                        ),
                      ),
                      SizedBox(width: XSizes.spacingSm),
                      Obx(() {
                        if (_notificationController.unreadCount.value > 0) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_notificationController.unreadCount.value}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: XFonts.lexend,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  Obx(() {
                    if (_notificationController.hasUnreadNotifications) {
                      return TextButton(
                        onPressed: _notificationController.markAllAsRead,
                        child: Text(
                          'Mark all read',
                          style: TextStyle(
                            fontSize: XSizes.textSizeSm,
                            fontFamily: XFonts.lexend,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Obx(() {
                if (_notificationController.isLoading.value &&
                    _notificationController.notifications.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_notificationController.hasError.value) {
                  return RefreshIndicator(
                    onRefresh: _notificationController.refreshNotifications,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: themeController.textColor.withOpacity(0.3),
                              ),
                              SizedBox(height: XSizes.spacingMd),
                              Text(
                                'Failed to load notifications',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeMd,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor,
                                ),
                              ),
                              SizedBox(height: XSizes.spacingSm),
                              ElevatedButton(
                                onPressed: _notificationController.retry,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (!_notificationController.hasNotifications) {
                  return RefreshIndicator(
                    onRefresh: _notificationController.refreshNotifications,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 80,
                                color: themeController.textColor.withOpacity(0.3),
                              ),
                              SizedBox(height: XSizes.spacingLg),
                              Text(
                                'No Notifications Yet',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeLg,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor,
                                ),
                              ),
                              SizedBox(height: XSizes.spacingSm),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: XSizes.paddingXl),
                                child: Text(
                                  'Pull down to refresh',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeSm,
                                    fontFamily: XFonts.lexend,
                                    color: themeController.textColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _notificationController.refreshNotifications,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: XSizes.paddingMd,
                      vertical: XSizes.paddingSm,
                    ),
                    itemCount: _notificationController.notifications.length +
                        (_notificationController.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index ==
                          _notificationController.notifications.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(XSizes.paddingMd),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final notification =
                          _notificationController.notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        themeController: themeController,
                        onTap: () {
                          _notificationController
                              .markNotificationAsRead(notification.id);
                          _handleNotificationTap(notification);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    final type = notification.notificationType;
    final data = notification.data ?? {};

    switch (type) {
      case 'program':
        final programId = data['program_id'];
        if (programId != null) {
          Get.toNamed('/course-details', arguments: {'programId': programId});
        }
        break;
      case 'enrollment':
        // Navigate to my learnings
        break;
      default:
        // Do nothing or show details
        break;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final XThemeController themeController;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.themeController,
    required this.onTap,
  });

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'program':
        return Icons.school_rounded;
      case 'certificate':
        return Icons.workspace_premium_rounded;
      case 'enrollment':
        return Icons.check_circle_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'promotional':
        return Icons.local_offer_rounded;
      case 'system':
        return Icons.settings_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'program':
        return Colors.blue;
      case 'certificate':
        return Colors.amber;
      case 'enrollment':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'promotional':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildNotificationImage(NotificationModel notification, Color color) {
    // Build icon container as fallback
    final iconContainer = Container(
      width: 60,
      height: 60,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getNotificationIcon(notification.notificationType),
        color: color,
        size: 24,
      ),
    );

    // Check if image URL is valid
    if (notification.imageUrl == null || notification.imageUrl!.isEmpty) {
      return iconContainer; // Use type-based icon
    }

    final imageUrl = notification.imageUrl!.trim();
    
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return iconContainer;
    }

    // Use Image.network to load notification image
    return Container(
      width: 60,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Image load error for ${notification.id}: $error');
            return iconContainer; // Use type-based icon on error
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor(notification.notificationType);
    final timeAgo = timeago.format(notification.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: XSizes.spacingMd),
      decoration: BoxDecoration(
        color: notification.isRead
            ? themeController.backgroundColor
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? themeController.backgroundColor
              : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(XSizes.paddingSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon or Image (no app logo)
                _buildNotificationImage(notification, color),
                SizedBox(width: XSizes.spacingMd),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: XSizes.textSizeMd,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontFamily: XFonts.lexend,
                                color: themeController.textColor,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: XSizes.spacingXs),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: XSizes.spacingXs),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: XSizes.textSizeXs,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
