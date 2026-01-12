package com.topgrade.app

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display for Android 15+ compatibility
        // This addresses the deprecated window API warnings
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            // Android 15+ (API 35+) - Use the new edge-to-edge API
            WindowCompat.setDecorFitsSystemWindows(window, false)
        } else {
            // Backward compatibility for older Android versions
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
