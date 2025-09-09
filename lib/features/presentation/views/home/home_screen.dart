import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

import '../../../../utils/constants/sizes.dart';
import '../../controllers/theme_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return Scaffold(
          backgroundColor: themeController.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeController.backgroundColor,
            title: Text('change_language'.tr),
            actions: [
              IconButton(
                onPressed: () {
                  // Show confirmation dialog
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: themeController.backgroundColor,
                      title: Text(
                        'Logout',
                        style: TextStyle(color: themeController.textColor),
                      ),
                      content: Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(color: themeController.textColor),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: themeController.textColor),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back(); // Close dialog
                            authController.logout(); // Logout
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.logout,
                  color: themeController.textColor,
                ),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'hello'.tr,
                  style: TextStyle(color: themeController.textColor),
                ),
                SizedBox(height: XSizes.spacingMd),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primaryColor,
                  ),
                  onPressed: () {
                    themeController.changeTheme(!themeController.isLightTheme);
                  },
                  child: Text(
                    'Change Theme',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
