pluginManagement {
    val localProperties = java.util.Properties().apply {
        file("local.properties").inputStream().use { load(it) }
    }
    val flutterSdk = localProperties.getProperty("flutter.sdk")
        ?: error("flutter.sdk not set in local.properties")
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}


plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}

include(":app")
