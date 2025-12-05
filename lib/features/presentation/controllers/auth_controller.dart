import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/helpers/snackbars.dart';
import '../../../utils/helpers/token_helper.dart';
import '../../data/source/remote_source.dart';
import '../../data/model/signin_response_model.dart';
import '../../data/model/signup_response_model.dart';
import '../../data/model/reset_password_response_model.dart';
import '../../data/model/verify_otp_response_model.dart';
import '../../data/model/phone_signin_response_model.dart';
import '../routes/routes.dart';
import 'notification_controller.dart';

enum ResetStep { email, otp, newPassword }

class AuthController extends GetxController {
  late RemoteSourceImpl remoteSource;
  final _isLoading = false.obs;

  // TextField Controllers for sign-in form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // TextField Controllers for mobile sign-in form
  final mobileNameController = TextEditingController();
  final mobileEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final _isOtpSent = false.obs;

  // Firebase Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Method to reset mobile signin form
  void resetMobileSigninForm() {
    phoneController.clear();
    otpController.clear();
    _isOtpSent.value = false;
    _verificationId = null;
    _resendToken = null;
  }

  // Check profile status after signin
  Future<void> checkProfileStatus() async {
    try {
      _isLoading.value = true;

      final response = await remoteSource.getProfileStatus();

      if (response.isProfileComplete) {
        // Save user data to storage
        if (response.user != null) {
          await TokenHelper.saveUserData(
            fullname: response.user!.fullname,
            email: response.user!.email,
            phoneNumber: response.user!.phoneNumber,
          );
        }
        
        // Check if user has area of interest
        if (response.hasAreaOfInterest) {
          // User has completed everything, navigate to home
          Get.offAllNamed(XRoutes.home);
        } else {
          // User has profile but not area of interest, navigate to interest screen
          Get.offAllNamed(XRoutes.interest);
        }
      } else {
        // Profile is incomplete, navigate to complete profile screen
        Get.offAllNamed(XRoutes.completeProfile);
      }
    } on ResponseException catch (e) {
      // Handle API response errors (400, 401, etc.)
      Snackbars.errorSnackBar(e.message);
      // Navigate to complete profile as safe fallback for auth errors
      Get.offAllNamed(XRoutes.completeProfile);
    } on ServerException catch (e) {
      // Handle server/network errors
      Snackbars.errorSnackBar(e.message);
      // Navigate to complete profile as safe fallback
      Get.offAllNamed(XRoutes.completeProfile);
    } catch (e) {
      // Handle any other unexpected errors
      Snackbars.errorSnackBar('Failed to check profile status. Please try again.');
      // Navigate to complete profile as safe fallback
      Get.offAllNamed(XRoutes.completeProfile);
    } finally {
      _isLoading.value = false;
    }
  }

  // Update profile method
  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;

      // Validation
      if (profileNameController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your full name');
        return;
      }

      if (profileEmailController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(profileEmailController.text.trim())) {
        Snackbars.errorSnackBar('Please enter a valid email address');
        return;
      }

      // Call API
      final response = await remoteSource.updateProfile(
        email: profileEmailController.text.trim(),
        fullname: profileNameController.text.trim(),
      );

