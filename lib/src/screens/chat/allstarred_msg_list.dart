// ignore_for_file: avoid_print, must_be_immutable, prefer_is_empty, deprecated_member_use
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
import 'package:whoxachat/Models/add_star_model.dart';
import 'package:whoxachat/Models/all_starred_msg_list.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/controller/audio_controller.dart';
import 'package:whoxachat/controller/reply_msg_controller.dart';
import 'package:whoxachat/controller/single_chat_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/pdf.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/Onlichat/ChatOnline.dart';
import 'package:whoxachat/src/screens/chat/FileView.dart';
import 'package:whoxachat/src/screens/chat/chatvideo.dart';
import 'package:whoxachat/src/screens/chat/group_chat_temp.dart';
import 'package:whoxachat/src/screens/chat/imageView.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:whoxachat/src/screens/save_contact.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;

final ApiHelper apiHelper = ApiHelper();

class AllStarredMsgList extends StatefulWidget {
  int? index;
  String? conversationid;
  bool? isPersonal;
  AllStarredMsgList(
      {super.key, this.index, this.conversationid, this.isPersonal});

  @override
  State<AllStarredMsgList> createState() => _AllStarredMsgListState();
}

class _AllStarredMsgListState extends State<AllStarredMsgList> {
  AllStaredMsgController allStaredMsgController = Get.find();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioController audioController = Get.put(AudioController());
  ChatListController chatListController = Get.find();
  ReplyMsgController replyMsgController = Get.put(ReplyMsgController());
  SingleChatContorller singleChatContorller = Get.put(SingleChatContorller());

