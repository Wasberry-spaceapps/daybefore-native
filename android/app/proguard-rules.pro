# Keep Gson serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class app.daybefore.** { *; }
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
