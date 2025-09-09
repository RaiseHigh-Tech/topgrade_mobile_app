import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FontPreloader {
  static bool _isLoaded = false;
  
  static Future<void> preloadFonts() async {
    if (_isLoaded) return;
    
    try {
      // Preload all Lexend font variants to ensure they're available in release builds
      final List<Future<ByteData>> fontFutures = [
        rootBundle.load('assets/fonts/Lexend-Thin.ttf'),
        rootBundle.load('assets/fonts/Lexend-ExtraLight.ttf'),
        rootBundle.load('assets/fonts/Lexend-Light.ttf'),
        rootBundle.load('assets/fonts/Lexend-Regular.ttf'),
        rootBundle.load('assets/fonts/Lexend-Medium.ttf'),
        rootBundle.load('assets/fonts/Lexend-SemiBold.ttf'),
        rootBundle.load('assets/fonts/Lexend-Bold.ttf'),
        rootBundle.load('assets/fonts/Lexend-ExtraBold.ttf'),
        rootBundle.load('assets/fonts/Lexend-Black.ttf'),
      ];
      
      // Load all fonts
      final fontLoader = FontLoader('Lexend');
      for (final fontFuture in fontFutures) {
        fontLoader.addFont(fontFuture);
      }
      
      await fontLoader.load();
      _isLoaded = true;
      
      debugPrint('✅ Lexend fonts preloaded successfully');
    } catch (e) {
      debugPrint('❌ Error preloading Lexend fonts: $e');
    }
  }
  
  // Force load specific font weights that are commonly used
  static Future<void> loadCommonWeights() async {
    try {
      final commonWeights = [
        FontLoader('Lexend-Regular')..addFont(rootBundle.load('assets/fonts/Lexend-Regular.ttf')),
        FontLoader('Lexend-Medium')..addFont(rootBundle.load('assets/fonts/Lexend-Medium.ttf')),
        FontLoader('Lexend-Bold')..addFont(rootBundle.load('assets/fonts/Lexend-Bold.ttf')),
        FontLoader('Lexend-SemiBold')..addFont(rootBundle.load('assets/fonts/Lexend-SemiBold.ttf')),
      ];
      
      await Future.wait(commonWeights.map((loader) => loader.load()));
      debugPrint('✅ Common Lexend font weights loaded');
    } catch (e) {
      debugPrint('❌ Error loading common font weights: $e');
    }
  }
}