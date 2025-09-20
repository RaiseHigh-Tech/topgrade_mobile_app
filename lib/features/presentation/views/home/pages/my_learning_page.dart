import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/bookmarks_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/api_endpoints.dart';

// A simple data model for a course
class Course {
  final String title;
  final String institution;
  final double rating;
  final String description;
  final int studentCount;
  final String imageUrl;

  Course({
    required this.title,
    required this.institution,
    required this.rating,
    required this.description,
    required this.studentCount,
    required this.imageUrl,
  });
}

class MyLearningPage extends StatefulWidget {
  const MyLearningPage({super.key});

  @override
  _MyLearningPageState createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage>
    with TickerProviderStateMixin {
  final BookmarksController _bookmarksController = Get.put(
    BookmarksController(),
  );

  // Refresh my learning data
  Future<void> _refreshMyLearningData() async {
    // Refresh bookmarks data
    await _bookmarksController.refreshBookmarks();
  }

  int _selectedFilterIndex = 0;
  bool _isSearchVisible = false;
  final List<String> _filters = ["Saved Courses", "In Progress", "Completed"];

  late AnimationController _searchAnimationController;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _searchFadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }

  // Dummy data representing
  // the list of courses
  final List<Course> courses = [
    Course(
      title: 'Branding and Identity Design',
      institution: 'Brand Strategy College',
      rating: 4.4,
      description:
          'This course explores the fundamentals of branding, brand strategy, and visual identity design. Learn how to ...',
      studentCount: 1457,
      imageUrl:
          'https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=500',
    ),
    Course(
      title: 'Game Design and Development',
      institution: 'Game Development Academy',
      rating: 4.4,
      description:
          'Visual Communication College\'s Typography and Layout Design course explores the art and science of...',
      studentCount: 5679,
      imageUrl:
          'https://images.unsplash.com/photo-1580327344181-c1163234e5a0?w=500', // Placeholder
    ),
    Course(
      title: 'Animation and Motion Graphics',
      institution: 'Animation Institute of Digital Arts',
      rating: 4.7,
      description:
          'This course in Animation and Motion Graphics. Learn the principles of animation, 2D and 3D animation...',
      studentCount: 2679,
      imageUrl:
          'https://images.unsplash.com/photo-1579566346927-c68383817a25?w=500', // Placeholder
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Scaffold(
            backgroundColor: themeController.backgroundColor,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshMyLearningData,
                color: themeController.primaryColor,
                backgroundColor: themeController.backgroundColor,
                strokeWidth: 2.5,
                displacement: 60,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 100,
                    padding: EdgeInsets.all(XSizes.paddingMd),
                    child: Column(
                      children: [
                        _buildHeader(themeController),
                        AnimatedBuilder(
                          animation: _searchAnimationController,
                          builder: (context, child) {
                            return ClipRect(
                              child: SlideTransition(
                                position: _searchSlideAnimation,
                                child: FadeTransition(
                                  opacity: _searchFadeAnimation,
                                  child:
                                      _isSearchVisible
                                          ? _buildSearchBar(themeController)
                                          : const SizedBox.shrink(),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: XSizes.spacingMd),
                        _buildFilterTabs(themeController),
                        SizedBox(height: XSizes.spacingXl),
                        Expanded(child: _buildCourseList(themeController)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildHeader(XThemeController themeController) {
    return Row(
      children: [
        Text(
          'My Learning',
          style: TextStyle(
            fontSize: XSizes.textSizeXl,
            fontWeight: FontWeight.bold,
            color: themeController.textColor,
            fontFamily: XFonts.lexend,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(
            Icons.search,
            color: themeController.textColor,
            size: XSizes.iconSizeMd,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(XThemeController themeController) {
    return SizedBox(
      height: XSizes.paddingXl + XSizes.paddingXs,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: XSizes.marginSm),
              padding: EdgeInsets.symmetric(
                horizontal: XSizes.paddingMd,
                vertical: XSizes.paddingSm,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? themeController.primaryColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : themeController.textColor.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: XSizes.textSizeSm,
                    fontFamily: XFonts.lexend,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, XThemeController themeController) {
    return Container(
      margin: EdgeInsets.only(bottom: XSizes.marginMd),
      padding: EdgeInsets.all(XSizes.paddingSm),
      decoration: BoxDecoration(
        color: themeController.backgroundColor,
        borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
        border: Border.all(
          color: themeController.textColor.withValues(alpha: 0.2),
          width: XSizes.borderSizeSm,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
            child: Stack(
              children: [
                Container(
                  width: XSizes.iconSizeXxl + XSizes.paddingXl,
                  height: XSizes.iconSizeXxl + XSizes.paddingXl,
                  color: themeController.textColor.withValues(alpha: 0.1),
                  child:
                      course.imageUrl.isNotEmpty
                          ? Image.network(
                            course.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.play_circle_fill,
                                  size: XSizes.iconSizeXl,
                                  color: themeController.primaryColor,
                                ),
                          )
                          : Icon(
                            Icons.play_circle_fill,
                            size: XSizes.iconSizeXl,
                            color: themeController.primaryColor,
                          ),
                ),
                Container(
                  width: XSizes.iconSizeXxl + XSizes.paddingXl,
                  height: XSizes.iconSizeXxl + XSizes.paddingXl,
                  color: themeController.primaryColor.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          SizedBox(width: XSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: XSizes.textSizeSm,
                    color: themeController.textColor,
                    fontFamily: XFonts.lexend,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: XSizes.spacingXxs),
                Text(
                  course.institution,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: themeController.textColor.withValues(alpha: 0.6),
                    fontSize: XSizes.textSizeXs,
                    fontFamily: XFonts.lexend,
                  ),
                ),
                SizedBox(height: XSizes.spacingXs),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                      size: XSizes.iconSizeXs,
                    ),
                    SizedBox(width: XSizes.spacingXs),
                    Text(
                      course.rating.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: XSizes.textSizeXs,
                        color: themeController.textColor,
                        fontFamily: XFonts.lexend,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: XSizes.spacingXs),
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: themeController.textColor.withValues(alpha: 0.6),
                    fontSize: XSizes.textSizeXxs,
                    fontFamily: XFonts.lexend,
                  ),
                ),
                SizedBox(height: XSizes.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/course-details');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeController.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(90, 35),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Enroll Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: XFonts.lexend,
                          fontSize: XSizes.textSizeXs,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          color: themeController.textColor.withValues(
                            alpha: 0.5,
                          ),
                          size: XSizes.iconSizeXs,
                        ),
                        SizedBox(width: XSizes.spacingXs),
                        Text(
                          course.studentCount.toString(),
                          style: TextStyle(
                            color: themeController.textColor.withValues(
                              alpha: 0.6,
                            ),
                            fontWeight: FontWeight.w500,
                            fontSize: XSizes.textSizeXs,
                            fontFamily: XFonts.lexend,
                          ),
                        ),
                      ],
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

  Widget _buildCourseList(XThemeController themeController) {
    // Check which tab is selected
    if (_selectedFilterIndex == 0) {
      // Saved Courses tab - show bookmarks
      return Obx(() {
        if (_bookmarksController.isLoading.value) {
          return _buildBookmarksShimmer();
        }

        if (_bookmarksController.hasError.value) {
          return _buildErrorState();
        }

        if (_bookmarksController.bookmarks.isEmpty) {
          return _buildEmptyBookmarks();
        }

        return ListView.builder(
          itemCount: _bookmarksController.bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = _bookmarksController.bookmarks[index];
            return _buildBookmarkCard(bookmark);
          },
        );
      });
    } else {
      // Other tabs - show dummy data for now
      return ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(courses[index], themeController);
        },
      );
    }
  }

  Widget _buildBookmarkCard(dynamic bookmark) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => GestureDetector(
            onTap: () {
              Get.toNamed(
                '/course-details',
                arguments: {
                  'programId': bookmark.program.id,
                  'programType': bookmark.program.type,
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: XSizes.marginMd),
              padding: EdgeInsets.all(XSizes.paddingSm),
              decoration: BoxDecoration(
                color: themeController.backgroundColor,
                borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                border: Border.all(
                  color: themeController.textColor.withValues(alpha: 0.2),
                  width: XSizes.borderSizeSm,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
                    child: Stack(
                      children: [
                        Container(
                          width: XSizes.iconSizeXxl + XSizes.paddingXl,
                          height: XSizes.iconSizeXxl + XSizes.paddingXl,
                          color: themeController.textColor.withValues(
                            alpha: 0.1,
                          ),
                          child:
                              bookmark.program.image.isNotEmpty
                                  ? Image.network(
                                    bookmark.program.image.startsWith('http')
                                        ? bookmark.program.image
                                        : '${ApiEndpoints.baseUrl}${bookmark.program.image}',
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: themeController.textColor
                                            .withValues(alpha: 0.1),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                                  themeController.primaryColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: themeController.textColor
                                                  .withValues(alpha: 0.1),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: XSizes.iconSizeXl,
                                                color: themeController.textColor
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                  )
                                  : Container(
                                    color: themeController.textColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: XSizes.iconSizeXl,
                                      color: themeController.primaryColor,
                                    ),
                                  ),
                        ),
                        // Bookmark icon in top-right corner
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.bookmark,
                              color: themeController.primaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: XSizes.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.program.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: XSizes.textSizeSm,
                            color: themeController.textColor,
                            fontFamily: XFonts.lexend,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: XSizes.spacingXxs),
                        Text(
                          bookmark.program.category?.name ?? 'General',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeController.textColor.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: XSizes.textSizeXs,
                            fontFamily: XFonts.lexend,
                          ),
                        ),
                        SizedBox(height: XSizes.spacingXs),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: XSizes.iconSizeXs,
                            ),
                            SizedBox(width: XSizes.spacingXs),
                            Text(
                              bookmark.program.programRating.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: XSizes.textSizeXs,
                                color: themeController.textColor,
                                fontFamily: XFonts.lexend,
                              ),
                            ),
                            SizedBox(width: XSizes.spacingMd),
                            Icon(
                              Icons.access_time,
                              color: themeController.textColor.withValues(
                                alpha: 0.5,
                              ),
                              size: XSizes.iconSizeXs,
                            ),
                            SizedBox(width: XSizes.spacingXs),
                            Text(
                              bookmark.program.duration,
                              style: TextStyle(
                                fontSize: XSizes.textSizeXs,
                                color: themeController.textColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontFamily: XFonts.lexend,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: XSizes.spacingSm),
                        Row(
                          children: [
                            // Price
                            if (bookmark.program.pricing.isFree)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'FREE',
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeXs,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontFamily: XFonts.lexend,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: themeController.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '\$${bookmark.program.pricing.finalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeXs,
                                    fontWeight: FontWeight.bold,
                                    color: themeController.primaryColor,
                                    fontFamily: XFonts.lexend,
                                  ),
                                ),
                              ),
                            SizedBox(width: XSizes.spacingMd),
                            // Students count
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.group,
                                    color: themeController.textColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: XSizes.iconSizeXs,
                                  ),
                                  SizedBox(width: XSizes.spacingXs),
                                  Text(
                                    '${bookmark.program.enrolledStudents} students',
                                    style: TextStyle(
                                      color: themeController.textColor
                                          .withValues(alpha: 0.6),
                                      fontSize: XSizes.textSizeXs,
                                      fontFamily: XFonts.lexend,
                                    ),
                                  ),
                                ],
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
          ),
    );
  }

  Widget _buildBookmarksShimmer() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: XSizes.marginMd),
                padding: EdgeInsets.all(XSizes.paddingSm),
                decoration: BoxDecoration(
                  color: themeController.backgroundColor,
                  borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: XSizes.iconSizeXxl + XSizes.paddingXl,
                      height: XSizes.iconSizeXxl + XSizes.paddingXl,
                      decoration: BoxDecoration(
                        color: themeController.textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          XSizes.borderRadiusSm,
                        ),
                      ),
                    ),
                    SizedBox(width: XSizes.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: themeController.textColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 12,
                            decoration: BoxDecoration(
                              color: themeController.textColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
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
    );
  }

  Widget _buildEmptyBookmarks() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: XSizes.iconSizeXxl * 1.5,
                  color: themeController.textColor.withValues(alpha: 0.3),
                ),
                SizedBox(height: XSizes.spacingMd),
                Text(
                  'No Saved Courses',
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    fontWeight: FontWeight.bold,
                    color: themeController.textColor.withValues(alpha: 0.6),
                    fontFamily: XFonts.lexend,
                  ),
                ),
                SizedBox(height: XSizes.spacingSm),
                Text(
                  'Start exploring courses and save your favorites here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: XSizes.textSizeSm,
                    color: themeController.textColor.withValues(alpha: 0.4),
                    fontFamily: XFonts.lexend,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildErrorState() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: XSizes.iconSizeXxl,
                  color: themeController.textColor.withValues(alpha: 0.3),
                ),
                SizedBox(height: XSizes.spacingMd),
                Text(
                  'Failed to load bookmarks',
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    color: themeController.textColor.withValues(alpha: 0.6),
                    fontFamily: XFonts.lexend,
                  ),
                ),
                SizedBox(height: XSizes.spacingSm),
                ElevatedButton(
                  onPressed: () => _bookmarksController.retry(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSearchBar(XThemeController themeController) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: XSizes.paddingMd),
      margin: EdgeInsets.only(top: XSizes.marginSm),
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
                hintText: "Search Courses...",
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
    );
  }
}
