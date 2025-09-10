import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/bottom_nav_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../../../utils/constants/icons.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/fonts.dart';
import 'pages/home_page.dart';
import 'pages/my_learning_page.dart';
import 'pages/chat_page.dart';
import 'pages/profile_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavController bottomNavController = Get.put(BottomNavController());
    
    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return Obx(() => Scaffold(
          backgroundColor: themeController.backgroundColor,
          body: _getSelectedPage(bottomNavController.selectedIndex, themeController),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeController.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: XSizes.paddingLg,
                  vertical: XSizes.paddingSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, XIcons.icHome, XIcons.icHomeActive, 'Home', bottomNavController, themeController),
                    _buildNavItem(1, XIcons.icBook, XIcons.icBookActive, 'My Learning', bottomNavController, themeController),
                    _buildNavItem(2, XIcons.icChat, XIcons.icChatActive, 'Chat', bottomNavController, themeController),
                    _buildNavItem(3, XIcons.icProfile, XIcons.icProfileActive, 'Profile', bottomNavController, themeController),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }

  Widget _buildNavItem(int index, String inactiveIcon, String activeIcon, String label, BottomNavController controller, XThemeController themeController) {
    final bool isSelected = controller.selectedIndex == index;
    
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: XSizes.paddingSm,
          vertical: XSizes.paddingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? activeIcon : inactiveIcon,
              width: XSizes.iconSizeMd,
              height: XSizes.iconSizeMd,
              colorFilter: ColorFilter.mode(
                isSelected ? themeController.primaryColor : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: XSizes.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: XSizes.textSizeXxs,
                fontFamily: XFonts.lexend,
                color: isSelected ? themeController.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedPage(int index, XThemeController themeController) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const MyLearningPage();
      case 2:
        return const ChatPage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }
}
