// ignore_for_file: avoid_print, unused_field, must_be_immutable
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/single_chat_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/chatdetails/single_chat_list_model.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/model/userchatlist_model/userchatlist_model.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';

class ForwardMessage extends StatefulWidget {
  String chatid;
  bool isMsgType;
  String? converstionID;
  List<MessageList> forwardMsgList;
  ForwardMessage(
      {super.key,
      required this.chatid,
      required this.isMsgType,
      this.converstionID,
      required this.forwardMsgList});

  @override
  State<ForwardMessage> createState() => _ForwardMessageState();
}

class _ForwardMessageState extends State<ForwardMessage> {
  ChatListController chatListController = Get.find();
  SingleChatContorller chatContorller = Get.find();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isview = false;
  TextEditingController controller = TextEditingController();
  List<String> isSelectedusername = [];

  @override
  void initState() {
    super.initState();
    print("chat_ID:${widget.chatid}");
    print("conversation_ID:${widget.converstionID}");
  }

  List forwardmessageuser = [];

  String username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 70,
        color: chatownColor,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(0),
            topLeft: Radius.circular(0),
          ),
          child: BottomAppBar(
            color: chatownColor,
            elevation: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0), color: chatownColor),
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.63,
                            height: 40,
                            child: ListView.builder(
                                itemCount: isSelectedusername.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Text(
                                      capitalizeFirstLetter(isSelectedusername[
                                              index] +
                                          (index ==
                                                  isSelectedusername.length - 1
                                              ? ""
                                              : ", ")),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black));
                                }),
                          ),
                        ],
                      ),
                    ),
                    forwardmessageuser.isNotEmpty
                        ? chatContorller.isSendMsg.value
                            ? loader(context)
                            : InkWell(
                                onTap: onTap,
                                child: Container(
                                  height: 35,
                                  width: 85,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: const Color(0xffF4F5F6)),
                                  child: Center(
                                    child: Text(
                                      languageController
                                          .textTranslate('Forward'),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  appBarWidget(context),
                  chatWidget(context),
                  Expanded(
                      child: SingleChildScrollView(child: chatListScreen()))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onTap() {
    try {
      chatContorller.isSendMsg.value = true;
      if (forwardmessageuser.isNotEmpty) {
        for (var i = 0; i < forwardmessageuser.length; i++) {
          for (var j = 0; j < widget.forwardMsgList.length; j++) {
            if (widget.forwardMsgList[j].messageType == 'text') {
              chatContorller.sendMessageText(
                  widget.forwardMsgList[j].message!,
                  forwardmessageuser[i].toString(),
                  'text',
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '');
            } else if (widget.forwardMsgList[j].messageType == 'image') {
              chatContorller.sendMessageIMGDoc(
                  forwardmessageuser[i].toString(),
                  'image',
                  widget.forwardMsgList[j].url,
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '',
                  true);
            } else if (widget.forwardMsgList[j].messageType == 'location') {
              chatContorller.sendMessageLocation(
                  forwardmessageuser[i].toString(),
                  "location",
                  widget.forwardMsgList[j].latitude!,
                  widget.forwardMsgList[j].longitude!,
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '');
            } else if (widget.forwardMsgList[j].messageType == 'video') {
              chatContorller.sendMessageVideo(
                  forwardmessageuser[i].toString(),
                  "video",
                  widget.forwardMsgList[j].url,
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '',
                  true);
            } else if (widget.forwardMsgList[j].messageType == 'document') {
              chatContorller.sendMessageIMGDoc(
                  forwardmessageuser[i].toString(),
                  'document',
                  widget.forwardMsgList[j].url,
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '',
                  true);
            } else if (widget.forwardMsgList[j].messageType == 'audio') {
              chatContorller.sendMessageVoice(
                  forwardmessageuser[i].toString(),
                  "audio",
                  File(''),
                  widget.forwardMsgList[j].url!,
                  widget.forwardMsgList[j].audioTime!,
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '',
                  true);
            } else if (widget.forwardMsgList[j].messageType == 'gif') {
              chatContorller.sendMessageGIF(
                  forwardmessageuser[i].toString(),
                  'gif',
                  Uint8List(0),
                  widget.forwardMsgList[j].url!,
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '');
            } else if (widget.forwardMsgList[j].messageType == 'link') {
              chatContorller.sendMessageText(
                  widget.forwardMsgList[j].message!,
                  forwardmessageuser[i].toString(),
                  'text',
                  '',
                  widget.forwardMsgList[j].messageId.toString(),
                  '');
            } else if (widget.forwardMsgList[j].messageType == 'contact') {
              chatContorller.sendMessageContact(
                  forwardmessageuser[i].toString(),
                  "contact",
                  widget.forwardMsgList[j].sharedContactName,
                  widget.forwardMsgList[j].sharedContactNumber,
                  '',
                  widget.forwardMsgList[j].sharedContactProfileImage,
                  widget.forwardMsgList[j].messageId.toString(),
                  '');
            }
          }
        }
        chatContorller.isSendMsg.value = false;
      }
    } catch (e) {
      chatContorller.isSendMsg.value = false;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TabbarScreen(currentTab: 0)),
        (route) => false);
  }

  Widget chatListScreen() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        color: appColorWhite,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              chatListController.userChatListModel.value!.chatList!.length,
          itemBuilder: (context, index) {
            List<ChatList> chatlist =
                chatListController.userChatListModel.value!.chatList!;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isSelectedusername.contains(chatlist[index].userName) ||
                            isSelectedusername
                                .contains(chatlist[index].groupName)
                        ? isSelectedusername.remove(
                            chatlist[index].userName.toString().isEmpty
                                ? chatlist[index].groupName.toString()
                                : chatlist[index].userName.toString())
                        : isSelectedusername.add(
                            chatlist[index].userName.toString().isEmpty
                                ? chatlist[index].groupName.toString()
                                : chatlist[index].userName.toString());

                    if (chatlist[index].conversationId != null) {
                      forwardmessageuser
                              .contains(chatlist[index].conversationId)
                          ? forwardmessageuser
                              .remove(chatlist[index].conversationId)
                          : forwardmessageuser
                              .add(chatlist[index].conversationId!);
                      print("TO_USERS:$forwardmessageuser");
                    }
                  });
                  print("USERNAME:$isSelectedusername");
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  height: 75,
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 0,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: chatlist[index].profileImage != ""
                              ? CustomCachedNetworkImage(
                                  imageUrl: chatlist[index].profileImage!,
                                  placeholderColor: chatownColor,
                                  errorWidgeticon: const Icon(
                                    Icons.person,
                                    size: 25,
                                  ))
                              : CustomCachedNetworkImage(
                                  imageUrl: chatlist[index].groupProfileImage!,
                                  placeholderColor: chatownColor,
                                  errorWidgeticon: const Icon(
                                    Icons.groups_2,
                                    size: 30,
                                  )),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 28,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.6,
                                  child: chatlist[index]
                                          .userName
                                          .toString()
                                          .isEmpty
                                      ? Text(
                                          capitalizeFirstLetter(
                                              '${chatlist[index].groupName}'),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        )
                                      : Text(
                                          capitalizeFirstLetter(
                                              chatlist[index].userName!),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      isSelectedusername.contains(chatlist[index].userName) ||
                              isSelectedusername
                                  .contains(chatlist[index].groupName)
                          ? Container(
                              width: 15.0,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: bg1,
                                  gradient: LinearGradient(
                                      colors: [blackColor, black1Color],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomCenter)),
                              child: Image.asset("assets/images/right.png")
                                  .paddingAll(3))
                          : Container(
                              width: 15.0,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: black1Color),
                                  color: bg1),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 35,
              width: 85,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xffF4F5F6)),
              child: Center(
                child: Text(
                  languageController.textTranslate('Cancel'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 70,
          ),
          const Text(
            'Send to',
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget chatWidget(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT CHATS',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String convertUTCTimeTo12HourFormat(String utcTimeString) {
    DateTime utcDate = DateTime.parse(utcTimeString);
    String formattedTime = DateFormat('h:mm a').format(utcDate.toLocal());
    return formattedTime;
  }
}
