package com.example.aronium

import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication

class AroniumApplication : FlutterApplication() {
    override fun attachBaseContext(base: android.content.Context) {
        super.attachBaseContext(base)
        // Install MultiDex early in the process (before onCreate)
        // This is required for apps with more than 65K methods
        MultiDex.install(this)
    }
}