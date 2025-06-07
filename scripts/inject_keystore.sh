#!/usr/bin/env bash

set -e
echo "📦 Replacing build.gradle.kts and configuring signing..."

: "${KEY_STORE:?Missing KEY_STORE}"
: "${CM_KEYSTORE_PASSWORD:?Missing CM_KEYSTORE_PASSWORD}"
: "${CM_KEY_ALIAS:?Missing CM_KEY_ALIAS}"
: "${CM_KEY_PASSWORD:?Missing CM_KEY_PASSWORD}"

mkdir -p android/app

echo "📥 Downloading keystore..."
curl -fsSL -o android/app/keystore.jks "$KEY_STORE" || {
  echo "❌ Failed to download keystore"
  exit 1
}

echo "📝 Writing key.properties..."
cat > android/key.properties <<EOF
storeFile=keystore.jks
storePassword=$CM_KEYSTORE_PASSWORD
keyAlias=$CM_KEY_ALIAS
keyPassword=$CM_KEY_PASSWORD
EOF

echo "🧾 Writing full build.gradle.kts file..."
cat > android/app/build.gradle.kts <<EOF
import java.util.Properties

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    load(File(rootProject.rootDir, "android/key.properties").inputStream())
}

android {
    namespace = "com.example.app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            enableV1Signing = true
            enableV2Signing = true
            enableV3Signing = true
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isDebuggable = true
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
EOF

echo "✅ build.gradle.kts replaced and signing configured"
