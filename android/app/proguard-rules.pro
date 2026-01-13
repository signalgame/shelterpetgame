# =============================================================================
# Pet Shelter Rush - ProGuard/R8 Rules
# =============================================================================
# These rules are used during release builds to configure code shrinking,
# obfuscation, and optimization.
# =============================================================================

# =============================================================================
# FLUTTER RULES
# =============================================================================

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# =============================================================================
# GOOGLE PLAY CORE - DEFERRED COMPONENTS FIX
# =============================================================================
# Flutter's Android build may reference Google Play Core classes for deferred
# components (dynamic feature modules). If the app doesn't use this feature,
# R8 will fail because it cannot find those classes.
#
# These rules tell R8 to ignore the missing classes since we don't use
# deferred components functionality.
# =============================================================================

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Additional Play Core classes that may be referenced
-dontwarn com.google.android.play.core.**

# =============================================================================
# FLAME GAME ENGINE
# =============================================================================

# Keep Flame classes
-keep class org.libsdl.** { *; }

# =============================================================================
# SHARED PREFERENCES
# =============================================================================

-keep class androidx.datastore.** { *; }

# =============================================================================
# GENERAL ANDROID RULES
# =============================================================================

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R class and its fields
-keepclassmembers class **.R$* {
    public static <fields>;
}

# =============================================================================
# OPTIMIZATION SETTINGS
# =============================================================================

# Don't note about unused classes (reduces build log noise)
-dontnote **

# Optimization iterations
-optimizationpasses 5

# Keep line numbers for better crash reports
-keepattributes SourceFile,LineNumberTable

# Hide original source file name in stack traces
-renamesourcefileattribute SourceFile
