import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/theme_controller.dart';

class SubTopic {
  final String title;
  final String duration;
  final bool isLocked;

  SubTopic({required this.title, required this.duration, this.isLocked = true});
}

/// Represents a main lesson section, which can be expanded.
class Lesson {
  final String title;
  final List<SubTopic> subTopics;
  bool isExpanded;

  Lesson({
    required this.title,
    required this.subTopics,
    this.isExpanded = false,
  });
}

class LessonsTab extends StatefulWidget {
  const LessonsTab({super.key});

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab> {
  late final List<Lesson> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = _getLessonsData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => SingleChildScrollView(
            padding: EdgeInsets.only(
              top: XSizes.spacingLg,
              bottom: XSizes.spacingXxl,
            ),
            child: Column(
              children:
                  _lessons.asMap().entries.map((entry) {
                    int index = entry.key;
                    Lesson lesson = entry.value;
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
                          initiallyExpanded: lesson.isExpanded,
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              lesson.isExpanded = expanded;
                            });
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
                                    '${index + 1}',
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
                                  lesson.title,
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
                              lesson.subTopics.map((subTopic) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: XSizes.spacingSm,
                                  ),
                                  padding: EdgeInsets.all(XSizes.paddingMd),
                                  decoration: BoxDecoration(
                                    color: themeController.textColor.withValues(
                                      alpha: 0.02,
                                    ),
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
                                              subTopic.isLocked
                                                  ? themeController.textColor
                                                      .withValues(alpha: 0.1)
                                                  : themeController.primaryColor
                                                      .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          subTopic.isLocked
                                              ? Icons.lock
                                              : Icons.play_arrow,
                                          size: XSizes.iconSizeXs,
                                          color:
                                              subTopic.isLocked
                                                  ? themeController.textColor
                                                      .withValues(alpha: 0.4)
                                                  : themeController
                                                      .primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: XSizes.spacingMd),
                                      Expanded(
                                        child: Text(
                                          subTopic.title,
                                          style: TextStyle(
                                            fontSize: XSizes.textSizeXs,
                                            fontFamily: XFonts.lexend,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                subTopic.isLocked
                                                    ? themeController.textColor
                                                        .withValues(alpha: 0.5)
                                                    : themeController.textColor
                                                        .withValues(alpha: 0.8),
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
                                          subTopic.duration,
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
          ),
    );
  }

  // --- Dummy Data Source for Lessons ---
  List<Lesson> _getLessonsData() {
    return [
      Lesson(
        title: 'Introduction to Mobile Applications',
        isExpanded: true, // Initially expanded as in the image
        subTopics: [
          SubTopic(
            title: 'Brief history of mobile applications',
            duration: '2:00',
            isLocked: false,
          ),
          SubTopic(
            title: 'Brief history of mobile applications',
            duration: '15:00',
            isLocked: true,
          ),
          SubTopic(
            title: 'Brief history of mobile applications',
            duration: '22:00',
            isLocked: true,
          ),
        ],
      ),
      Lesson(
        title: 'Introduction to Android',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: 'Android Architecture',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: 'Preparing Android Developement',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: 'Creating First Android Application',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: 'Android Application Component - Part 1',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
    ];
  }
}
