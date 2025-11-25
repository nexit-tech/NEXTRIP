// --- FUNÇÃO PARA LER CHAVES DE AMBIENTE/PROPERTIES ---
// Esta função lê a chave da API do Google Maps do arquivo 'local.properties'
// (que deve ser ignorado pelo Git) e a injeta nas variáveis de build.
fun getLocalProperty(propertyName: String): String {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        val properties = java.util.Properties()
        // Usa 'use' para fechar o stream com segurança
        localPropertiesFile.inputStream().use { properties.load(it) }
        // Retorna o valor da propriedade ou uma string vazia se não for encontrada
        return properties.getProperty(propertyName) ?: ""
    }
    // Retorna uma string vazia se o arquivo local.properties não existir
    return "" 
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_v7_web"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.app_v7_web"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // --- INJEÇÃO DA CHAVE DO GOOGLE MAPS API NO AndroidManifest.xml ---
        // A variável 'MAPS_API_KEY' agora carrega o valor de 'GOOGLE_MAPS_API_KEY' do seu local.properties.
        manifestPlaceholders["MAPS_API_KEY"] = getLocalProperty("GOOGLE_MAPS_API_KEY")
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