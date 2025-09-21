// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class PlayVideo extends StatefulWidget {
  final String videoLink;
  const PlayVideo({super.key, required this.videoLink});

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoLink);
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.setVolume(1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
