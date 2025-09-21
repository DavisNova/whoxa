// ignore_for_file: avoid_print, prefer_conditional_assignment, unrelated_type_equality_checks, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:whoxachat/main.dart';
import 'package:whoxachat/src/screens/chat/sticker/data/models/sticker_model.dart';
import 'package:whoxachat/src/screens/chat/sticker/widget/sticker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:whoxachat/Models/add_star_model.dart';
import 'package:whoxachat/Models/clear_all_chat_model.dart';
import 'package:whoxachat/Models/send_msg_model.dart';
// import 'package:whoxachat/controller/reply_msg_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';

import 'package:whoxachat/model/chatdetails/single_chat_list_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class SingleChatContorller extends GetxController {
  RxBool isSendMsg = false.obs;
  RxBool isLoading = false.obs;
  Rx<SingleChatListModel?> userdetailschattModel = SingleChatListModel().obs;
  //RxList<MessageList> chatList = <MessageList>[].obs;

  Rx<SendMsgModel?> sendMsgModel = SendMsgModel().obs;

  RxBool isStar = false.obs;
  Rx<AddStarMsgModel?> starModel = AddStarMsgModel().obs;

  RxBool isClear = false.obs;
  Rx<ClearAllChatModel?> clearChatModel = ClearAllChatModel().obs;

  // get message list
  getdetailschat(
    conversationID, {
    bool isAddData = false,
    Function(MessageList)? onNewMessageReceived,
  }) async {
    try {
      isLoading(true);

      // Emit the initial request for messages
      socketIntilized.socket!.emit("messageReceived", {
        "conversation_id": conversationID,
        "user_timezone": Hive.box(userdata).get(utcLocaName)
      });
      print("SingleChat Emitted");

      // Remove any existing listeners to prevent duplicates
      socketIntilized.socket!.off("messageReceived");

      // Listen for messages
      socketIntilized.socket!.on("messageReceived", (data) {
        if (data['MessageList'] != null && data['MessageList'].isNotEmpty) {
          print("DATA1:::::$data");

          // If this is the initial fetch, set the message list
          if (userdetailschattModel.value == null ||
              userdetailschattModel.value!.messageList == null) {
            print("MESSAGE_RECEIVED-1");
            userdetailschattModel.value = SingleChatListModel.fromJson(data);
            // Reverse the initial message list
            userdetailschattModel.value!.messageList =
                userdetailschattModel.value!.messageList!.reversed.toList();
          } else {
            // Reverse the new messages before adding them to the existing list
            print("MESSAGE_RECEIVED-2");
            List<MessageList> reversedNewMessages = data['MessageList']
                .map<MessageList>(
                    (newMessage) => MessageList.fromJson(newMessage))
                .toList()
                .reversed
                .toList();

            // Add reversed new messages to the existing list
            userdetailschattModel
                .value!
                .messageList
                // = reversedNewMessages;
                !
                .addAll(reversedNewMessages);
          }
          print("MESSAGE_RECEIVED-3");
          // userdetailschattModel.value!.messageList!.insert(
          //     userdetailschattModel.value!.messageList!.length,
          //     MessageList.fromJson(data));
          print("MESSAGE LIST : ${userdetailschattModel.value!.messageList}");
        } else {
          print("List Emitted 222");
          print("Data2: ${userdetailschattModel.value!.messageList}");

          if (userdetailschattModel.value == null) {
            userdetailschattModel.value = SingleChatListModel(messageList: []);
          }

          if (userdetailschattModel.value!.messageList == null) {
            userdetailschattModel.value!.messageList = [];
          }

          print("MESSAGE_RECEIVED-4");

          final localData = MessageList.fromJson(data);
          if (localData.conversationId.toString() == conversationID) {
            final lastMessages = userdetailschattModel.value!.messageList!
                .toList()
                .reversed
                .toList();
            bool todayDateFound = false;
            final today = DateTime.now().toUtc();

// Check if today's date message already exists
            for (var i = 0; i < lastMessages.length; i++) {
              if (lastMessages[i].messageType == "date") {
                final lastMessageDate = DateTime.parse(lastMessages[i]
                    .message!); // Assuming UTC date is stored in message field

                if (lastMessageDate.year == today.year &&
                    lastMessageDate.month == today.month &&
                    lastMessageDate.day == today.day) {
                  todayDateFound = true;
                  break;
                }
              }
            }

// If no date message with today's date exists, add it
            if (!todayDateFound) {
              final todayDateMessage = MessageList(
                message: today.toIso8601String(),
                messageType: "date",
                // Add any other necessary fields here
              );
              userdetailschattModel.value!.messageList!
                  .insert(0, todayDateMessage);
            }
            userdetailschattModel.value!.messageList!
                .insert(0, MessageList.fromJson(data));
            userdetailschattModel.refresh();
            if (onNewMessageReceived != null) {
              onNewMessageReceived(
                MessageList.fromJson(data),
              );
            }
            debugPrint("messageViewed called");
          }
        }

        isLoading(false);
        userdetailschattModel.refresh();
        socketIntilized.socket!.on(
          "update_data",
          (data) {
            print("data: $data");
            socketIntilized.socket!.emit("ChatList");
            if ((data["conversation_id"]).toString() ==
                conversationID.toString()) {
              if (data["delete_from_everyone_ids"].toList().isNotEmpty) {
                data["delete_from_everyone_ids"].map((id) {
                  debugPrint("delete_from_everyone_id $id");
                  userdetailschattModel.value!.messageList!
                      .where((element) =>
                          element.messageId.toString() == id.toString())
                      .first
                      .deleteFromEveryone = true;
                }).toList();
                userdetailschattModel.refresh();
              } else {
                socketIntilized.socket!.emit("messageReceived", {
                  "conversation_id": conversationID.toString(),
                  "user_timezone": Hive.box(userdata).get(utcLocaName),
                  "per_page_message": 1,
                });
              }
            }
          },
        );
      });
    } catch (e) {
      log("Error ${e.toString()}");
    } finally {
      print("Finally Called");
    }
  }

  loadingTime() {
    Timer(const Duration(seconds: 15), () {
      if (isSendMsg.value == true) {
        isSendMsg(false);
        showCustomToast('Something Wrong, Please Try Again');
      }
    });
  }

  //================== send DOC message api ==================================
  sendMessageIMGDoc(conversationID, msgtype, filePath, String mobileNum,
      String forwardid, String replyid, bool isforwardUrl) async {
    print("PATH:$filePath");
    isSendMsg(true);
    loadingTime();
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    if (isforwardUrl == true) {
      request.fields['url'] = filePath;
    } else {
      request.files.add(await http.MultipartFile.fromPath('files', filePath));
    }

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    print("IMAGE-FILEDS: ${request.fields}");
    print(responseData);
    isSendMsg(false);
    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (forwardid.isEmpty) {
      if (userdetailschattModel.value?.messageList == null) {
        userdetailschattModel.value =
            SingleChatListModel(messageList: [newMessage]);
      } else {
        print("check.......");
        print("check.......2");
        final lastMessages = userdetailschattModel.value!.messageList!
            .toList()
            .reversed
            .toList();
        bool todayDateFound = false;
        final today = DateTime.now().toUtc();

// Check if today's date message already exists
        for (var i = 0; i < lastMessages.length; i++) {
          if (lastMessages[i].messageType == "date") {
            final lastMessageDate = DateTime.parse(lastMessages[i]
                .message!); // Assuming UTC date is stored in message field

            if (lastMessageDate.year == today.year &&
                lastMessageDate.month == today.month &&
                lastMessageDate.day == today.day) {
              todayDateFound = true;
              break;
            }
          }
        }

// If no date message with today's date exists, add it
        if (!todayDateFound) {
          final todayDateMessage = MessageList(
            message: today.toIso8601String(),
            messageType: "date",
            // Add any other necessary fields here
          );
          userdetailschattModel.value!.messageList!.insert(0, todayDateMessage);
        }
        userdetailschattModel.value!.messageList!.insert(0, newMessage);
      }
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //======================= send text message api ==============================
  sendMessageText(String message, String conversationID, String msgtype,
      String mobileNum, String forwardid, String replyid) async {
    try {
      print(message);
      print(conversationID);
      print(msgtype);
      print(mobileNum);
      var uri = Uri.parse(apiHelper.sendChatMsg);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);

      //adding params
      request.fields['message'] = message;
      request.fields['message_type'] = msgtype;
      request.fields['conversation_id'] = conversationID;
      request.fields['phone_number'] = mobileNum;
      request.fields['forward_id'] = forwardid;
      request.fields['reply_id'] = replyid;

      print(request.fields);
      // send
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      debugPrint("message responseData $responseData");
      var useData = json.decode(responseData);

      sendMsgModel.value = SendMsgModel.fromJson(useData);
      print("object: ${request.fields}");
      print(responseData);
      final newMessage = MessageList.fromJson(useData);
      if (forwardid.isEmpty) {
        if (userdetailschattModel.value?.messageList == null) {
          print("check.......1");
          userdetailschattModel.value =
              SingleChatListModel(messageList: [newMessage]);
        } else {
          print("check.......2");
          final lastMessages = userdetailschattModel.value!.messageList!
              .toList()
              .reversed
              .toList();
          bool todayDateFound = false;
          final today = DateTime.now().toUtc();

// Check if today's date message already exists
          for (var i = 0; i < lastMessages.length; i++) {
            if (lastMessages[i].messageType == "date") {
              final lastMessageDate = DateTime.parse(lastMessages[i]
                  .message!); // Assuming UTC date is stored in message field

              if (lastMessageDate.year == today.year &&
                  lastMessageDate.month == today.month &&
                  lastMessageDate.day == today.day) {
                todayDateFound = true;
                break;
              }
            }
          }

// If no date message with today's date exists, add it
          if (!todayDateFound) {
            final todayDateMessage = MessageList(
              message: today.toIso8601String(),
              messageType: "date",
              // Add any other necessary fields here
            );
            userdetailschattModel.value!.messageList!
                .insert(0, todayDateMessage);
          }

          userdetailschattModel.value!.messageList!.insert(0, newMessage);
        }
      }
      userdetailschattModel.refresh();
      Get.find<ChatListController>().forChatList();

      print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
    } catch (e) {
      debugPrint("send message error $e");
    }
  }

  //======================= Send Location message Api ==========================
  sendMessageLocation(String conversationID, String msgtype, String lat,
      String long, String mobileNum, String forwardid, String replyid) async {
    isSendMsg(true);
    loadingTime();
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);

    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['latitude'] = lat;
    request.fields['longitude'] = long;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    print("object: ${request.fields}");
    print(responseData);

    isSendMsg(false);
    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (forwardid.isEmpty) {
      if (userdetailschattModel.value?.messageList == null) {
        userdetailschattModel.value =
            SingleChatListModel(messageList: [newMessage]);
      } else {
        print("check.......");
        print("check.......2");
        final lastMessages = userdetailschattModel.value!.messageList!
            .toList()
            .reversed
            .toList();
        bool todayDateFound = false;
        final today = DateTime.now().toUtc();

// Check if today's date message already exists
        for (var i = 0; i < lastMessages.length; i++) {
          if (lastMessages[i].messageType == "date") {
            final lastMessageDate = DateTime.parse(lastMessages[i]
                .message!); // Assuming UTC date is stored in message field

            if (lastMessageDate.year == today.year &&
                lastMessageDate.month == today.month &&
                lastMessageDate.day == today.day) {
              todayDateFound = true;
              break;
            }
          }
        }

// If no date message with today's date exists, add it
        if (!todayDateFound) {
          final todayDateMessage = MessageList(
            message: today.toIso8601String(),
            messageType: "date",
            // Add any other necessary fields here
          );
          userdetailschattModel.value!.messageList!.insert(0, todayDateMessage);
        }
        userdetailschattModel.value!.messageList!.insert(0, newMessage);
      }
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //====================== send GIF message =========================================
  sendMessageGIF(conversationID, msgtype, Uint8List? bytes, String forwardurl,
      String mobileNum, String forwardid, String replyid) async {
    isSendMsg(true);
    loadingTime();
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    request.fields['url'] = forwardurl;
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      bytes!,
      filename: 'giphy.gif',
    ));

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    isSendMsg(false);
    print("object: ${request.fields}");
    print(responseData);

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);
    if (forwardid.isEmpty) {
      if (userdetailschattModel.value?.messageList == null) {
        userdetailschattModel.value =
            SingleChatListModel(messageList: [newMessage]);
      } else {
        print("check.......");
        print("check.......2");
        final lastMessages = userdetailschattModel.value!.messageList!
            .toList()
            .reversed
            .toList();
        bool todayDateFound = false;
        final today = DateTime.now().toUtc();

// Check if today's date message already exists
        for (var i = 0; i < lastMessages.length; i++) {
          if (lastMessages[i].messageType == "date") {
            final lastMessageDate = DateTime.parse(lastMessages[i]
                .message!); // Assuming UTC date is stored in message field

            if (lastMessageDate.year == today.year &&
                lastMessageDate.month == today.month &&
                lastMessageDate.day == today.day) {
              todayDateFound = true;
              break;
            }
          }
        }

// If no date message with today's date exists, add it
        if (!todayDateFound) {
          final todayDateMessage = MessageList(
            message: today.toIso8601String(),
            messageType: "date",
            // Add any other necessary fields here
          );
          userdetailschattModel.value!.messageList!.insert(0, todayDateMessage);
        }
        userdetailschattModel.value!.messageList!.insert(0, newMessage);
      }
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

//================================ send Voice message ===============================
  sendMessageVoice(
      String conversationID,
      String msgtype,
      File filePath,
      forwardurl,
      String duration,
      String mobileNum,
      String forwardid,
      String replyid,
      bool isforwardUrl) async {
    isSendMsg(true);
    loadingTime();
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['audio_time'] = duration;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;

    if (isforwardUrl == true) {
      request.fields['url'] = forwardurl;
    } else {
      final filePathNative = Platform.isIOS
          ? Uri.parse(filePath.path).toFilePath()
          : filePath.path;

      request.files
          .add(await http.MultipartFile.fromPath('files', filePathNative));
    }

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    isSendMsg(false);
    print("AUDIO_URL:${request.fields}");
    print("AUDIO_URL:${request.files}");
    print(responseData);

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    if (duration != null) {
      final newMessage = MessageList.fromJson(useData);

      if (forwardid.isEmpty) {
        if (userdetailschattModel.value?.messageList == null) {
          userdetailschattModel.value =
              SingleChatListModel(messageList: [newMessage]);
        } else {
          print("check.......");
          print("check.......2");
          final lastMessages = userdetailschattModel.value!.messageList!
              .toList()
              .reversed
              .toList();
          bool todayDateFound = false;
          final today = DateTime.now().toUtc();

// Check if today's date message already exists
          for (var i = 0; i < lastMessages.length; i++) {
            if (lastMessages[i].messageType == "date") {
              final lastMessageDate = DateTime.parse(lastMessages[i]
                  .message!); // Assuming UTC date is stored in message field

              if (lastMessageDate.year == today.year &&
                  lastMessageDate.month == today.month &&
                  lastMessageDate.day == today.day) {
                todayDateFound = true;
                break;
              }
            }
          }

// If no date message with today's date exists, add it
          if (!todayDateFound) {
            final todayDateMessage = MessageList(
              message: today.toIso8601String(),
              messageType: "date",
              // Add any other necessary fields here
            );
            userdetailschattModel.value!.messageList!
                .insert(0, todayDateMessage);
          }
          userdetailschattModel.value!.messageList!.insert(0, newMessage);
        }
      }
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //================================ Send Video Message ===================================
  sendMessageVideo(conversationID, msgtype, filePath, String mobileNum,
      String forwardid, String replyid, bool isforwardUrl) async {
    print("RESPONSE:$filePath");
    isSendMsg(true);
    loadingTime();
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };
    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    if (isforwardUrl == true) {
      request.fields['url'] = filePath;
    } else {
      for (String data in filePath) {
        request.files.add(await http.MultipartFile.fromPath('files', data));
      }
    }
    print("VIDEO-FILES:${request.fields}");
    print("VIDEO-FILES:${request.files}");
    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    isSendMsg(false);
    print("object: ${request.fields}");
    print("object: ${request.files}");
    print("RESPONSE: $responseData");

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (forwardid.isEmpty) {
      if (userdetailschattModel.value?.messageList == null) {
        userdetailschattModel.value =
            SingleChatListModel(messageList: [newMessage]);
      } else {
        print("check.......");
        print("check.......2");
        final lastMessages = userdetailschattModel.value!.messageList!
            .toList()
            .reversed
            .toList();
        bool todayDateFound = false;
        final today = DateTime.now().toUtc();

// Check if today's date message already exists
        for (var i = 0; i < lastMessages.length; i++) {
          if (lastMessages[i].messageType == "date") {
            final lastMessageDate = DateTime.parse(lastMessages[i]
                .message!); // Assuming UTC date is stored in message field

            if (lastMessageDate.year == today.year &&
                lastMessageDate.month == today.month &&
                lastMessageDate.day == today.day) {
              todayDateFound = true;
              break;
            }
          }
        }

// If no date message with today's date exists, add it
        if (!todayDateFound) {
          final todayDateMessage = MessageList(
            message: today.toIso8601String(),
            messageType: "date",
            // Add any other necessary fields here
          );
          userdetailschattModel.value!.messageList!.insert(0, todayDateMessage);
        }
        userdetailschattModel.value!.messageList!.insert(0, newMessage);
        userdetailschattModel.refresh();
        Get.find<ChatListController>().forChatList();
        print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
      }
    }
  }

  //========================= send contact message ==============================
  sendMessageContact(conversationID, msgtype, contactName, contactNumber,
      String mobileNum, image, String forwardid, String replyid) async {
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };
    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['shared_contact_name'] = contactName;
    request.fields['shared_contact_number'] = contactNumber;
    request.fields['shared_contact_profile_image'] = image;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    Get.back();
    print("object: ${request.fields}");
    print("object: ${request.files}");
    print("RESPONSE: $responseData");

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (forwardid.isEmpty) {
      if (userdetailschattModel.value?.messageList == null) {
        userdetailschattModel.value =
            SingleChatListModel(messageList: [newMessage]);
      } else {
        print("check.......");
        print("check.......2");
        final lastMessages = userdetailschattModel.value!.messageList!
            .toList()
            .reversed
            .toList();
        bool todayDateFound = false;
        final today = DateTime.now().toUtc();

// Check if today's date message already exists
        for (var i = 0; i < lastMessages.length; i++) {
          if (lastMessages[i].messageType == "date") {
            final lastMessageDate = DateTime.parse(lastMessages[i]
                .message!); // Assuming UTC date is stored in message field

            if (lastMessageDate.year == today.year &&
                lastMessageDate.month == today.month &&
                lastMessageDate.day == today.day) {
              todayDateFound = true;
              break;
            }
          }
        }

// If no date message with today's date exists, add it
        if (!todayDateFound) {
          final todayDateMessage = MessageList(
            message: today.toIso8601String(),
            messageType: "date",
            // Add any other necessary fields here
          );
          userdetailschattModel.value!.messageList!.insert(0, todayDateMessage);
        }
        userdetailschattModel.value!.messageList!.insert(0, newMessage);
      }
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  sendMessageStatusMessage(
      String message, String msgtype, String mobileNum, String statusID) async {
    try {
      print(message);
      print(msgtype);
      print(mobileNum);
      isSendMsg(true);
      loadingTime();
      var uri = Uri.parse(apiHelper.sendChatMsg);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);

      //adding params
      request.fields['message'] = message;
      request.fields['message_type'] = msgtype;
      request.fields['phone_number'] = mobileNum;
      request.fields['status_id'] = statusID;
      // request.fields['forward_id'] = "";
      // request.fields['reply_id'] = "";

      print(request.fields);
      // send
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      sendMsgModel.value = SendMsgModel.fromJson(useData);
      print("object: ${request.fields}");
      print("message responseData $responseData");
      // final newMessage = MessageList.fromJson(useData);

      // if (userdetailschattModel.value?.messageList == null) {
      //   userdetailschattModel.value =
      //       SingleChatListModel(messageList: [newMessage]);
      // } else {
      //   print("check.......");
      //   userdetailschattModel.value!.messageList!.insert(0, newMessage);
      // }
      // userdetailschattModel.refresh();
      // // final respo = MessageList.fromJson(useData);
      // // userdetailschattModel.value!.messageList!.add(respo);
      // // Get.back();
      Get.find<ChatListController>().forChatList();
      // print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");

      isSendMsg(false);
    } catch (e) {
      isSendMsg(false);
    }

    // getdetailschat(conversationID);
  }

  deleteChatApi(chatID, bool deleteFrom, String mobileNum) async {
    isSendMsg(true);
    loadingTime();

    var uri = Uri.parse(apiHelper.deleteChatMsg);

    // Constructing the body as a JSON object
    Map<String, dynamic> requestBody = {
      'message_id_list': chatID
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .removeAllWhitespace,
      'delete_from_every_one': deleteFrom.toString(),
      'conversation_id': int.parse(mobileNum),
    };

    // Creating headers with Authorization
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
      "Content-Type": "application/json", // Important to send JSON payload
    };

    // Send POST request with JSON body
    try {
      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody), // Encoding request body as JSON
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        String responseData = response.body;
        var useData = json.decode(responseData);

        // Handling response
        isSendMsg(false);
        print("Response Data: $useData");

        userdetailschattModel.value!.messageList!
            .removeWhere((message) => chatID.contains(message.messageId));

        userdetailschattModel.refresh();
        Get.find<ChatListController>().forChatList();
        print(
            "Updated message list length: ${userdetailschattModel.value!.messageList!.length}");
      } else {
        print("Failed to delete message. Status code: ${response.statusCode}");
        // Handle failure if needed
      }
    } catch (e) {
      print("Error occurred while sending request: $e");
      isSendMsg(false);
      // Handle error if needed
    }
  }
  // deleteChatApi(chatID, bool deleteFrom, String mobileNum) async {
  //   isSendMsg(true);
  //   loadingTime();
  //   var uri = Uri.parse(apiHelper.deleteChatMsg);

  //   var request = http.MultipartRequest("POST", uri);

  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
  //     "Accept": "application/json",
  //   };

  //   //add headers
  //   request.headers.addAll(headers);
  //   //adding params
  //   request.fields['message_id_list'] = chatID
  //       .toString()
  //       .replaceAll('[', '')
  //       .replaceAll(']', '')
  //       .removeAllWhitespace;
  //   request.fields['delete_from_every_one'] = deleteFrom.toString();
  //   request.fields['conversation_id'] = mobileNum;

  //   // send
  //   var response = await request.send();

  //   String responseData = await response.stream.transform(utf8.decoder).join();
  //   var useData = json.decode(responseData);

  //   isSendMsg(false);
  //   print("object: ${request.fields}");
  //   print("object: $useData");
  //   print(responseData);

  //   userdetailschattModel.value!.messageList!
  //       .removeWhere((message) => chatID.contains(message.messageId));

  //   userdetailschattModel.refresh();
  //   Get.find<ChatListController>().forChatList();
  //   print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  // }

  addStarApi(chatID, conversationId) async {
    print(chatID);
    isStar(true);
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['message_id'] = chatID;
      request.fields['conversation_id'] = conversationId;
      var response = await request.send();
      print("chatid:${request.fields}");

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel.value = AddStarMsgModel.fromJson(useData);

      if (starModel.value!.success == true) {
        for (var i = 0;
            i < userdetailschattModel.value!.messageList!.length;
            i++) {
          debugPrint(
              "chatList[i].messageId ${userdetailschattModel.value!.messageList![i].messageId}");
          debugPrint("chatList[i].chatID $chatID");
          if (userdetailschattModel.value!.messageList![i].messageId
                  .toString() ==
              chatID.toString()) {
            debugPrint(
                "chatList[i].messageId 1 ${userdetailschattModel.value!.messageList![i].messageId}");
            debugPrint("chatList[i].chatID 1 $chatID");
            userdetailschattModel.value!.messageList![i].isStarMessage =
                true; // Update message's star status
            userdetailschattModel.refresh();
            //chatList.refresh();
          }
        }
        isStar(false);
        // Find and update message list
        // chatList.firstWhere(
        //   (msg) {
        //     if (msg.messageId == chatID) {
        //       msg.isStarMessage = true; // Update message's star status
        //       chatList.refresh();
        //     }
        //   },
        //   orElse: () => MessageList(), // Return a default MessageList object
        // );
        // if (message != null) {}
        Get.find<ChatListController>().forChatList();
        showCustomToast(starModel.value!.message!);
      } else {
        isStar(false);
      }
    } catch (e) {
      isStar(false);
      showCustomToast(e.toString());
    } finally {
      isStar(false);
    }
  }

  removeStarApi(chatID) async {
    print(chatID);
    isStar(true);
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['message_id'] = chatID;
      request.fields['remove_from_star'] = true.toString();
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel.value = AddStarMsgModel.fromJson(useData);

      if (starModel.value!.success == true) {
        for (var i = 0;
            i < userdetailschattModel.value!.messageList!.length;
            i++) {
          debugPrint(
              "chatList[i].messageId ${userdetailschattModel.value!.messageList![i].messageId}");
          debugPrint("chatList[i].chatID $chatID");
          if (userdetailschattModel.value!.messageList![i].messageId
                  .toString() ==
              chatID.toString()) {
            debugPrint(
                "chatList[i].messageId 1 ${userdetailschattModel.value!.messageList![i].messageId}");
            debugPrint("chatList[i].chatID 1 $chatID");
            userdetailschattModel.value!.messageList![i].isStarMessage =
                false; // Update message's star status
            userdetailschattModel.refresh();
            // chatList.refresh();
          }
        }
        isStar(false);
        userdetailschattModel.refresh();
        Get.find<ChatListController>().forChatList();
        showCustomToast(starModel.value!.message!);
      } else {
        isStar(false);
      }
    } catch (e) {
      print(e.toString());
      showCustomToast(e.toString());
      isStar(false);
    } finally {
      isStar(false);
    }
  }

  clearAllChatApi(
      {required String conversationid, required String messageID}) async {
    isClear(true);
    try {
      var uri = Uri.parse(apiHelper.clearChatUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationid;
      request.fields['message_id'] = messageID;

      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      clearChatModel.value = ClearAllChatModel.fromJson(useData);

      if (clearChatModel.value!.success == true) {
        userdetailschattModel.refresh();
        isClear(false);
        showCustomToast("Clear all chat");
      } else {
        isClear(false);
        showCustomToast(clearChatModel.value!.message!);
      }
    } catch (e) {
      isClear(false);
      print(e.toString());
    } finally {
      isClear(false);
    }
  }

  isTypingApi(cID, istyping) {
    print("IS_TYPING_CONVERSATION:$cID");
    print("IS-TYPING:$istyping");
    socketIntilized.socket!.emit("isTyping", {
      "conversation_id": cID.toString(),
      "is_typing": int.parse(istyping.toString())
    });
    userdetailschattModel.refresh();
    print("isTyping Emitted");
  }

  removeStarApiMultiple(chatID) async {
    print(chatID);
    isStar(true);
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['message_id'] = chatID
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .removeAllWhitespace;

      request.fields['remove_from_star'] = true.toString();
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel.value = AddStarMsgModel.fromJson(useData);

      if (starModel.value!.success == true) {
        for (var i = 0;
            i < userdetailschattModel.value!.messageList!.length;
            i++) {
          debugPrint(
              "chatList[i].messageId ${userdetailschattModel.value!.messageList![i].messageId}");
          debugPrint("chatList[i].chatID $chatID");
          if (userdetailschattModel.value!.messageList![i].messageId
                  .toString() ==
              chatID.toString()) {
            debugPrint(
                "chatList[i].messageId 1 ${userdetailschattModel.value!.messageList![i].messageId}");
            debugPrint("chatList[i].chatID 1 $chatID");
            userdetailschattModel.value!.messageList![i].isStarMessage =
                false; // Update message's star status
            userdetailschattModel.refresh();
            // chatList.refresh();
          }
        }
        isStar(false);
        userdetailschattModel.refresh();
        showCustomToast(starModel.value!.message!);
      } else {
        isStar(false);
      }
    } catch (e) {
      print(e.toString());
      showCustomToast(e.toString());
      isStar(false);
    } finally {
      isStar(false);
    }
  }

  //this method not work to set data is null in result it is create error
  // @override
  // void onClose() {
  //   super.onClose();
  //   userdetailschattModel.value?.messageList?.clear();
  //   userdetailschattModel.value = null;
  // }

  /// sticker management
  Future<void> showStickerPicker(
      BuildContext context, String conversationID, String mobileNum) async {
    try {
      // Show sticker/GIF picker and wait for selection
      final Map<String, dynamic>? result = await StickerPicker.show(context);

      if (result != null) {
        final StickerItem selectedItem = result['item'];
        final String type = result['type']; // 'sticker' or 'gif'

        // Send the selected item with appropriate type
        await _sendStickerOrGif(
          conversationID,
          type, // Use the type from selection
          null, // No bytes needed
          selectedItem.fileLocation ?? '',
          mobileNum,
          '',
          '',
        );
      }
    } catch (e) {
      print('Error in sticker/GIF picker: $e');
      Get.snackbar('Error',
          'Failed to send ${e.toString().contains('gif') ? 'GIF' : 'sticker'}');
    }
  }

  Future<void> _sendStickerOrGif(
      String conversationID,
      String msgtype, // 'sticker' or 'gif'
      Uint8List? bytes, // Keep for signature compatibility but not used
      String forwardurl,
      String mobileNum,
      String forwardid,
      String replyid) async {
    isSendMsg(true);
    loadingTime();

    var uri = Uri.parse(apiHelper.sendChatMsg);
    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    request.headers.addAll(headers);

    // Adding params - send URL instead of file
    request.fields['message_type'] = msgtype; // 'sticker' or 'gif'
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    request.fields['url'] = forwardurl; // Sticker/GIF URL

    // No file upload needed - just send the URL

    try {
      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      sendMsgModel.value = SendMsgModel.fromJson(useData);
      isSendMsg(false);

      print("${msgtype.toUpperCase()} request fields: ${request.fields}");
      print("${msgtype.toUpperCase()} response: $responseData");

      // Your existing message handling logic
      final newMessage = MessageList.fromJson(useData);

      if (forwardid.isEmpty) {
        if (userdetailschattModel.value?.messageList == null) {
          userdetailschattModel.value =
              SingleChatListModel(messageList: [newMessage]);
        } else {
          print("check.......");
          print("check.......2");
          final lastMessages = userdetailschattModel.value!.messageList!
              .toList()
              .reversed
              .toList();
          bool todayDateFound = false;
          final today = DateTime.now().toUtc();

          // Check if today's date message already exists
          for (var i = 0; i < lastMessages.length; i++) {
            if (lastMessages[i].messageType == "date") {
              final lastMessageDate = DateTime.parse(lastMessages[i].message!);
              if (lastMessageDate.year == today.year &&
                  lastMessageDate.month == today.month &&
                  lastMessageDate.day == today.day) {
                todayDateFound = true;
                break;
              }
            }
          }

          // If no date message with today's date exists, add it
          if (!todayDateFound) {
            final todayDateMessage = MessageList(
              message: today.toIso8601String(),
              messageType: "date",
            );
            userdetailschattModel.value!.messageList!
                .insert(0, todayDateMessage);
          }

          userdetailschattModel.value!.messageList!.insert(0, newMessage);
        }
      }

      userdetailschattModel.refresh();
      Get.find<ChatListController>().forChatList();
      print(
          "${msgtype.toUpperCase()} LIST: ${userdetailschattModel.value!.messageList!.length}");
    } catch (e) {
      isSendMsg(false);
      print('Error sending ${msgtype}: $e');
      Get.snackbar('Error', 'Failed to send ${msgtype}');
      throw e;
    }
  }


  @override
  void onClose() {
    super.onClose();
    if (userdetailschattModel.value != null) {
      // Clear the message list if it exists
      userdetailschattModel.value?.messageList?.clear();
      // Reset to a new empty model instead of null
      userdetailschattModel.value = SingleChatListModel();
    }
  }
}
