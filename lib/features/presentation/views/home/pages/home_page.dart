import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Scaffold(
            backgroundColor: themeController.backgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(XSizes.paddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(),
                      SizedBox(height: XSizes.spacingMd),
                      _buildSearchBar(),
                      SizedBox(height: XSizes.spacingMd),
                      _buildSectionHeader("Continue Watching"),
                      SizedBox(height: XSizes.spacingSm),
                      _buildContinueWatchingCard(
                        title: "UI/UX Design Essentials",
                        university: "Tech Innovations University",
                        rating: 4.9,
                        progress: 0.79,
                        imageUrl:
                            "https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=500",
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      _buildContinueWatchingCard(
                        title: "Graphic Design Fundamentals",
                        university: "Creative Arts Institute",
                        rating: 4.7,
                        progress: 0.55,
                        imageUrl:
                            "https://images.unsplash.com/photo-1580327344181-c1163234e5a0?w=500",
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      _buildSectionHeader("Categories"),
                      SizedBox(height: XSizes.spacingSm),
                      _buildCategories(),
                      SizedBox(height: XSizes.spacingMd),
                      _buildSectionHeader("Suggestions for You"),
                      const SizedBox(height: 16),
                      _buildHorizontalCourseList(),
                      const SizedBox(height: 24),
                      _buildSectionHeader("Top Courses"),
                      const SizedBox(height: 16),
                      _buildHorizontalCourseList(isTopCourse: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  // --- WIDGET BUILDER METHODS ---
  Widget _buildAppBar() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good Morning!",
                    style: TextStyle(
                      fontSize: XSizes.textSizeSm,
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor,
                    ),
                  ),
                  Text(
                    "John Doe",
                    style: TextStyle(
                      fontSize: XSizes.textSizeMd,
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: themeController.primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
    );
  }

  Widget _buildSearchBar() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Container(
            padding: EdgeInsets.symmetric(horizontal: XSizes.paddingMd),
            decoration: BoxDecoration(
              color: themeController.backgroundColor,
              borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
              border: Border.all(
                color:
                    themeController.isLightTheme
                        ? Colors.grey[300]!
                        : Colors.grey[600]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color:
                      themeController.isLightTheme
                          ? Colors.grey[600]!
                          : Colors.white,
                ),
                SizedBox(width: XSizes.spacingSm),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search courses...",
                      hintStyle: TextStyle(
                        fontFamily: XFonts.lexend,
                        fontSize: XSizes.textSizeMd,
                        color:
                            themeController.isLightTheme
                                ? Colors.grey[600]!
                                : Colors.white,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildContinueWatchingCard({
    required String title,
    required String university,
    required double rating,
    required double progress,
    required String imageUrl,
  }) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Container(
            padding: EdgeInsets.all(XSizes.paddingSm),
            decoration: BoxDecoration(
              color: themeController.backgroundColor,
              borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: XSizes.textSizeMd,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        university,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: XSizes.textSizeXs,
                          fontFamily: XFonts.lexend,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontFamily: XFonts.lexend,
                              color: themeController.textColor,
                              fontSize: XSizes.textSizeXs,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeController.primaryColor,
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(
                                XSizes.borderRadiusXxl,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: XSizes.textSizeXs,
                              color: themeController.textColor,
                              fontFamily: XFonts.lexend,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCategories() {
    final categories = ["Graphic Design", "User Interface", "User Experience"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) => _buildCategoryChip(category)).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Container(
            margin: EdgeInsets.only(right: XSizes.marginSm),
            padding: EdgeInsets.symmetric(
              horizontal: XSizes.paddingLg,
              vertical: XSizes.paddingSm,
            ),
            decoration: BoxDecoration(
              color: themeController.backgroundColor,
              borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: XFonts.lexend,
                color: themeController.textColor,
                fontSize: XSizes.textSizeXs,
              ),
            ),
          ),
    );
  }

  Widget _buildHorizontalCourseList({bool isTopCourse = false}) {
    // Dummy data
    final courses = [
      {
        "title": "Typography and Layout Design",
        "college": "Visual Communication College",
        "rating": 4.7,
        "bookmarked": false,
        "imageUrl":
            "https://images.unsplash.com/photo-1580327344181-c1163234e5a0?w=500",
      },
      {
        "title": "Branding and Identity Design",
        "college": "Innovation and Design School",
        "rating": 4.4,
        "bookmarked": true,
        "imageUrl":
            "https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=500",
      },
      {
        "title": "Web Design Fundamentals",
        "college": "Web Development Uni",
        "rating": 4.9,
        "bookmarked": false,
        "imageUrl":
            "https://images.unsplash.com/photo-1579566346927-c68383817a25?w=500",
      },
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _buildSuggestionCard(
            title: course['title'] as String,
            college: course['college'] as String,
            rating: course['rating'] as double,
            isBookmarked: isTopCourse ? true : course['bookmarked'] as bool,
            imageUrl: course['imageUrl'] as String,
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required String college,
    required double rating,
    required bool isBookmarked,
    required String imageUrl,
  }) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Container(
            width: 160,
            margin: EdgeInsets.only(right: XSizes.marginSm + XSizes.marginXs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 110,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          XSizes.borderRadiusLg,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          XSizes.borderRadiusMd,
                        ),
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: themeController.backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color:
                              isBookmarked ? XColors.primaryColor : Colors.grey,
                          size: XSizes.iconSizeSm,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: XSizes.textSizeSm,
                    fontFamily: XFonts.lexend,
                  ),
                ),
                SizedBox(height: XSizes.spacingXs),
                Text(
                  college,
                  style: TextStyle(
                    color: themeController.textColor,
                    fontSize: XSizes.textSizeXs,
                    fontFamily: XFonts.lexend,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: XSizes.iconSizeSm,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: XSizes.textSizeXs,
                        fontFamily: XFonts.lexend,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Text(
            title,
            style: TextStyle(
              fontSize: XSizes.textSizeLg,
              fontFamily: XFonts.lexend,
              color: themeController.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }
}
