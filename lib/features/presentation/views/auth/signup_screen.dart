import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/sizes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/primary_button.dart';
import 'components/password_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return Scaffold(
          backgroundColor: themeController.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeController.backgroundColor,
            surfaceTintColor: themeController.backgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: themeController.textColor),
              onPressed: () => Get.back(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(XSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome Text
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: XSizes.textSize2xl,
                      fontWeight: FontWeight.bold,
                      color: themeController.textColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: XSizes.spacingSm),
                  Text(
                    'Create your account to embark on \nyour educational adventure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1.1,
                      fontSize: XSizes.textSizeMd,
                      fontWeight: FontWeight.w300,
                      color: themeController.textColor.withValues(alpha: 0.7),
                      fontFamily: 'Lexend',
                    ),
                  ),

                  SizedBox(height: XSizes.spacingXl),

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
                          fontFamily: 'Lexend',
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      TextField(
                        controller: authController.fullNameController,
                        keyboardType: TextInputType.name,
                        cursorColor: themeController.primaryColor,
                        style: TextStyle(
                          color: themeController.textColor,
                          fontFamily: 'Lexend',
                          fontSize: XSizes.textSizeSm,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(
                            color: themeController.textColor.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: XSizes.textSizeSm,
                            fontFamily: 'Lexend',
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

                  SizedBox(height: XSizes.spacingMd),

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
                          fontFamily: 'Lexend',
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      TextField(
                        controller: authController.signupEmailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: themeController.primaryColor,
                        style: TextStyle(
                          color: themeController.textColor,
                          fontFamily: 'Lexend',
                          fontSize: XSizes.textSizeSm,
                        ),
                        decoration: InputDecoration(
                          hintText: 'example@gmail.com',
                          hintStyle: TextStyle(
                            color: themeController.textColor.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: XSizes.textSizeSm,
                            fontFamily: 'Lexend',
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

                  SizedBox(height: XSizes.spacingMd),

                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontWeight: FontWeight.w500,
                          color: themeController.textColor,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      PasswordField(
                        controller: authController.signupPasswordController,
                        hintText: '******************',
                      ),
                    ],
                  ),

                  SizedBox(height: XSizes.spacingMd),

                  // Confirm Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontWeight: FontWeight.w500,
                          color: themeController.textColor,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      PasswordField(
                        controller: authController.confirmPasswordController,
                        hintText: '******************',
                      ),
                    ],
                  ),

                  SizedBox(height: XSizes.spacingXl),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => PrimaryButton(
                        text: 'SIGN UP',
                        onPressed: authController.signUp,
                        isLoading: authController.isLoading.value,
                      ),
                    ),
                  ),

                  SizedBox(height: XSizes.spacingLg),

                  // Or Sign Up with
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: themeController.textColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: XSizes.spacingMd,
                        ),
                        child: Text(
                          'Or Sign Up with',
                          style: TextStyle(
                            color: themeController.textColor.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: XSizes.textSizeSm,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: themeController.textColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: XSizes.spacingLg),

                  // Social Login Buttons
                  Column(
                    children: [
                      // Phone Number Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle Phone number signup
                            authController.signInWithPhone();
                          },
                          label: Text(
                            'Sign Up With Phone Number',
                            style: TextStyle(
                              color: themeController.textColor,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: XSizes.spacingMd,
                            ),
                            side: BorderSide(
                              color: themeController.textColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  SizedBox(height: XSizes.spacingLg),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an Account? ",
                        style: TextStyle(
                          color: themeController.textColor.withValues(
                            alpha: 0.7,
                          ),
                          fontFamily: 'Lexend',
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w400,
                          fontSize: XSizes.textSizeSm,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          'Sign In here',
                          style: TextStyle(
                            color: themeController.textColor,
                            fontFamily: 'Lexend',
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                            fontSize: XSizes.textSizeSm,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: XSizes.spacingMd),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
