// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/group_exit_model.dart';
import 'package:whoxachat/Models/make_admin_model.dart';
import 'package:whoxachat/Models/remove_admin_modeld.dart';
import 'package:whoxachat/model/chat_profile_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';

final ApiHelper apiHelper = ApiHelper();

class ChatProfileController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<ChatProfileModel?> profileModel = ChatProfileModel().obs;
  RxString totalCount = ''.obs;
  RxList<ConversationsUsers> users = <ConversationsUsers>[].obs;

  RxBool isAdmin = false.obs;
  Rx<MakeAdmingModel?> adminModel = MakeAdmingModel().obs;

  RxBool isRemoveAdmin = false.obs;
  Rx<RemoveAdminModel?> removeAdminModel = RemoveAdminModel().obs;

  RxBool isExit = false.obs;
  Rx<ExitGroupModel?> exitModel = ExitGroupModel().obs;

  Future<void> getProfileDATA(String conversationID) async {
    debugPrint("conversationID $conversationID");
    isLoading.value = true;
    try {
      var uri = Uri.parse(apiHelper.getOnetoOneMedia);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields.addAll({
        'conversation_id': conversationID,
      });

      var response = await request.send();
      print("RES PROFILE DATA ${response.statusCode}");
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      log('res user data: $userData');
      profileModel.value = ChatProfileModel.fromJson(userData);
      int mediaLength = profileModel.value!.mediaData!.length;
      int docLength = profileModel.value!.documentData!.length;
      int linkLength = profileModel.value!.linkData!.length;

      totalCount.value = (mediaLength + docLength + linkLength).toString();
      users.clear();
      if (profileModel.value != null) {
        for (var i = 0;
            i <
                profileModel
                    .value!.conversationDetails!.conversationsUsers!.length;
            i++) {
          users.add(
              profileModel.value!.conversationDetails!.conversationsUsers![i]);
        }
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  makeAdminApi(String conversationID, String userid, String value) async {
    isAdmin(true);
    try {
      var uri = Uri.parse(apiHelper.createGroupAdmin);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        'Accept': 'application/json',
      };
      request.headers.addAll(headers);
      request.fields.addAll({
        'conversation_id': conversationID,
        'new_user_id': userid,
        'remove_from_admin': value
      });
      print("FIELDS:${request.fields}");
      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      adminModel.value = MakeAdmingModel.fromJson(userData);

      if (adminModel.value!.success == true) {
        for (var i = 0;
            i <
                profileModel
                    .value!.conversationDetails!.conversationsUsers!.length;
            i++) {
          if (userid ==
              profileModel.value!.conversationDetails!.conversationsUsers![i]
                  .user!.userId
                  .toString()) {
            if (value == "true") {
              profileModel.value!.conversationDetails!.conversationsUsers![i]
                  .isAdmin = false;
            } else {
              profileModel.value!.conversationDetails!.conversationsUsers![i]
                  .isAdmin = true;
            }
            profileModel.refresh();
          }
        }
        isAdmin(false);
        showCustomToast(adminModel.value!.message!);
      } else {
        isAdmin(false);
        showCustomToast(adminModel.value!.message!);
      }
    } catch (e) {
      isAdmin(false);
      showCustomToast(e.toString());
    } finally {
      isAdmin(false);
    }
  }

  removeAdminApi(String conversationID, String userid) async {
    isAdmin(true);
    try {
      var uri = Uri.parse(apiHelper.removeGroupAdmin);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        'Accept': 'application/json',
      };
      request.headers.addAll(headers);
      request.fields.addAll({
        'conversation_id': conversationID,
        'remove_user_id': userid,
      });
      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      removeAdminModel.value = RemoveAdminModel.fromJson(userData);

      print("DATA:$responseData");

      if (removeAdminModel.value!.success == true) {
        getProfileDATAUpdate(conversationID);
        isAdmin(false);
        showCustomToast(removeAdminModel.value!.message!);
      } else {
        isAdmin(false);
        showCustomToast(removeAdminModel.value!.message!);
      }
    } catch (e) {
      isAdmin(false);
      showCustomToast(e.toString());
    } finally {
      isAdmin(false);
    }
  }

  exitGroupApi({required String cID}) async {
    isExit(true);
    try {
      var uri = Uri.parse(apiHelper.exitGroupUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        'Accept': 'application/json',
      };
      request.headers.addAll(headers);
      request.fields['conversation_id'] = cID;

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      exitModel.value = ExitGroupModel.fromJson(userData);

      if (exitModel.value!.success == true) {
        isExit(false);
        showCustomToast(exitModel.value!.message!);
        Get.offAll(() => TabbarScreen(currentTab: 0));
      } else {
        isExit(false);
        showCustomToast(exitModel.value!.message!);
      }
    } catch (e) {
      isExit(false);
      print(e.toString());
    } finally {
      isExit(false);
    }
  }

  getProfileDATAUpdate(String conversationID) async {
    var uri = Uri.parse(apiHelper.getOnetoOneMedia);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({
      'conversation_id': conversationID,
    });

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    profileModel.value = ChatProfileModel.fromJson(userData);

    int mediaLength = profileModel.value!.mediaData!.length;
    int docLength = profileModel.value!.documentData!.length;
    int linkLength = profileModel.value!.linkData!.length;

    totalCount.value = (mediaLength + docLength + linkLength).toString();
    users.clear();
    if (profileModel.value != null) {
      for (var i = 0;
          i <
              profileModel
                  .value!.conversationDetails!.conversationsUsers!.length;
          i++) {
        users.add(
            profileModel.value!.conversationDetails!.conversationsUsers![i]);
      }
    }
  }
}
