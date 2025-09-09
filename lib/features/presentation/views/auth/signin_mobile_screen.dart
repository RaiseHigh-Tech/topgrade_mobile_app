import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/sizes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/primary_button.dart';

class SigninMobileScreen extends StatelessWidget {
  const SigninMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    // Debug print to check the state
    print('isOtpSent value: ${authController.isOtpSent.value}');

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
                  // Logo
                  Image.asset('assets/images/logo.png', width: 240),
                  SizedBox(height: XSizes.spacingLg),
                  // Welcome Text
                  Text(
                    'Sign In with Mobile',
                    style: TextStyle(
                      fontSize: XSizes.textSize2xl,
                      fontWeight: FontWeight.bold,
                      color: themeController.textColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: XSizes.spacingSm),
                  Text(
                    'Enter your mobile number to receive \na verification code',
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

                  Obx(
                    () {
                      print('Obx rebuilding - isOtpSent: ${authController.isOtpSent.value}');
                      return !authController.isOtpSent.value
                          ? _buildPhoneNumberSection(
                              themeController,
                              authController,
                            )
                          : _buildOtpSection(themeController, authController);
                    },
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

                  // Email Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                      },
                      label: Text(
                        'Sign In With Email',
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
                      Text(
                        'Sign Up here',
                        style: TextStyle(
                          color: themeController.textColor,
                          fontFamily: 'Lexend',
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w700,
                          fontSize: XSizes.textSizeSm,
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

  Widget _buildPhoneNumberSection(
    XThemeController themeController,
    AuthController authController,
  ) {
    return Column(
      children: [
        // Phone Number Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number',
              style: TextStyle(
                fontSize: XSizes.textSizeSm,
                fontWeight: FontWeight.w500,
                color: themeController.textColor,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: XSizes.spacingSm),
            TextField(
              controller: authController.phoneController,
              keyboardType: TextInputType.phone,
              cursorColor: themeController.primaryColor,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(
                color: themeController.textColor,
                fontFamily: 'Lexend',
                fontSize: XSizes.textSizeSm,
              ),
              decoration: InputDecoration(
                hintText: '9876543210',
                prefixText: '+91 ',
                prefixStyle: TextStyle(
                  color: themeController.textColor,
                  fontFamily: 'Lexend',
                  fontSize: XSizes.textSizeSm,
                ),
                hintStyle: TextStyle(
                  color: themeController.textColor.withValues(alpha: 0.5),
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

        SizedBox(height: XSizes.spacingXl),

        // Send OTP Button
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => PrimaryButton(
              text: 'SEND OTP',
              onPressed: authController.sendOtp,
              isLoading: authController.isLoading.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSection(
    XThemeController themeController,
    AuthController authController,
  ) {
    return Column(
      children: [
        // OTP Sent Message
        Container(
          padding: EdgeInsets.all(XSizes.spacingMd),
          decoration: BoxDecoration(
            color: themeController.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeController.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: themeController.primaryColor,
                size: XSizes.iconSizeSm,
              ),
              SizedBox(width: XSizes.spacingSm),
              Expanded(
                child: Text(
                  'OTP sent to +91 ${authController.phoneController.text}',
                  style: TextStyle(
                    color: themeController.textColor,
                    fontFamily: 'Lexend',
                    fontSize: XSizes.textSizeSm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: XSizes.spacingLg),

        // OTP Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: XSizes.textSizeSm,
                fontWeight: FontWeight.w500,
                color: themeController.textColor,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: XSizes.spacingSm),
            TextField(
              controller: authController.otpController,
              keyboardType: TextInputType.number,
              cursorColor: themeController.primaryColor,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(
                color: themeController.textColor,
                fontFamily: 'Lexend',
                fontSize: XSizes.textSizeLg,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  color: themeController.textColor.withValues(alpha: 0.5),
                  fontSize: XSizes.textSizeLg,
                  fontFamily: 'Lexend',
                  letterSpacing: 8,
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

        // Resend OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                authController.phoneController.clear();
                authController.otpController.clear();
                authController.isOtpSent.value = false;
                print('Manually set isOtpSent to false');
              },
              child: Text(
                'Change Number',
                style: TextStyle(
                  color: themeController.textColor.withValues(alpha: 0.6),
                  fontSize: XSizes.textSizeSm,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                authController.sendOtp();
              },
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: themeController.primaryColor,
                  fontSize: XSizes.textSizeSm,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: XSizes.spacingMd),

        // Verify OTP Button
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => PrimaryButton(
              text: 'VERIFY & SIGN IN',
              onPressed: authController.verifyOtpAndSignIn,
              isLoading: authController.isLoading.value,
            ),
          ),
        ),
      ],
    );
  }
}