      if (response.success) {
        Snackbars.successSnackBar(response.message);
        
        // Save user data to storage
        if (response.user != null) {
          await TokenHelper.saveUserData(
            fullname: response.user!.fullname,
            email: response.user!.email,
            phoneNumber: response.user!.phoneNumber,
          );
        }
        
        // Clear form
        profileNameController.clear();
        profileEmailController.clear();

        // Navigate based on area of interest status
        if (response.hasAreaOfInterest) {
          // User already has area of interest, navigate to home
          Get.offAllNamed(XRoutes.home);
        } else {
          // User needs to set area of interest, navigate to interest screen
          Get.offAllNamed(XRoutes.interest);
        }
      } else {
        Snackbars.errorSnackBar('Failed to update profile. Please try again.');
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } catch (e) {
      Snackbars.errorSnackBar('Failed to update profile. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // TextField Controllers for sign-up form
  final fullNameController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // TextField Controllers for reset password form
  final resetEmailController = TextEditingController();
  final resetOtpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // TextField Controllers for complete profile form
  final profileNameController = TextEditingController();
  final profileEmailController = TextEditingController();
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
        Snackbars.errorSnackBar('Please enter your full name');
        return;
      }

      if (signupPhoneController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your phone number');
        return;
      }

      if (signupPhoneController.text.trim().length != 10) {
        Snackbars.errorSnackBar('Please enter a valid 10-digit phone number');
        return;
      }

      if (signupEmailController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(signupEmailController.text.trim())) {
        Snackbars.errorSnackBar('Please enter a valid email address');
        return;
      }

      if (signupPasswordController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your password');
        return;
      }

      if (signupPasswordController.text.trim().length < 6) {
        Snackbars.errorSnackBar('Password must be at least 6 characters');
        return;
      }

      if (confirmPasswordController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please confirm your password');
        return;
      }

      if (signupPasswordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Snackbars.errorSnackBar('Passwords do not match');
        return;
      }

      // Call signup API
      final SignupResponseModel response = await remoteSource.signup(
        fullname: fullNameController.text.trim(),
        phoneNumber: '+91${signupPhoneController.text.trim()}',
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

        // Save user data to storage
        if (response.user != null) {
          await TokenHelper.saveUserData(
            fullname: response.user!.fullname,
            email: response.user!.email,
            phoneNumber: response.user!.phoneNumber,
          );
        }

        // Clear form
        fullNameController.clear();
        signupPhoneController.clear();
        signupEmailController.clear();
        signupPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate based on area of interest status
        if (response.hasAreaOfIntrest == true) {
          // User has selected area of interest, go to home
          Get.offAllNamed(XRoutes.home);
        } else {
          // User hasn't selected area of interest, go to interest screen
          Get.offAllNamed(XRoutes.interest);
        }
      } else {
        Snackbars.errorSnackBar(response.message);
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } catch (e) {
      Snackbars.errorSnackBar('Signup failed. Please try again.');
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
        Snackbars.errorSnackBar('Please enter your email');
        return;
      }

      if (!GetUtils.isEmail(emailController.text.trim())) {
        Snackbars.errorSnackBar('Please enter a valid email address');
        return;
      }

      if (passwordController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your password');
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

        // Save user data to storage
        if (response.user != null) {
          await TokenHelper.saveUserData(
            fullname: response.user!.fullname,
            email: response.user!.email,
            phoneNumber: response.user!.phoneNumber,
          );
        }

        // Clear form
        emailController.clear();
        passwordController.clear();

        // Navigate based on area of interest status
        if (response.hasAreaOfIntrest == true) {
          // User has selected area of interest, go to home
          Get.offAllNamed(XRoutes.home);
        } else {
          // User hasn't selected area of interest, go to interest screen
          Get.offAllNamed(XRoutes.interest);
        }
      } else {
        Snackbars.errorSnackBar(response.message);
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } catch (e) {
      Snackbars.errorSnackBar('Signin failed. Please try again.');
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
        Snackbars.errorSnackBar('Please enter your email address');
        return;
      }

      if (!GetUtils.isEmail(resetEmailController.text.trim())) {
        Snackbars.errorSnackBar('Please enter a valid email address');
        return;
      }

      // Call request OTP API
      final ResetPasswordResponseModel response = await remoteSource
          .requestPasswordResetOtp(email: resetEmailController.text.trim());

      // Check if OTP request was successful
      if (response.isOtpRequestSuccess) {
        _resetStep.value = ResetStep.otp;
      } else {
        Snackbars.errorSnackBar(response.message);
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } catch (e) {
      Snackbars.errorSnackBar('Failed to send verification code');
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
        Snackbars.errorSnackBar('Please enter the verification code');
        return;
      }

      if (resetOtpController.text.trim().length < 6) {
        Snackbars.errorSnackBar('Please enter a valid 6-digit code');
        return;
      }

      // Call verify OTP API
      final VerifyOtpResponseModel response = await remoteSource
          .verifyPasswordResetOtp(
            email: resetEmailController.text.trim(),
            otp: resetOtpController.text.trim(),
          );

      // Check if OTP verification was successful
      if (response.isOtpVerificationSuccess) {
        _resetStep.value = ResetStep.newPassword;
        Snackbars.successSnackBar(response.message);
      } else {
        Snackbars.errorSnackBar(response.message);
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } catch (e) {
      Snackbars.errorSnackBar('Invalid verification code');
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
        Snackbars.errorSnackBar('Please enter your new password');
        return;
      }

      if (newPasswordController.text.trim().length < 6) {
        Snackbars.errorSnackBar('Password must be at least 6 characters');
        return;
      }

      if (confirmNewPasswordController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please confirm your new password');
        return;
      }

      if (newPasswordController.text.trim() !=
          confirmNewPasswordController.text.trim()) {
        Snackbars.errorSnackBar('Passwords do not match');
        return;
      }

      // Call reset password API
      final ResetPasswordResponseModel response = await remoteSource
          .resetPassword(
            email: resetEmailController.text.trim(),
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
        Snackbars.successSnackBar(response.message);
      } else {
        Snackbars.errorSnackBar(response.message);
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message);
    } catch (e) {
      Snackbars.errorSnackBar('Password reset failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Phone number sign in (redirect to mobile screen)
  Future<void> signInWithPhone() async {
    Get.toNamed(XRoutes.signinMobile);
  }

  // Send OTP using Firebase
  Future<void> sendOtp() async {
    try {
      // Basic validation (before setting loading state)
      if (phoneController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter your phone number', duration: const Duration(milliseconds: 1500));
        return;
      }

      if (phoneController.text.trim().length != 10) {
        Snackbars.errorSnackBar('Please enter a valid 10-digit phone number', duration: const Duration(milliseconds: 1500));
        return;
      }

      // Set loading state after validation passes
      _isLoading.value = true;

      final phoneNumber = '+91${phoneController.text.trim()}';

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading.value = false;
          if (e.code == 'invalid-phone-number') {
            Snackbars.errorSnackBar('Invalid phone number format', duration: const Duration(milliseconds: 1500));
          } else {
            Snackbars.errorSnackBar(e.message ?? 'Verification failed', duration: const Duration(milliseconds: 1500));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isOtpSent.value = true;
          _isLoading.value = false;
          Snackbars.successSnackBar('OTP sent successfully to your phone', duration: const Duration(milliseconds: 1500));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      _isLoading.value = false;
      Snackbars.errorSnackBar('Failed to send OTP. Please try again', duration: const Duration(milliseconds: 1500));
    }
  }

  // Verify OTP and sign in
  Future<void> verifyOtp() async {
    try {
      // Basic validation (before setting loading state)
      if (otpController.text.trim().isEmpty) {
        Snackbars.errorSnackBar('Please enter the OTP', duration: const Duration(milliseconds: 1500));
        return;
      }

      if (otpController.text.trim().length != 6) {
        Snackbars.errorSnackBar('Please enter a valid 6-digit OTP', duration: const Duration(milliseconds: 1500));
        return;
      }

      if (_verificationId == null) {
        Snackbars.errorSnackBar('Please request OTP first', duration: const Duration(milliseconds: 1500));
        return;
      }

      // Set loading state after validation passes
      _isLoading.value = true;

      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );

      // Sign in with credential
      await _signInWithCredential(credential);
    } catch (e) {
      _isLoading.value = false;
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          Snackbars.errorSnackBar('Invalid OTP. Please try again', duration: const Duration(milliseconds: 1500));
        } else {
          Snackbars.errorSnackBar(e.message ?? 'Verification failed', duration: const Duration(milliseconds: 1500));
        }
      } else {
        Snackbars.errorSnackBar('Failed to verify OTP. Please try again', duration: const Duration(milliseconds: 1500));
      }
    }
  }

