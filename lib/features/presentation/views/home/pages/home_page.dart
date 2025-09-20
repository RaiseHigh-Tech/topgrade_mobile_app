import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _shimmerAnimationController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start shimmer animation after screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _shimmerAnimationController.repeat();
        _simulateLoading();
      }
    });
  }

  @override
  void dispose() {
    _shimmerAnimationController.dispose();
    super.dispose();
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _shimmerAnimationController.stop();
      }
    });
  }

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
                      _isLoading ? _buildShimmerAppBar() : _buildAppBar(),
                      SizedBox(height: XSizes.spacingMd),
                      _isLoading ? _buildShimmerSearchBar() : _buildSearchBar(),
                      SizedBox(height: XSizes.spacingMd),
                      _isLoading ? _buildShimmerSectionHeader() : _buildSectionHeader("Continue Watching"),
                      SizedBox(height: XSizes.spacingSm),
                      _isLoading ? _buildShimmerContinueWatchingCards() : _buildContinueWatchingCard(
                        title: "UI/UX Design Essentials",
                        university: "Tech Innovations University",
                        rating: 4.9,
                        progress: 0.79,
                        imageUrl:
                            "https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=500",
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      if (!_isLoading) _buildContinueWatchingCard(
                        title: "Graphic Design Fundamentals",
                        university: "Creative Arts Institute",
                        rating: 4.7,
                        progress: 0.55,
                        imageUrl:
                            "https://images.unsplash.com/photo-1580327344181-c1163234e5a0?w=500",
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      _isLoading ? _buildShimmerSectionHeader() : _buildSectionHeader("Categories"),
                      SizedBox(height: XSizes.spacingSm),
                      _isLoading ? _buildShimmerCategories() : _buildCategories(),
                      SizedBox(height: XSizes.spacingMd),
                      _isLoading ? _buildShimmerSectionHeader() : _buildSectionHeader("Suggestions for You", showViewAll: true),
                      const SizedBox(height: 16),
                      _isLoading ? _buildShimmerHorizontalCourseList() : _buildHorizontalCourseList(),
                      const SizedBox(height: 24),
                      _isLoading ? _buildShimmerSectionHeader() : _buildSectionHeader("Top Courses", showViewAll: true),
                      const SizedBox(height: 16),
                      _isLoading ? _buildShimmerHorizontalCourseList() : _buildHorizontalCourseList(isTopCourse: true),
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
                Icon(Icons.search, color: Colors.grey[600]),
                SizedBox(width: XSizes.spacingSm),
                Expanded(
                  child: TextField(
                    cursorColor: themeController.primaryColor,
                    decoration: InputDecoration(
                      hintText: "Search courses...",
                      hintStyle: TextStyle(
                        fontFamily: XFonts.lexend,
                        fontSize: XSizes.textSizeMd,
                        color: Colors.grey[600],
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

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
    return GetBuilder<XThemeController>(
      builder: (themeController) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: XSizes.textSizeLg,
              fontFamily: XFonts.lexend,
              color: themeController.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {
                Get.toNamed('/course-list');
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: XSizes.textSizeSm,
                  fontFamily: XFonts.lexend,
                  color: themeController.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Shimmer effect methods
  Widget _buildShimmerWrapper(Widget child, XThemeController themeController) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeController.textColor.withValues(alpha: 0.1),
                themeController.textColor.withValues(alpha: 0.3),
                themeController.textColor.withValues(alpha: 0.1),
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildShimmerAppBar() {
    return GetBuilder<XThemeController>(
      builder: (themeController) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerWrapper(
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: themeController.textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                themeController,
              ),
              SizedBox(height: 4),
              _buildShimmerWrapper(
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeController.textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                themeController,
              ),
            ],
          ),
          _buildShimmerWrapper(
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
            themeController,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSearchBar() {
    return GetBuilder<XThemeController>(
      builder: (themeController) => _buildShimmerWrapper(
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: XSizes.paddingMd),
          decoration: BoxDecoration(
            color: themeController.textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
          ),
        ),
        themeController,
      ),
    );
  }

  Widget _buildShimmerSectionHeader() {
    return GetBuilder<XThemeController>(
      builder: (themeController) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShimmerWrapper(
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            themeController,
          ),
          _buildShimmerWrapper(
            Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            themeController,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContinueWatchingCards() {
    return GetBuilder<XThemeController>(
      builder: (themeController) => Column(
        children: [
          _buildShimmerContinueWatchingCard(themeController),
          SizedBox(height: XSizes.spacingSm),
          _buildShimmerContinueWatchingCard(themeController),
        ],
      ),
    );
  }

  Widget _buildShimmerContinueWatchingCard(XThemeController themeController) {
    return Container(
      padding: EdgeInsets.all(XSizes.paddingSm),
      decoration: BoxDecoration(
        color: themeController.backgroundColor,
        borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildShimmerWrapper(
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
              ),
            ),
            themeController,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerWrapper(
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  themeController,
                ),
                const SizedBox(height: 4),
                _buildShimmerWrapper(
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  themeController,
                ),
                const SizedBox(height: 8),
                _buildShimmerWrapper(
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  themeController,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildShimmerWrapper(
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: themeController.textColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(XSizes.borderRadiusXxl),
                          ),
                        ),
                        themeController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildShimmerWrapper(
                      Container(
                        width: 30,
                        height: 12,
                        decoration: BoxDecoration(
                          color: themeController.textColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      themeController,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCategories() {
    return GetBuilder<XThemeController>(
      builder: (themeController) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(3, (index) => 
            _buildShimmerWrapper(
              Container(
                margin: EdgeInsets.only(right: XSizes.marginSm),
                padding: EdgeInsets.symmetric(
                  horizontal: XSizes.paddingLg,
                  vertical: XSizes.paddingSm,
                ),
                decoration: BoxDecoration(
                  color: themeController.textColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
                ),
                child: SizedBox(
                  width: 80 + (index * 15.0),
                  height: 16,
                ),
              ),
              themeController,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerHorizontalCourseList() {
    return GetBuilder<XThemeController>(
      builder: (themeController) => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildShimmerCourseCard(themeController);
          },
        ),
      ),
    );
  }

  Widget _buildShimmerCourseCard(XThemeController themeController) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: XSizes.marginSm + XSizes.marginXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerWrapper(
            Container(
              height: 110,
              width: 160,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
              ),
            ),
            themeController,
          ),
          const SizedBox(height: 8),
          _buildShimmerWrapper(
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            themeController,
          ),
          SizedBox(height: XSizes.spacingXs),
          _buildShimmerWrapper(
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            themeController,
          ),
          const Spacer(),
          _buildShimmerWrapper(
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            themeController,
          ),
        ],
      ),
    );
  }
}
