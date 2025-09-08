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

  RxBool get isLoading => _isLoading;

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

  // Phone number sign in
  Future<void> signInWithPhone() async {
    try {
      _isLoading.value = true;
      
      // Simulate phone authentication
      await Future.delayed(const Duration(seconds: 2));
      
      Get.offAllNamed(XRoutes.home);
      Get.snackbar(
        'Success', 
        'Signed in with phone number!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar('Error', 'Phone sign-in failed');
    } finally {
      _isLoading.value = false;
    }
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

  @override
  void onInit() {
    super.onInit();
    remoteSource = Get.find<RemoteSourceImpl>();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
