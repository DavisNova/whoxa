// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/all_starred_msg_list.dart';
import 'package:whoxachat/Models/report_types_model.dart';
import 'package:whoxachat/controller/reply_msg_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class AllStaredMsgController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isReportTypeLoading = false.obs;
  RxBool isReportUserLoading = false.obs;

  Rx<AllStaredMsgModel?> starMessageModel = AllStaredMsgModel().obs;
  RxList<StarMessageList> allStarred = <StarMessageList>[].obs;
  RxList<ReportType> reportTypesData = <ReportType>[].obs;

  RxInt selectedReportIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    getReportTypes();
  }

  getAllStarMsg(conversationid) async {
    isLoading.value = true;

    try {
      var uri = Uri.parse(apiHelper.allStarredUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationid;

      var response = await request.send();
      print(response.statusCode);
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      starMessageModel.value = AllStaredMsgModel.fromJson(userData);
      print(responseData);
      allStarred.clear();
      if (starMessageModel.value!.success == true) {
        if (starMessageModel.value != null) {
          for (var i = 0;
              i < starMessageModel.value!.starMessageList!.length;
              i++) {
            allStarred.add(starMessageModel.value!.starMessageList![i]);
            allStarred.value = allStarred
                .where((element) =>
                    element.chat!.deleteFromEveryone == false &&
                    element.chat!.deleteForMe!.split(",").contains(
                            Hive.box(userdata).get(userId).toString()) ==
                        false)
                .toList();
            allStarred.refresh();
          }

          for (var i = 0;
              i < starMessageModel.value!.starMessageList!.length;
              i++) {
            if (allStarred[i].chat!.replyId != 0) {
              print("INDEXXXX:$i");
              Get.put(ReplyMsgController()).getReplyDataApi(
                  replyMsgId: allStarred[i].chat!.replyId.toString(), index: i);
            }
          }
        }
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  getReportTypes() async {
    try {
      isReportTypeLoading.value = true;
      await Hive.openBox(userdata);
      final token = Hive.box(userdata).get(authToken);
      log("token: $token");

      // Using standard http package instead of apiHelper.postMethod
      final response = await http.post(
        Uri.parse(apiHelper.getReportTypesList),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"pageSize": 500, "page": 1}),
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        log("getReportTypes API Response: $responseJson"); // ✅ Print full response
        reportTypesData.value =
            ReportTypesModel.fromJson(responseJson).reportType!;
        log("reportTypesData length ${reportTypesData.length}");
      } else {
        log("Error: ${response.statusCode} - ${response.body}");
      }

      isReportTypeLoading.value = false;
    } catch (e) {
      isReportTypeLoading.value = false;
      if (kDebugMode) {
        print('get reportTypes data failed: $e');
      }
    }
  }

  reportUser({
    required String conversationId,
    required String reportUserId,
    required String reportId,
  }) async {
    try {
      isReportUserLoading.value = true;

      await Hive.openBox(userdata);
      log("token: ${Hive.box(userdata).get(authToken)}");
      final responseJson = await apiHelper.postMethod(
        url: apiHelper.reportUser,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Content-Type': 'application/json',
        },
        requestBody: {
          "conversation_id": int.parse(conversationId),
          "reported_user_id": int.parse(reportUserId),
          "report_id": int.parse(reportId),
        },
      );
      if (responseJson['success'] == true) {
        showCustomToast("User reported");
        Get.back();
      }
      isReportUserLoading.value = false;
    } catch (e) {
      isReportUserLoading.value = false;

      if (kDebugMode) {
        print('report user faield: $e');
      }
    }
  }

  reportMessage({
    required String messageId,
    required String reportId,
    String? reportText,
  }) async {
    try {
      isReportUserLoading.value = true;

      await Hive.openBox(userdata);
      log("token: ${Hive.box(userdata).get(authToken)}");
      
      Map<String, dynamic> requestBody = {
        "message_id": int.parse(messageId),
        "report_id": int.parse(reportId),
      };
      
      if (reportText != null && reportText.isNotEmpty) {
        requestBody["report_text"] = reportText;
      }
      
      final responseJson = await apiHelper.postMethod(
        url: apiHelper.reportMessage,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Content-Type': 'application/json',
        },
        requestBody: requestBody,
      );
      if (responseJson['success'] == true) {
        showCustomToast("Message reported");
        Get.back();
      }
      isReportUserLoading.value = false;
    } catch (e) {
      isReportUserLoading.value = false;

      if (kDebugMode) {
        print('report message failed: $e');
      }
    }
  }
}
