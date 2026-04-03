import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val debugKeystorePropertiesFile = rootProject.file("debug-key.properties")
val debugKeystoreProperties = Properties()
if (debugKeystorePropertiesFile.exists()) {
    debugKeystoreProperties.load(FileInputStream(debugKeystorePropertiesFile))
}

android {
    namespace = "rusk.media.player"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
        // Configure existing debug signing config (created by default by Android Gradle Plugin)
        getByName("debug") {
            if (debugKeystorePropertiesFile.exists()) {
                keyAlias = debugKeystoreProperties["debugKeyAlias"] as String
                keyPassword = debugKeystoreProperties["debugKeyPassword"] as String
                storeFile = file(debugKeystoreProperties["debugStoreFile"] as String)
                storePassword = debugKeystoreProperties["debugStorePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "rusk.media.player"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isShrinkResources = true
            isMinifyEnabled = true
            buildConfigField("boolean", "LOG", "false")
            buildConfigField("boolean", "NON_PROD", "false")
            buildConfigField("boolean", "STETHO", "false")
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

        }
        debug {
            buildConfigField("boolean", "LOG", "true")
            buildConfigField("boolean", "NON_PROD", "true")
            buildConfigField("boolean", "STETHO", "false")
            if (debugKeystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    buildFeatures {
        dataBinding = true
        viewBinding = true
        buildConfig = true
    }
}

flutter {
    source = "../.."
}
