// ignore_for_file: avoid_print, file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:whoxachat/main.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/calls_Model/call_history_model.dart';
import 'package:whoxachat/Models/calls_Model/get_roomId.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/Models/calls_Model/joined_users_model.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';

import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/web_rtc.dart';

final ApiHelper apiHelper = ApiHelper();

class RoomIdController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isCallCutByMeLoading = false.obs;
  RxBool isCallCutByReceiverLoading = false.obs;
  RxBool isCallHistoryLoading = false.obs;
  Rx<GetRoomIdModel?> roomModel = GetRoomIdModel().obs;
  RxList<CallList> callHistoryData = <CallList>[].obs;
  RxList<ConnectedUsers> connnectdUsersData = <ConnectedUsers>[].obs;

  getRoomModelApi({String? conversationID, String? callType}) async {
    isLoading(true);
    try {
      var uri = Uri.parse(apiHelper.getRoomIdUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID!;
      request.fields['call_type'] = callType!;

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      roomModel.value = GetRoomIdModel.fromJson(userData);

      print("DATA:$responseData");

      if (roomModel.value!.success == true) {
        isLoading(false);
      } else {
        isLoading(false);
        showCustomToast("Something went wrong...!");
      }
    } catch (e) {
      isLoading(false);
      print(e.toString());
    } finally {
      isLoading(false);
    }
  }

  callCutByMe(
      {required String conversationID, required String callType}) async {
    isCallCutByMeLoading(true);
    try {
      var uri = Uri.parse(apiHelper.callCutByMe);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID;
      request.fields['call_type'] = callType;
      request.fields['message_id'] = roomModel.value!.messageId.toString();

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var callCutByMeData = json.decode(responseData);

      print("callCutByMeData: $callCutByMeData");

      if (callCutByMeData["success"] == true) {
        Get.back();

        isCallCutByMeLoading(false);
      } else {
        isCallCutByMeLoading(false);
        showCustomToast("Something went wrong...!");
      }
    } catch (e) {
      isCallCutByMeLoading(false);
      print(e.toString());
    } finally {
      isCallCutByMeLoading(false);
    }
  }

  callCutByReceiver({
    required String conversationID,
    required String message_id,
    required String caller_id,
  }) async {
    isCallCutByReceiverLoading(true);
    try {
      var uri = Uri.parse(apiHelper.callCutByReceiver);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID;
      request.fields['message_id'] = message_id;
      request.fields['caller_id'] = caller_id;

      print("callCutByReceiver FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var callCutByReceiverData = json.decode(responseData);

      print("callCutByRcecieverData: $callCutByReceiverData");

      if (callCutByReceiverData["success"] == true) {
        Get.find<ChatListController>().forChatList();
        Get.offAll(
          TabbarScreen(
            currentTab: 0,
          ),
        );

        isCallCutByReceiverLoading(false);
      } else {
        isCallCutByReceiverLoading(false);
        showCustomToast("Something went wrong...!");
      }
    } catch (e) {
      isCallCutByReceiverLoading(false);
      print(e.toString());
    } finally {
      isCallCutByReceiverLoading(false);
    }
  }

  callHistory() async {
    try {
      isCallHistoryLoading.value = true;

      await Hive.openBox(userdata);
      log("token: ${Hive.box(userdata).get(authToken)}");
      final responseJson = await apiHelper.postMethod(
        url: apiHelper.callHistory,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          "Accept": "application/json",
        },
        requestBody: {},
      );
      callHistoryData.value = CallHistoryModel.fromJson(responseJson).callList!;
      log("callHistoryData length ${callHistoryData.length}");
      isCallHistoryLoading.value = false;
    } catch (e) {
      isCallHistoryLoading.value = false;

      if (kDebugMode) {
        print('get call history faield: $e');
      }
    }
  }

  joinUsers({
    required bool isCaller,
    required bool isGroupCall,
    VoidCallback? callback,
  }) {
    try {
      socketIntilized.socket!.on("connected-user-list", (data) {
        if (kDebugMode) {
          print("connected-user-list DATA  $data");
        }
        connnectdUsersData.value =
            ConnectedUsersModel.fromJson(data).connectedUsers!;

        if (isCaller == false) {
          if (callback != null) {
            callback();
            log("connnectdUsersData call back executed");
          }
        }
      });
    } catch (e) {
      isCallHistoryLoading.value = false;

      if (kDebugMode) {
        print('connected-user-list DATA faield: $e');
      }
    }
  }
}
