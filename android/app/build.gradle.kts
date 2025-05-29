plugins {
        id("com.android.application")
        id("kotlin-android")
        // O plugin do Flutter deve ser aplicado após os plugins do Android e Kotlin.
        id("dev.flutter.flutter-gradle-plugin")
    }

    android {
        namespace = "com.example.breakforlove_last_update"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = "27.0.12077973"

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_11.toString()
        }

        defaultConfig {
            applicationId = "com.example.breakforlove_last_update"
            minSdk = flutter.minSdkVersion
            targetSdk = flutter.targetSdkVersion
            versionCode = flutter.versionCode
            versionName = flutter.versionName
        }

        buildTypes {
            release {
                // Adicione sua própria configuração de assinatura para o build de release.
                // Assinando com as chaves de debug por enquanto, para que `flutter run --release` funcione.
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    flutter {
        source = "../.."
    }