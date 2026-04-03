# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# video_player — ExoPlayer / Media3
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# flutter_cache_manager — OkHttp + Sqflite
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class com.tekartik.sqflite.** { *; }

# Enums, Parcelables, Serializable
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}
-dontwarn javax.annotation.**
