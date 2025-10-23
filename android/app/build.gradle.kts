plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin phải nằm sau Android và Kotlin
    id("dev.flutter.flutter-gradle-plugin")

    // 👉 Thêm plugin Google Services
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.a"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.a" // 👈 để nguyên hoặc thay package ID Firebase của bạn
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 👉 Thêm Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // Firebase Analytics (bắt buộc để khởi tạo Firebase)
    implementation("com.google.firebase:firebase-analytics")

    // Nếu bạn dùng thêm các dịch vụ Firebase khác thì add vào:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}
