import 'package:flutter/material.dart';
import 'package:topgrade/utils/constants/colors.dart';
import 'package:topgrade/utils/constants/sizes.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.70, curve: Curves.ease),
      ),
    );
    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.80, curve: Curves.ease),
      ),
    );
    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.90, curve: Curves.ease),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 24, // Set a fixed height to prevent layout shifts
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildAnimatedDot(_animation1),
          const SizedBox(width: 5),
          _buildAnimatedDot(_animation2),
          const SizedBox(width: 5),
          _buildAnimatedDot(_animation3),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: const SizedBox(
        width: 8,
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: XColors.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(XSizes.borderRadiusSm),
        ),
        elevation: 0,
      ),
      onPressed: widget.isLoading ? null : widget.onPressed,
      child:
          widget.isLoading
              ? _buildLoadingIndicator()
              : Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: XSizes.textSizeSm,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Lexend',
                ),
              ),
    );
  }
}