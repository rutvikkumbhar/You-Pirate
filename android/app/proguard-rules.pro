# --- Gson (required generically, per Gson's official proguard example) ---
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# --- media_store_plus internal model classes ---
# Replace the package below with the plugin's actual package (see step 2)
-keep class com.snnafi.media_store_plus.** { *; }
-keepclassmembers class com.snnafi.media_store_plus.** { *; }