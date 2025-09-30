import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/bookmarks_controller.dart';
import '../../../controllers/my_learnings_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/api_endpoints.dart';

class MyLearningPage extends StatefulWidget {
  const MyLearningPage({super.key});

  @override
  _MyLearningPageState createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final BookmarksController _bookmarksController = Get.put(
    BookmarksController(),
  );
  final MyLearningsController _myLearningsController = Get.put(
    MyLearningsController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize search animation controller
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

    // Refresh data when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMyLearningData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      _bookmarksController.fetchBookmarks();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh bookmarks when returning to this page
    _bookmarksController.fetchBookmarks();
  }

  // Refresh my learning data
  Future<void> _refreshMyLearningData() async {
    // Refresh both bookmarks and my learnings data
    await Future.wait([
      _bookmarksController.refreshBookmarks(),
      _myLearningsController.refreshLearnings(),
    ]);
  }

  int _selectedFilterIndex = 0;
  bool _isSearchVisible = false;
  final List<String> _filters = ["Saved Courses", "In Progress", "Completed"];

  late AnimationController _searchAnimationController;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _searchFadeAnimation;

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
    } else if (_selectedFilterIndex == 1) {
      // In Progress tab - show in-progress learnings
      return Obx(() {
        if (_myLearningsController.isLoading.value) {
          return _buildLearningsShimmer();
        }

        if (_myLearningsController.hasError.value) {
          return _buildErrorState();
        }

        if (_myLearningsController.inProgressLearnings.isEmpty) {
          return _buildEmptyInProgress();
        }

        return ListView.builder(
          itemCount: _myLearningsController.inProgressLearnings.length,
          itemBuilder: (context, index) {
            final learning = _myLearningsController.inProgressLearnings[index];
            return _buildLearningCard(learning);
          },
        );
      });
    } else {
      // Completed tab - show completed learnings
      return Obx(() {
        if (_myLearningsController.isLoading.value) {
          return _buildLearningsShimmer();
        }

        if (_myLearningsController.hasError.value) {
          return _buildErrorState();
        }

        if (_myLearningsController.completedLearnings.isEmpty) {
          return _buildEmptyCompleted();
        }

        return ListView.builder(
          itemCount: _myLearningsController.completedLearnings.length,
          itemBuilder: (context, index) {
            final learning = _myLearningsController.completedLearnings[index];
            return _buildLearningCard(learning);
          },
        );
      });
    }
  }

  Widget _buildBookmarkCard(dynamic bookmark) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => GestureDetector(
            onTap: () {
              Get.toNamed(
                '/course-details',
                arguments: {'programId': bookmark.program.id},
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
                          bookmark.program.subtitle,
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
                                  '₹${bookmark.program.pricing.finalPrice.toStringAsFixed(2)}',
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

  // Build learning card for in-progress and completed courses
  Widget _buildLearningCard(dynamic learning) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => GestureDetector(
            onTap: () {
              Get.toNamed(
                '/course-details',
                arguments: {'programId': learning.program.id},
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
                          color: Colors.grey.withValues(alpha: 0.2),
                          child:
                              learning.program.image.isNotEmpty
                                  ? Image.network(
                                    learning.program.image.startsWith('http')
                                        ? learning.program.image
                                        : '${ApiEndpoints.baseUrl}${learning.program.image}',
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
                      ],
                    ),
                  ),
                  SizedBox(width: XSizes.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          learning.program.subtitle,
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
                          learning.program.category?.name ?? 'General',
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
                        // Progress section for in-progress courses
                        if (learning.progress.status.toLowerCase() ==
                            'onprogress') ...[
                          LinearProgressIndicator(
                            value: learning.progress.percentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              themeController.primaryColor,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(
                              XSizes.borderRadiusXxl,
                            ),
                          ),
                          SizedBox(height: XSizes.spacingXxs),
                          Row(
                            children: [
                              Text(
                                '${learning.progress.percentage.toStringAsFixed(1)}% Complete',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeXs,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.primaryColor,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${learning.progress.completedModules}/${learning.progress.totalModules} modules',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeXs,
                                  fontFamily: XFonts.lexend,
                                  color: themeController.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Completed status
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: XSizes.iconSizeXs,
                              ),
                              SizedBox(width: XSizes.spacingXs),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: XSizes.textSizeXs,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: XFonts.lexend,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: XSizes.spacingXs),
                        // Rating and duration
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: XSizes.iconSizeXs,
                            ),
                            SizedBox(width: XSizes.spacingXs),
                            Text(
                              learning.program.programRating.toString(),
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
                              learning.program.duration,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Build shimmer for learnings
  Widget _buildLearningsShimmer() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
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
                    SizedBox(width: XSizes.spacingSm),
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
                          SizedBox(height: XSizes.spacingXs),
                          Container(
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              color: themeController.textColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: XSizes.spacingXs),
                          Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              color: themeController.textColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                XSizes.borderRadiusXxl,
                              ),
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

  // Build empty state for in-progress
  Widget _buildEmptyInProgress() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: XSizes.iconSizeXxl,
                  color: themeController.textColor.withValues(alpha: 0.3),
                ),
                SizedBox(height: XSizes.spacingMd),
                Text(
                  'No courses in progress',
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    fontWeight: FontWeight.bold,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: XSizes.spacingSm),
                Text(
                  'Start learning a course to see your progress here.',
                  style: TextStyle(
                    fontSize: XSizes.textSizeMd,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  // Build empty state for completed
  Widget _buildEmptyCompleted() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: XSizes.iconSizeXxl,
                  color: themeController.textColor.withValues(alpha: 0.3),
                ),
                SizedBox(height: XSizes.spacingMd),
                Text(
                  'No completed courses',
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    fontWeight: FontWeight.bold,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: XSizes.spacingSm),
                Text(
                  'Complete a course to see your achievements here.',
                  style: TextStyle(
                    fontSize: XSizes.textSizeMd,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }
}
