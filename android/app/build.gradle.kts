plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Re-enable Firebase plugin
}

android {
    namespace = "com.zaidjoapps.gymmanagment"
    compileSdk = flutter.compileSdkVersion.toInt()
    ndkVersion = "29.0.13113456" // Updated to a more recent stable version

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.zaidjoapps.gymmanagment"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true // Add this for larger apps
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1") // For multiDex support
    
    // Add these Google Play Services dependencies
    implementation("com.google.android.gms:play-services-base:18.4.0")
    implementation("com.google.android.gms:play-services-auth:21.1.0")
    
    // Re-enable Firebase dependencies
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}