import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/categories_controller.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';

// Course model for the course list
class Course {
  final String title;
  final String institution;
  final double rating;
  final String description;
  final int studentCount;
  final String imageUrl;
  final String category;
  final String duration;
  final double price;
  final bool isFree;

  Course({
    required this.title,
    required this.institution,
    required this.rating,
    required this.description,
    required this.studentCount,
    required this.imageUrl,
    required this.category,
    required this.duration,
    required this.price,
    this.isFree = false,
  });
}

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  bool _isSearchVisible = false;
  String _sortBy = 'Popular'; // Popular, Rating, Price, Recent
  final List<String> _sortOptions = ["Popular", "Rating", "Price", "Recent"];
  
  final CategoriesController _categoriesController = Get.put(CategoriesController());

  late AnimationController _searchAnimationController;
  late AnimationController _shimmerAnimationController;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
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
        
        // Listen to categories controller loading state
        ever(_categoriesController.isLoading, (isLoading) {
          if (!isLoading) {
            _shimmerAnimationController.stop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _shimmerAnimationController.dispose();
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

  void _showSortOptions(XThemeController themeController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeController.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(XSizes.borderRadiusMd),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(XSizes.paddingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: TextStyle(
                  fontSize: XSizes.textSizeLg,
                  fontWeight: FontWeight.bold,
                  color: themeController.textColor,
                  fontFamily: XFonts.lexend,
                ),
              ),
              SizedBox(height: XSizes.spacingMd),
              ..._sortOptions.map(
                (option) => ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      color: themeController.textColor,
                      fontFamily: XFonts.lexend,
                    ),
                  ),
                  leading: Radio<String>(
                    value: option,
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                      Navigator.pop(context);
                    },
                    activeColor: themeController.primaryColor,
                  ),
                  onTap: () {
                    setState(() {
                      _sortBy = option;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: XSizes.spacingMd),
            ],
          ),
        );
      },
    );
  }

  // Sample course data
  final List<Course> courses = [
    Course(
      title: 'Complete Flutter Development Bootcamp',
      institution: 'Tech Academy',
      rating: 4.8,
      description:
          'Learn Flutter from scratch and build amazing mobile apps. This comprehensive course covers everything from basics to advanced concepts.',
      studentCount: 12567,
      imageUrl:
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500',
      category: 'Programming',
      duration: '42 hours',
      price: 89.99,
    ),
    Course(
      title: 'UI/UX Design Masterclass',
      institution: 'Design Institute',
      rating: 4.6,
      description:
          'Master the art of user interface and user experience design. Create stunning designs that users love.',
      studentCount: 8934,
      imageUrl:
          'https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=500',
      category: 'Design',
      duration: '28 hours',
      price: 79.99,
    ),
    Course(
      title: 'Digital Marketing Strategy',
      institution: 'Marketing Pro Academy',
      rating: 4.5,
      description:
          'Learn effective digital marketing strategies to grow your business online and reach your target audience.',
      studentCount: 6789,
      imageUrl:
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500',
      category: 'Marketing',
      duration: '35 hours',
      price: 69.99,
    ),
    Course(
      title: 'Business Analytics with Python',
      institution: 'Data Science Hub',
      rating: 4.7,
      description:
          'Analyze business data using Python. Learn data visualization, statistical analysis, and business intelligence.',
      studentCount: 5432,
      imageUrl:
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500',
      category: 'Business',
      duration: '45 hours',
      price: 99.99,
    ),
    Course(
      title: 'Photography Fundamentals',
      institution: 'Creative Arts School',
      rating: 4.4,
      description:
          'Master the basics of photography including composition, lighting, and editing techniques.',
      studentCount: 4321,
      imageUrl:
          'https://images.unsplash.com/photo-1606983340126-99ab4feaa64a?w=500',
      category: 'Photography',
      duration: '20 hours',
      price: 49.99,
    ),
    Course(
      title: 'React Native Development',
      institution: 'Mobile Dev Academy',
      rating: 4.6,
      description:
          'Build cross-platform mobile apps with React Native. Learn to create apps for both iOS and Android.',
      studentCount: 7890,
      imageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=500',
      category: 'Programming',
      duration: '38 hours',
      price: 84.99,
    ),
    Course(
      title: 'Graphic Design for Beginners',
      institution: 'Creative Studio',
      rating: 4.3,
      description:
          'Learn the fundamentals of graphic design using industry-standard tools and techniques.',
      studentCount: 3456,
      imageUrl:
          'https://images.unsplash.com/photo-1626785774573-4b799315345d?w=500',
      category: 'Design',
      duration: '25 hours',
      price: 0.0,
      isFree: true,
    ),
  ];

  List<Course> get filteredCourses {
    List<Course> filtered = courses;

    // Filter by category
    if (_selectedCategoryIndex != 0) {
      filtered =
          filtered
              .where(
                (course) =>
                    course.category == _categoriesController.displayCategories[_selectedCategoryIndex],
              )
              .toList();
    }

    // Sort courses
    switch (_sortBy) {
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Recent':
        // For demo purposes, we'll reverse the list for "recent"
        filtered = filtered.reversed.toList();
        break;
      case 'Popular':
      default:
        filtered.sort((a, b) => b.studentCount.compareTo(a.studentCount));
        break;
    }

    return filtered;
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
                  onPressed: () => _showSortOptions(themeController),
                  icon: Icon(
                    Icons.sort,
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
                    Obx(() => _categoriesController.isLoading.value 
                        ? _buildShimmerCategoryTabs(themeController) 
                        : _buildCategoryTabs(themeController)),
                    SizedBox(height: XSizes.spacingMd),
                    Obx(() => _categoriesController.isLoading.value 
                        ? _buildShimmerResultsHeader(themeController) 
                        : _buildResultsHeader(themeController)),
                    SizedBox(height: XSizes.spacingSm),
                    Expanded(
                      child: Obx(() => _categoriesController.isLoading.value 
                          ? _buildShimmerCourseList(themeController) 
                          : _buildCourseList(themeController)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${filteredCourses.length} courses found',
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeController.primaryColor.withValues(alpha: 0.1),
                        themeController.primaryColor.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: XSizes.paddingXs,
                  right: XSizes.paddingXs,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: XSizes.paddingXs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          course.isFree
                              ? Colors.green
                              : themeController.primaryColor,
                      borderRadius: BorderRadius.circular(
                        XSizes.borderRadiusXs,
                      ),
                    ),
                    child: Text(
                      course.isFree ? 'FREE' : course.category.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
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
                  course.title,
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
                    SizedBox(width: XSizes.spacingMd),
                    Icon(
                      Icons.access_time,
                      color: themeController.textColor.withValues(alpha: 0.5),
                      size: XSizes.iconSizeXs,
                    ),
                    SizedBox(width: XSizes.spacingXs),
                    Text(
                      course.duration,
                      style: TextStyle(
                        fontSize: XSizes.textSizeXs,
                        color: themeController.textColor.withValues(alpha: 0.6),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (course.isFree)
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
                            '\$${course.price.toStringAsFixed(2)}',
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
                              '${course.studentCount} students',
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
                        Get.toNamed('/course-details');
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
                        course.isFree ? 'Enroll Free' : 'View Details',
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
    );
  }

  Widget _buildCourseList(XThemeController themeController) {
    final courses = filteredCourses;

    if (courses.isEmpty) {
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

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(courses[index], themeController);
      },
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
