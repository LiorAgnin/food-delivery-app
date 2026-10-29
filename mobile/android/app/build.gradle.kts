plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Patrol stub native lib for the androidTest APK (Android 16).
// One exported symbol, built per ABI with the NDK clang that AGP already
// resolves, so the artifact is reproducible from source. Mirrors ferrule.
val patrolAbiStubTargets = mapOf(
    "arm64-v8a" to "aarch64-linux-android",
    "armeabi-v7a" to "armv7a-linux-androideabi",
    "x86_64" to "x86_64-linux-android",
)

abstract class BuildPatrolAbiStub : DefaultTask() {
    @get:InputFile
    abstract val source: RegularFileProperty

    @get:Input
    abstract val targets: MapProperty<String, String>

    @get:Input
    abstract val minSdk: Property<Int>

    @get:Internal
    abstract val clang: RegularFileProperty

    @get:OutputDirectory
    abstract val outputDir: DirectoryProperty

    @TaskAction
    fun build() {
        val clangBin = clang.get().asFile
        require(clangBin.exists()) { "NDK clang not found at $clangBin" }
        val outRoot = outputDir.get().asFile
        outRoot.deleteRecursively()
        for ((abi, triple) in targets.get()) {
            val outFile = outRoot.resolve("$abi/libpatrol_androidtest_abi.so")
            outFile.parentFile.mkdirs()
            val exit = ProcessBuilder(
                clangBin.path,
                "--target=$triple${minSdk.get()}",
                "-shared", "-fPIC", "-Os", "-Wl,--strip-all",
                "-o", outFile.path,
                source.get().asFile.path,
            ).inheritIO().start().waitFor()
            require(exit == 0) { "clang exited $exit building the $abi Patrol stub" }
        }
    }
}

android {
    namespace = "com.levelapp.food_delivery"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.levelapp.food_delivery"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Patrol Android setup, same runner ferrule uses.
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }

    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }

    // Android 16's app classloader does not include the instrumentation APK
    // (DexPathList is only the app). Patrol's ScanningTestLoader still
    // Class.forName's MainActivityTest on that loader, so the runner class
    // must also live in the debug APK. Release is untouched.
    // The androidTest APK also needs a tiny stub .so per ABI so its
    // primaryCpuAbi matches the app; buildPatrolAbiStub compiles it from
    // src/androidTest/c into the androidTest jniLibs (nothing binary is
    // committed).
    sourceSets {
        getByName("debug") {
            java.srcDir("src/androidTest/java")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

val buildPatrolAbiStub = tasks.register<BuildPatrolAbiStub>("buildPatrolAbiStub") {
    val hostTag = System.getProperty("os.name").lowercase().let { os ->
        when {
            os.contains("mac") || os.contains("darwin") -> "darwin-x86_64"
            os.contains("windows") -> "windows-x86_64"
            else -> "linux-x86_64"
        }
    }
    source.set(layout.projectDirectory.file("src/androidTest/c/patrol_androidtest_abi.c"))
    targets.set(patrolAbiStubTargets)
    minSdk.set(provider { android.defaultConfig.minSdk ?: 21 })
    clang.fileProvider(
        provider { android.ndkDirectory.resolve("toolchains/llvm/prebuilt/$hostTag/bin/clang") },
    )
    outputDir.set(layout.buildDirectory.dir("generated/patrolAbiStub/jniLibs"))
}

androidComponents {
    onVariants { variant ->
        variant.androidTest?.sources?.jniLibs?.addGeneratedSourceDirectory(
            buildPatrolAbiStub,
            BuildPatrolAbiStub::outputDir,
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    androidTestUtil("androidx.test:orchestrator:1.5.1")
    // JUnit is required to compile MainActivityTest into the debug APK
    // (see sourceSets.debug above). Debug-only; not in release.
    debugImplementation("junit:junit:4.13.2")
    debugImplementation("androidx.test:runner:1.6.2")
}
