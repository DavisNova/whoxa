// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;

class GetDeleteStroy extends GetxController {
  Future<void> getDelete() async {
    var uri = Uri.parse("${ApiHelper.baseUrl}/DeleteStory");
    var request = http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);

    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    print(userData);
  }
}
