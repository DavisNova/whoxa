// ignore_for_file: avoid_print, library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/story_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

class VideoTrimmer extends StatefulWidget {
  final PlatformFile files;

  const VideoTrimmer({super.key, required this.files});

  @override
  _VideoTrimmerState createState() => _VideoTrimmerState();
}

class _VideoTrimmerState extends State<VideoTrimmer> {
  late VideoPlayerController _controller;
  RangeValues _selectedRange = const RangeValues(0, 30);
  double _maxSliderValue = 30;

  final StroyGetxController stroyGetxController =
      Get.find<StroyGetxController>();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.files.path!))
      ..initialize().then((_) {
        setState(() {
          _maxSliderValue = _controller.value.duration.inSeconds.toDouble();
          if (_maxSliderValue > 30) {
            _maxSliderValue = 30;
          } else {
            _selectedRange = RangeValues(0, _maxSliderValue);
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Status'),
      ),
      body: Column(
        children: [
          _controller.value.isInitialized
              ? Expanded(
                  flex: 8,
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          child: AnimatedOpacity(
                            opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              color: Colors.transparent,
                              child: _controller.value.isPlaying
                                  ? const SizedBox.shrink()
                                  : const Icon(Icons.play_arrow),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(color: chatownColor),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                RangeSlider(
                  min: 0,
                  max: _controller.value.duration.inSeconds.toDouble(),
                  values: _selectedRange,
                  onChanged: (values) {
                    setState(() {
                      _selectedRange = values;
                      if (_selectedRange.end - _selectedRange.start > 30) {
                        _selectedRange = RangeValues(
                          _selectedRange.end - 30,
                          _selectedRange.end,
                        );
                      }
                      _controller.seekTo(
                          Duration(seconds: _selectedRange.start.toInt()));
                      if (_controller.value.isPlaying) {
                        _controller.play();
                      }
                    });
                  },
                ),
                Positioned(
                  left: 20,
                  child: Text('${_selectedRange.start.toInt()}s'),
                ),
                Positioned(
                  right: 20,
                  child: Text('${_selectedRange.end.toInt()}s'),
                ),
              ],
            ),
          ),
          Obx(() {
            return stroyGetxController.isUploadStoryLoad.value
                ? Center(
                    child: loader(context),
                  )
                : SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        double start = _selectedRange.start;
                        double end = _selectedRange.end;
                        double duration = end - start;
                        log("${_controller.value.duration}");
                        log("Start $start");
                        log("End $end");
                        log("Duration $duration");
                        var outputPath = await _trimVideo(start, duration, end);
                        if (outputPath != null) {
                          await stroyGetxController.addVideoStory(
                              outputPath, "");
                        }
                      },
                      child: const Text('Upload'),
                    ),
                  ).paddingSymmetric(horizontal: 15);
          }),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<String?> _trimVideo(double start, double duration, double end) async {
    try {
      String tempDir = (await getTemporaryDirectory()).path;
      String timestamp = DateTime.now().microsecond.toString();
      String outputPath = path.join(tempDir, 'output_$timestamp.mp4');

      int startTimeInMilliseconds = (start * 1000).round();
      int durationInMilliseconds = (duration * 1000).round();
      log("START TIME IN MILLI SECOND $startTimeInMilliseconds");
      log("DURATION TIME IN MILLI SECOND $durationInMilliseconds");

      bool exists = await File(outputPath).exists();
      if (exists) {
        log("IT Exists");
        return outputPath;
      } else {
        print('Output file does not exist');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
