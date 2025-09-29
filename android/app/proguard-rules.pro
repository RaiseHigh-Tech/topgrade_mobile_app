# Flutter custom fonts
-keep class io.flutter.** { *; }
-keep class com.google.android.material.** { *; }

# Preserve font files
-keep class **.R$*
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Don't obfuscate Flutter engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep font assets
-keep class * extends android.graphics.Typeface { *; }