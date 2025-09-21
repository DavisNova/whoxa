// ignore_for_file: file_names, deprecated_member_use

import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double lat, double long) async {
    String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$long";

    if (await canLaunchUrlString(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw "could not open map";
    }
  }
}

// String status = '';
bool isBLOCKED = false;
