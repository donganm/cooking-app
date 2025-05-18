pluginManagement {
    // Load Flutter SDK path from local.properties
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    // Include Flutter tools for building Flutter projects
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    // Define repositories for plugins
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // Flutter plugin for plugin loading
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // Android application plugin (apply false so it won't be applied globally here)
    id("com.android.application") version "8.7.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration

    // Kotlin plugin for Android (apply false so it won't be applied globally here)
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// Include the app module (usually located in the :app directory)
include(":app")
