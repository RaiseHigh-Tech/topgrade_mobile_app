import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/helpers/token_helper.dart';
import '../../data/source/remote_source.dart';
import '../../data/model/signin_response_model.dart';
import '../../data/model/signup_response_model.dart';
import '../../data/model/reset_password_response_model.dart';
import '../../data/model/phone_otp_response_model.dart';
import '../../data/model/phone_signin_response_model.dart';
import '../routes/routes.dart';

enum ResetStep { email, otp, newPassword }

class AuthController extends GetxController {
  late RemoteSourceImpl remoteSource;
  final _isLoading = false.obs;

  // TextField Controllers for sign-in form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // TextField Controllers for mobile sign-in form
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final _isOtpSent = false.obs;

  // TextField Controllers for sign-up form
  final fullNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // TextField Controllers for reset password form
  final resetEmailController = TextEditingController();
  final resetOtpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final _resetStep = ResetStep.email.obs;

  RxBool get isLoading => _isLoading;
  RxBool get isOtpSent => _isOtpSent;
  Rx<ResetStep> get resetStep => _resetStep;

  // Sign up method
  Future<void> signUp() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (fullNameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your full name');
        return;
      }

      if (signupEmailController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(signupEmailController.text.trim())) {
        Get.snackbar('Error', 'Please enter a valid email address');
        return;
      }

      if (signupPasswordController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your password');
        return;
      }

      if (signupPasswordController.text.trim().length < 6) {
        Get.snackbar('Error', 'Password must be at least 6 characters');
        return;
      }

      if (confirmPasswordController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please confirm your password');
        return;
      }

      if (signupPasswordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      // Call signup API
      final SignupResponseModel response = await remoteSource.signup(
        fullname: fullNameController.text.trim(),
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      // Check if signup was successful
      if (response.isSignupSuccess) {
        // Save tokens to storage
        await TokenHelper.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );

        // Clear form
        fullNameController.clear();
        signupEmailController.clear();
        signupPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate to home
        Get.offAllNamed(XRoutes.home);
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Signup failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign in method for the new UI
  Future<void> signIn() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (emailController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(emailController.text.trim())) {
        Get.snackbar('Error', 'Please enter a valid email address');
        return;
      }

      if (passwordController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your password');
        return;
      }

      // Call signin API
      final SigninResponseModel response = await remoteSource.signin(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if signin was successful
      if (response.isAuthSuccess) {
        // Save tokens to storage
        await TokenHelper.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );

        // Clear form
        emailController.clear();
        passwordController.clear();

        // Navigate to home
        Get.offAllNamed(XRoutes.home);
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Signin failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Send reset password OTP
  Future<void> sendResetOtp() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (resetEmailController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your email address');
        return;
      }

      if (!GetUtils.isEmail(resetEmailController.text.trim())) {
        Get.snackbar('Error', 'Please enter a valid email address');
        return;
      }

      // Call request OTP API
      final ResetPasswordResponseModel response = await remoteSource
          .requestPasswordResetOtp(email: resetEmailController.text.trim());

      // Check if OTP request was successful
      if (response.isOtpRequestSuccess) {
        _resetStep.value = ResetStep.otp;
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send verification code');
    } finally {
      _isLoading.value = false;
    }
  }

  // Verify reset password OTP
  Future<void> verifyResetOtp() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (resetOtpController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter the verification code');
        return;
      }

      if (resetOtpController.text.trim().length < 6) {
        Get.snackbar('Error', 'Please enter a valid 6-digit code');
        return;
      }

      // Simulate OTP verification
      await Future.delayed(const Duration(seconds: 2));

      _resetStep.value = ResetStep.newPassword;
      Get.snackbar(
        'Success',
        'Code verified successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Invalid verification code');
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (newPasswordController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your new password');
        return;
      }

      if (newPasswordController.text.trim().length < 6) {
        Get.snackbar('Error', 'Password must be at least 6 characters');
        return;
      }

      if (confirmNewPasswordController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please confirm your new password');
        return;
      }

      if (newPasswordController.text.trim() !=
          confirmNewPasswordController.text.trim()) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      // Call reset password API
      final ResetPasswordResponseModel response = await remoteSource
          .resetPassword(
            email: resetEmailController.text.trim(),
            otp: resetOtpController.text.trim(),
            newPassword: newPasswordController.text.trim(),
            confirmPassword: confirmNewPasswordController.text.trim(),
          );

      // Check if password reset was successful
      if (response.isPasswordResetSuccess) {
        // Clear all reset form data
        resetEmailController.clear();
        resetOtpController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        _resetStep.value = ResetStep.email;

        Get.back(); // Go back to signin screen
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Password reset failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Send OTP to phone number
  Future<void> sendOtp() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (phoneController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your phone number');
        return;
      }

      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phoneController.text.trim().replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      // Remove country code if present
      if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
        cleanPhone = cleanPhone.substring(2);
      }

      if (cleanPhone.length != 10) {
        Get.snackbar('Error', 'Please enter a valid 10-digit phone number');
        return;
      }

      // Call request phone OTP API
      final PhoneOtpResponseModel response = await remoteSource.requestPhoneOtp(
        phoneNumber: cleanPhone,
      );

      // Check if OTP request was successful
      if (response.isOtpRequestSuccess) {
        _isOtpSent.value = true;
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP');
    } finally {
      _isLoading.value = false;
    }
  }

  // Verify OTP and sign in
  Future<void> verifyOtpAndSignIn() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (otpController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter the OTP');
        return;
      }

      if (otpController.text.trim().length < 6) {
        Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
        return;
      }

      // Clean phone number (same logic as sendOtp)
      String cleanPhone = phoneController.text.trim().replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
        cleanPhone = cleanPhone.substring(2);
      }