  @override
  void initState() {
    super.initState();
    listScrollController = AutoScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.conversationid != null && widget.conversationid!.isNotEmpty) {
        allStaredMsgController.getAllStarMsg(widget.conversationid);
      }
      chatListController.forChatList();
      initlizedcontroller();
    });
  }

  @override
  void dispose() {
    listScrollController?.dispose();
    super.dispose();
  }

  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int? gotoindex;
  AutoScrollController? listScrollController;
  List<List<int>>? randomList;

  _scrollToIndex(index, {Function? callback}) async {
    await listScrollController?.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
    if (callback != null) {
      callback();
    }
  }

  initlizedcontroller() async {
    listScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    listScrollController?.addListener(hideKeyboard);
    if (widget.index != null && widget.index != 0) {
      await listScrollController?.scrollToIndex(widget.index!,
          preferPosition: AutoScrollPosition.begin);
    }
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  List chatID = [];
  String isSelectedmessage = "0";
  String localmsgid = "";
  List starId = [];

  String isIdMatch(String id) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (id ==
          chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString()) {
        return chatListController.userChatListModel.value!.chatList![i].userName
            .toString();
      }
    }
    return "";
  }

  String isPicMatch(String id) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (id ==
          chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString()) {
        return chatListController
            .userChatListModel.value!.chatList![i].profileImage
            .toString();
      }
    }
    return "";
  }

  bool isBlockMatch(String id) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (id ==
          chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString()) {
        return chatListController
            .userChatListModel.value!.chatList![i].isBlock!;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300)),
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 50,
          titleSpacing: -10,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios, size: 20, color: chatColor),
          ),
          title: Text(
            languageController.textTranslate('Starred Messages'),
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 19, color: chatColor),
          ),
          actions: [
            allStaredMsgController.allStarred.length > 0
                ? containerWidget(
                    onTap: () {
                      setState(() {
                        isSelectedmessage = "1";
                        starId.add(0);
                        print("STARID:$starId");
                      });
                    },
                    title: languageController.textTranslate('Edit'))
                : SizedBox().paddingOnly(right: 10)
          ],
        ),
        bottomNavigationBar: starId.isEmpty
            ? null
            : BottomAppBar(
                height: 70,
                elevation: 0,
                color: Colors.white,
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (starId.length == 1 && starId.contains(0)) {
                            showCustomToast("Please starred message");
                          } else {
                            setState(() {
                              singleChatContorller
                                  .removeStarApiMultiple(starId);

                              for (var id in starId) {
                                allStaredMsgController.allStarred.removeWhere(
                                    (item) =>
                                        item.messageId.toString() ==
                                        id.toString());
                              }
                              allStaredMsgController.allStarred.refresh();

                              isSelectedmessage = "0";
                              starId = [];
                            });
                          }
                        },
                        child: Image.asset("assets/images/star-slash.png",
                            height: 25))
                  ],
                ),
              ),
        body: Obx(() {
          return allStaredMsgController.isLoading.value &&
                  allStaredMsgController.allStarred.isEmpty
              ? loader(context)
              : Column(
                  children: [
                    Flexible(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: allStaredMsgController.allStarred.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        commonImageTexts(
                                          image:
                                              "assets/images/empty_stared_list.png",
                                          text1:
                                              languageController.textTranslate(
                                                  'No Starred Messages'),
                                          text2: languageController.textTranslate(
                                              'Tap and hold on any message to star it, so you can easily find it later.'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView(children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    controller: listScrollController,
                                    itemCount: allStaredMsgController
                                        .allStarred.length,
                                    itemBuilder: (context, index) {
                                      for (int i = 0;
                                          i <
                                              allStaredMsgController
                                                  .allStarred.length;
                                          i++) {
                                        if (isScroll == true) {
                                          gotoindex = i;
                                          _scrollToIndex(gotoindex);
                                          isScroll = false;
                                        }
                                      }

                                      return AutoScrollTag(
                                          key: ValueKey(index),
                                          controller: listScrollController!,
                                          index: index,
                                          child: buildItem(
                                              index,
                                              allStaredMsgController
                                                  .allStarred[index]));
                                    },
                                  ),
                                ]),
                        ),
                      ),
                    )
                  ],
                );
        }));
  }

  Widget buildItem(int index, StarMessageList data) {
    switch (data.chat!.messageType) {
      case 'text':
        return data.chat!.replyId == 0
            ? getTextMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'image':
        return data.chat!.replyId == 0
            ? getImgMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'location':
        return data.chat!.replyId == 0
            ? getLocationMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'video':
        return data.chat!.replyId == 0
            ? getVideoMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'document':
        return data.chat!.replyId == 0
            ? getDocMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'audio':
        return data.chat!.replyId == 0
            ? getVoiceMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'gif':
        return data.chat!.replyId == 0
            ? getGifMessage(index, data)
            : getReplyMessage(index, data);
      case 'link':
        return data.chat!.replyId == 0
            ? getHttpLinkMessage(index, data)
            : getReplyMessage(index, data);
      case 'contact':
        return data.chat!.replyId == 0
            ? getContactMessage(index, data)
            : getReplyMessage(index, data);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget getTextMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myText(index, data)
              : otherText(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherText(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: data.chat!.user!.userId ==
                                  Hive.box(userdata).get(userId)
                              ? secondaryColor
                              : grey1Color,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 20.0,
                                minWidth: 10.0,
                                maxWidth: 230,
                              ),
                              child: Text(
                                data.chat!.message.toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ).paddingSymmetric(horizontal: 5, vertical: 5),
                            ),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 3,
                              right: 3,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myText(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: data.chat!.user!.userId ==
                                  Hive.box(userdata).get(userId)
                              ? secondaryColor
                              : grey1Color,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 20.0,
                                minWidth: 10.0,
                                maxWidth: 230,
                              ),
                              child: Text(
                                data.chat!.message.toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ).paddingSymmetric(horizontal: 5, vertical: 5),
                            ),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 3,
                              right: 3,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getImgMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myImage(index, data)
              : otherImage(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherImage(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                                curve: Curves.linear,
                                type: PageTransitionType.rightToLeft,
                                child: ImageView(
                                  image: data.chat!.url!,
                                  userimg: "",
                                )),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? secondaryColor
                                : Colors.grey.shade200,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    data.chat!.url!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myImage(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                                curve: Curves.linear,
                                type: PageTransitionType.rightToLeft,
                                child: ImageView(
                                  image: data.chat!.url!,
                                  userimg: "",
                                )),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? secondaryColor
                                : Colors.grey.shade200,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    data.chat!.url!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getLocationMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myLocation(index, data)
              : otherLocation(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherLocation(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: grey1Color),
                    constraints: const BoxConstraints(
                        minHeight: 10.0, minWidth: 10.0, maxWidth: 250),
                    child: Column(
                      children: [
                        Container(
                          height: 130,
                          width: 250,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: data.chat!.latitude.toString() == "" ||
                                      data.chat!.longitude.toString() == ""
                                  ? Container(
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/map_Blurr.png"),
                                              fit: BoxFit.cover)),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: chatownColor.withOpacity(0.6),
                                        size: 50,
                                      ),
                                    )
                                  : FutureBuilder<Uint8List>(
                                      future: getBytesFromAsset(
                                        'assets/images/location_for_google.png',
                                        70,
                                        70,
                                      ),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<Uint8List> snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18)),
                                            height: 100,
                                            child: Stack(
                                              children: [
                                                GoogleMap(
                                                  zoomControlsEnabled: false,
                                                  onTap: (argument) {
                                                    MapUtils.openMap(
                                                        double.parse(data
                                                            .chat!.latitude!),
                                                        double.parse(data
                                                            .chat!.longitude!));
                                                  },
                                                  mapType: MapType.normal,
                                                  compassEnabled: false,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                          target: LatLng(
                                                              double.parse(data
                                                                  .chat!
                                                                  .latitude!),
                                                              double.parse(data
                                                                  .chat!
                                                                  .longitude!)),
                                                          zoom: 15),
                                                  markers: {
                                                    Marker(
                                                      icon: BitmapDescriptor
                                                          .fromBytes(
                                                              snapshot.data!),
                                                      markerId: const MarkerId(
                                                          'my_location'),
                                                      position: LatLng(
                                                          double.parse(data
                                                              .chat!.latitude!),
                                                          double.parse(data
                                                              .chat!
                                                              .longitude!)),
                                                    ),
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const Center(
                                              child:
                                                  CupertinoActivityIndicator());
                                        }
                                      },
                                    )),
                        ).paddingOnly(
                          left: 4,
                          top: 4,
                          right: 4,
                        ),
                        InkWell(
                          onTap: () {
                            MapUtils.openMap(double.parse(data.chat!.latitude!),
                                double.parse(data.chat!.longitude!));
                          },
                          child: Container(
                            width: Get.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(7)),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xffDDDDDD),
                                  Color(0xffCDCDCD),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  "View Location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: appColorWhite),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myLocation(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: secondaryColor),
                    constraints: const BoxConstraints(
                        minHeight: 10.0, minWidth: 10.0, maxWidth: 250),
                    child: Column(
                      children: [
                        Container(
                          height: 130,
                          width: 250,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: data.chat!.latitude == "" ||
                                      data.chat!.longitude.toString() == ""
                                  ? Container(
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/map_Blurr.png"),
                                              fit: BoxFit.cover)),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: chatownColor.withOpacity(0.6),
                                        size: 50,
                                      ),
                                    )
                                  : FutureBuilder<Uint8List>(
                                      future: getBytesFromAsset(
                                        'assets/images/location_for_google.png',
                                        70,
                                        70,
                                      ),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<Uint8List> snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18)),
                                            height: 100,
                                            child: Stack(
                                              children: [
                                                GoogleMap(
                                                  zoomControlsEnabled: false,
                                                  onTap: (argument) {
                                                    MapUtils.openMap(
                                                        double.parse(data
                                                            .chat!.latitude!),
                                                        double.parse(data
                                                            .chat!.longitude!));
                                                  },
                                                  mapType: MapType.normal,
                                                  compassEnabled: false,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                          target: LatLng(
                                                              double.parse(data
                                                                  .chat!
                                                                  .latitude!),
                                                              double.parse(data
                                                                  .chat!
                                                                  .longitude!)),
                                                          zoom: 15),
                                                  markers: {
                                                    Marker(
                                                      icon: BitmapDescriptor
                                                          .fromBytes(
                                                              snapshot.data!),
                                                      markerId: const MarkerId(
                                                          'my_location'),
                                                      position: LatLng(
                                                          double.parse(data
                                                              .chat!.latitude!),
                                                          double.parse(data
                                                              .chat!
                                                              .longitude!)),
                                                    ),
                                                  },
                                                ),
                                                data.chat!.user!.userId !=
                                                        Hive.box(userdata)
                                                            .get(userId)
                                                    ? const SizedBox.shrink()
                                                    : const Positioned(
                                                        bottom: 3,
                                                        right: 3,
                                                        child: Icon(
                                                          Icons
                                                              .star_rate_rounded,
                                                          color:
                                                              Color(0xFFFFC700),
                                                          size: 15,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const Center(
                                              child:
                                                  CupertinoActivityIndicator());
                                        }
                                      },
                                    )),
                        ).paddingOnly(
                          left: 4,
                          top: 4,
                          right: 4,
                        ),
                        InkWell(
                          onTap: () {
                            MapUtils.openMap(double.parse(data.chat!.latitude!),
                                double.parse(data.chat!.longitude!));
                          },
                          child: Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  secondaryColor,
                                  chatownColor,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  "View Location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: appColorWhite),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Future<Uint8List> getBytesFromAsset(
      String path, int width, int height) async {
    final byteData = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    return (await frame.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Widget getVideoMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myVideo(index, data)
              : otherVideo(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherVideo(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: data.chat!.user!.userId ==
                                        Hive.box(userdata).get(userId)
                                    ? secondaryColor
                                    : grey1Color,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        data.chat!.thumbnail!,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoViewFix(
                                          username: "",
                                          url: data.chat!.url!,
                                          play: true,
                                          mute: false,
                                          date: ""),
                                    ));
                              },
                              child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      const Color(0xff000000).withOpacity(0.56),
                                  foregroundColor: chatownColor,
                                  child: Image.asset("assets/images/play2.png",
                                      height: 12)),
                            )
                          ],
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myVideo(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: data.chat!.user!.userId ==
                                        Hive.box(userdata).get(userId)
                                    ? secondaryColor
                                    : grey1Color,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        data.chat!.thumbnail!,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoViewFix(
                                          username: "",
                                          url: data.chat!.url!,
                                          play: true,
                                          mute: false,
                                          date: ""),
                                    ));
                              },
                              child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      const Color(0xff000000).withOpacity(0.56),
                                  foregroundColor: chatownColor,
                                  child: Image.asset("assets/images/play2.png",
                                      height: 12)),
                            )
                          ],
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getDocMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myDocument(index, data)
              : otherDocument(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherDocument(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 3, right: 3, top: 0, bottom: 0),
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: data.chat!.user!.userId !=
                                Hive.box(userdata).get(userId)
                            ? grey1Color
                            : secondaryColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 240,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        curve: Curves.linear,
                                        type: PageTransitionType.rightToLeft,
                                        child: FileView(
                                          file: "${data.chat!.url}",
                                        ),
                                      ));
                                },
                                child: SizedBox(
                                  width: Get.width * 0.50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: const Radius.circular(8.0),
                                      bottomRight: data.chat!.user!.userId !=
                                              Hive.box(userdata).get(userId)
                                          ? const Radius.circular(8)
                                          : const Radius.circular(0.0),
                                      topLeft: const Radius.circular(8.0),
                                      bottomLeft: data.chat!.user!.userId !=
                                              Hive.box(userdata).get(userId)
                                          ? const Radius.circular(0)
                                          : const Radius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          const Image(
                                            height: 30,
                                            image: AssetImage(
                                                'assets/images/pdf.png'),
                                          ),
                                          FutureBuilder<Map<String, dynamic>>(
                                            future: getPdfInfo(data.chat!.url!),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      extractFilename(
                                                              data.chat!.url!)
                                                          .toString()
                                                          .split("-")
                                                          .last,
                                                      style: const TextStyle(
                                                        color: chatColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      languageController
                                                          .textTranslate(
                                                              '0 Page - 0 KB'),
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    )
                                                  ],
                                                ).paddingOnly(left: 12);
                                              } else if (snapshot.hasError) {
                                                return const Text('');
                                              } else if (snapshot.hasData) {
                                                final int pageCount =
                                                    snapshot.data!['pageCount'];
                                                final String fileSize =
                                                    snapshot.data!['fileSize'];
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 11),
                                                      child: Text(
                                                        extractFilename(
                                                                data.chat!.url!)
                                                            .toString()
                                                            .split("-")
                                                            .last,
                                                        style: const TextStyle(
                                                          color: chatColor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '$pageCount Page - $fileSize',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ).paddingOnly(left: 12),
                                                  ],
                                                );
                                              } else {
                                                return Text(languageController
                                                    .textTranslate(
                                                        'No PDF info available'));
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).paddingOnly(top: 3, bottom: 3),
                        SizedBox(
                          height: 16,
                          child: data.chat!.user!.userId !=
                                  Hive.box(userdata).get(userId)
                              ? const SizedBox.shrink()
                              : const Positioned(
                                  bottom: 3,
                                  right: 3,
                                  child: Icon(
                                    Icons.star_rate_rounded,
                                    color: Color(0xFFFFC700),
                                    size: 15,
                                  ),
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myDocument(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 3, right: 3, top: 0, bottom: 0),
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: data.chat!.user!.userId !=
                                Hive.box(userdata).get(userId)
                            ? grey1Color
                            : secondaryColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 240,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        curve: Curves.linear,
                                        type: PageTransitionType.rightToLeft,
                                        child: FileView(
                                          file: "${data.chat!.url}",
                                        ),
                                      ));
                                },
                                child: SizedBox(
                                  width: Get.width * 0.50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: const Radius.circular(8.0),
                                      bottomRight: data.chat!.user!.userId !=
                                              Hive.box(userdata).get(userId)
                                          ? const Radius.circular(8)
                                          : const Radius.circular(0.0),
                                      topLeft: const Radius.circular(8.0),
                                      bottomLeft: data.chat!.user!.userId !=
                                              Hive.box(userdata).get(userId)
                                          ? const Radius.circular(0)
                                          : const Radius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          const Image(
                                            height: 30,
                                            image: AssetImage(
                                                'assets/images/pdf.png'),
                                          ),
                                          FutureBuilder<Map<String, dynamic>>(
                                            future: getPdfInfo(data.chat!.url!),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      extractFilename(
                                                              data.chat!.url!)
                                                          .toString()
                                                          .split("-")
                                                          .last,
                                                      style: const TextStyle(
                                                        color: chatColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      languageController
                                                          .textTranslate(
                                                              '0 Page - 0 KB'),
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    )
                                                  ],
                                                ).paddingOnly(left: 12);
                                              } else if (snapshot.hasError) {
                                                return const Text('');
                                              } else if (snapshot.hasData) {
                                                final int pageCount =
                                                    snapshot.data!['pageCount'];
                                                final String fileSize =
                                                    snapshot.data!['fileSize'];
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 11),
                                                      child: Text(
                                                        extractFilename(
                                                                data.chat!.url!)
                                                            .toString()
                                                            .split("-")
                                                            .last,
                                                        style: const TextStyle(
                                                          color: chatColor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '$pageCount Page - $fileSize',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ).paddingOnly(left: 12),
                                                  ],
                                                );
                                              } else {
                                                return Text(languageController
                                                    .textTranslate(
                                                        'No PDF info available'));
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).paddingOnly(top: 3, bottom: 3),
                        SizedBox(
                          height: 16,
                          child: data.chat!.user!.userId !=
                                  Hive.box(userdata).get(userId)
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.star_rate_rounded,
                                  color: Color(0xFFFFC700),
                                  size: 15,
                                ).paddingOnly(bottom: 4, right: 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getVoiceMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myVoice(index, data)
              : otherVoice(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherVoice(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: _audio(
                      message: data.chat!.url!,
                      index: index,
                      duration: data.chat!.audioTime!,
                      data: data),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myVoice(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: _audio(
                      message: data.chat!.url!,
                      index: index,
                      duration: data.chat!.audioTime!,
                      data: data),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getGifMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myGif(index, data)
              : otherGif(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherGif(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                                curve: Curves.linear,
                                type: PageTransitionType.rightToLeft,
                                child: ImageView(
                                  image: data.chat!.url!,
                                  userimg: "",
                                )),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? secondaryColor
                                : grey1Color,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    data.chat!.url!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 6,
                              right: 6,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myGif(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                                curve: Curves.linear,
                                type: PageTransitionType.rightToLeft,
                                child: ImageView(
                                  image: data.chat!.url!,
                                  userimg: "",
                                )),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? secondaryColor
                                : grey1Color,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    data.chat!.url!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 6,
                              right: 6,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getHttpLinkMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myLink(index, data)
              : otherLink(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherLink(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: data.chat!.user!.userId ==
                                  Hive.box(userdata).get(userId)
                              ? secondaryColor
                              : grey1Color,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 3, left: 3, right: 3),
                          child: Container(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 8.3,
                                maxWidth:
                                    MediaQuery.of(context).size.width * .7),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              onTap: () {
                                launchURL(data.chat!.message!);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: FlutterLinkPreview(
                                      url: data.chat!.message!,
                                      builder: (info) {
                                        if (info is WebInfo) {
                                          return info.title == null &&
                                                  info.description == null
                                              ? Text(
                                                  data.chat!.message!,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (info.image != null)
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                              info.image!,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (info.title !=
                                                              null)
                                                            Text(
                                                              info.title!,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ).paddingAll(2),
                                                          info.image == null
                                                              ? const SizedBox(
                                                                  height: 5)
                                                              : const SizedBox
                                                                  .shrink(),
                                                          if (info.description !=
                                                              null)
                                                            Text(
                                                              info.description!,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          68,
                                                                          68,
                                                                          68,
                                                                          1),
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                        }
                                        return const CircularProgressIndicator();
                                      },
                                      titleStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    data.chat!.message!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: linkColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ).paddingOnly(left: 10)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 3,
                              right: 3,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myLink(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: data.chat!.user!.userId ==
                                  Hive.box(userdata).get(userId)
                              ? secondaryColor
                              : grey1Color,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 3, left: 3, right: 3),
                          child: Container(
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 8.3,
                                maxWidth:
                                    MediaQuery.of(context).size.width * .7),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              onTap: () {
                                launchURL(data.chat!.message!);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: FlutterLinkPreview(
                                      url: data.chat!.message!,
                                      builder: (info) {
                                        if (info is WebInfo) {
                                          return info.title == null &&
                                                  info.description == null
                                              ? Text(
                                                  data.chat!.message!,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (info.image != null)
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                              info.image!,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (info.title !=
                                                              null)
                                                            Text(
                                                              info.title!,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ).paddingAll(2),
                                                          info.image == null
                                                              ? const SizedBox(
                                                                  height: 5)
                                                              : const SizedBox
                                                                  .shrink(),
                                                          if (info.description !=
                                                              null)
                                                            Text(
                                                              info.description!,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          68,
                                                                          68,
                                                                          68,
                                                                          1),
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                        }
                                        return const CircularProgressIndicator();
                                      },
                                      titleStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    data.chat!.message!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: linkColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ).paddingOnly(left: 10)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      data.chat!.user!.userId != Hive.box(userdata).get(userId)
                          ? const SizedBox.shrink()
                          : const Positioned(
                              bottom: 3,
                              right: 3,
                              child: Icon(
                                Icons.star_rate_rounded,
                                color: Color(0xFFFFC700),
                                size: 15,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget getContactMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Padding(
          padding: EdgeInsets.only(
              top: 5, bottom: 5, left: starId.isNotEmpty ? 34 : 28, right: 28),
          child: data.chat!.user!.userId == Hive.box(userdata).get(userId)
              ? myContact(index, data)
              : otherContact(index, data),
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget otherContact(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.arrow_right_rounded, size: 30),
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
              ],
            ),
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: data.chat!.user!.userId !=
                                Hive.box(userdata).get(userId)
                            ? grey1Color
                            : secondaryColor),
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                              borderRadius:
                                  matchContact(data.chat!.sharedContactNumber!)
                                      ? BorderRadius.circular(10)
                                      : const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                              color: Colors.white),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(35)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: CustomCachedNetworkImage(
                                          imageUrl: data
                                              .chat!.sharedContactProfileImage!,
                                          placeholderColor: chatownColor,
                                          errorWidgeticon: const Icon(
                                            Icons.person,
                                            size: 30,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: Get.width * 0.30,
                                        child: Text(
                                          capitalizeFirstLetter(
                                              data.chat!.sharedContactName!),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: chatColor),
                                        ),
                                      ),
                                      Text(
                                        data.chat!.sharedContactNumber!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: chatColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              data.chat!.user!.userId !=
                                      Hive.box(userdata).get(userId)
                                  ? const SizedBox.shrink()
                                  : const Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: Icon(
                                        Icons.star_rate_rounded,
                                        color: Color(0xFFFFC700),
                                        size: 15,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        InkWell(
                          onTap: () {
                            Get.to(() => SaveContact(
                                name: data.chat!.sharedContactName!,
                                number: data.chat!.sharedContactNumber!));
                          },
                          child: Container(
                            height: 30,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(7)),
                              gradient: LinearGradient(
                                colors: data.chat!.user!.userId ==
                                        Hive.box(userdata).get(userId)
                                    ? [
                                        secondaryColor,
                                        chatownColor,
                                      ]
                                    : [
                                        const Color(0xffDDDDDD),
                                        const Color(0xffCDCDCD),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  languageController
                                      .textTranslate('View contact'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: appColorWhite),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget myContact(index, StarMessageList data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date(convertToLocalDate(data.updatedAt!)),
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500),
            ),
            Row(
              children: [
                data.chat!.conversation!.isGroup == false
                    ? Text(
                        data.otherUserDetails![0].userId ==
                                data.chat!.user!.userId
                            ? languageController.textTranslate('You')
                            : data.otherUserDetails![0].firstName! +
                                data.otherUserDetails![0].lastName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      )
                    : Text(
                        data.chat!.conversation!.groupName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                data.chat!.conversation!.isGroup == false
                    ? const Icon(Icons.arrow_left_outlined, size: 30)
                    : const Icon(Icons.arrow_left_outlined, size: 30),
                Text(
                  data.chat!.user!.userId == Hive.box(userdata).get(userId)
                      ? languageController.textTranslate('You')
                      : data.chat!.user!.firstName! +
                          data.chat!.user!.lastName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(28)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: data.chat!.user!.profileImage!,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: chatownColor,
                      )),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isSelectedmessage == "1"
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            starId.contains(data.chat!.messageId)
                                ? starId.remove(data.chat!.messageId)
                                : starId.add(data.chat!.messageId);
                          });
                          print("STARID:$starId");
                        },
                        child: starId.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: starId.contains(
                                        data.chat!.messageId.toString())
                                    ? checkContainer()
                                    : removeCheckContainer(),
                              ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  width: isSelectedmessage == "1" ? 10 : 0,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: data.chat!.user!.userId !=
                                Hive.box(userdata).get(userId)
                            ? grey1Color
                            : secondaryColor),
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                              borderRadius:
                                  matchContact(data.chat!.sharedContactNumber!)
                                      ? BorderRadius.circular(10)
                                      : const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                              color: Colors.white),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(35)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: CustomCachedNetworkImage(
                                          imageUrl: data
                                              .chat!.sharedContactProfileImage!,
                                          placeholderColor: chatownColor,
                                          errorWidgeticon: const Icon(
                                            Icons.person,
                                            size: 30,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: Get.width * 0.30,
                                        child: Text(
                                          capitalizeFirstLetter(
                                              data.chat!.sharedContactName!),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: chatColor),
                                        ),
                                      ),
                                      Text(
                                        data.chat!.sharedContactNumber!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: chatColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              data.chat!.user!.userId !=
                                      Hive.box(userdata).get(userId)
                                  ? const SizedBox.shrink()
                                  : const Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: Icon(
                                        Icons.star_rate_rounded,
                                        color: Color(0xFFFFC700),
                                        size: 15,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        InkWell(
                          onTap: () {
                            Get.to(() => SaveContact(
                                name: data.chat!.sharedContactName!,
                                number: data.chat!.sharedContactNumber!));
                          },
                          child: Container(
                            height: 30,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(7)),
                              gradient: LinearGradient(
                                colors: data.chat!.user!.userId ==
                                        Hive.box(userdata).get(userId)
                                    ? [
                                        secondaryColor,
                                        chatownColor,
                                      ]
                                    : [
                                        const Color(0xffDDDDDD),
                                        const Color(0xffCDCDCD),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  languageController
                                      .textTranslate('View contact'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: appColorWhite),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSelectedmessage == "1" ? 20 : 0,
                ),
                Text(
                  convertUTCTimeTo12HourFormat(data.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  bool matchContact(String num) {
    for (var i = 0; i < getAllDeviceContact.getList.length; i++) {
      if (num == getAllDeviceContact.getList[i].phoneNumber) {
        return true;
      }
    }
    return false;
  }

  Widget getReplyMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (chatID.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId)
                ? chatID.remove(data.messageId)
                : chatID.add(data.messageId);
          });
        }
        print("ONTAPMSGID:$chatID");
      },
      child: replyMSGWidget(index, data),
    );
  }

//============================================================= REPLY MESSAGE DESIGN =======================================================================
//=============================================================                      =======================================================================

  Widget replyMSGWidget(int index, StarMessageList data) {
    String isMatching(String msgID) {
      if (data.resData!.messageType == "text") {
        return data.resData!.message!;
      } else if (data.resData!.messageType == "image") {
        return "📷 ${languageController.textTranslate('Photo')}";
      } else if (data.resData!.messageType == "location") {
        return "📌 ${languageController.textTranslate('Location')}";
      } else if (data.resData!.messageType == "document") {
        return "📄 ${languageController.textTranslate('Document')}";
      } else if (data.resData!.messageType == "video") {
        return "🎥 ${languageController.textTranslate('Video')}";
      } else if (data.resData!.messageType == "audio") {
        return "🔊 ${languageController.textTranslate('Audio')}";
      } else if (data.resData!.messageType == "link") {
        return data.resData!.message!;
      } else if (data.resData!.messageType == "gif") {
        return languageController.textTranslate('GIF');
      } else if (data.resData!.messageType == "contact") {
        return languageController.textTranslate('Contact');
      }
      return "message removed";
    }

    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: data.chat!.messageType == "text"
                        ? 85
                        : data.chat!.messageType == "document"
                            ? 90
                            : data.chat!.messageType == "image"
                                ? 130
                                : data.chat!.messageType == "video"
                                    ? 130
                                    : data.chat!.messageType == "location"
                                        ? 140
                                        : data.chat!.messageType == "audio"
                                            ? 90
                                            : data.chat!.messageType == "link"
                                                ? 120
                                                : data.chat!.messageType ==
                                                        "gif"
                                                    ? 120
                                                    : data.chat!.messageType ==
                                                            "contact"
                                                        ? 120
                                                        : 85,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? languageController.textTranslate('You')
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? languageController.textTranslate('You')
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth: data.chat!.messageType == "link"
                                      ? MediaQuery.of(context).size.width * .7
                                      : data.chat!.messageType == "audio"
                                          ? MediaQuery.of(context).size.width *
                                              0.7
                                          : data.chat!.messageType == "location"
                                              ? 250
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6),
                              padding: const EdgeInsets.only(
                                  left: 7, right: 7, top: 0, bottom: 0),
                              decoration: BoxDecoration(
                                  color: data.chat!.user!.userId ==
                                          Hive.box(userdata).get(userId)
                                      ? secondaryColor
                                      : Colors.grey.shade200,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, top: 10),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            top: 8,
                                            bottom: 8,
                                            right: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${data.resData!.senderData!.firstName} ${data.resData!.senderData!.lastName!}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              isMatching(data.resData!.messageId
                                                  .toString()),
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: data.chat!.messageType == "text"
                                        ? Text(data.chat!.message!)
                                        : data.chat!.messageType == "document"
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                        curve: Curves.linear,
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: FileView(
                                                            file:
                                                                "${data.chat!.url}"),
                                                      ));
                                                },
                                                child: SizedBox(
                                                  width: Get.width * 0.50,
                                                  child: Row(
                                                    children: [
                                                      const Image(
                                                        height: 30,
                                                        image: AssetImage(
                                                            'assets/images/pdf.png'),
                                                      ),
                                                      FutureBuilder<
                                                          Map<String, dynamic>>(
                                                        future: getPdfInfo(
                                                            data.chat!.url!),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  extractFilename(data
                                                                          .chat!
                                                                          .url!)
                                                                      .toString()
                                                                      .split(
                                                                          "-")
                                                                      .last,
                                                                  style:
                                                                      const TextStyle(
                                                                    color:
                                                                        chatColor,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  languageController
                                                                      .textTranslate(
                                                                          '0 Page - 0 KB'),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                )
                                                              ],
                                                            ).paddingOnly(
                                                                left: 12);
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return const Text(
                                                                '');
                                                          } else if (snapshot
                                                              .hasData) {
                                                            final int
                                                                pageCount =
                                                                snapshot.data![
                                                                    'pageCount'];
                                                            final String
                                                                fileSize =
                                                                snapshot.data![
                                                                    'fileSize'];
                                                            return Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              11),
                                                                  child: Text(
                                                                    extractFilename(data
                                                                            .chat!
                                                                            .url!)
                                                                        .toString()
                                                                        .split(
                                                                            "-")
                                                                        .last,
                                                                    style:
                                                                        const TextStyle(
                                                                      color:
                                                                          chatColor,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '$pageCount Page - $fileSize',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ).paddingOnly(
                                                                    left: 12),
                                                              ],
                                                            );
                                                          } else {
                                                            return Text(
                                                                languageController
                                                                    .textTranslate(
                                                                        'No PDF info available'));
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : data.chat!.messageType == "image"
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            curve:
                                                                Curves.linear,
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: ImageView(
                                                              image: data
                                                                  .chat!.url!,
                                                              userimg: "",
                                                            )),
                                                      );
                                                    },
                                                    child: Container(
                                                        height: 120,
                                                        width: double.maxFinite,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            data.chat!.url!,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )),
                                                  )
                                                : data.chat!.messageType ==
                                                        "video"
                                                    ? Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          SizedBox(
                                                            height: 120,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: data
                                                                    .chat!
                                                                    .thumbnail!,
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    const Center(
                                                                  child:
                                                                      CupertinoActivityIndicator(),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    const Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .error),
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => VideoViewFix(
                                                                        username:
                                                                            "",
                                                                        url: data
                                                                            .chat!
                                                                            .url!,
                                                                        play:
                                                                            true,
                                                                        mute:
                                                                            false,
                                                                        date:
                                                                            ""),
                                                                  ));
                                                            },
                                                            child: CircleAvatar(
                                                                radius: 18,
                                                                backgroundColor:
                                                                    Colors.grey
                                                                        .shade300,
                                                                foregroundColor:
                                                                    chatownColor,
                                                                child: Image.asset(
                                                                    "assets/images/play1.png",
                                                                    color:
                                                                        chatColor,
                                                                    height:
                                                                        15)),
                                                          )
                                                        ],
                                                      )
                                                    : data.chat!.messageType ==
                                                            "location"
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minHeight:
                                                                        10.0,
                                                                    minWidth:
                                                                        10.0,
                                                                    maxWidth:
                                                                        250),
                                                            child: InkWell(
                                                              onTap: () {
                                                                MapUtils.openMap(
                                                                    double.parse(data
                                                                        .chat!
                                                                        .latitude!),
                                                                    double.parse(data
                                                                        .chat!
                                                                        .longitude!));
                                                              },
                                                              child: Container(
                                                                height: 130,
                                                                width: 250,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: data.chat!.latitude.toString() ==
                                                                              "" ||
                                                                          data.chat!.longitude.toString() ==
                                                                              ""
                                                                      ? Container(
                                                                          decoration: const BoxDecoration(
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                              image: DecorationImage(image: AssetImage("assets/images/map_Blurr.png"), fit: BoxFit.cover)),
                                                                          child:
                                                                              Icon(
                                                                            Icons.error_outline,
                                                                            color:
                                                                                chatownColor.withOpacity(0.6),
                                                                            size:
                                                                                50,
                                                                          ),
                                                                        )
                                                                      : GoogleMap(
                                                                          zoomControlsEnabled:
                                                                              false,
                                                                          zoomGesturesEnabled:
                                                                              false,
                                                                          initialCameraPosition: CameraPosition(
                                                                              target: LatLng(double.parse(data.chat!.latitude!), double.parse(data.chat!.longitude!)),
                                                                              zoom: 15),
                                                                          mapType:
                                                                              MapType.normal,
                                                                          onMapCreated:
                                                                              (GoogleMapController controller111) {},
                                                                        ),
                                                                ),
                                                              ),
                                                            ))
                                                        : data.chat!.messageType ==
                                                                "audio"
                                                            ? _audioReply(
                                                                message: data
                                                                    .chat!.url!,
                                                                index: index,
                                                                duration: data
                                                                    .chat!
                                                                    .audioTime!)
                                                            : data.chat!.messageType ==
                                                                    "link"
                                                                ? Container(
                                                                    constraints: BoxConstraints(
                                                                        maxHeight:
                                                                            MediaQuery.of(context).size.height /
                                                                                9.3,
                                                                        maxWidth:
                                                                            MediaQuery.of(context).size.width *
                                                                                .7),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        launchURL(data
                                                                            .chat!
                                                                            .message!);
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 5,
                                                                                right: 5,
                                                                                top: 5,
                                                                                bottom: 5),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                FlutterLinkPreview(
                                                                              url: data.chat!.message!,
                                                                              builder: (info) {
                                                                                if (info is WebInfo) {
                                                                                  return info.title == null && info.description == null
                                                                                      ? Text(
                                                                                          data.chat!.message!,
                                                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                                                                        )
                                                                                      : Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            if (info.image != null)
                                                                                              Container(
                                                                                                height: 50,
                                                                                                width: 50,
                                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                                                child: ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  child: Image.network(info.image!, fit: BoxFit.cover),
                                                                                                ),
                                                                                              ),
                                                                                            const SizedBox(width: 5),
                                                                                            Expanded(
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  if (info.title != null)
                                                                                                    Text(
                                                                                                      info.title!,
                                                                                                      maxLines: 1,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: const TextStyle(
                                                                                                        fontSize: 14,
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                      ),
                                                                                                    ).paddingAll(2),
                                                                                                  info.image == null ? const SizedBox(height: 5) : const SizedBox.shrink(),
                                                                                                  if (info.description != null)
                                                                                                    Text(
                                                                                                      info.description!,
                                                                                                      maxLines: 2,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: const TextStyle(color: Color.fromRGBO(68, 68, 68, 1), fontSize: 9, fontWeight: FontWeight.w400),
                                                                                                    ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                }
                                                                                return const CircularProgressIndicator();
                                                                              },
                                                                              titleStyle: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Text(
                                                                            data.chat!.message!,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                color: linkColor,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w400),
                                                                          ).paddingOnly(
                                                                              left: 10)
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : data.chat!.messageType ==
                                                                        "gif"
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            PageTransition(
                                                                                curve: Curves.linear,
                                                                                type: PageTransitionType.rightToLeft,
                                                                                child: ImageView(
                                                                                  image: data.chat!.url!,
                                                                                  userimg: "",
                                                                                )),
                                                                          );
                                                                        },
                                                                        child: Container(
                                                                            height: 120,
                                                                            width: double.maxFinite,
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                            child: ClipRRect(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              child: Image.network(
                                                                                data.chat!.url!,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            )),
                                                                      )
                                                                    : data.chat!.messageType ==
                                                                            "contact"
                                                                        ? Column(
                                                                            children: [
                                                                              Container(
                                                                                height: 50,
                                                                                width: 200,
                                                                                decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
                                                                                child: Row(
                                                                                  children: [
                                                                                    const SizedBox(width: 20),
                                                                                    Container(
                                                                                      height: 30,
                                                                                      width: 30,
                                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(35)),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(35),
                                                                                        child: CustomCachedNetworkImage(
                                                                                            imageUrl: data.chat!.sharedContactProfileImage!,
                                                                                            placeholderColor: chatownColor,
                                                                                            errorWidgeticon: const Icon(
                                                                                              Icons.groups,
                                                                                              size: 30,
                                                                                            )),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          capitalizeFirstLetter(data.chat!.sharedContactName!),
                                                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                        ),
                                                                                        Text(
                                                                                          capitalizeFirstLetter(data.chat!.sharedContactNumber!),
                                                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 3),
                                                                              Container(
                                                                                height: 30,
                                                                                width: 200,
                                                                                decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)), color: Colors.white),
                                                                                child: Column(
                                                                                  children: [
                                                                                    const SizedBox(height: 3),
                                                                                    Text(
                                                                                      languageController.textTranslate('Message'),
                                                                                      textAlign: TextAlign.center,
                                                                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: chatColor),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )
                                                                        : const SizedBox(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget myVoiceWidget(String audiourl, int index, String audioduration,
      messageSeen, timestamp, isStarted, StarMessageList data) {
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
      child: Column(
        children: [
          Column(
            children: [
              _audio(
                  message: audiourl,
                  index: index,
                  duration: audioduration.toString(),
                  data: data),
              Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: SizedBox(
                    child: timestpa(messageSeen!, timestamp!, isStarted!),
                  ))
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _audio(
      {required String message,
      required int index,
      required String duration,
      required StarMessageList data}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: data.chat!.user!.userId == Hive.box(userdata).get(userId)
            ? secondaryColor
            : grey1Color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Row(
              children: [
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      audioController.onPressedPlayButton(index, message);
                    });
                  },
                  onSecondaryTap: () {
                    audioPlayer.stop();
                  },
                  child: Obx(
                    () => (audioController.isRecordPlaying &&
                            audioController.currentId == index)
                        ? Icon(
                            CupertinoIcons.pause_circle_fill,
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? secondaryColor
                                : grey1Color,
                          )
                        : Icon(
                            CupertinoIcons.play_circle_fill,
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? secondaryColor
                                : grey1Color,
                          ),
                  ),
                ),
                const SizedBox(width: 5),
                Obx(
                  () => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            minHeight: 5,
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.black),
                            value: (audioController.isRecordPlaying &&
                                    audioController.currentId == index)
                                ? (audioController.totalDuration.value > 0
                                    ? audioController.completedPercentage.value
                                    : 0.0)
                                : 0.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  duration,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey),
                ),
                const SizedBox(width: 10)
              ],
            ),
          ),
          SizedBox(
            height: 16,
            child: data.chat!.user!.userId != Hive.box(userdata).get(userId)
                ? const SizedBox.shrink()
                : const Icon(
                    Icons.star_rate_rounded,
                    color: Color(0xFFFFC700),
                    size: 15,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _audioReply({
    required String message,
    required int index,
    required String duration,
  }) {
    return Row(
      children: [
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            setState(() {
              audioController.onPressedPlayButton(index, message);
            });
          },
          onSecondaryTap: () {
            audioPlayer.stop();
          },
          child: Obx(
            () => (audioController.isRecordPlaying &&
                    audioController.currentId == index)
                ? const Icon(
                    CupertinoIcons.pause_circle_fill,
                    color: appColorBlack,
                  )
                : const Icon(
                    CupertinoIcons.play_circle_fill,
                    color: appColorBlack,
                  ),
          ),
        ),
        const SizedBox(width: 5),
        Obx(
          () => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Colors.grey,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.black),
                    value: (audioController.isRecordPlaying &&
                            audioController.currentId == index)
                        ? (audioController.totalDuration.value > 0
                            ? audioController.completedPercentage.value
                            : 0.0)
                        : 0.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          duration,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
        const SizedBox(width: 10)
      ],
    ).paddingOnly(top: 5);
  }

  bool isStar = false;
  AddStarMsgModel starModel = AddStarMsgModel();
  removeStarApi(iD, StarMessageList data) async {
    setState(() {
      isStar = true;
    });
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['message_id'] = iD.toString();
      request.fields['remove_from_star'] = true.toString();
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel = AddStarMsgModel.fromJson(useData);

      if (starModel.success == true) {
        allStaredMsgController.allStarred.remove(data);
        setState(() {
          isStar = false;
        });
        showCustomToast(starModel.message!);
      } else {
        setState(() {
          isStar = false;
        });
      }
    } catch (e) {
      print(e.toString());
      showCustomToast(e.toString());
      setState(() {
        isStar = false;
      });
    } finally {
      setState(() {
        isStar = false;
      });
    }
  }
}
