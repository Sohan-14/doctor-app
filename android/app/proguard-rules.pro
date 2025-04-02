# --- Fix missing java.beans classes ---
-dontwarn java.beans.**
-keepclassmembers class * {
    @java.beans.ConstructorProperties <init>(...);
}
-keep class java.beans.** { *; }

# --- Fix missing org.w3c.dom.bootstrap classes ---
-dontwarn org.w3c.dom.bootstrap.**
-keep class org.w3c.dom.bootstrap.** { *; }

# --- Fix missing Transient annotation ---
-dontwarn java.beans.Transient

# --- Keep Firebase / Jackson related ---
-keep class com.fasterxml.** { *; }
-dontwarn com.fasterxml.**

# Flutter / Firebase Messaging plugin
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# Flutter CallKit Incoming plugin
-keep class com.hiennv.flutter_callkit_incoming.** { *; }

# Needed if you use reflection, JSON parsing etc.
-keepattributes *Annotation*
