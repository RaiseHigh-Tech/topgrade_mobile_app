import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(XSizes.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Good Morning!',
                      style: TextStyle(
                        fontSize: XSizes.textSize3xl,
                        fontFamily: XFonts.lexend,
                        color: themeController.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Notification action
                      },
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: themeController.textColor,
                        size: XSizes.iconSizeLg,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: XSizes.spacingSm),
                Text(
                  'What would you like to learn today?',
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    fontFamily: XFonts.lexend,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Search Bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: XSizes.paddingMd,
                    vertical: XSizes.paddingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: XSizes.iconSizeMd,
                      ),
                      SizedBox(width: XSizes.spacingSm),
                      Expanded(
                        child: Text(
                          'Search courses...',
                          style: TextStyle(
                            fontSize: XSizes.textSizeMd,
                            fontFamily: XFonts.lexend,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Featured Section
                Text(
                  'Featured Courses',
                  style: TextStyle(
                    fontSize: XSizes.textSize2xl,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: XSizes.spacingMd),
                
                // Course Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: XSizes.spacingMd),
                        padding: EdgeInsets.all(XSizes.paddingMd),
                        decoration: BoxDecoration(
                          color: themeController.backgroundColor,
                          borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: themeController.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                              ),
                              child: Icon(
                                Icons.play_circle_outline,
                                color: themeController.primaryColor,
                                size: XSizes.iconSizeLg,
                              ),
                            ),
                            SizedBox(width: XSizes.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Course ${index + 1}',
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeLg,
                                      fontFamily: XFonts.lexend,
                                      color: themeController.textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: XSizes.spacingXs),
                                  Text(
                                    'Learn the fundamentals',
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeSm,
                                      fontFamily: XFonts.lexend,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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