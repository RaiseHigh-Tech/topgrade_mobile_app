import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';

class MyLearningPage extends StatelessWidget {
  const MyLearningPage({super.key});

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
                // Header
                Text(
                  'My Learning',
                  style: TextStyle(
                    fontSize: XSizes.textSize3xl,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: XSizes.spacingSm),
                Text(
                  'Continue your learning journey',
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    fontFamily: XFonts.lexend,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Progress Overview
                Container(
                  padding: EdgeInsets.all(XSizes.paddingLg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeController.primaryColor,
                        themeController.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Progress',
                        style: TextStyle(
                          fontSize: XSizes.textSizeXl,
                          fontFamily: XFonts.lexend,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      Text(
                        '3 courses in progress',
                        style: TextStyle(
                          fontSize: XSizes.textSizeMd,
                          fontFamily: XFonts.lexend,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      Text(
                        '65% Complete',
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontFamily: XFonts.lexend,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Enrolled Courses
                Text(
                  'Enrolled Courses',
                  style: TextStyle(
                    fontSize: XSizes.textSize2xl,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: XSizes.spacingMd),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: XSizes.spacingMd),
                        padding: EdgeInsets.all(XSizes.paddingMd),
                        decoration: BoxDecoration(
                          color: themeController.backgroundColor,
                          borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: themeController.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                                  ),
                                  child: Icon(
                                    Icons.book_outlined,
                                    color: themeController.primaryColor,
                                    size: XSizes.iconSizeMd,
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
                                      Text(
                                        'Lesson ${index + 2} of 10',
                                        style: TextStyle(
                                          fontSize: XSizes.textSizeSm,
                                          fontFamily: XFonts.lexend,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(index + 1) * 20}%',
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeMd,
                                    fontFamily: XFonts.lexend,
                                    color: themeController.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: XSizes.spacingMd),
                            LinearProgressIndicator(
                              value: (index + 1) * 0.2,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(themeController.primaryColor),
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