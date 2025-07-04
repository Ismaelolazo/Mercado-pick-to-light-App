plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.picktolightapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456" // Actualiza la versión del NDK

    compileOptions {
        sourceCompatibility =JavaVersion.VERSION_11
        targetCompatibility =JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.picktolightapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 27
        targetSdk = 27
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Provides ARCore Session and related resources.
    implementation("com.google.ar:core:1.37.0")

    // Provides ArFragment, and other UX resources.
    implementation("com.google.ar.sceneform.ux:sceneform-ux:1.8.0")

    // Alternatively, use ArSceneView without the UX dependency.
    implementation("com.google.ar.sceneform:core:1.8.0")
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
}
