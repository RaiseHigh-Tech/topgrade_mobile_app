import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/course_details_controller.dart';
import '../../../routes/routes.dart';
import '../../../../data/model/program_details_response_model.dart';

class LessonsTab extends StatefulWidget {
  const LessonsTab({super.key});

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab> {
  late final CourseDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CourseDetailsController>();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => Obx(() {
            // Show loading state
            if (_controller.isLoading.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(XSizes.spacingXl),
                  child: CircularProgressIndicator(
                    color: themeController.primaryColor,
                  ),
                ),
              );
            }

            // Show error state
            if (_controller.hasError.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(XSizes.spacingXl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: themeController.textColor.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      Text(
                        'Failed to load syllabus',
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontFamily: XFonts.lexend,
                          fontWeight: FontWeight.w500,
                          color: themeController.textColor.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      ElevatedButton(
                        onPressed: () => _controller.retry(),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show syllabus data
            final syllabus = _controller.syllabus;
            if (syllabus == null || syllabus.modules.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(XSizes.spacingXl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: themeController.textColor.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      Text(
                        'No syllabus available',
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontFamily: XFonts.lexend,
                          fontWeight: FontWeight.w500,
                          color: themeController.textColor.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                top: XSizes.spacingLg,
                bottom: XSizes.spacingXxl,
              ),
              child: Column(
                children:
                    syllabus.modules.asMap().entries.map((entry) {
                      int moduleIndex = entry.key;
                      ModuleModel module = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: XSizes.spacingMd),
                        decoration: BoxDecoration(
                          color: themeController.backgroundColor,

                          border: Border.all(
                            color: themeController.textColor.withValues(
                              alpha: 0.05,
                            ),
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: themeController.textColor.withValues(
                              alpha: 0.05,
                            ),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded:
                                moduleIndex == 0, // First module expanded
                            onExpansionChanged: (bool expanded) {
                              // Remove setState since we're not tracking expansion state
                            },
                            tilePadding: EdgeInsets.symmetric(
                              horizontal: XSizes.paddingMd,
                              vertical: XSizes.paddingXs,
                            ),
                            childrenPadding: EdgeInsets.only(
                              left: XSizes.paddingMd,
                              right: XSizes.paddingMd,
                              bottom: XSizes.paddingMd,
                            ),
                            backgroundColor: themeController.backgroundColor,
                            collapsedBackgroundColor:
                                themeController.backgroundColor,
                            iconColor: themeController.primaryColor,
                            collapsedIconColor: themeController.textColor
                                .withValues(alpha: 0.6),
                            title: Row(
                              children: [
                                // Extract and display serial number
                                Container(
                                  width: XSizes.iconSizeLg,
                                  height: XSizes.iconSizeLg,
                                  decoration: BoxDecoration(
                                    color: themeController.primaryColor
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${moduleIndex + 1}',
                                      style: TextStyle(
                                        fontSize: XSizes.textSizeXs,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: XFonts.lexend,
                                        color: themeController.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: XSizes.spacingMd),
                                // Display title without serial number
                                Expanded(
                                  child: Text(
                                    module.moduleTitle,
                                    style: TextStyle(
                                      fontSize: XSizes.textSizeSm,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: XFonts.lexend,
                                      color: themeController.textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children:
                                module.topics.map((topic) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                      bottom: XSizes.spacingSm,
                                    ),
                                    padding: EdgeInsets.all(XSizes.paddingMd),
                                    decoration: BoxDecoration(
                                      color: themeController.textColor
                                          .withValues(alpha: 0.02),
                                      borderRadius: BorderRadius.circular(
                                        XSizes.borderRadiusMd,
                                      ),
                                      border: Border.all(
                                        color: themeController.textColor
                                            .withValues(alpha: 0.05),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: XSizes.iconSizeMd,
                                          height: XSizes.iconSizeMd,
                                          decoration: BoxDecoration(
                                            color:
                                                topic.videoUrl.isEmpty
                                                    ? themeController.textColor
                                                        .withValues(alpha: 0.1)
                                                    : themeController
                                                        .primaryColor
                                                        .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: GestureDetector(
                                            onTap:
                                                topic.videoUrl.isEmpty
                                                    ? null
                                                    : () {
                                                      try {
                                                        final syllabusData =
                                                            _controller
                                                                .syllabus;

                                                        if (syllabusData !=
                                                            null) {
                                                          final syllabusJson = {
                                                            'total_modules':
                                                                syllabusData
                                                                    .totalModules,
                                                            'total_topics':
                                                                syllabusData
                                                                    .totalTopics,
                                                            'modules':
                                                                syllabusData
                                                                    .modules
                                                                    .map(
                                                                      (m) => {
                                                                        'id':
                                                                            m.id,
                                                                        'module_title':
                                                                            m.moduleTitle,
                                                                        'topics_count':
                                                                            m.topicsCount,
                                                                        'topics':
                                                                            m.topics
                                                                                .map(
                                                                                  (
                                                                                    t,
                                                                                  ) => {
                                                                                    'id':
                                                                                        t.id,
                                                                                    'topic_title':
                                                                                        t.topicTitle,
                                                                                    'video_url':
                                                                                        t.videoUrl,
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
                                                              'syllabus':
                                                                  syllabusJson,
                                                              'currentTopicId':
                                                                  topic.id,
                                                              'videoTitle':
                                                                  topic
                                                                      .topicTitle,
                                                              'moduleTitle':
                                                                  module
                                                                      .moduleTitle,
                                                              'programTitle':
                                                                  _controller
                                                                      .program
                                                                      ?.title ??
                                                                  'Course',
                                                              'hasPurchased':
                                                                  _controller
                                                                      .programDetails
                                                                      .value
                                                                      ?.program
                                                                      .hasPurchased ??
                                                                  false,
                                                              'purchaseId':
                                                                  _controller
                                                                      .programDetails
                                                                      .value
                                                                      ?.program
                                                                      .purchaseId,
                                                            },
                                                          );
                                                        } else {
                                                          // Fallback to simple navigation
                                                          Get.toNamed(
                                                            XRoutes.videoPlayer,
                                                            arguments: {
                                                              'videoTitle':
                                                                  topic
                                                                      .topicTitle,
                                                              'moduleTitle':
                                                                  module
                                                                      .moduleTitle,
                                                            },
                                                          );
                                                        }
                                                      } catch (e) {
                                                        // Show error message to user
                                                        Get.snackbar(
                                                          'Error',
                                                          'Failed to open video player: ${e.toString()}',
                                                          backgroundColor:
                                                              Colors.red,
                                                          colorText:
                                                              Colors.white,
                                                          duration: Duration(
                                                            seconds: 3,
                                                          ),
                                                        );
                                                      }
                                                    },
                                            child: Icon(
                                              topic.videoUrl.isEmpty
                                                  ? Icons.lock
                                                  : Icons.play_arrow,
                                              size: XSizes.iconSizeXs,
                                              color:
                                                  topic.videoUrl.isEmpty
                                                      ? themeController
                                                          .textColor
                                                          .withValues(
                                                            alpha: 0.4,
                                                          )
                                                      : themeController
                                                          .primaryColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: XSizes.spacingMd),
                                        Expanded(
                                          child: Text(
                                            topic.topicTitle,
                                            style: TextStyle(
                                              fontSize: XSizes.textSizeXs,
                                              fontFamily: XFonts.lexend,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  topic.videoUrl.isEmpty
                                                      ? themeController
                                                          .textColor
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                      : themeController
                                                          .textColor
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: XSizes.paddingSm,
                                            vertical: XSizes.paddingXs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: themeController.textColor
                                                .withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                              XSizes.borderRadiusSm,
                                            ),
                                          ),
                                          child: Text(
                                            topic.videoDuration ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: XSizes.textSizeXs,
                                              fontFamily: XFonts.lexend,
                                              fontWeight: FontWeight.w500,
                                              color: themeController.textColor
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          }),
    );
  }
}
