import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:topgrade/utils/constants/sizes.dart';
import '../../../controllers/theme_controller.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;

  const PasswordField({super.key, this.controller, this.hintText});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<XThemeController>(
      builder: (themeController) {
        return TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: TextStyle(
            color: themeController.textColor,
            fontFamily: 'Lexend',
            fontSize: XSizes.textSizeSm,
          ),
          cursorColor: themeController.primaryColor,
          decoration: InputDecoration(
            hintText: widget.hintText ?? '******************',
            hintStyle: TextStyle(
              color: themeController.textColor.withValues(alpha: 0.5),
              fontFamily: 'Lexend',
              fontSize: XSizes.textSizeSm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeController.primaryColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeController.primaryColor,
                width: 1,
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                _obscureText
                    ? 'assets/icons/ic_eye_close.svg'
                    : 'assets/icons/ic_eye_open.svg',
                width: XSizes.iconSizeSm,
                height: XSizes.iconSizeSm,
                colorFilter: ColorFilter.mode(
                  themeController.textColor.withValues(alpha: 0.6),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
        );
      },
    );
  }
}
