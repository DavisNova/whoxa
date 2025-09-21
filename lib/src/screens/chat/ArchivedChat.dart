// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, prefer_if_null_operators, prefer_is_empty, unused_field, avoid_function_literals_in_foreach_calls, unused_local_variable, file_names
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/online_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/common_widget.dart';
import 'package:whoxachat/model/userchatlist_model/archive_list_model.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/screens/chat/group_chat_temp.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class ArchiveChat extends StatefulWidget {
  const ArchiveChat({super.key});

  @override
  State<ArchiveChat> createState() => _ArchiveChatState();
}

class _ArchiveChatState extends State<ArchiveChat> with WidgetsBindingObserver {
  ChatListController chatListController = Get.put(ChatListController());
  TextEditingController controller = TextEditingController();
  OnlineOfflineController onlieController = Get.find();

  Future<void> requestPermissions() async {
    await Permission.notification.request();

    // await Permission.location.request();

    await Permission.camera.request();

    await Permission.microphone.request();

    await Permission.storage.request();

    await Permission.photos.request();

    await Permission.contacts.request();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatListController.forArchiveChatList();
    });
  }

  bool? isonline;

  Widget isUserOnline(String userID) {
    for (var i = 0; i < onlieController.allOffline.length; i++) {
      if (userID == onlieController.allOffline[i].userId.toString()) {
        return const SizedBox.shrink();
      }
    }
    return const SizedBox.shrink();
  }

  String isUserTyping(String cID) {
    for (var i = 0; i < onlieController.typingList.length; i++) {
      if (cID == onlieController.typingList[i].conversationId.toString()) {
        return "Typing...";
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            scrolledUnderElevation: 0,
            backgroundColor: appColorWhite,
            elevation: 0,
            titleSpacing: 0,
            leadingWidth: 50,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black)),
            title: Text(
              languageController.textTranslate('Archive list'),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.black),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 10),
              searchBar(),
              Expanded(child: chatListScreen1())
            ],
          ),
        ));
  }

//_________________________________________________________________________________________________________________________________________________________
  // Widget chatListScreen1() {
  //   // print(
  //   //     "LENGTH:${chatListController.userArchiveListModel.value!.archiveList!.length}");
  //   return Obx(() {
  //     return chatListController
  //                 .userArchiveListModel.value!.archiveList!.length >
  //             0
  //         ? SingleChildScrollView(
  //             child: _searchResult.length != 0 ||
  //                     controller.text.trim().toLowerCase().isNotEmpty
  //                 ? ListView.builder(
  //                     shrinkWrap: true,
  //                     scrollDirection: Axis.vertical,
  //                     physics: const NeverScrollableScrollPhysics(),
  //                     itemCount: _searchResult.length,
  //                     itemBuilder: (context, index) {
  //                       List chatlist = _searchResult;
  //                       return chatsWidget(chatlist[index], index);
  //                     },
  //                   )
  //                 : ListView.builder(
  //                     shrinkWrap: true,
  //                     scrollDirection: Axis.vertical,
  //                     physics: const NeverScrollableScrollPhysics(),
  //                     itemCount: chatListController
  //                         .userArchiveListModel.value!.archiveList!.length,
  //                     itemBuilder: (context, index) {
  //                       isOnline = chatListController.onlineUsers
  //                           .contains(chatListController.userChatListModel
  //                               .value!.chatList![index].userId
  //                               .toString())
  //                           .toString();
  //                       return chatsWidget(
  //                           chatListController.userArchiveListModel.value!
  //                               .archiveList![index],
  //                           index);
  //                     },
  //                   ),
  //           )
  //         : Expanded(
  //             child: commonImageTexts(
  //               image: "assets/images/no_contact_found_1.png",
  //               text1: languageController.textTranslate("No Contact Found"),
  //               text2: languageController.textTranslate(
  //                   "Tap and hold on any message to archive it, so you can easily find it later."),
  //             ),
  //           );
  //   });
  // }
  // In your ArchiveChat.dart file, find the chatListScreen1() method