  // Sign in with Firebase credential and send token to backend
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Get Firebase ID token
      final firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }

      // Send phone number and Firebase token to backend
      final PhoneSigninResponseModel response = await remoteSource.phoneSignin(
        phoneNumber: '+91${phoneController.text.trim()}',
        firebaseToken: firebaseToken,
      );

      // Check if signin was successful
      if (response.isAuthSuccess) {
        // Save tokens to storage
        await TokenHelper.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );

        // Save user data to storage
        if (response.user != null) {
          await TokenHelper.saveUserData(
            fullname: response.user!.fullname,
            email: response.user!.email,
            phoneNumber: response.user!.phoneNumber,
          );
        }

        // Check profile status and navigate accordingly
        await checkProfileStatus();

        // Clear form
        phoneController.clear();
        otpController.clear();
        _isOtpSent.value = false;
        _verificationId = null;
        _resendToken = null;

      } else {
        Snackbars.errorSnackBar(response.message, duration: const Duration(milliseconds: 1500));
      }
    } on ResponseException catch (e) {
      Snackbars.errorSnackBar(e.message, duration: const Duration(milliseconds: 1500));
    } on ServerException catch (e) {
      Snackbars.errorSnackBar(e.message, duration: const Duration(milliseconds: 1500));
    } on FirebaseAuthException catch (e) {
      Snackbars.errorSnackBar(e.message ?? 'Authentication failed', duration: const Duration(milliseconds: 1500));
    } catch (e) {
      Snackbars.errorSnackBar('Sign in failed. Please try again', duration: const Duration(milliseconds: 1500));
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    otpController.clear();
    await sendOtp();
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
      // Delete FCM token before clearing tokens
      try {
        final notificationController = Get.find<NotificationController>();
        await notificationController.deleteFcmToken();
      } catch (e) {
        debugPrint('Error deleting FCM token: $e');
        // Continue with logout even if FCM token deletion fails
      }

      // Clear tokens
      await TokenHelper.clearTokens();

      // Clear all form controllers safely
      try {
        emailController.clear();
        passwordController.clear();
        mobileNameController.clear();
        mobileEmailController.clear();
        phoneController.clear();
        otpController.clear();
        fullNameController.clear();
        signupPhoneController.clear();
        signupEmailController.clear();
        signupPasswordController.clear();
        confirmPasswordController.clear();
        profileNameController.clear();
        profileEmailController.clear();
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
    } catch (e) {
      Snackbars.errorSnackBar('Logout failed');
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
      mobileNameController.dispose();
      mobileEmailController.dispose();
      phoneController.dispose();
      otpController.dispose();
      fullNameController.dispose();
      signupPhoneController.dispose();
      signupEmailController.dispose();
      signupPasswordController.dispose();
      confirmPasswordController.dispose();
      profileNameController.dispose();
      profileEmailController.dispose();
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
