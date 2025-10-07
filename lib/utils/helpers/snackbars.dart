import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:topgrade/utils/constants/colors.dart';

class Snackbars {
  static void errorSnackBar(String message) {
    Get.snackbar(
      "",
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.zero,
      borderRadius: 0,
      backgroundColor: XColors.error,
      colorText: Colors.white,
      isDismissible: true,
      duration: const Duration(seconds: 1),
      dismissDirection: DismissDirection.horizontal,
      titleText: SizedBox.shrink(),
    );
  }
}
