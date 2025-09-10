import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:topgrade/features/presentation/controllers/interest_controller.dart';
import 'package:topgrade/features/presentation/controllers/theme_controller.dart';
import 'package:topgrade/features/presentation/widgets/primary_button.dart';
import 'package:topgrade/utils/constants/fonts.dart';
import 'package:topgrade/utils/constants/sizes.dart';
import 'package:topgrade/utils/constants/strings.dart';

class IntrestScreen extends StatelessWidget {
  const IntrestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InterestController interestController = Get.put(InterestController());

    final List<Map<String, dynamic>> interests = [
      {
        'title': 'Illustrate, Design & Creative',
        'icon': Icons.lightbulb_outline,
        'iconColor': Colors.deepOrangeAccent,
      },
      {
        'title': 'Product Design & UI/UX',
        'icon': Icons.design_services,
        'iconColor': Colors.orange,
      },
      {
        'title': 'Web Development & Coding',
        'icon': Icons.code,
        'iconColor': Colors.blue,
      },
      {
        'title': 'Motion & Video Editing',
        'icon': Icons.cut,
        'iconColor': Colors.redAccent,
      },
    ];

    return GetBuilder<XThemeController>(
      builder:
          (controller) => Obx(
            () => Scaffold(
              backgroundColor: controller.backgroundColor,
              body: Stack(
                children: [
                  // Background Gradient at the bottom
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: controller.height * 0.55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            controller.backgroundColor.withValues(alpha: 0.0),
                            controller.primaryColor.withValues(alpha: 0.05),
                            controller.primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: XSizes.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: XSizes.spacingXxl),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle Skip action
                            },
                            child: Text(
                              XString.skip,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: XSizes.textSizeMd,
                                fontFamily: XFonts.lexend,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: XSizes.spacingMd),
                        Text(
                          "Find out what you're\ninterested in",
                          style: TextStyle(
                            fontSize: XSizes.textSize3xl,
                            fontWeight: FontWeight.bold,
                            fontFamily: XFonts.lexend,
                            color: controller.textColor,
                          ),
                        ),
                        SizedBox(height: XSizes.spacingMd),
                        Text(
                          "To provide you with class recommendations",
                          style: TextStyle(
                            fontSize: XSizes.textSizeSm,
                            color: Colors.grey,
                            fontFamily: XFonts.lexend,
                          ),
                        ),
                        SizedBox(height: XSizes.spacingSm),
                        Expanded(
                          child: ListView.builder(
                            itemCount: interests.length,
                            itemBuilder: (context, index) {
                              return _buildInterestCard(
                                index,
                                interests,
                                interestController,
                                controller,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: XSizes.spacingLg),
                          child: Column(
                            children: [
                              Text(
                                "Your Current Selections Are Not Fixed. Explore Countless Learning Opportunities and Tailor Your Path as You Progress.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: XSizes.textSizeSm,
                                  color: Colors.grey,
                                  fontFamily: XFonts.lexend,
                                ),
                              ),
                              SizedBox(height: XSizes.spacingLg),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: PrimaryButton(
                                  text: 'Next',
                                  onPressed: () {
                                    // Handle Next button action
                                    final selectedInterest = interestController
                                        .getSelectedInterest(interests);
                                    if (selectedInterest != null) {
                                      print(
                                        'Selected: ${selectedInterest['title']}',
                                      );
                                      // Send to server or navigate to next screen
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildInterestCard(
    int index,
    List<Map<String, dynamic>> interests,
    InterestController interestController,
    XThemeController themeController,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          interestController.selectInterest(index);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: XSizes.spacingMd),
          padding: EdgeInsets.symmetric(
            horizontal: XSizes.paddingMd,
            vertical: XSizes.paddingMd,
          ),
          decoration: BoxDecoration(
            color: themeController.backgroundColor,
            borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
            border: Border.all(
              color:
                  interestController.isInterestSelected(index)
                      ? themeController.textColor
                      : Colors.grey.withValues(alpha: 0.2),
              width: XSizes.borderSizeSm,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(XSizes.paddingSm),
                decoration: BoxDecoration(
                  color: interests[index]['iconColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
                ),
                child: Icon(
                  interests[index]['icon'],
                  color: interests[index]['iconColor'],
                  size: XSizes.iconSizeSm,
                ),
              ),
              SizedBox(width: XSizes.spacingMd),
              Expanded(
                child: Text(
                  interests[index]['title'],
                  style: TextStyle(
                    fontSize: XSizes.textSizeMd,
                    fontWeight: FontWeight.w400,
                    color: themeController.textColor,
                    fontFamily: XFonts.lexend,
                  ),
                ),
              ),
              if (interestController.isInterestSelected(index))
                Icon(
                  Icons.check_circle,
                  color: interests[index]['iconColor'],
                  size: XSizes.iconSizeSm + 4,
                )
              else
                Container(
                  width: XSizes.iconSizeSm + 4,
                  height: XSizes.iconSizeSm + 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
