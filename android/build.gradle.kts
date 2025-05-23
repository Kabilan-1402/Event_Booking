// File: android/build.gradle.kts
import org.gradle.api.tasks.Delete

buildscript {
    // Define the Kotlin version you want to use.
    val kotlinVersion = "2.0.21"

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin version.
        classpath("com.android.tools.build:gradle:7.4.2")
        // Kotlin Gradle Plugin using the defined kotlinVersion.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        // Firebase / Google Services plugin.
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // This block forces all configurations to use specified Kotlin libraries.
    configurations.all {
        resolutionStrategy {
            // Force the JDK8-optimized Kotlin stdlib and Kotlin reflect with your chosen version.
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.0.21")
            force("org.jetbrains.kotlin:kotlin-reflect:2.0.21")
        }
    }
}

// Optional: Customize output build directories.
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(name)
    layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    evaluationDependsOn(":app")
}

// Register a clean task.
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
