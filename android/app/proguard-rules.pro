# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase & Google Services (Ye crash rokega)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.** { *; }

# Prevent R8 warnings from stopping the build
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-ignorewarnings