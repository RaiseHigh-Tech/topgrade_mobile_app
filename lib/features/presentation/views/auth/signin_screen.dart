import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/sizes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../routes/routes.dart';
import '../../widgets/primary_button.dart';
import 'components/password_field.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return Scaffold(
          backgroundColor: themeController.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(XSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: XSizes.spacingMd),
                  // Logo
                  Image.asset('assets/images/logo.png', width: 240),
                  SizedBox(height: XSizes.spacingLg),
                  // Welcome Text
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: XSizes.textSize2xl,
                      fontWeight: FontWeight.bold,
                      color: themeController.textColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: XSizes.spacingSm),
                  Text(
                    'Sign in to access your personalized \nlearning journey',
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

                  // Email Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Here',
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontWeight: FontWeight.w500,
                          color: themeController.textColor,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      SizedBox(height: XSizes.spacingSm),
                      TextField(
                        controller: authController.emailController,
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

                  SizedBox(height: XSizes.spacingLg),

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
                        controller: authController.passwordController,
                        hintText: '******************',
                      ),
                    ],
                  ),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(XRoutes.resetPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: themeController.textColor.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: XSizes.textSizeSm,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: XSizes.spacingSm),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => PrimaryButton(
                        text: 'SIGN IN',
                        onPressed: authController.signIn,
                        isLoading: authController.isLoading.value,
                      ),
                    ),
                  ),

                  SizedBox(height: XSizes.spacingLg),

                  // Or Sign In with
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
                          'Or Sign In with',
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
                            // Handle Phone number login
                            authController.signInWithPhone();
                          },
                          label: Text(
                            'Sign In With Phone Number',
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

                      SizedBox(height: XSizes.spacingMd),

                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle Google login
                            authController.signInWithGoogle();
                          },
                          label: Text(
                            'Sign In With Google',
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
                        "Don't have an Account? ",
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
                        onTap: () => Get.toNamed(XRoutes.signup),
                        child: Text(
                          'Sign Up here',
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
