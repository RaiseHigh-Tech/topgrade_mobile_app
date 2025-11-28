import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:topgrade/features/presentation/routes/routes.dart';

import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/api_endpoints.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../webview/webview_screen.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final XThemeController themeController = Get.find<XThemeController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(XSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: XSizes.spacingMd),
              // Profile Header Card
              _buildProfileCard(),
              SizedBox(height: XSizes.spacingLg),

              // Profile Options List
              _buildProfileOptionsList(),

              SizedBox(height: XSizes.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(XSizes.paddingLg),
      decoration: BoxDecoration(
        color: themeController.backgroundColor,
        borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
        border: Border.all(
          color:
              themeController.isLightTheme
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(XSizes.borderRadiusCircle),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeController.primaryColor,
                  themeController.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: XSizes.iconSizeLg,
              color: Colors.white,
            ),
          ),
          SizedBox(width: XSizes.spacingMd),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: XSizes.textSizeXl,
                    fontWeight: FontWeight.bold,
                    color: themeController.textColor,
                    fontFamily: XFonts.lexend,
                  ),
                ),
                SizedBox(height: XSizes.spacingXs),
                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: XSizes.iconSizeSm,
                      color: themeController.textColor.withOpacity(0.6),
                    ),
                    SizedBox(width: XSizes.spacingXs),
                    Expanded(
                      child: Text(
                        'john.doe@example.com', // TODO: Replace with actual email
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          color: themeController.textColor.withOpacity(0.7),
                          fontFamily: XFonts.lexend,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionsList() {
    final profileOptions = [
      ProfileOption(
        icon: Icons.edit_rounded,
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        onTap: () => _navigateToEditProfile(),
      ),
      ProfileOption(
        icon: Icons.palette_rounded,
        title: 'Theme',
        subtitle: 'Switch between light and dark mode',
        trailing: Obx(
          () => Switch.adaptive(
            value: themeController.isLightTheme,
            onChanged: (value) => themeController.changeTheme(value),
            activeColor: themeController.primaryColor,
          ),
        ),
        onTap: null, // Handled by switch
      ),
      ProfileOption(
        icon: Icons.description_rounded,
        title: 'Terms & Conditions',
        subtitle: 'Read our terms of service',
        onTap: () => _navigateToTerms(),
      ),
      ProfileOption(
        icon: Icons.privacy_tip_rounded,
        title: 'Privacy Policy',
        subtitle: 'Learn about your privacy rights',
        onTap: () => _navigateToPrivacy(),
      ),
      ProfileOption(
        icon: Icons.logout_rounded,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        isDestructive: true,
        onTap: () => _showLogoutDialog(),
      ),
    ];

    return Column(
      children:
          profileOptions.map((option) => _buildOptionTile(option)).toList(),
    );
  }

  Widget _buildOptionTile(ProfileOption option) {
    return Container(
      margin: EdgeInsets.only(bottom: XSizes.spacingSm),
      decoration: BoxDecoration(
        color: themeController.backgroundColor,
        borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
        border: Border.all(
          color:
              themeController.isLightTheme
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isLightTheme
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: XSizes.paddingMd,
          vertical: XSizes.paddingSm,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color:
                option.isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : themeController.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
          ),
          child: Icon(
            option.icon,
            color:
                option.isDestructive
                    ? Colors.red
                    : themeController.primaryColor,
            size: XSizes.iconSizeMd,
          ),
        ),
        title: Text(
          option.title,
          style: TextStyle(
            fontSize: XSizes.textSizeMd,
            fontWeight: FontWeight.w600,
            color:
                option.isDestructive ? Colors.red : themeController.textColor,
            fontFamily: XFonts.lexend,
          ),
        ),
        subtitle:
            option.subtitle != null
                ? Text(
                  option.subtitle!,
                  style: TextStyle(
                    fontSize: XSizes.textSizeSm,
                    color: themeController.textColor.withOpacity(0.6),
                    fontFamily: XFonts.lexend,
                  ),
                )
                : null,
        trailing:
            option.trailing ??
            Icon(
              Icons.chevron_right_rounded,
              size: XSizes.iconSizeMd,
              color: themeController.textColor.withOpacity(0.4),
            ),
        onTap: option.onTap,
      ),
    );
  }

  // Navigation methods
  void _navigateToEditProfile() {
    // TODO: Navigate to edit profile screen
    Get.snackbar(
      'Coming Soon',
      'Edit Profile feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: themeController.primaryColor.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void _navigateToTerms() {
    Get.to(
      () => WebViewScreen(
        url: ApiEndpoints.termsAndConditionsUrl,
        title: 'Terms & Conditions',
      ),
    );
  }

  void _navigateToPrivacy() {
    Get.to(
      () => WebViewScreen(
        url: ApiEndpoints.privacyPolicyUrl,
        title: 'Privacy Policy',
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(XSizes.borderRadiusXl),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: XSizes.iconSizeMd,
            ),
            SizedBox(width: XSizes.spacingSm),
            Text(
              'Logout',
              style: TextStyle(
                color: themeController.textColor,
                fontFamily: XFonts.lexend,
                fontWeight: FontWeight.bold,
                fontSize: XSizes.textSizeXl,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(
            color: themeController.textColor.withOpacity(0.8),
            fontFamily: XFonts.lexend,
            fontSize: XSizes.textSizeMd,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: XSizes.paddingLg,
                vertical: XSizes.paddingSm,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: themeController.textColor.withOpacity(0.7),
                fontFamily: XFonts.lexend,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _performLogout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                horizontal: XSizes.paddingLg,
                vertical: XSizes.paddingSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: XFonts.lexend,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    Get.back(); // Close dialog
    // TODO: Implement actual logout logic with AuthController
    authController.logout();
    Get.offAllNamed(XRoutes.login);
  }
}

// Helper class for profile options
class ProfileOption {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });
}
