import 'dart:developer';

import 'package:whoxachat/main.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:whoxachat/Models/last_seen_model.dart';
import 'package:whoxachat/Models/typing_user_model.dart';
import 'package:whoxachat/controller/online_user_controller.dart';

class OnlineOfflineController extends GetxController {
  Rx<OnlineUsersModel> onlineUserModel = OnlineUsersModel().obs;
  RxList<String> allOnline = <String>[].obs;

  Rx<LastSeenModel> lastSeenModel = LastSeenModel().obs;
  RxList<LastSeenUserList> allOffline = <LastSeenUserList>[].obs;

  bool typingloder = true;
  Rx<TypingUserModel?> typingUserListModel = TypingUserModel().obs;
  RxList<TypingUserList> typingList = <TypingUserList>[].obs;

  forData() {
    socketIntilized.socket!.on("onlineUsers", (data) {
      if (kDebugMode) {
        print("ONLINE DATA  $data");
      }
      if (onlineUserModel.value.onlineUserList == null) {
        if (kDebugMode) {
          print('online users null');
        }
        var respo = OnlineUsersModel.fromJson(data);
        onlineUserModel.value = respo;
        allOnline.value = OnlineUsersModel.fromJson(data).onlineUserList!;

        log("ONLINE USER LIST ${onlineUserModel.value.onlineUserList}");
      } else {
        if (kDebugMode) {
          print('Online users not null');
        }
        if (kDebugMode) {
          print("ONLINE DATA $data");
        }
        var res = OnlineUsersModel.fromJson(data);
        onlineUserModel.value = res;
        allOnline.value = OnlineUsersModel.fromJson(data).onlineUserList!;
        log("${onlineUserModel.value.onlineUserList}");
      }
    });
  }

  offlineUser() {
    socketIntilized.socket!.on("userLastSeenList", (data) {
      if (kDebugMode) {
        print("OFFLINE DATA  $data");
      }
      if (lastSeenModel.value.lastSeenUserList == null) {
        if (kDebugMode) {
          print('offline users null');
        }
        var respo = LastSeenModel.fromJson(data);
        lastSeenModel.value = respo;
        allOffline.value = LastSeenModel.fromJson(data).lastSeenUserList!;
        log("OFFLINE USER LIST ${lastSeenModel.value.lastSeenUserList}");
      } else {
        if (kDebugMode) {
          print('Offline users not null');
        }
        if (kDebugMode) {
          print("OFFLINE DATA $data");
        }
        var res = LastSeenModel.fromJson(data);
        lastSeenModel.value = res;
        allOffline.value = LastSeenModel.fromJson(data).lastSeenUserList!;
        log("${lastSeenModel.value.lastSeenUserList}");
      }
    });
  }

  isTyping() {
    socketIntilized.socket!.on('isTyping', (data) {
      if (typingUserListModel.value!.typingUserList == null) {
        log(data.toString());
        var respo = TypingUserModel.fromJson(data);
        typingUserListModel.value = respo;
        typingList.value = TypingUserModel.fromJson(data).typingUserList!;
        typingList.refresh();
        typingloder = false;
      } else {
        log(data.toString());
        var respo = TypingUserModel.fromJson(data);
        typingUserListModel.value = respo;
        typingList.value = TypingUserModel.fromJson(data).typingUserList!;
        typingList.refresh();
        typingloder = false;
      }
    });
  }
}
