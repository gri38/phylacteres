import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val requiredReleaseKeystoreProperties = listOf(
    "storePassword",
    "keyPassword",
    "keyAlias",
    "storeFile",
)
val missingReleaseKeystoreProperties =
    requiredReleaseKeystoreProperties.filter { key ->
        keystoreProperties.getProperty(key).isNullOrBlank()
    }
val releaseStoreFilePath = keystoreProperties.getProperty("storeFile")?.trim().orEmpty()
val releaseStoreFile = releaseStoreFilePath.takeIf { it.isNotEmpty() }?.let(rootProject::file)
val hasReleaseKeystore =
    keystorePropertiesFile.exists() &&
        missingReleaseKeystoreProperties.isEmpty() &&
        releaseStoreFile != null
val requiresReleaseSigning =
    gradle.startParameter.taskNames.any { taskName ->
        taskName.contains("release", ignoreCase = true)
    }

if (requiresReleaseSigning) {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release signing requires android/key.properties with storePassword, keyPassword, keyAlias, and storeFile.",
        )
    }

    if (missingReleaseKeystoreProperties.isNotEmpty()) {
        throw GradleException(
            "Release signing requires these properties in android/key.properties: ${missingReleaseKeystoreProperties.joinToString(", ")}.",
        )
    }

    if (releaseStoreFile == null || !releaseStoreFile.isFile) {
        throw GradleException(
            "Release signing keystore file not found at android/${releaseStoreFilePath.ifEmpty { "app/upload-keystore.jks" }}.",
        )
    }
}

android {
    namespace = "com.guillot.phylactere"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    dependenciesInfo {
        // Disables dependency metadata when building APKs (for IzzyOnDroid/F-Droid)
        includeInApk = false
        // Disables dependency metadata when building Android App Bundles (for Google Play)
        includeInBundle = false
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.guillot.phylactere"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                // Default file with automatically generated optimization rules.
                getDefaultProguardFile("proguard-android-optimize.txt"),
            )
        }
    }
}

flutter {
    source = "../.."
}
