// ignore_for_file: avoid_print

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AudioController extends GetxController {
  final _isRecordPlaying = false.obs,
      isRecording = false.obs,
      isSending = false.obs,
      isUploading = false.obs;
  final _currentId = 999999.obs;
  final start = DateTime.now().obs;
  final end = DateTime.now().obs;
  String _total = "";
  String get total => _total;
  var completedPercentage = 0.0.obs;
  var currentDuration = 0.obs;
  var totalDuration = 0.obs;

  bool get isRecordPlaying => _isRecordPlaying.value;
  bool get isRecordingValue => isRecording.value;
  late final AudioPlayerService _audioPlayerService;
  int get currentId => _currentId.value;

  @override
  void onInit() {
    _audioPlayerService = AudioPlayerAdapter();

    _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
      totalDuration.value = duration.inMicroseconds;
      // Ensure totalDuration is not zero to prevent divide by zero
      if (totalDuration.value <= 0) {
        totalDuration.value = 1; // Prevent divide by zero or NaN
      }
    });

    _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
      currentDuration.value = duration.inMicroseconds;
      // Check if totalDuration is valid before calculating completedPercentage
      if (totalDuration.value > 0) {
        completedPercentage.value =
            currentDuration.value.toDouble() / totalDuration.value.toDouble();
      } else {
        completedPercentage.value = 0.0; // Handle as needed
      }
    });

    _audioPlayerService.getAudioPlayer.onPlayerComplete.listen((event) async {
      await _audioPlayerService.getAudioPlayer.seek(Duration.zero);
      _isRecordPlaying.value = false;
    });

    super.onInit();
  }

  @override
  void onClose() {
    _audioPlayerService.dispose();
    super.onClose();
  }

  Future<void> changeProg() async {
    if (isRecordPlaying) {
      _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
        totalDuration.value = duration.inMicroseconds;
      });

      _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
        currentDuration.value = duration.inMicroseconds;
        // Check if totalDuration is valid before calculating completedPercentage
        if (totalDuration.value > 0) {
          completedPercentage.value =
              currentDuration.value.toDouble() / totalDuration.value.toDouble();
        } else {
          completedPercentage.value = 0.0; // Handle as needed
        }
      });
    }
  }

  void onPressedPlayButton(int id, var content) async {
    _currentId.value = id;
    if (isRecordPlaying) {
      await _pauseRecord();
    } else {
      _isRecordPlaying.value = true;
      try {
        await _audioPlayerService.play(content);
        // Delay duration fetch to ensure it's loaded properly
        await Future.delayed(
            const Duration(milliseconds: 500)); // Adjust delay as needed
      } catch (e) {
        _isRecordPlaying.value = false;
        print('Error playing audio: $e');
      }
    }
  }

  calcDuration() {
    var a = end.value.difference(start.value).inSeconds;
    format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
    _total = format(Duration(seconds: a));
  }

  Future<void> _pauseRecord() async {
    _isRecordPlaying.value = false;
    await _audioPlayerService.pause();
  }
}

abstract class AudioPlayerService {
  void dispose();
  Future<void> play(String url);
  Future<void> resume();
  Future<void> pause();
  Future<void> release();

  AudioPlayer get getAudioPlayer;
}

class AudioPlayerAdapter implements AudioPlayerService {
  late AudioPlayer _audioPlayer;

  @override
  AudioPlayer get getAudioPlayer => _audioPlayer;

  AudioPlayerAdapter() {
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() async {
    await _audioPlayer.dispose();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> play(String url) async {
    try {
      await _audioPlayer
          .play(UrlSource(url))
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException("Audio playback timed out");
      });
    } catch (e) {
      print('Error during audio play: $e');
      rethrow;
    }
  }

  @override
  Future<void> release() async {
    await _audioPlayer.release();
  }

  @override
  Future<void> resume() async {
    await _audioPlayer.resume();
  }
}

// // ignore_for_file: avoid_print

// import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';

// class AudioController extends GetxController {
//   final _isRecordPlaying = false.obs,
//       isRecording = false.obs,
//       isSending = false.obs,
//       isUploading = false.obs;
//   final _currentId = 999999.obs;
//   final start = DateTime.now().obs;
//   final end = DateTime.now().obs;
//   String _total = "";
//   String get total => _total;
//   var completedPercentage = 0.0.obs;
//   var currentDuration = 0.obs;
//   var totalDuration = 0.obs;

