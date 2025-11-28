import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:topgrade/features/presentation/routes/routes.dart';
import 'package:topgrade/features/presentation/views/course_details/tabs/lession_tab.dart';
import 'package:topgrade/features/presentation/widgets/primary_button.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/course_details_controller.dart';
import '../../controllers/bookmarks_controller.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';
import '../../../../utils/constants/api_endpoints.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final CourseDetailsController _controller = Get.put(
    CourseDetailsController(),
  );
  final BookmarksController _bookmarksController = Get.put(
    BookmarksController(),
  );

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
              Obx(
                () => GestureDetector(
                  onTap:
                      _bookmarksController.isBookmarkLoading.value
                          ? null
                          : () async {
                            await _bookmarksController.toggleBookmark(
                              programId: _controller.programId,
                              currentBookmarkStatus: _controller.isBookmarked,
                            );
                            // Refresh program details to update bookmark status
                            _controller.fetchProgramDetails();
                          },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: XSizes.paddingMd,
                      top: XSizes.spacingSm,
                      bottom: XSizes.spacingSm,
                    ),
                    padding: EdgeInsets.all(XSizes.spacingSm),
                    decoration: BoxDecoration(
                      color:
                          _bookmarksController.isBookmarkLoading.value
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        XSizes.borderRadiusLg,
                      ),
                    ),
                    child:
                        _bookmarksController.isBookmarkLoading.value
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(
                              _controller.isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                  ),
                ),
              ),
            ],
          ),
          body: Obx(() {
            if (_controller.isLoading.value) {
              return _buildLoadingState(themeController);
            }

            if (_controller.hasError.value) {
              return _buildErrorState(themeController);
            }

            if (!_controller.hasData) {
              return _buildNotFoundState(themeController);
            }

            final program = _controller.program!;

            return DefaultTabController(
              length: 2, // Changed to 2 tabs
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
                            program.image.startsWith('http')
                                ? program.image
                                : '${ApiEndpoints.baseUrl}${program.image}',
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 230,
                                  width: double.infinity,
                                  color: themeController.textColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: themeController.textColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
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
                              program.title,
                              style: TextStyle(
                                fontSize: XSizes.textSizeSm,
                                fontWeight: FontWeight.bold,
                                fontFamily: XFonts.lexend,
                                color: themeController.primaryColor,
                              ),
                            ),
                            SizedBox(height: XSizes.spacingXs),
                            Text(
                              program.subtitle,
                              style: TextStyle(
                                fontSize: XSizes.textSizeXl,
                                fontFamily: XFonts.lexend,
                                fontWeight: FontWeight.w500,
                                color: themeController.textColor,
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
                                      color: themeController.textColor
                                          .withValues(alpha: 0.6),
                                      size: XSizes.iconSizeSm,
                                    ),
                                    SizedBox(width: XSizes.spacingXs),
                                    Text(
                                      '${program.enrolledStudents} students enrolled',
                                      style: TextStyle(
                                        fontSize: XSizes.textSizeXs,
                                        fontFamily: XFonts.lexend,
                                        color: themeController.textColor
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (program.pricing.discountPercentage >
                                        0) ...[
                                      Text(
                                        '₹ ${program.pricing.originalPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: XSizes.textSizeSm,
                                          fontFamily: XFonts.lexend,
                                          color: themeController.textColor
                                              .withValues(alpha: 0.5),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        '₹ ${program.pricing.discountedPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: XSizes.textSizeLg,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: XFonts.lexend,
                                          color: themeController.textColor,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        '₹ ${program.pricing.originalPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: XSizes.textSizeLg,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: XFonts.lexend,
                                          color: themeController.textColor,
                                        ),
                                      ),
                                    ],
                                  ],
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
                      padding: EdgeInsets.symmetric(
                        horizontal: XSizes.paddingMd,
                      ),
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
                                      color: themeController.textColor
                                          .withValues(alpha: 0.6),
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(text: program.description),
                                      TextSpan(
                                        text: ' Read More...',
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
                                      children:
                                          _controller.staticSkills
                                              .map(
                                                (skill) => _buildSkillChip(
                                                  themeController,
                                                  skill,
                                                ),
                                              )
                                              .toList(),
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
                                      value:
                                          "${_controller.syllabus?.totalTopics} Lecture${_controller.syllabus?.totalModules != 1 ? 's' : ''}",
                                    ),
                                    SizedBox(height: XSizes.spacingLg),
                                    _buildDetailRow(
                                      themeController: themeController,
                                      icon: Icons.access_time_filled,
                                      label: 'Learning Time',
                                      value:
                                          _controller.program?.duration ??
                                          'N/A',
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
                              ],
                            ),
                          ),
                          // Lessons Tab - Scrollable
                          LessonsTab(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Request Access Button
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(XSizes.paddingMd),
            child: Obx(
              () {
                final hasPurchased = _controller.program?.hasPurchased == true;
                final hasRequested = _controller.hasProgramRequested;
                
                String buttonText;
                if (hasPurchased) {
                  buttonText = 'Go to Course';
                } else if (hasRequested) {
                  buttonText = 'Access Requested';
                } else {
                  buttonText = 'Request Access';
                }

                return PrimaryButton(
                  text: buttonText,
                  isLoading: _controller.isRequestingAccess.value,
                  // Disable button if already requested but not purchased
                  onPressed: (hasPurchased || (!hasPurchased && !hasRequested))
                      ? () {
                          if (hasPurchased) {
                            final syllabusData = _controller.syllabus;
                            if (syllabusData != null &&
                                syllabusData.modules.isNotEmpty) {
                              // Get first module and first topic
                              final firstModule = syllabusData.modules.first;
                              final firstTopic =
                                  firstModule.topics.isNotEmpty
                                      ? firstModule.topics.first
                                      : null;

                              if (firstTopic != null) {
                                final syllabusJson = {
                                  'total_modules': syllabusData.totalModules,
                                  'total_topics': syllabusData.totalTopics,
                                  'modules':
                                      syllabusData.modules
                                          .map(
                                            (m) => {
                                              'id': m.id,
                                              'module_title': m.moduleTitle,
                                              'topics_count': m.topicsCount,
                                              'topics':
                                                  m.topics
                                                      .map(
                                                        (t) => {
                                                          'id': t.id,
                                                          'topic_title': t.topicTitle,
                                                          'video_url': t.videoUrl,
                                                          'video_duration':
                                                              t.videoDuration,
                                                        },
                                                      )
                                                      .toList(),
                                            },
                                          )
                                          .toList(),
                                };

                                Get.toNamed(
                                  XRoutes.videoPlayer,
                                  arguments: {
                                    'syllabus': syllabusJson,
                                    'currentTopicId': firstTopic.id,
                                    'videoTitle': firstTopic.topicTitle,
                                    'moduleTitle': firstModule.moduleTitle,
                                    'programTitle':
                                        _controller.program?.title ?? 'Course',
                                    'hasPurchased': _controller.program?.hasPurchased,
                                    'purchaseId': _controller.program?.purchaseId,
                                  },
                                );
                              }
                            }
                          } else {
                            // Request access to the program
                            _controller.requestProgramAccess();
                          }
                        }
                      : null, // null disables the button
                );
              },
            ),
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

  // Loading state
  Widget _buildLoadingState(XThemeController themeController) {
    return Center(
      child: CircularProgressIndicator(color: themeController.primaryColor),
    );
  }

  // Error state
  Widget _buildErrorState(XThemeController themeController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: themeController.textColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: XSizes.spacingMd),
          Text(
            'Error Loading Course',
            style: TextStyle(
              fontSize: XSizes.textSizeLg,
              fontWeight: FontWeight.bold,
              fontFamily: XFonts.lexend,
              color: themeController.textColor,
            ),
          ),
          SizedBox(height: XSizes.spacingSm),
          Text(
            _controller.errorMessage.value,
            style: TextStyle(
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
              color: themeController.textColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: XSizes.spacingLg),
          ElevatedButton(
            onPressed: () => _controller.retry(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Not found state
  Widget _buildNotFoundState(XThemeController themeController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: themeController.textColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: XSizes.spacingMd),
          Text(
            'Course Not Found',
            style: TextStyle(
              fontSize: XSizes.textSizeLg,
              fontWeight: FontWeight.bold,
              fontFamily: XFonts.lexend,
              color: themeController.textColor,
            ),
          ),
          SizedBox(height: XSizes.spacingSm),
          Text(
            'The course you are looking for does not exist.',
            style: TextStyle(
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
              color: themeController.textColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