      // Call phone signin API
      final PhoneSigninResponseModel response = await remoteSource.phoneSignin(
        phoneNumber: cleanPhone,
        otp: otpController.text.trim(),
      );

      // Check if phone signin was successful
      if (response.isPhoneSigninSuccess) {
        // Save tokens to storage
        await TokenHelper.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );

        // Clear form
        phoneController.clear();
        otpController.clear();
        _isOtpSent.value = false;

        // Navigate to home
        Get.offAllNamed(XRoutes.home);
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      _isLoading.value = false;
    }
  }

  // Phone number sign in (redirect to mobile screen)
  Future<void> signInWithPhone() async {
    Get.toNamed(XRoutes.signinMobile);
  }

  // Google sign in
  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;

      // Simulate Google authentication
      await Future.delayed(const Duration(seconds: 2));

      Get.offAllNamed(XRoutes.home);
      Get.snackbar(
        'Success',
        'Signed in with Google!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Google sign-in failed');
    } finally {
      _isLoading.value = false;
    }
  }

  // Get access token from storage
  Future<String?> getAccessToken() async {
    return await TokenHelper.getAccessToken();
  }

  // Get refresh token from storage
  Future<String?> getRefreshToken() async {
    return await TokenHelper.getRefreshToken();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await TokenHelper.isLoggedIn();
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Clear tokens first
      await TokenHelper.clearTokens();

      // Clear all form controllers safely
      try {
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        otpController.clear();
        fullNameController.clear();
        signupEmailController.clear();
        signupPasswordController.clear();
        confirmPasswordController.clear();
        resetEmailController.clear();
        resetOtpController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
      } catch (e) {
        debugPrint('Error clearing controllers: $e');
      }

      // Reset states
      _isOtpSent.value = false;
      _resetStep.value = ResetStep.email;

      // Navigate to signin screen
      Get.offAllNamed(XRoutes.login);

      // Show success message
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.offAllNamed(XRoutes.login);
    }
  }

  @override
  void onInit() {
    super.onInit();
    remoteSource = Get.find<RemoteSourceImpl>();
  }

  @override
  void onClose() {
    try {
      emailController.dispose();
      passwordController.dispose();
      phoneController.dispose();
      otpController.dispose();
      fullNameController.dispose();
      signupEmailController.dispose();
      signupPasswordController.dispose();
      confirmPasswordController.dispose();
      resetEmailController.dispose();
      resetOtpController.dispose();
      newPasswordController.dispose();
      confirmNewPasswordController.dispose();
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }
    super.onClose();
  }
}
