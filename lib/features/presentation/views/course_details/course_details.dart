import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:get/get.dart';
import 'package:topgrade/features/presentation/widgets/primary_button.dart';
import '../../controllers/theme_controller.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return Scaffold(
          backgroundColor: themeController.backgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            // Keep AppBar transparent
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Configure status bar to be opaque while keeping AppBar transparent
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor:
                  themeController.backgroundColor, // Opaque status bar
              statusBarIconBrightness:
                  themeController.backgroundColor == Colors.white
                      ? Brightness.dark
                      : Brightness.light, // Icon color based on background
              statusBarBrightness:
                  themeController.backgroundColor == Colors.white
                      ? Brightness.light
                      : Brightness.dark,
            ),
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: EdgeInsets.all(XSizes.spacingSm),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: EdgeInsets.only(
                    right: XSizes.paddingMd,
                    top: XSizes.spacingSm,
                    bottom: XSizes.spacingSm,
                  ),
                  padding: EdgeInsets.all(XSizes.spacingSm),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                  ),
                  child: const Icon(Icons.bookmark_border, color: Colors.white),
                ),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Fixed Header Section (Non-scrollable)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1521185496955-15097b20c5fe?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGRlc2lnbnxlbnwwfHwwfHx8MA%3D%3D',
                          height: 230,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: XSizes.iconSizeXxl,
                        ),
                      ],
                    ),
                    SizedBox(height: XSizes.spacingLg),
                    // Course Title and Info
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: XSizes.paddingMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Typography and Layout Design',
                            style: TextStyle(
                              fontSize: XSizes.textSizeXl,
                              fontWeight: FontWeight.bold,
                              fontFamily: XFonts.lexend,
                              color: themeController.textColor,
                            ),
                          ),
                          SizedBox(height: XSizes.spacingXs),
                          Text(
                            'Visual Communication College',
                            style: TextStyle(
                              fontSize: XSizes.textSizeSm,
                              color: themeController.primaryColor,
                              fontFamily: XFonts.lexend,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: XSizes.spacingMd),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: themeController.textColor.withValues(
                                      alpha: 0.6,
                                    ),
                                    size: XSizes.iconSizeSm,
                                  ),
                                  SizedBox(width: XSizes.spacingXs),
                                  Text(
                                    '3.4k students already enrolled',
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeXs,
                                      fontFamily: XFonts.lexend,
                                      color: themeController.textColor
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹ 4,999',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeLg,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: XSizes.spacingSm),
                    // Fixed Tab Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: XSizes.paddingMd,
                      ),
                      child: TabBar(
                        isScrollable: false,
                        labelColor: themeController.primaryColor,
                        unselectedLabelColor: themeController.textColor
                            .withValues(alpha: 0.6),
                        indicatorColor: themeController.primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: TextStyle(
                          fontFamily: XFonts.lexend,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: XFonts.lexend,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Lessons'),
                        ],
                      ),
                    ),
                  ],
                ),
                // Scrollable Tab Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: XSizes.paddingMd),
                    child: TabBarView(
                      children: [
                        // Overview Tab - Scrollable
                        SingleChildScrollView(
                          padding: EdgeInsets.only(
                            top: XSizes.spacingLg,
                            bottom: XSizes.spacingXxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeSm,
                                    fontFamily: XFonts.lexend,
                                    color: themeController.textColor.withValues(
                                      alpha: 0.6,
                                    ),
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          "Visual Communication College's Typography and Layout Design course explores the art and science of typography and layout composition. Learn how to effectively use typefaces, hierarchy, alignment, and grid systems to create visually compelling designs. Gain hands-on experience in editorial design, branding, and digital layouts. ",
                                    ),
                                    TextSpan(
                                      text: 'Read More...',
                                      style: TextStyle(
                                        color: themeController.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: XFonts.lexend,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: XSizes.spacingLg),
                              // Skills Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Skills',
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeXl,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: XFonts.lexend,
                                      color: themeController.textColor,
                                    ),
                                  ),
                                  SizedBox(height: XSizes.spacingSm),
                                  Wrap(
                                    spacing: XSizes.spacingSm,
                                    runSpacing: XSizes.spacingXs,
                                    children: [
                                      _buildSkillChip(
                                        themeController,
                                        'Typography',
                                      ),
                                      _buildSkillChip(
                                        themeController,
                                        'Editorial design',
                                      ),
                                      _buildSkillChip(
                                        themeController,
                                        'Branding',
                                      ),
                                      _buildSkillChip(
                                        themeController,
                                        'Layout composition',
                                      ),
                                      _buildSkillChip(
                                        themeController,
                                        'Visual communication',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: XSizes.spacingLg),
                              // Course Details Section
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildDetailRow(
                                    themeController: themeController,
                                    icon: Icons.library_books,
                                    label: 'Lectures',
                                    value: '50+ Lectures',
                                  ),
                                  SizedBox(height: XSizes.spacingLg),
                                  _buildDetailRow(
                                    themeController: themeController,
                                    icon: Icons.access_time_filled,
                                    label: 'Learning Time',
                                    value: '4 Weeks',
                                  ),
                                  SizedBox(height: XSizes.spacingLg),
                                  _buildDetailRow(
                                    themeController: themeController,
                                    icon: Icons.workspace_premium,
                                    label: 'Certification',
                                    value: 'Online Certificate',
                                  ),
                                ],
                              ),
                              SizedBox(height: XSizes.spacingLg),
                              // Reviews Section
                              Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeXl,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor,
                                ),
                              ),
                              SizedBox(height: XSizes.spacingSm),
                              // Add some sample reviews for demonstration
                              Text(
                                'Great course! Very comprehensive and well-structured.',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeSm,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Lessons Tab - Scrollable
                        SingleChildScrollView(
                          padding: EdgeInsets.only(
                            top: XSizes.spacingLg,
                            bottom: XSizes.spacingXxl,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Lessons will be listed here.',
                                style: TextStyle(
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor,
                                ),
                              ),
                              SizedBox(height: XSizes.spacingMd),
                              // Add some sample lesson content
                              ...List.generate(
                                10,
                                (index) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: XSizes.spacingSm,
                                  ),
                                  child: Text(
                                    'Lesson ${index + 1}: Introduction to Typography',
                                    style: TextStyle(
                                      fontFamily: XFonts.lexend,
                                      color: themeController.textColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Enroll Now Button
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(XSizes.paddingMd),
            child: PrimaryButton(text: 'ENROLL NOW', onPressed: () {}),
          ),
        );
      },
    );
  }

  // Helper widget to build each grid-style row for the course details.
  Widget _buildDetailRow({
    required XThemeController themeController,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        // Icon with the primary color
        Icon(
          icon,
          color: themeController.primaryColor,
          size: XSizes.iconSizeSm,
        ),
        SizedBox(width: XSizes.paddingMd), // Space between icon and label
        // Label text with bold font
        Text(
          label,
          style: TextStyle(
            fontSize: XSizes.textSizeSm,
            fontWeight: FontWeight.bold,
            fontFamily: XFonts.lexend,
            color: themeController.textColor,
          ),
        ),
        // Spacer pushes the value text to the far right
        const Spacer(),
        // Value text with a lighter color
        Text(
          value,
          style: TextStyle(
            fontSize: XSizes.textSizeSm,
            fontFamily: XFonts.lexend,
            color: themeController.textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // Helper widget for skill chips
  Widget _buildSkillChip(XThemeController themeController, String label) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: themeController.textColor.withValues(alpha: 0.7),
          fontFamily: XFonts.lexend,
          fontSize: XSizes.textSizeSm,
        ),
      ),
      backgroundColor: themeController.backgroundColor,
      side: BorderSide(
        color: themeController.textColor.withValues(alpha: 0.2),
        width: XSizes.borderSizeSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: XSizes.paddingSm,
        vertical: XSizes.paddingXs,
      ),
    );
  }
}
