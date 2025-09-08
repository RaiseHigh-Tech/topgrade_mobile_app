import 'package:flutter/material.dart';

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
        backgroundColor: const Color(0xFFF97316), // A nice orange color
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0, // No shadow for a flatter look
      ),
      onPressed: widget.isLoading ? null : widget.onPressed,
      child:
          widget.isLoading
              ? _buildLoadingIndicator()
              : Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }
}

class ButtonExample extends StatefulWidget {
  const ButtonExample({Key? key}) : super(key: key);

  @override
  State<ButtonExample> createState() => _ButtonExampleState();
}

class _ButtonExampleState extends State<ButtonExample> {
  bool _isLoading = false;

  void _handlePress() async {
    setState(() => _isLoading = true);
    // Simulate a network call
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Primary Button Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: PrimaryButton(
            text: 'CONTINUE',
            isLoading: _isLoading,
            onPressed: _handlePress,
          ),
        ),
      ),
    );
  }
}
