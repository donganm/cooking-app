// Root-level build.gradle.kts
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google services plugin
        classpath("com.google.gms:google-services:4.4.2") // Add this if not already present
        // Add other necessary classpaths like the Kotlin Gradle plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0") // Kotlin plugin version
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define the new build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Set a new build directory for each subproject
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure app project evaluation depends on all other subprojects
subprojects {
    project.evaluationDependsOn(":app")
}

// Register a clean task to delete the build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
