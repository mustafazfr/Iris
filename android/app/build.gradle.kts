import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val props = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) load(f.inputStream())
}
val mapsKey: String = props.getProperty("MAPS_API_KEY") ?: ""

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

        manifestPlaceholders += mapOf("MAPS_API_KEY" to mapsKey)

    }

    buildTypes {
        release { signingConfig = signingConfigs.getByName("debug") }
    }
}

flutter { source = "../.." }
