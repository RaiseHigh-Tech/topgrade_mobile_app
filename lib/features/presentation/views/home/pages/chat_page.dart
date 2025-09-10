import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../../../utils/constants/fonts.dart';
import '../../../../../utils/constants/sizes.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(XSizes.paddingLg),
                decoration: BoxDecoration(
                  color: themeController.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: XSizes.textSize3xl,
                        fontFamily: XFonts.lexend,
                        color: themeController.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // New chat action
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: themeController.textColor,
                        size: XSizes.iconSizeLg,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: EdgeInsets.all(XSizes.paddingLg),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: XSizes.paddingMd,
                    vertical: XSizes.paddingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: XSizes.iconSizeMd,
                      ),
                      SizedBox(width: XSizes.spacingSm),
                      Expanded(
                        child: Text(
                          'Search conversations...',
                          style: TextStyle(
                            fontSize: XSizes.textSizeMd,
                            fontFamily: XFonts.lexend,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Chat List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: XSizes.paddingLg),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final bool isOnline = index % 3 == 0;
                    final bool hasUnread = index % 4 == 0;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: XSizes.spacingSm),
                      padding: EdgeInsets.all(XSizes.paddingMd),
                      decoration: BoxDecoration(
                        color: hasUnread 
                            ? themeController.primaryColor.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: themeController.primaryColor.withValues(alpha: 0.2),
                                child: Text(
                                  'U${index + 1}',
                                  style: TextStyle(
                                    fontSize: XSizes.textSizeMd,
                                    fontFamily: XFonts.lexend,
                                    color: themeController.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: themeController.backgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: XSizes.spacingMd),
                          
                          // Chat Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'User ${index + 1}',
                                        style: TextStyle(
                                          fontSize: XSizes.textSizeLg,
                                          fontFamily: XFonts.lexend,
                                          color: themeController.textColor,
                                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${index + 1}:${(index * 5) % 60}${index % 2 == 0 ? 'AM' : 'PM'}',
                                      style: TextStyle(
                                        fontSize: XSizes.textSizeXs,
                                        fontFamily: XFonts.lexend,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: XSizes.spacingXs),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        index % 2 == 0 
                                            ? 'Hey! How are you doing?'
                                            : 'Thanks for the help with the course!',
                                        style: TextStyle(
                                          fontSize: XSizes.textSizeSm,
                                          fontFamily: XFonts.lexend,
                                          color: Colors.grey,
                                          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasUnread)
                                      Container(
                                        margin: EdgeInsets.only(left: XSizes.spacingSm),
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: themeController.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: XSizes.textSizeXs,
                                            fontFamily: XFonts.lexend,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Start new chat
          },
          backgroundColor: themeController.primaryColor,
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}