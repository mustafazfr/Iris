plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.denemeye_devam"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        applicationId = "com.example.denemeye_devam"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Gradle property > Env var sırası ile oku
        val mapsKey = providers.gradleProperty("MAPS_API_KEY").orNull
            ?: providers.environmentVariable("MAPS_API_KEY").orNull
            ?: ""

        // Manifest placeholder'ını bas
        manifestPlaceholders["MAPS_API_KEY"] = mapsKey
        // İstersen zorunlu kıl:
        // check(mapsKey.isNotBlank()) { "MAPS_API_KEY tanımlı değil" }
    }

    buildTypes {
        release { signingConfig = signingConfigs.getByName("debug") }
    }
}

flutter { source = "../.." }
