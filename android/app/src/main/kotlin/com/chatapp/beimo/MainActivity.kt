package com.chatapp.beimo

import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL1 = "com.chatapp.beimo/audio"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册相册插件
        flutterEngine.plugins.add(GalleryPlugin())

        // MethodChannel for audio control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL1).setMethodCallHandler { call, result ->
            when (call.method) {
                "setEarpiece" -> {
                    setEarpiece()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setEarpiece() {
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
        audioManager.isSpeakerphoneOn = false
    }
}
