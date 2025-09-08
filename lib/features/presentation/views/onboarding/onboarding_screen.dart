import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/strings.dart';
import '../../controllers/onboarding_controller.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: XColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: const [
                  OnboardingPage(
                    image: 'assets/images/onboarding_01.png',
                    title: XString.onboardingTitle1,
                    subtitle: XString.onboardingSubtitle1,
                  ),
                  OnboardingPage(
                    image: 'assets/images/onboarding_02.png',
                    title: XString.onboardingTitle2,
                    subtitle: XString.onboardingSubtitle2,
                  ),
                  OnboardingPage(
                    image: 'assets/images/onboarding_03.png',
                    title: XString.onboardingTitle3,
                    subtitle: XString.onboardingSubtitle3,
                  ),
                  OnboardingPage(
                    image: 'assets/images/onboarding_04.png',
                    title: XString.onboardingTitle4,
                    subtitle: XString.onboardingSubtitle4,
                  ),
                ],
              ),
            ),

            // Bottom section with indicator and button
            Column(
              children: [
                // Smooth Page Indicator
                SmoothPageIndicator(
                  controller: controller.pageController,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    activeDotColor: XColors.primaryColor,
                    dotColor: XColors.dotIndicatorColor,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    spacing: 8,
                  ),
                ),

                SizedBox(height: XSizes.spacingXl),
                // Button
                Obx(
                  () => SizedBox(
                    width: Get.width * 0.5,
                    child: PrimaryButton(
                      text:
                          controller.currentPageIndex.value == 3
                              ? XString.letsGetStarted.toUpperCase()
                              : XString.continueText.toUpperCase(),
                      onPressed: controller.nextPage,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: XSizes.spacingMd),

            // Skip button
            TextButton(
              onPressed: controller.skipOnboarding,
              child: Text(
                XString.skip.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Lexend',
                  decoration: TextDecoration.underline,
                  color: XColors.textColor.withValues(alpha: 0.6),
                  fontSize: XSizes.textSizeSm,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(height: XSizes.spacingXl),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(XSizes.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Onboarding Image
          Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    decoration: BoxDecoration(
                      color: XColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 80,
                      color: XColors.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: XSizes.spacingXl),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: XSizes.textSize4xl,
              fontWeight: FontWeight.bold,
              color: XColors.textColor,
              fontFamily: 'Lexend',
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: XSizes.spacingMd),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: XSizes.textSizeMd,
              fontFamily: 'Lexend',
              color: XColors.textColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
