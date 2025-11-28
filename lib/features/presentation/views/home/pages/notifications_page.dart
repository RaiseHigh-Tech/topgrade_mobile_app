import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/theme_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
                ],
              ),
            ),
            // Content
            Expanded(
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
                      padding: EdgeInsets.symmetric(horizontal: XSizes.paddingXl),
                      child: Text(
                        'We\'ll notify you when something new arrives',
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
          ],
        ),
      ),
    );
  }
}