//   bool get isRecordPlaying => _isRecordPlaying.value;
//   bool get isRecordingValue => isRecording.value;
//   late final AudioPlayerService _audioPlayerService;
//   int get currentId => _currentId.value;
//   @override
//   void onInit() {
//     _audioPlayerService = AudioPlayerAdapter();

//     _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
//       totalDuration.value = duration.inMicroseconds;
//     });

//     _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
//       currentDuration.value = duration.inMicroseconds;
//       completedPercentage.value =
//           currentDuration.value.toDouble() / totalDuration.value.toDouble();
//     });

//     _audioPlayerService.getAudioPlayer.onPlayerComplete.listen((event) async {
//       await _audioPlayerService.getAudioPlayer.seek(Duration.zero);
//       _isRecordPlaying.value = false;
//     });

//     super.onInit();
//   }

//   @override
//   void onClose() {
//     _audioPlayerService.dispose();
//     super.onClose();
//   }

//   Future<void> changeProg() async {
//     if (isRecordPlaying) {
//       _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
//         totalDuration.value = duration.inMicroseconds;
//       });

//       _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
//         currentDuration.value = duration.inMicroseconds;
//         // Only calculate completedPercentage if totalDuration is not zero
//         if (totalDuration.value > 0) {
//           completedPercentage.value =
//               currentDuration.value.toDouble() / totalDuration.value.toDouble();
//         } else {
//           completedPercentage.value =
//               0.0; // Or handle the case differently if needed
//         }
//       });
//     }
//   }

//   void onPressedPlayButton(int id, var content) async {
//     _currentId.value = id;
//     if (isRecordPlaying) {
//       await _pauseRecord();
//     } else {
//       _isRecordPlaying.value = true;
//       try {
//         await _audioPlayerService.play(content);
//       } catch (e) {
//         _isRecordPlaying.value = false;
//         print('Error playing audio: $e');
//       }
//     }
//   }

//   calcDuration() {
//     var a = end.value.difference(start.value).inSeconds;
//     format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
//     _total = format(Duration(seconds: a));
//   }

//   Future<void> _pauseRecord() async {
//     _isRecordPlaying.value = false;
//     await _audioPlayerService.pause();
//   }
// }

// abstract class AudioPlayerService {
//   void dispose();
//   Future<void> play(String url);
//   Future<void> resume();
//   Future<void> pause();
//   Future<void> release();

//   AudioPlayer get getAudioPlayer;
// }

// class AudioPlayerAdapter implements AudioPlayerService {
//   late AudioPlayer _audioPlayer;

//   @override
//   AudioPlayer get getAudioPlayer => _audioPlayer;

//   AudioPlayerAdapter() {
//     _audioPlayer = AudioPlayer();
//   }

//   @override
//   void dispose() async {
//     await _audioPlayer.dispose();
//   }

//   @override
//   Future<void> pause() async {
//     await _audioPlayer.pause();
//   }

//   @override
//   Future<void> play(String url) async {
//     try {
//       await _audioPlayer
//           .play(UrlSource(url))
//           .timeout(const Duration(seconds: 30), onTimeout: () {
//         throw TimeoutException("Audio playback timed out");
//       });
//     } catch (e) {
//       print('Error during audio play: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<void> release() async {
//     await _audioPlayer.release();
//   }

//   @override
//   Future<void> resume() async {
//     await _audioPlayer.resume();
//   }
// }

class AudioDuration {
  static double calculate(Duration soundDuration) {
    if (soundDuration.inSeconds > 60) {
      return 70.w;
    } else if (soundDuration.inSeconds > 50) {
      return 65.w;
    } else if (soundDuration.inSeconds > 40) {
      return 60.w;
    } else if (soundDuration.inSeconds > 30) {
      return 55.w;
    } else if (soundDuration.inSeconds > 20) {
      return 50.w;
    } else if (soundDuration.inSeconds > 10) {
      return 45.w;
    } else {
      return 40.w;
    }
  }
}
