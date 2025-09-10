import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return GetBuilder<XThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(XSizes.paddingLg),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: XSizes.textSize3xl,
                        fontFamily: XFonts.lexend,
                        color: themeController.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Settings action
                      },
                      icon: Icon(
                        Icons.settings_outlined,
                        color: themeController.textColor,
                        size: XSizes.iconSizeLg,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Profile Info
                Container(
                  padding: EdgeInsets.all(XSizes.paddingLg),
                  decoration: BoxDecoration(
                    color: themeController.backgroundColor,
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: themeController.primaryColor.withValues(alpha: 0.2),
                        child: Text(
                          'JD',
                          style: TextStyle(
                            fontSize: XSizes.textSize3xl,
                            fontFamily: XFonts.lexend,
                            color: themeController.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: XSizes.textSize2xl,
                          fontFamily: XFonts.lexend,
                          color: themeController.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: XSizes.spacingXs),
                      Text(
                        'john.doe@example.com',
                        style: TextStyle(
                          fontSize: XSizes.textSizeMd,
                          fontFamily: XFonts.lexend,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: XSizes.spacingMd),
                      
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('5', 'Courses', themeController),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          _buildStatItem('120', 'Hours', themeController),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          _buildStatItem('15', 'Certificates', themeController),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Menu Items
                _buildMenuItem(
                  Icons.person_outline,
                  'Edit Profile',
                  () {},
                  themeController,
                ),
                _buildMenuItem(
                  Icons.bookmark_outline,
                  'Saved Courses',
                  () {},
                  themeController,
                ),
                _buildMenuItem(
                  Icons.download_outlined,
                  'Downloads',
                  () {},
                  themeController,
                ),
                _buildMenuItem(
                  Icons.notifications,
                  'Notifications',
                  () {},
                  themeController,
                ),
                _buildMenuItem(
                  Icons.help_outline,
                  'Help & Support',
                  () {},
                  themeController,
                ),
                _buildMenuItem(
                  Icons.info_outline,
                  'About',
                  () {},
                  themeController,
                ),
                
                SizedBox(height: XSizes.spacingLg),
                
                // Theme Toggle
                Container(
                  padding: EdgeInsets.all(XSizes.paddingMd),
                  decoration: BoxDecoration(
                    color: themeController.backgroundColor,
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        themeController.isLightTheme ? Icons.light_mode : Icons.dark_mode,
                        color: themeController.textColor,
                        size: XSizes.iconSizeMd,
                      ),
                      SizedBox(width: XSizes.spacingMd),
                      Expanded(
                        child: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: XSizes.textSizeLg,
                            fontFamily: XFonts.lexend,
                            color: themeController.textColor,
                          ),
                        ),
                      ),
                      Switch(
                        value: !themeController.isLightTheme,
                        onChanged: (value) {
                          themeController.changeTheme(!value);
                        },
                        activeColor: themeController.primaryColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: XSizes.spacingLg),
                
                // Logout Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(XSizes.paddingMd),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Show logout confirmation
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
                                Get.back();
                                authController.logout();
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        SizedBox(width: XSizes.spacingSm),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: XSizes.textSizeLg,
                            fontFamily: XFonts.lexend,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, XThemeController themeController) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: XSizes.textSize2xl,
            fontFamily: XFonts.lexend,
            color: themeController.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: XSizes.textSizeSm,
            fontFamily: XFonts.lexend,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, XThemeController themeController) {
    return Container(
      margin: EdgeInsets.only(bottom: XSizes.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
        child: Container(
          padding: EdgeInsets.all(XSizes.paddingMd),
          decoration: BoxDecoration(
            color: themeController.backgroundColor,
            borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: themeController.textColor,
                size: XSizes.iconSizeMd,
              ),
              SizedBox(width: XSizes.spacingMd),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: XSizes.textSizeLg,
                    fontFamily: XFonts.lexend,
                    color: themeController.textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: XSizes.iconSizeSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}