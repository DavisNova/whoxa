import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static const MethodChannel _channel =
      MethodChannel('com.chatapp.beimo/audio');

  static Future<void> setEarpiece() async {
    // if (Platform.isAndroid) {
    try {
      await _channel.invokeMethod('setEarpiece');
    } on PlatformException catch (e) {
      debugPrint("Failed to set earpiece: '${e.message}'.");
    }
    // }
  }

  // Method to play audio, either custom or default system ringtone
  static Future<void> playAudio({required String audioFile}) async {
    try {
      // If audioFile is null or empty, it will play the system ringtone
      if (audioFile.isEmpty) {
        await _channel.invokeMethod('playAudio');
      } else {
        await _channel.invokeMethod('playAudio', {'audioFile': audioFile});
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to play audio: '${e.message}'");
    }
  }

  // Method to pause the currently playing audio
  static Future<void> pauseAudio() async {
    try {
      await _channel.invokeMethod('pauseAudio');
    } on PlatformException catch (e) {
      debugPrint("Failed to pause audio: '${e.message}'.");
    }
  }

  // Listen to the log messages from iOS native code
  static void listenToLogs() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "logMessage") {
        // This will print the log message sent from iOS to the Flutter terminal
        debugPrint("Native iOS log: ${call.arguments}");
      }
    });
  }
}
