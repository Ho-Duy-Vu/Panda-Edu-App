# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep speech_to_text
-keep class com.csdcorp.speech_to_text.** { *; }

# Keep record package
-keep class com.llfbandit.record.** { *; }

# Keep audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Keep file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Keep shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep Google Play Core (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Additional Flutter rules
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# CRITICAL: Keep all data models for JSON serialization
# This prevents ProGuard from renaming fields which breaks JSON parsing
-keep class **.data.models.** { *; }
-keep class **.domain.entities.** { *; }
-keepclassmembers class **.data.models.** { *; }
-keepclassmembers class **.domain.entities.** { *; }

# Keep all field names in models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve JSON field names
-keepclassmembers class * {
    private <fields>;
}

