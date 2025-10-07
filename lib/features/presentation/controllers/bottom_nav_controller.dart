import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxInt _selectedIndex = 0.obs;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _previousIndex = 0;

  int get selectedIndex => _selectedIndex.value;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _updateSlideAnimation();

    // Start with the first animation
    _animationController.forward();
  }

  void _updateSlideAnimation() {
    // Determine slide direction based on tab position
    bool isMovingRight = _selectedIndex.value > _previousIndex;

    _slideAnimation = Tween<Offset>(
      begin: isMovingRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  void changeTab(int index) {
    if (_selectedIndex.value != index) {
      _previousIndex = _selectedIndex.value;
      _selectedIndex.value = index;
      _updateSlideAnimation();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  // Tab names
  List<String> get tabNames => ['Home', 'My Learning', 'Chat', 'Profile'];
}
