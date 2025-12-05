import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/categories_controller.dart';
import '../../controllers/programs_controller.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';
import '../../../../utils/constants/api_endpoints.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  bool _isSearchVisible = false;
  String _sortBy = 'Popular';

  final CategoriesController _categoriesController = Get.put(
    CategoriesController(),
  );
  final ProgramsController _programsController = Get.put(ProgramsController());

  // Temporary filter states (for preview before applying)
  String? _tempProgramType;
  double? _tempMinPrice;
  double? _tempMaxPrice;
  double? _tempMinRating;
  bool? _tempIsBestSeller;
  String? _tempSortBy;

  // Search functionality
  Timer? _debounceTimer;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _searchAnimationController;
  late AnimationController _shimmerAnimationController;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Check if we came from home page with category filter or auto focus search
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final categoryId = arguments['categoryId'] as int?;
      final categoryName = arguments['categoryName'] as String?;
      final autoFocusSearch = arguments['autoFocusSearch'] as bool?;

      if (categoryId != null && categoryName != null) {
        // Set the category filter and update selected index
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _programsController.filterByCategory(categoryId);
          // Find and set the correct category index
          final categories = _categoriesController.displayCategories;
          final index = categories.indexOf(categoryName);
          if (index != -1) {
            setState(() {
              _selectedCategoryIndex = index;
            });
          }
        });
      }

      // Auto focus search if requested from home page
      if (autoFocusSearch == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isSearchVisible = true;
          });
          _searchAnimationController.forward();
          // Delay focus slightly to ensure animation starts
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _searchFocusNode.requestFocus();
            }
          });
        });
      }
    }

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shimmerAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ), // Slower animation for better performance
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

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start shimmer animation after a short delay to prevent navigation lag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _shimmerAnimationController.repeat();

        // Listen to both controllers loading state
        ever(_categoriesController.isLoading, (isLoading) {
          if (!isLoading && !_programsController.isLoading.value && mounted) {
            if (_shimmerAnimationController.isAnimating) {
              _shimmerAnimationController.stop();
            }
          }
        });

        ever(_programsController.isLoading, (isLoading) {
          if (!isLoading && !_categoriesController.isLoading.value && mounted) {
            if (_shimmerAnimationController.isAnimating) {
              _shimmerAnimationController.stop();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _shimmerAnimationController.dispose();
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
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

  void _debounceSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    _programsController.searchPrograms(query.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    _programsController.searchPrograms('');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Scaffold(
            backgroundColor: themeController.backgroundColor,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              surfaceTintColor: themeController.backgroundColor,
              backgroundColor: themeController.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: themeController.textColor),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'All Courses',
                style: TextStyle(
                  color: themeController.textColor,
                  fontFamily: XFonts.lexend,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(
                    Icons.search,
                    color: themeController.textColor,
                    size: XSizes.iconSizeMd,
                  ),
                ),
                IconButton(
                  onPressed: () => _showFilterOptions(themeController),
                  icon: Icon(
                    Icons.tune,
                    color: themeController.textColor,
                    size: XSizes.iconSizeMd,
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: XSizes.paddingMd),
                child: Column(
                  children: [
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
                    Obx(
                      () =>
                          (_categoriesController.isLoading.value ||
                                  _programsController.isLoading.value)
                              ? _buildShimmerCategoryTabs(themeController)
                              : _buildCategoryTabs(themeController),
                    ),
                    SizedBox(height: XSizes.spacingMd),
                    Obx(
                      () =>
                          (_categoriesController.isLoading.value ||
                                  _programsController.isLoading.value)
                              ? _buildShimmerResultsHeader(themeController)
                              : _buildResultsHeader(themeController),
                    ),
                    SizedBox(height: XSizes.spacingSm),
                    Obx(
                      () =>
                          _programsController.hasActiveFilters
                              ? _buildActiveFiltersChips(themeController)
                              : const SizedBox.shrink(),
                    ),
                    SizedBox(height: XSizes.spacingSm),
                    Expanded(
                      child: Obx(
                        () =>
                            (_categoriesController.isLoading.value ||
                                    _programsController.isLoading.value)
                                ? _buildShimmerCourseList(themeController)
                                : _buildProgramsList(themeController),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildCategoryTabs(XThemeController themeController) {
    return SizedBox(
      height: XSizes.paddingXl + XSizes.paddingXs,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categoriesController.displayCategories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });

              // Filter programs by category
              if (index == 0) {
                // "All" selected - clear category filter
                _programsController.filterByCategory(null);
              } else {
                // Get category ID and filter
                final categoryName =
                    _categoriesController.displayCategories[index];
                final categoryId = _categoriesController.getCategoryIdByName(
                  categoryName,
                );
                _programsController.filterByCategory(categoryId);
              }
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
                  _categoriesController.displayCategories[index],
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

  Widget _buildResultsHeader(XThemeController themeController) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_programsController.programs.length} courses found',
            style: TextStyle(
              color: themeController.textColor.withValues(alpha: 0.6),
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
            ),
          ),
          Text(
            'Sorted by $_sortBy',
            style: TextStyle(
              color: themeController.textColor.withValues(alpha: 0.6),
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsList(XThemeController themeController) {
    return Obx(() {
      // Handle error state
      if (_programsController.hasError.value) {
        return Center(
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
                'Failed to load courses',
                style: TextStyle(
                  fontSize: XSizes.textSizeLg,
                  color: themeController.textColor.withValues(alpha: 0.6),
                  fontFamily: XFonts.lexend,
                ),
              ),
              SizedBox(height: XSizes.spacingSm),
              ElevatedButton(
                onPressed: () => _programsController.retry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeController.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Handle empty state
      if (_programsController.programs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: XSizes.iconSizeXxl,
                color: themeController.textColor.withValues(alpha: 0.3),
              ),
              SizedBox(height: XSizes.spacingMd),
              Text(
                'No courses found',
                style: TextStyle(
                  fontSize: XSizes.textSizeLg,
                  color: themeController.textColor.withValues(alpha: 0.6),
                  fontFamily: XFonts.lexend,
                ),
              ),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(
                  fontSize: XSizes.textSizeSm,
                  color: themeController.textColor.withValues(alpha: 0.4),
                  fontFamily: XFonts.lexend,
                ),
              ),
            ],
          ),
        );
      }

      // Display programs list
      return ListView.builder(
        itemCount: _programsController.programs.length,
        itemBuilder: (context, index) {
          return _buildProgramCard(
            _programsController.programs[index],
            themeController,
          );
        },
      );
    });
  }

  Widget _buildProgramCard(dynamic program, XThemeController themeController) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/course-details', arguments: {'programId': program.id});
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
          boxShadow: [
            BoxShadow(
              color: themeController.textColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                        program.image.isNotEmpty
                            ? Image.network(
                              program.image.startsWith('http')
                                  ? program.image
                                  : '${ApiEndpoints.baseUrl}${program.image}',
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Container(
                                  width: XSizes.iconSizeXxl + XSizes.paddingXl,
                                  height: XSizes.iconSizeXxl + XSizes.paddingXl,
                                  color: themeController.textColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: themeController.primaryColor,
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toInt()}%'
                                              : 'Loading...',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: themeController.textColor
                                                .withValues(alpha: 0.6),
                                            fontFamily: XFonts.lexend,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width:
                                        XSizes.iconSizeXxl + XSizes.paddingXl,
                                    height:
                                        XSizes.iconSizeXxl + XSizes.paddingXl,
                                    color: themeController.textColor.withValues(
                                      alpha: 0.05,
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: XSizes.iconSizeXl,
                                      color: themeController.textColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                            )
                            : Container(
                              width: XSizes.iconSizeXxl + XSizes.paddingXl,
                              height: XSizes.iconSizeXxl + XSizes.paddingXl,
                              color: themeController.textColor.withValues(
                                alpha: 0.05,
                              ),
                              child: Icon(
                                Icons.play_circle_fill,
                                size: XSizes.iconSizeXl,
                                color: themeController.primaryColor,
                              ),
                            ),
                  ),
                  if (program.pricing.isFree || program.isBestSeller)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              program.pricing.isFree
                                  ? Colors.green
                                  : Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          program.pricing.isFree ? 'FREE' : 'BEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: XFonts.lexend,
                          ),
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
                    program.subtitle,
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
                    program.category?.name ?? 'General',
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
                        program.programRating.toString(),
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
                        color: themeController.textColor.withValues(alpha: 0.5),
                        size: XSizes.iconSizeXs,
                      ),
                      SizedBox(width: XSizes.spacingXs),
                      Text(
                        program.duration,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (program.pricing.isFree)
                            Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: XSizes.textSizeSm,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontFamily: XFonts.lexend,
                              ),
                            )
                          else
                            Text(
                              '₹${program.pricing.finalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: XSizes.textSizeSm,
                                fontWeight: FontWeight.bold,
                                color: themeController.primaryColor,
                                fontFamily: XFonts.lexend,
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
                                '${program.enrolledStudents} students',
                                style: TextStyle(
                                  color: themeController.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: XSizes.textSizeXxs,
                                  fontFamily: XFonts.lexend,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            '/course-details',
                            arguments: {'programId': program.id},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeController.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(90, 35),
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
                          program.pricing.isFree
                              ? 'Enroll Free'
                              : 'View Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: XFonts.lexend,
                            fontSize: XSizes.textSizeXs,
                          ),
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

  void _showFilterOptions(XThemeController themeController) {
    // Initialize temp values with current filter values
    _tempProgramType = _programsController.selectedProgramType.value;
    _tempMinPrice = _programsController.selectedMinPrice.value;
    _tempMaxPrice = _programsController.selectedMaxPrice.value;
    _tempMinRating = _programsController.selectedMinRating.value;
    _tempIsBestSeller = _programsController.selectedIsBestSeller.value;
    _tempSortBy = _programsController.selectedSortBy.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: themeController.backgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(XSizes.borderRadiusMd),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(XSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters & Sort',
                        style: TextStyle(
                          fontSize: XSizes.textSizeXl,
                          fontWeight: FontWeight.bold,
                          color: themeController.textColor,
                          fontFamily: XFonts.lexend,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tempProgramType = null;
                            _tempMinPrice = null;
                            _tempMaxPrice = null;
                            _tempMinRating = null;
                            _tempIsBestSeller = null;
                            _tempSortBy = 'most_relevant';
                          });
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: themeController.primaryColor,
                            fontFamily: XFonts.lexend,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: XSizes.spacingMd),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSortByFilter(themeController),
                          SizedBox(height: XSizes.spacingLg),
                          _buildPriceRangeFilter(themeController),
                          SizedBox(height: XSizes.spacingLg),
                          _buildRatingFilter(themeController),
                          SizedBox(height: XSizes.spacingLg),
                          _buildBestSellerFilter(themeController),
                          SizedBox(height: XSizes.spacingLg),
                        ],
                      ),
                    ),
                  ),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply all temp filters to the controller
                        _programsController.selectedProgramType.value =
                            _tempProgramType;
                        _programsController.selectedMinPrice.value =
                            _tempMinPrice;
                        _programsController.selectedMaxPrice.value =
                            _tempMaxPrice;
                        _programsController.selectedMinRating.value =
                            _tempMinRating;
                        _programsController.selectedIsBestSeller.value =
                            _tempIsBestSeller;
                        _programsController.selectedSortBy.value =
                            _tempSortBy ?? 'most_relevant';

                        // Update UI sort by value
                        String uiSortBy;
                        switch (_tempSortBy) {
                          case 'top_rated':
                            uiSortBy = 'Rating';
                            break;
                          case 'price':
                            uiSortBy = 'Price';
                            break;
                          case 'recently_added':
                            uiSortBy = 'Recent';
                            break;
                          case 'most_relevant':
                          default:
                            uiSortBy = 'Popular';
                        }
                        _sortBy = uiSortBy;

                        // Fetch filtered programs
                        _programsController.fetchFilteredPrograms();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeController.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: XSizes.paddingMd,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: XFonts.lexend,
                          fontSize: XSizes.textSizeMd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortByFilter(XThemeController themeController) {
    final sortOptions = [
      {'label': 'Most Relevant', 'value': 'most_relevant'},
      {'label': 'Top Rated', 'value': 'top_rated'},
      {'label': 'Price: Low to High', 'value': 'price'},
      {'label': 'Recently Added', 'value': 'recently_added'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontSize: XSizes.textSizeMd,
            fontWeight: FontWeight.bold,
            color: themeController.textColor,
            fontFamily: XFonts.lexend,
          ),
        ),
        SizedBox(height: XSizes.spacingSm),
        StatefulBuilder(
          builder:
              (context, setFilterState) => Column(
                children:
                    sortOptions.map((option) {
                      final isSelected = _tempSortBy == option['value'];

                      return RadioListTile<String>(
                        title: Text(
                          option['label']!,
                          style: TextStyle(
                            fontFamily: XFonts.lexend,
                            fontSize: XSizes.textSizeXs,
                            color: themeController.textColor,
                          ),
                        ),
                        value: option['value']!,
                        groupValue: _tempSortBy,
                        onChanged: (value) {
                          setFilterState(() {
                            _tempSortBy = value;
                          });
                        },
                        activeColor: themeController.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter(XThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: XSizes.textSizeMd,
            fontWeight: FontWeight.bold,
            color: themeController.textColor,
            fontFamily: XFonts.lexend,
          ),
        ),
        SizedBox(height: XSizes.spacingSm),
        StatefulBuilder(
          builder: (context, setFilterState) {
            final minPrice = _tempMinPrice ?? 0.0;
            final maxPrice = _tempMaxPrice ?? 12999.0;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${minPrice.toInt()}',
                      style: TextStyle(
                        color: themeController.textColor,
                        fontFamily: XFonts.lexend,
                      ),
                    ),
                    Text(
                      '₹${maxPrice.toInt()}+',
                      style: TextStyle(
                        color: themeController.textColor,
                        fontFamily: XFonts.lexend,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(minPrice, maxPrice),
                  min: 0,
                  max: 12999,
                  divisions: 25,
                  activeColor: themeController.primaryColor,
                  inactiveColor: Colors.grey.withValues(alpha: 0.3),
                  onChanged: (values) {
                    setFilterState(() {
                      _tempMinPrice = values.start;
                      _tempMaxPrice = values.end;
                    });
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter(XThemeController themeController) {
    final ratings = [4.5, 4.0, 3.5, 3.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: TextStyle(
            fontSize: XSizes.textSizeMd,
            fontWeight: FontWeight.bold,
            color: themeController.textColor,
            fontFamily: XFonts.lexend,
          ),
        ),
        SizedBox(height: XSizes.spacingSm),
        StatefulBuilder(
          builder:
              (context, setFilterState) => Column(
                children:
                    ratings.map((rating) {
                      return RadioListTile<double>(
                        title: Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color:
                                    index < rating
                                        ? Colors.amber
                                        : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            SizedBox(width: XSizes.spacingXs),
                            Text(
                              '$rating & up',
                              style: TextStyle(
                                fontFamily: XFonts.lexend,
                                fontSize: XSizes.textSizeXs,
                              ),
                            ),
                          ],
                        ),
                        value: rating,
                        groupValue: _tempMinRating,
                        onChanged: (value) {
                          setFilterState(() {
                            _tempMinRating = value;
                          });
                        },
                        activeColor: themeController.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildBestSellerFilter(XThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Offers',
          style: TextStyle(
            fontSize: XSizes.textSizeMd,
            fontWeight: FontWeight.bold,
            color: themeController.textColor,
            fontFamily: XFonts.lexend,
          ),
        ),
        SizedBox(height: XSizes.spacingSm),
        StatefulBuilder(
          builder:
              (context, setFilterState) => CheckboxListTile(
                title: Text(
                  'Best Sellers Only',
                  style: TextStyle(
                    fontFamily: XFonts.lexend,
                    fontSize: XSizes.textSizeXs,
                  ),
                ),
                subtitle: Text(
                  'Show only top-rated courses',
                  style: TextStyle(
                    color: themeController.textColor.withValues(alpha: 0.6),
                    fontFamily: XFonts.lexend,
                    fontSize: XSizes.textSizeXxs,
                  ),
                ),
                value: _tempIsBestSeller == true,
                onChanged: (value) {
                  setFilterState(() {
                    _tempIsBestSeller = value;
                  });
                },
                activeColor: themeController.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersChips(XThemeController themeController) {
    return Obx(() {
      List<Widget> chips = [];

      // Program type filter
      if (_programsController.selectedProgramType.value != null) {
        String displayText =
            _programsController.selectedProgramType.value == 'program'
                ? 'Regular Programs'
                : 'Advanced Programs';
        chips.add(
          _buildFilterChip(displayText, () {
            _programsController.filterByProgramType(null);
          }, themeController),
        );
      }

      // Price range filter
      if (_programsController.selectedMinPrice.value != null ||
          _programsController.selectedMaxPrice.value != null) {
        String priceText =
            'Price: ₹${(_programsController.selectedMinPrice.value ?? 0).toInt()}-₹${(_programsController.selectedMaxPrice.value ?? 9999).toInt()}';
        chips.add(
          _buildFilterChip(priceText, () {
            _programsController.filterByPriceRange(null, null);
          }, themeController),
        );
      }

      // Rating filter
      if (_programsController.selectedMinRating.value != null) {
        chips.add(
          _buildFilterChip(
            '${_programsController.selectedMinRating.value}+ Rating',
            () {
              _programsController.filterByRating(null);
            },
            themeController,
          ),
        );
      }

      // Best seller filter
      if (_programsController.selectedIsBestSeller.value == true) {
        chips.add(
          _buildFilterChip('Best Sellers', () {
            _programsController.filterByBestSeller(null);
          }, themeController),
        );
      }

      // Search filter
      if (_programsController.searchQuery.value.isNotEmpty) {
        chips.add(
          _buildFilterChip(
            'Search: "${_programsController.searchQuery.value}"',
            () {
              _programsController.searchPrograms('');
            },
            themeController,
          ),
        );
      }

      if (chips.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters:',
                style: TextStyle(
                  fontSize: XSizes.textSizeXs,
                  color: themeController.textColor.withValues(alpha: 0.7),
                  fontFamily: XFonts.lexend,
                ),
              ),
              SizedBox(width: XSizes.spacingXs),
              TextButton(
                onPressed: () => _programsController.clearAllFilters(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: XSizes.textSizeXs,
                    color: themeController.primaryColor,
                    fontFamily: XFonts.lexend,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: XSizes.spacingXs),
          Wrap(
            spacing: XSizes.spacingXs,
            runSpacing: XSizes.spacingXs,
            children: chips,
          ),
          SizedBox(height: XSizes.spacingSm),
        ],
      );
    });
  }

  Widget _buildFilterChip(
    String label,
    VoidCallback onRemove,
    XThemeController themeController,
  ) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: XSizes.textSizeXxs,
          color: themeController.textColor,
          fontFamily: XFonts.lexend,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 16,
        color: themeController.textColor.withValues(alpha: 0.7),
      ),
      onDeleted: onRemove,
      backgroundColor: themeController.textColor.withValues(alpha: 0.1),
      side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
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
              controller: _searchController,
              focusNode: _searchFocusNode,
              cursorColor: themeController.primaryColor,
              onChanged: (value) {
                // Debounce search to avoid too many API calls
                _debounceSearch(value);
              },
              onSubmitted: (value) {
                // Immediate search on submit
                _performSearch(value);
              },
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
          Obx(
            () =>
                _programsController.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        _clearSearch();
                      },
                    )
                    : const SizedBox.shrink(),
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

  Widget _buildShimmerCategoryTabs(XThemeController themeController) {
    return SizedBox(
      height: XSizes.paddingXl + XSizes.paddingXs,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildShimmerWrapper(
            Container(
              margin: EdgeInsets.only(right: XSizes.marginSm),
              padding: EdgeInsets.symmetric(
                horizontal: XSizes.paddingMd,
                vertical: XSizes.paddingSm,
              ),
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
              ),
              child: SizedBox(
                width: 60 + (index * 10.0), // Varying widths
                height: 20,
              ),
            ),
            themeController,
          );
        },
      ),
    );
  }

  Widget _buildShimmerResultsHeader(XThemeController themeController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShimmerWrapper(
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: themeController.textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          themeController,
        ),
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
      ],
    );
  }

  Widget _buildShimmerCourseCard(XThemeController themeController) {
    return Container(
      margin: EdgeInsets.only(bottom: XSizes.marginMd),
      padding: EdgeInsets.all(XSizes.paddingSm),
      decoration: BoxDecoration(
        color: themeController.backgroundColor,
        borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
        border: Border.all(
          color: themeController.textColor.withValues(alpha: 0.05),
          width: XSizes.borderSizeSm,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerWrapper(
            Container(
              width: XSizes.iconSizeXxl + XSizes.paddingXl,
              height: XSizes.iconSizeXxl + XSizes.paddingXl,
              decoration: BoxDecoration(
                color: themeController.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
              ),
            ),
            themeController,
          ),
          SizedBox(width: XSizes.spacingMd),
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
                SizedBox(height: XSizes.spacingXxs),
                _buildShimmerWrapper(
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  themeController,
                ),
                SizedBox(height: XSizes.spacingXs),
                Row(
                  children: [
                    _buildShimmerWrapper(
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: themeController.textColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      themeController,
                    ),
                    SizedBox(width: XSizes.spacingMd),
                    _buildShimmerWrapper(
                      Container(
                        width: 70,
                        height: 12,
                        decoration: BoxDecoration(
                          color: themeController.textColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      themeController,
                    ),
                  ],
                ),
                SizedBox(height: XSizes.spacingXs),
                _buildShimmerWrapper(
                  Container(
                    width: double.infinity,
                    height: 12,
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
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  themeController,
                ),
                SizedBox(height: XSizes.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerWrapper(
                          Container(
                            width: 60,
                            height: 16,
                            decoration: BoxDecoration(
                              color: themeController.textColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          themeController,
                        ),
                        SizedBox(height: 4),
                        _buildShimmerWrapper(
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: themeController.textColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          themeController,
                        ),
                      ],
                    ),
                    _buildShimmerWrapper(
                      Container(
                        width: 90,
                        height: 35,
                        decoration: BoxDecoration(
                          color: themeController.textColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
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

  Widget _buildShimmerCourseList(XThemeController themeController) {
    return ListView.builder(
      itemCount: 5, // Reduced from 6 to 5 for better performance
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling during loading
      itemBuilder: (context, index) {
        return _buildShimmerCourseCard(themeController);
      },
    );
  }
}
