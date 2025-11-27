import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:topgrade/utils/constants/colors.dart';

class Snackbars {
  /// Show Flutter's default ScaffoldMessenger snackbar
  static void _showSnackbar({
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Duration? duration,
    IconData? icon,
  }) {
    final context = Get.context;
    
    if (context == null) {
      debugPrint('Snackbar message: $message');
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: duration ?? const Duration(milliseconds: 2500),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Snackbar error: $e, Message: $message');
    }
  }

  static void errorSnackBar(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      backgroundColor: XColors.error,
      icon: Icons.error_outline,
      duration: duration, // No default, will use "no auto-dismiss"
    );
  }

  static void successSnackBar(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      backgroundColor: XColors.success,
      icon: Icons.check_circle_outline,
      duration: duration, // No default, will use "no auto-dismiss"
    );
  }

  static void infoSnackBar(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      backgroundColor: XColors.primaryColor,
      icon: Icons.info_outline,
      duration: duration, // No default, will use "no auto-dismiss"
    );
  }

  static void warningSnackBar(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_rounded,
      duration: duration, // No default, will use "no auto-dismiss"
    );
  }
}
