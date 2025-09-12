import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:topgrade/features/presentation/controllers/theme_controller.dart';
import 'package:topgrade/utils/constants/sizes.dart';

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
  // List to hold the lesson data and manage the expansion state.
  late final List<Lesson> _lessons;

  @override
  void initState() {
    super.initState();
    // Initialize the lesson data when the widget is first created.
    _lessons = _getLessonsData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder:
          (themeController) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: XSizes.paddingXs),
            child: ExpansionPanelList(
              elevation: 0, // Remove shadow
              expansionCallback: (int index, bool isExpanded) {},
              children:
                  _lessons.map<ExpansionPanel>((Lesson lesson) {
                    return ExpansionPanel(
                      backgroundColor: themeController.backgroundColor,
                      canTapOnHeader: true,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: XSizes.paddingMd,
                            horizontal: XSizes.paddingMd,
                          ),
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: XSizes.textSizeMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: Container(
                        color: themeController.backgroundColor,
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                        ),
                        child: Column(
                          children:
                              lesson.subTopics.map((subTopic) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            subTopic.isLocked
                                                ? Colors.grey.shade300
                                                : themeController.primaryColor,
                                        child: Icon(
                                          subTopic.isLocked
                                              ? Icons.lock
                                              : Icons.play_arrow,
                                          size: 14,
                                          color:
                                              subTopic.isLocked
                                                  ? Colors.grey.shade600
                                                  : themeController.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        subTopic.title,
                                        style: const TextStyle(
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        subTopic.duration,
                                        style: const TextStyle(
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      isExpanded: lesson.isExpanded,
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
        title: '1. Introduction to Mobile Applications',
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
        title: '2. Introduction to Android',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: '3. Android Architecture',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: '4. Preparing Android Developement',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: '5. Creating First Android Application',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
      Lesson(
        title: '6. Android Application Component - Part 1',
        subTopics: [SubTopic(title: '...', duration: '...')],
      ),
    ];
  }
}
