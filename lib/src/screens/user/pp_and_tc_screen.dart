// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:http/http.dart' as http;

class PpAndTcScreen extends StatefulWidget {
  bool isFromPP;
  PpAndTcScreen({super.key, this.isFromPP = true});

  @override
  State<PpAndTcScreen> createState() => _PpAndTcScreenState();
}

class _PpAndTcScreenState extends State<PpAndTcScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 45,
          ),
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Image.asset(
              "assets/images/arrow-left.png",
              color: appColorBlack,
              height: 27,
              width: 27,
            ),
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: chatownColor,
                  )).paddingOnly(bottom: 80);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Html(
                      data: snapshot.data!,
                    ),
                  );
                } else {
                  return const Center(child: Text('No data found'));
                }
              },
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }

  Future<String> fetchData() async {
    final url = Uri.parse(widget.isFromPP == true
        ? '${ApiHelper.baseUrl}/get-privacy-policy'
        : "${ApiHelper.baseUrl}/get-tncs");
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        // Return the HTML string from the 'Link' field
        return widget.isFromPP == true
            ? data['privacy_policy'][0]['Link']
            : data['TandCs'][0]['Link'];
      } else {
        throw Exception('Failed to load privacy policy Or term and condition');
      }
    } else {
      throw Exception('Failed to load privacy policy Or term and condition');
    }
  }
}