// and update the code to handle potential null values

  // Widget chatListScreen1() {
  //   print(
  //       "LENGTH: ${chatListController.userArchiveListModel.value?.archiveList?.length ?? 0}");
  //   return Obx(() {
  //     // First check if userArchiveListModel.value is null
  //     if (chatListController.userArchiveListModel.value == null) {
  //       return Expanded(
  //         child: commonImageTexts(
  //           image: "assets/images/no_contact_found_1.png",
  //           text1: languageController.textTranslate("No Contact Found"),
  //           text2: languageController.textTranslate(
  //               "Tap and hold on any message to archive it, so you can easily find it later."),
  //         ),
  //       );
  //     }

  //     // Then check if archiveList is null or empty
  //     final archiveList =
  //         chatListController.userArchiveListModel.value?.archiveList;
  //     if (archiveList == null || archiveList.isEmpty) {
  //       return Expanded(
  //         child: commonImageTexts(
  //           image: "assets/images/no_contact_found_1.png",
  //           text1: languageController.textTranslate("No Contact Found"),
  //           text2: languageController.textTranslate(
  //               "Tap and hold on any message to archive it, so you can easily find it later."),
  //         ),
  //       );
  //     }

  //     // Now we know it has items
  //     return SingleChildScrollView(
  //       child: _searchResult.length != 0 ||
  //               controller.text.trim().toLowerCase().isNotEmpty
  //           ? ListView.builder(
  //               shrinkWrap: true,
  //               scrollDirection: Axis.vertical,
  //               physics: const NeverScrollableScrollPhysics(),
  //               itemCount: _searchResult.length,
  //               itemBuilder: (context, index) {
  //                 List chatlist = _searchResult;
  //                 return chatsWidget(chatlist[index], index);
  //               },
  //             )
  //           : ListView.builder(
  //               shrinkWrap: true,
  //               scrollDirection: Axis.vertical,
  //               physics: const NeverScrollableScrollPhysics(),
  //               itemCount: archiveList.length,
  //               itemBuilder: (context, index) {
  //                 isOnline = chatListController.onlineUsers
  //                     .contains(chatListController
  //                         .userChatListModel.value?.chatList?[index].userId
  //                         .toString())
  //                     .toString();
  //                 return chatsWidget(archiveList[index], index);
  //               },
  //             ),
  //     );
  //   });
  // }

  Widget chatListScreen1() {
    print(
        "LENGTH: ${chatListController.userArchiveListModel.value?.archiveList?.length ?? 0}");
    return Obx(() {
      // First check if userArchiveListModel.value is null
      if (chatListController.userArchiveListModel.value == null) {
        return Expanded(
          child: commonImageTexts(
            image: "assets/images/no_contact_found_1.png",
            text1: languageController.textTranslate("No Contact Found"),
            text2: languageController.textTranslate(
                "Tap and hold on any message to archive it, so you can easily find it later."),
          ),
        );
      }

      // Then check if archiveList is null or empty
      final archiveList =
          chatListController.userArchiveListModel.value?.archiveList;
      if (archiveList == null || archiveList.isEmpty) {
        return Expanded(
          child: commonImageTexts(
            image: "assets/images/no_contact_found_1.png",
            text1: languageController.textTranslate("No Contact Found"),
            text2: languageController.textTranslate(
                "Tap and hold on any message to archive it, so you can easily find it later."),
          ),
        );
      }

      // Now we know it has items
      return SingleChildScrollView(
        child: _searchResult.length != 0 ||
                controller.text.trim().toLowerCase().isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResult.length,
                itemBuilder: (context, index) {
                  List chatlist = _searchResult;
                  return chatsWidget(chatlist[index], index);
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: archiveList.length,
                itemBuilder: (context, index) {
                  // Get the user ID directly from the archive item
                  final userId = archiveList[index].userId?.toString() ?? "";
                  isOnline = chatListController.onlineUsers
                      .contains(userId)
                      .toString();

                  return chatsWidget(archiveList[index], index);
                },
              ),
      );
    });
  }

  Widget chatsWidget(ArchiveList data, index) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onLongPress: () {
              dialogBox(data.isBlock.toString(), data.conversationId.toString(),
                  data.isGroup!, data.userName!, data.groupName!, data);
            },
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.rightToLeft,
                    child: data.isGroup == false
                        ? SingleChatMsg(
                            conversationID: data.conversationId.toString(),
                            username: data.userName,
                            userPic: data.profileImage,
                            index: 0,
                            isMsgHighLight: false,
                            isBlock: data.isBlock,
                            userID: data.userId.toString(),
                            verificationBadge: data.verificationType != null
                                ? data.verificationType?.logo
                                : '',
                          )
                        : GroupChatMsg(
                            conversationID: data.conversationId.toString(),
                            gPusername: data.groupName,
                            gPPic: data.groupProfileImage,
                            index: 0,
                            isMsgHighLight: false,
                            verificationBadge: data.verificationType != null
                                ? data.verificationType?.logo
                                : '',
                          )),
              ).then((value) {});
            },
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(),
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 0,
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: data.profileImage != ""
                                    ? CustomCachedNetworkImage(
                                        imageUrl: data.profileImage.toString(),
                                        placeholderColor: chatownColor,
                                        errorWidgeticon: const Icon(
                                          Icons.person,
                                          size: 30,
                                        ))
                                    : CustomCachedNetworkImage(
                                        imageUrl:
                                            data.groupProfileImage.toString(),
                                        placeholderColor: chatownColor,
                                        errorWidgeticon: const Icon(
                                          Icons.groups,
                                          size: 30,
                                        ))),
                          ),
                          Positioned(
                              bottom: 5,
                              right: 0,
                              child: Obx(() {
                                return onlieController.allOnline
                                        .contains(data.userId.toString())
                                    ? Container(
                                        height: 10,
                                        width: 10,
                                        decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle),
                                      )
                                    : isUserOnline(data.userId.toString());
                              }))
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    data.userName.toString().isEmpty
                                        ? Text(
                                            capitalizeFirstLetter(
                                                '${data.groupName}'),
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          )
                                        : Text(
                                            capitalizeFirstLetter(
                                                data.userName!),
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          ),
                                    // Add the verification logo widget here
                                  ],
                                ),
                                Text(
                                  data.createdAt!.isEmpty
                                      ? ''
                                      : "${CommonWidget.convertDateForm(data.createdAt!)}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            onlieController.typingList.isNotEmpty
                                ? Obx(() {
                                    return Text(
                                      isUserTyping(
                                          data.conversationId.toString()),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    );
                                  })
                                : data.lastMessageType == "text"
                                    ? Text(
                                        capitalizeFirstLetter(
                                            data.lastMessage!),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    : data.lastMessageType == "image"
                                        ? Row(
                                            children: [
                                              Image.asset(
                                                "assets/icons/image_icon.png",
                                                height: 15,
                                                color: Colors.grey,
                                              ),
                                              Text(
                                                  " ${languageController.textTranslate('Photo')}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey))
                                            ],
                                          )
                                        : data.lastMessageType == "location"
                                            ? Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/icons/location_icon.png",
                                                    height: 15,
                                                    color: Colors.grey,
                                                  ),
                                                  Text(
                                                      " ${languageController.textTranslate('Location')}",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey))
                                                ],
                                              )
                                            : data.lastMessageType == "video"
                                                ? Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/icons/video_icon.png",
                                                        height: 15,
                                                        color: Colors.grey,
                                                      ),
                                                      Text(
                                                          " ${languageController.textTranslate('Video')}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey))
                                                    ],
                                                  )
                                                : data.lastMessageType == "gif"
                                                    ? Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .gif_box_outlined,
                                                            color: Colors.grey,
                                                          ),
                                                          Text(
                                                            languageController
                                                                .textTranslate(
                                                                    'GIF'),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                        ],
                                                      )
                                                    : data.lastMessageType ==
                                                            "link"
                                                        ? Row(
                                                            children: [
                                                              const Icon(
                                                                  CupertinoIcons
                                                                      .link,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .grey),
                                                              Text(
                                                                  " ${languageController.textTranslate('Link')}",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          13))
                                                            ],
                                                          )
                                                        : data.lastMessageType ==
                                                                "audio"
                                                            ? Row(
                                                                children: [
                                                                  Image.asset(
                                                                      "assets/images/microphone-2.png",
                                                                      height:
                                                                          15,
                                                                      color: Colors
                                                                          .grey),
                                                                  Text(
                                                                      " ${languageController.textTranslate('Voice message')}",
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              13))
                                                                ],
                                                              )
                                                            : data.lastMessageType ==
                                                                    "contact"
                                                                ? Row(
                                                                    children: [
                                                                      Image.asset(
                                                                          'assets/icons/profile_outline.png',
                                                                          height:
                                                                              15,
                                                                          color:
                                                                              Colors.grey),
                                                                      Text(
                                                                          " ${languageController.textTranslate('Contact')}",
                                                                          style: const TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 13))
                                                                    ],
                                                                  )
                                                                : const SizedBox
                                                                    .shrink()
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (index !=
                  chatListController
                          .userArchiveListModel.value!.archiveList!.length -
                      1 &&
              index != _searchResult.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.grey.shade300,
              ),
            )
        ],
      ),
    );
  }

  String convertUTCTimeTo12HourFormat(String utcTimeString) {
    DateTime utcDate = DateTime.parse(utcTimeString);
    String formattedTime = DateFormat('h:mm a').format(utcDate.toLocal());
    return formattedTime;
  }

  Widget searchBar() {
    return commonSearchField(
      context: context,
      controller: controller,
      onChanged: onSearchTextChanged,
      hintText: languageController.textTranslate('Search User'),
    );
    //     Container(
    //   height: 50,
    //   width: MediaQuery.of(context).size.width * 0.9,
    //   decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
    //   child: TextField(
    //     controller: controller,
    //     onChanged: onSearchTextChanged,
    //     decoration: InputDecoration(
    //       prefixIcon: const Padding(
    //         padding: EdgeInsets.all(17),
    //         child: Image(
    //           image: AssetImage('assets/icons/search.png'),
    //         ),
    //       ),
    //       hintText: languageController.textTranslate('Search User'),
    //       hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
    //       filled: true,
    //       fillColor: Colors.transparent,
    //       border: const OutlineInputBorder(borderSide: BorderSide.none),
    //     ),
    //   ),
    // );
  }

