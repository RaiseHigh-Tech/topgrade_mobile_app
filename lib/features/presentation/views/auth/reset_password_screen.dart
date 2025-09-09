import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/sizes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/primary_button.dart';
import 'components/password_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

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
              icon: Icon(
                Icons.arrow_back,
                color: themeController.textColor,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(XSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: XSizes.spacingMd),
                  
                  // Welcome Text
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: XSizes.textSize2xl,
                      fontWeight: FontWeight.bold,
                      color: themeController.textColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: XSizes.spacingSm),
                  Text(
                    'Enter your email to receive a \nverification code',
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

                  Obx(() {
                    if (authController.resetStep.value == ResetStep.email) {
                      return _buildEmailSection(themeController, authController);
                    } else if (authController.resetStep.value == ResetStep.otp) {
                      return _buildOtpSection(themeController, authController);
                    } else {
                      return _buildNewPasswordSection(themeController, authController);
                    }
                  }),

                  SizedBox(height: XSizes.spacingLg),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Remember your password? ",
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

  Widget _buildEmailSection(XThemeController themeController, AuthController authController) {
    return Column(
      children: [
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: XSizes.textSizeSm,
                fontWeight: FontWeight.w500,
                color: themeController.textColor,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: XSizes.spacingSm),
            TextField(
              controller: authController.resetEmailController,
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

        SizedBox(height: XSizes.spacingXl),

        // Send OTP Button
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => PrimaryButton(
              text: 'SEND VERIFICATION CODE',
              onPressed: authController.sendResetOtp,
              isLoading: authController.isLoading.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSection(XThemeController themeController, AuthController authController) {
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
                  'Verification code sent to ${authController.resetEmailController.text}',
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
              'Enter Verification Code',
              style: TextStyle(
                fontSize: XSizes.textSizeSm,
                fontWeight: FontWeight.w500,
                color: themeController.textColor,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: XSizes.spacingSm),
            TextField(
              controller: authController.resetOtpController,
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
                  color: themeController.textColor.withValues(
                    alpha: 0.5,
                  ),
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
                authController.resetEmailController.clear();
                authController.resetOtpController.clear();
                authController.resetStep.value = ResetStep.email;
              },
              child: Text(
                'Change Email',
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
            TextButton(
              onPressed: () {
                authController.sendResetOtp();
              },
              child: Text(
                'Resend Code',
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
              text: 'VERIFY CODE',
              onPressed: authController.verifyResetOtp,
              isLoading: authController.isLoading.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordSection(XThemeController themeController, AuthController authController) {
    return Column(
      children: [
        // Success Message
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
                  'Code verified! Now create your new password',
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

        // New Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Password',
              style: TextStyle(
                fontSize: XSizes.textSizeSm,
                fontWeight: FontWeight.w500,
                color: themeController.textColor,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: XSizes.spacingSm),
            PasswordField(
              controller: authController.newPasswordController,
              hintText: '******************',
            ),
          ],
        ),

        SizedBox(height: XSizes.spacingLg),

        // Confirm New Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm New Password',
              style: TextStyle(
                fontSize: XSizes.textSizeSm,
                fontWeight: FontWeight.w500,
                color: themeController.textColor,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: XSizes.spacingSm),
            PasswordField(
              controller: authController.confirmNewPasswordController,
              hintText: '******************',
            ),
          ],
        ),

        SizedBox(height: XSizes.spacingXl),

        // Reset Password Button
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => PrimaryButton(
              text: 'RESET PASSWORD',
              onPressed: authController.resetPassword,
              isLoading: authController.isLoading.value,
            ),
          ),
        ),
      ],
    );
  }
}