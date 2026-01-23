import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:topgrade/features/presentation/controllers/auth_controller.dart';
import 'package:topgrade/features/presentation/controllers/theme_controller.dart';
import 'package:topgrade/features/presentation/widgets/primary_button.dart';
import 'package:topgrade/utils/constants/fonts.dart';
import 'package:topgrade/utils/constants/sizes.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final XThemeController themeController = Get.find<XThemeController>();

    return Scaffold(
      backgroundColor: themeController.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Gradient at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: themeController.height * 0.55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    themeController.backgroundColor.withValues(alpha: 0.0),
                    themeController.primaryColor.withValues(alpha: 0.05),
                    themeController.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: XSizes.paddingLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: themeController.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: XSizes.spacingXxl),

                      // Header
                      Text(
                        "Complete Your\nProfile",

                        style: TextStyle(
                          fontSize: XSizes.textSize3xl,
                          fontWeight: FontWeight.bold,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor,
                        ),
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      Text(
                        "Please provide your name and email to continue",
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          color: Colors.grey,
                          fontFamily: XFonts.lexend,
                        ),
                      ),

                      SizedBox(height: XSizes.spacingXxl),

                      // Full Name Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: XSizes.textSizeSm,
                              fontWeight: FontWeight.w500,
                              color: themeController.textColor,
                              fontFamily: XFonts.lexend,
                            ),
                          ),
                          SizedBox(height: XSizes.spacingSm),
                          TextField(
                            controller: authController.profileNameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: themeController.primaryColor,
                            style: TextStyle(
                              color: themeController.textColor,
                              fontFamily: XFonts.lexend,
                              fontSize: XSizes.textSizeSm,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(
                                color: themeController.textColor.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: XSizes.textSizeSm,
                                fontFamily: XFonts.lexend,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: themeController.primaryColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: themeController.primaryColor,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: XSizes.spacingLg),

                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: XSizes.textSizeSm,
                              fontWeight: FontWeight.w500,
                              color: themeController.textColor,
                              fontFamily: XFonts.lexend,
                            ),
                          ),
                          SizedBox(height: XSizes.spacingSm),
                          TextField(
                            controller: authController.profileEmailController,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: themeController.primaryColor,
                            style: TextStyle(
                              color: themeController.textColor,
                              fontFamily: XFonts.lexend,
                              fontSize: XSizes.textSizeSm,
                            ),
                            decoration: InputDecoration(
                              hintText: 'example@gmail.com',
                              hintStyle: TextStyle(
                                color: themeController.textColor.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: XSizes.textSizeSm,
                                fontFamily: XFonts.lexend,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: themeController.primaryColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: themeController.primaryColor,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Footer Section
                      Padding(
                        padding: EdgeInsets.only(bottom: XSizes.spacingLg),
                        child: Column(
                          children: [
                            Text(
                              "This information will be used to personalize your experience",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: XSizes.textSizeSm,
                                color: Colors.grey,
                                fontFamily: XFonts.lexend,
                              ),
                            ),
                            SizedBox(height: XSizes.spacingLg),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: PrimaryButton(
                                  text: 'Continue',
                                  isLoading: authController.isLoading.value,
                                  onPressed: () {
                                    authController.updateProfile();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