//_________________________________________________________________________________________________________________________________________________________

  Future dialogBox(String isblock, String cID, bool isGroup, String uname,
      String gpname, ArchiveList data) {
    return showDialog(
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: AlertDialog(
                  insetPadding: const EdgeInsets.all(15),
                  alignment: Alignment.bottomCenter,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  content: SizedBox(
                    height: isGroup == false ? 87 : 50,
                    width: Get.width,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: ListTile(
                            title: Text(
                              languageController.textTranslate('Unarchive'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            leading: const Icon(
                              Icons.archive_outlined,
                              size: 19,
                              color: Colors.black,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              isGroup == false
                                  ? chatListController.addArchveApi(cID, uname)
                                  : chatListController.addArchveApi(
                                      cID, gpname);
                              chatListController
                                  .userArchiveListModel.value!.archiveList!
                                  .remove(data);
                            },
                          ),
                        ),
                        isGroup == false
                            ? const SizedBox(height: 5)
                            : const SizedBox.shrink(),
                        isGroup == false
                            ? Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey[200],
                              )
                            : const SizedBox.shrink(),
                        isGroup == false
                            ? SizedBox(
                                height: 40,
                                child: ListTile(
                                  title: Text(
                                    isblock == "false"
                                        ? languageController
                                            .textTranslate('Block')
                                        : languageController
                                            .textTranslate('Unblock'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  leading: const Icon(
                                    Icons.block,
                                    size: 19,
                                    color: Colors.black,
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await chatListController.blockUserApi(cID);
                                    await chatListController
                                        .forArchiveChatList();
                                  },
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

// This function search chats user/group name
  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    chatListController.userArchiveListModel.value!.archiveList!
        .forEach((userDetail) {
      if (userDetail.userName != null) if (userDetail.userName!
          .toLowerCase()
          .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });

    chatListController.userArchiveListModel.value!.archiveList!
        .forEach((userDetail) {
      if (userDetail.groupName != null) if (userDetail.groupName!
          .toLowerCase()
          .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List _searchResult = [];
