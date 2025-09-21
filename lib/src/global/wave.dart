import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveform; // List of waveform amplitudes
  final double progress;
  final bool isPlaying;

  WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPlaying ? Colors.black : Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / waveform.length; // Adjust stroke width

    final barWidth = size.width / waveform.length;
    final maxBarHeight = size.height;

    for (int i = 0; i < waveform.length; i++) {
      final x = i * barWidth;
      final barHeight = waveform[i] * maxBarHeight; // Scale height to canvas

      // Draw a line from the center up and down based on the amplitude
      canvas.drawLine(
        Offset(x, size.height / 2 - barHeight / 2),
        Offset(x, size.height / 2 + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
