import 'package:flutter/material.dart' hide CarouselController;
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../data/model/program_model.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/categories_controller.dart';
import '../../../controllers/landing_controller.dart';
import '../../../controllers/carousel_controller.dart';
import '../../../controllers/my_learnings_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/api_endpoints.dart';
import '../../../../../utils/helpers/token_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _shimmerAnimationController;
  late Animation<double> _shimmerAnimation;

  final CategoriesController _categoriesController = Get.put(
    CategoriesController(),
  );
  final LandingController _landingController = Get.put(LandingController());
  final CarouselController _carouselController = Get.put(CarouselController());
  final MyLearningsController _myLearningsController = Get.put(MyLearningsController());

  // Current carousel index for indicators
  int _currentCarouselIndex = 0;
  
  // User name
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();

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

        // Listen to controllers' loading states
        ever(_landingController.isLoading, (isLoading) {
          if (!isLoading && !_categoriesController.isLoading.value && mounted) {
            if (_shimmerAnimationController.isAnimating) {
              _shimmerAnimationController.stop();
            }
          }
        });

        ever(_categoriesController.isLoading, (isLoading) {
          if (!isLoading && !_landingController.isLoading.value && mounted) {
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
    WidgetsBinding.instance.removeObserver(this);
    _shimmerAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh data when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _refreshAllData();
    }
  }

  // Refresh all data on app resume
  void _refreshAllData() {
    _categoriesController.fetchCategories();
    _landingController.fetchLandingData();
    _carouselController.fetchCarouselData();
    _myLearningsController.fetchAllLearnings();
  }

  // Load user name from storage
  Future<void> _loadUserName() async {
    final fullname = await TokenHelper.getUserFullname();
    if (fullname != null && fullname.isNotEmpty && mounted) {
      setState(() {
        _userName = fullname;
      });
    }
  }

  // Get dynamic greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }

  // Get combined loading state from controllers
  bool get isLoading =>
      _landingController.isLoading.value ||
      _categoriesController.isLoading.value ||
      _carouselController.isLoading.value;

  // Refresh landing data
  Future<void> _refreshLandingData() async {
    // Refresh landing data, categories, and carousel
    await Future.wait<void>([
      _landingController.fetchLandingData(),
      _categoriesController.fetchCategories(),
      _carouselController.refreshCarouselData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Scaffold(
            backgroundColor: themeController.backgroundColor,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshLandingData,
                color: themeController.primaryColor,
                backgroundColor: themeController.backgroundColor,
                strokeWidth: 2.5,
                displacement: 60,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(XSizes.paddingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerAppBar()
                                  : _buildAppBar(),
                        ),
                        SizedBox(height: XSizes.spacingMd),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerSearchBar()
                                  : _buildSearchBar(),
                        ),
                        SizedBox(height: XSizes.spacingMd),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerCarousel()
                                  : _buildImageCarousel(),
                        ),
                        // Continue Watching Section - only show if data exists
                        SizedBox(height: XSizes.spacingMd),
                        Obx(
                          () =>
                              _myLearningsController.inProgressLearnings.isNotEmpty 
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader("Continue Watching"),
                                      SizedBox(height: XSizes.spacingSm),
                                      ..._myLearningsController.inProgressLearnings.map(
                                        (learning) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: XSizes.spacingSm,
                                          ),
                                          child:
                                              _buildContinueWatchingProgramCard(
                                                learning,
                                              ),
                                        ),
                                      ),
                                      SizedBox(height: XSizes.spacingMd),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                        ),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerSectionHeader()
                                  : _buildSectionHeader("Categories"),
                        ),
                        SizedBox(height: XSizes.spacingSm),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerCategories()
                                  : _buildRealCategories(),
                        ),
                        SizedBox(height: XSizes.spacingMd),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerSectionHeader()
                                  : _buildSectionHeader(
                                    "Suggestions for You",
                                    showViewAll: true,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerHorizontalCourseList()
                                  : _buildRealHorizontalCourseList(
                                    _landingController.suggestionsForYou,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerSectionHeader()
                                  : _buildSectionHeader(
                                    "Top Courses",
                                    showViewAll: true,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerHorizontalCourseList()
                                  : _buildRealHorizontalCourseList(
                                    _landingController.topCourses,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerSectionHeader()
                                  : _buildSectionHeader(
                                    "Programs",
                                    showViewAll: true,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () =>
                              isLoading
                                  ? _buildShimmerHorizontalCourseList()
                                  : _buildRealHorizontalCourseList(
                                    _landingController.programs,
                                  ),
                        ),
                        SizedBox(
                          height: XSizes.spacingMd,
                        ), // Extra bottom padding
                      ],
                    ),
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
              Image.asset(
                'assets/images/logo_main.png',
                width: 160,
                height: 60,
                fit: BoxFit.contain,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: XSizes.textSizeMd,
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor,
                    ),
                  ),
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: XSizes.textSizeLg,
                      fontFamily: XFonts.lexend,
                      color: themeController.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildSearchBar() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => GestureDetector(
            onTap: () {
              // Navigate to course list screen with search focused
              Get.toNamed('/course-list', arguments: {'autoFocusSearch': true});
            },
            child: Container(
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
                      enabled: false,
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
          ),
    );
  }

  Widget _buildRealCategories() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Obx(() {
            if (_categoriesController.isLoading.value) {
              return _buildShimmerCategories();
            }
            if (_categoriesController.hasError.value) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: XSizes.paddingMd,
                  vertical: XSizes.paddingSm,
                ),
                child: Text(
                  'Unable to load categories',
                  style: TextStyle(
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor.withValues(alpha: 0.5),
                    fontSize: XSizes.textSizeXs,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _categoriesController.categories
                        .map(
                          (category) => _buildCategoryChip(
                            category.name,
                            category.id,
                            themeController,
                          ),
                        )
                        .toList(),
              ),
            );
          }),
    );
  }

  Widget _buildCategoryChip(
    String label,
    int categoryId,
    XThemeController themeController,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to course list with category filter applied
        Get.toNamed(
          '/course-list',
          arguments: {'categoryId': categoryId, 'categoryName': label},
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: XSizes.marginSm),
        padding: EdgeInsets.symmetric(
          horizontal: XSizes.paddingMd,
          vertical: XSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: themeController.textColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealHorizontalCourseList(List<dynamic> programs) {
    if (programs.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: GetBuilder<XThemeController>(
            builder:
                (themeController) => Text(
                  'No courses available',
                  style: TextStyle(
                    color: themeController.textColor.withValues(alpha: 0.6),
                    fontFamily: XFonts.lexend,
                    fontSize: XSizes.textSizeSm,
                  ),
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return _buildRealSuggestionCard(program);
        },
      ),
    );
  }

  Widget _buildRealSuggestionCard(dynamic program) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => GestureDetector(
            onTap: () {
              Get.toNamed(
                '/course-details',
                arguments: {'programId': program.id},
              );
            },
            child: Container(
              width: 160,
              margin: EdgeInsets.only(right: XSizes.marginSm + XSizes.marginXs),
              padding: EdgeInsets.symmetric(
                horizontal: XSizes.paddingXs,
                vertical: XSizes.paddingXs,
              ),
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
                            XSizes.borderRadiusMd,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
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
                      ),
                      if (program.isBestSeller)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'BEST',
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
                  const SizedBox(height: 8),
                  Text(
                    program.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: XSizes.textSizeSm,
                      fontFamily: XFonts.lexend,
                      color: themeController.textColor,
                    ),
                  ),
                  SizedBox(height: XSizes.spacingXs),
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
                  SizedBox(height: XSizes.spacingXxs),
                  Text(
                    '${program.enrolledStudents} students',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: themeController.textColor.withValues(alpha: 0.5),
                      fontSize: XSizes.textSizeXxs,
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
                        program.programRating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: XSizes.textSizeXs,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildContinueWatchingProgramCard(dynamic learningData) {
    // Extract program and progress data based on type
    final program = learningData is ProgramModel ? learningData : learningData.program;
    final progress = learningData is ProgramModel ? null : learningData.progress;
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => GestureDetector(
            onTap: () {
              Get.toNamed(
                '/course-details',
                arguments: {'programId': program.id},
              );
            },
            child: Container(
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
                      borderRadius: BorderRadius.circular(
                        XSizes.borderRadiusMd,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        XSizes.borderRadiusMd,
                      ),
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
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: themeController.textColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: themeController.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.subtitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: XSizes.textSizeMd,
                            fontFamily: XFonts.lexend,
                            color: themeController.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          program.category?.name ?? 'General',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: XSizes.textSizeXs,
                            fontFamily: XFonts.lexend,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              program.programRating.toString(),
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
                                value: progress != null 
                                    ? (progress.percentage / 100.0).clamp(0.0, 1.0)
                                    : 0.0,
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
                              progress != null 
                                  ? '${progress.percentage.toStringAsFixed(0)}%'
                                  : '0%',
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
          ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Row(
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

  Widget _buildImageCarousel() {
    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return Obx(() {
          final carouselSlides = _carouselController.carouselSlides;

          // Show shimmer if loading or no data, fallback to sample images if API fails
          if (_carouselController.isLoading.value || carouselSlides.isEmpty) {
            return _buildShimmerCarousel();
          }

          // Convert API slides to image URLs for existing carousel structure
          final List<String> carouselImages =
              carouselSlides.map((slide) => slide.image).toList();

          return CarouselSlider(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
            items:
                carouselImages.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(
                          horizontal: XSizes.marginXs,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            XSizes.borderRadiusMd,
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: themeController.textColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: themeController.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: themeController.textColor
                                          .withValues(alpha: 0.1),
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: themeController.textColor
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                              ),
                              // Gradient overlay for better contrast
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.3),
                                    ],
                                  ),
                                ),
                              ),
                              // Carousel Indicators positioned at bottom center
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      carouselImages.asMap().entries.map((
                                        entry,
                                      ) {
                                        return GestureDetector(
                                          onTap: () {
                                            // You can add functionality to jump to specific slide here if needed
                                          },
                                          child: Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  _currentCarouselIndex ==
                                                          entry.key
                                                      ? Colors.white
                                                      : Colors.white.withValues(
                                                        alpha: 0.5,
                                                      ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
          );
        });
      },
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
      builder:
          (themeController) => Row(
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
      builder:
          (themeController) => _buildShimmerWrapper(
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
      builder:
          (themeController) => Row(
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

  Widget _buildShimmerCategories() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(
                3,
                (index) => _buildShimmerWrapper(
                  Container(
                    margin: EdgeInsets.only(right: XSizes.marginSm),
                    padding: EdgeInsets.symmetric(
                      horizontal: XSizes.paddingLg,
                      vertical: XSizes.paddingSm,
                    ),
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        XSizes.borderRadiusXl,
                      ),
                    ),
                    child: SizedBox(width: 80 + (index * 15.0), height: 16),
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
      builder:
          (themeController) => SizedBox(
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
          const SizedBox(height: 8),
          _buildShimmerWrapper(
            Container(
              width: 80,
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

  Widget _buildShimmerCarousel() {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Container(
            height: 160,
            margin: EdgeInsets.symmetric(horizontal: XSizes.marginXs),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildShimmerWrapper(
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: themeController.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        XSizes.borderRadiusMd,
                      ),
                    ),
                  ),
                  themeController,
                );
              },
            ),
          ),
    );
  }
}
