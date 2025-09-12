import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/fonts.dart';

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
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));
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
              child: Container(
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
                              child: _isSearchVisible
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
