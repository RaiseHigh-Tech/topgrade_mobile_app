import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../data/source/remote_source.dart';
import '../routes/routes.dart';

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

  RxBool get isLoading => _isLoading;
  RxBool get isOtpSent => _isOtpSent;

  // Sign in method for the new UI
  Future<void> signIn() async {
    try {
      _isLoading.value = true;

      // Basic validation
      if (emailController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your email');
        return;
      }

      if (passwordController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your password');
        return;
      }

      // Use existing remote source for login
      await remoteSource
          .demoLogin(email: emailController.text.trim(), password: passwordController.text.trim())
          .then((response) {
            _isLoading.value = false;
            Get.offAllNamed(XRoutes.home);
            Get.snackbar(
              'Success', 
              'Welcome back!',
              snackPosition: SnackPosition.BOTTOM,
            );
          });
    } on ResponseException catch (e) {
      Get.snackbar('Error', e.message);
    } on ServerException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Login failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Original login method (keeping for backward compatibility)
  Future<void> login() async {
    try {
      _isLoading.value = true;
      await remoteSource
          .demoLogin(email: "dhinesh.tech2001@gmail.com", password: "12345")
          .then((response) {
            _isLoading.value = false;
            Get.toNamed(XRoutes.home);
          });
    } on ResponseException catch (e) {
      print(e.message);
    } on ServerException catch (e) {
      print(e.message);
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
      
      if (phoneController.text.trim().length < 10) {
        Get.snackbar('Error', 'Please enter a valid phone number');
        return;
      }
      
      // Simulate OTP sending
      await Future.delayed(const Duration(seconds: 2));
      
      _isOtpSent.value = true;
      Get.snackbar(
        'Success', 
        'OTP sent to ${phoneController.text}',
        snackPosition: SnackPosition.BOTTOM,
      );
      
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
      
      // Simulate OTP verification
      await Future.delayed(const Duration(seconds: 2));
      
      Get.offAllNamed(XRoutes.home);
      Get.snackbar(
        'Success', 
        'Signed in successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
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

      if (signupPasswordController.text.trim() != confirmPasswordController.text.trim()) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      // Simulate signup process
      await Future.delayed(const Duration(seconds: 2));
      
      Get.offAllNamed(XRoutes.home);
      Get.snackbar(
        'Success', 
        'Account created successfully! Welcome ${fullNameController.text.trim()}!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar('Error', 'Sign up failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Phone number sign up
  Future<void> signUpWithPhone() async {
    Get.toNamed(XRoutes.signinMobile);
  }

  // Google sign up
  Future<void> signUpWithGoogle() async {
    try {
      _isLoading.value = true;
      
      // Simulate Google authentication
      await Future.delayed(const Duration(seconds: 2));
      
      Get.offAllNamed(XRoutes.home);
      Get.snackbar(
        'Success', 
        'Account created with Google!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar('Error', 'Google sign-up failed');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    remoteSource = Get.find<RemoteSourceImpl>();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    fullNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
