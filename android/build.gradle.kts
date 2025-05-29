// Define extra properties at the top level in Kotlin DSL:
extra["flutterCompileSdkVersion"] = 35
extra["flutterTargetSdkVersion"] = 35
extra["flutterMinSdkVersion"] = 23
extra["flutterNdkVersion"] = "25.1.8937393"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")

    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
