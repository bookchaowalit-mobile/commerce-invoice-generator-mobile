import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing reads the ignored android/key.properties (see README).
// Keystores and key.properties must never be committed.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

android {
    namespace = "com.bookchaowalit.invoice_generator"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.bookchaowalit.invoice_generator"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to the debug key: without key.properties the
            // guard below fails any release build.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

// CI-only escape hatch: `-PallowUnsignedRelease=true` (or the env var
// ORG_GRADLE_PROJECT_allowUnsignedRelease=true) lets a release build finish
// WITHOUT any signing config, producing an unsigned bundle that cannot be
// installed or uploaded. It never signs with the debug key. Without the flag,
// release builds still fail closed below.
val allowUnsignedRelease = providers.gradleProperty("allowUnsignedRelease").orNull == "true"

gradle.taskGraph.whenReady {
    val requestsRelease = allTasks.any {
        it.name.contains("release", ignoreCase = true) &&
            (it.name.contains("bundle", ignoreCase = true) ||
                it.name.contains("assemble", ignoreCase = true) ||
                it.name.contains("package", ignoreCase = true))
    }
    if (requestsRelease && !keystorePropertiesFile.exists() && !allowUnsignedRelease) {
        throw GradleException(
            "Release signing is not configured. Provide ignored android/key.properties and an upload keystore.",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
