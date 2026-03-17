## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Firebase
-keep class com.google.firebase.** { *; }

## Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

## Google Play Core (referenced by Flutter for deferred components)
-dontwarn com.google.android.play.core.**
