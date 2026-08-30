import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val requiredReleaseDartDefines = listOf(
    "SUPABASE_URL",
    "SUPABASE_ANON_KEY",
    "GOOGLE_WEB_CLIENT_ID",
)

fun releaseDartDefineKeys(): Set<String> {
    val encodedDefines = project.findProperty("dart-defines") as? String
    if (encodedDefines.isNullOrBlank()) {
        return emptySet()
    }

    return encodedDefines
        .split(",")
        .mapNotNull { encoded ->
            runCatching {
                Base64.getDecoder().decode(encoded).toString(Charsets.UTF_8)
            }.getOrNull()
        }
        .mapNotNull { decoded ->
            decoded.substringBefore("=", missingDelimiterValue = "")
                .takeIf { it.isNotBlank() }
        }
        .toSet()
}

tasks.register("verifyReleaseDartDefines") {
    group = "verification"
    description = "Fails release builds that would ship without required Dart defines."

    doLast {
        val presentKeys = releaseDartDefineKeys()
        val missingKeys = requiredReleaseDartDefines.filterNot { it in presentKeys }
        if (missingKeys.isNotEmpty()) {
            throw GradleException(
                "Release build is missing Dart defines: ${missingKeys.joinToString(", ")}. " +
                    "Use scripts/build-release-apk.ps1 or pass --dart-define-from-file=config/env/atlas.local.json."
            )
        }
    }
}

android {
    namespace = "com.pranav.atlas"
    compileSdk = 36
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
        applicationId = "com.pranav.atlas"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
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

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn("verifyReleaseDartDefines")
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
