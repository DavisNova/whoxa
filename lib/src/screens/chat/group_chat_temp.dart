// ignore_for_file: must_be_immutable, avoid_print, depend_on_referenced_packages, deprecated_member_use, prefer_is_empty, non_constant_identifier_names, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:whoxachat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
import 'package:lottie/lottie.dart' as lt;
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/audio_controller.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/controller/online_controller.dart';
import 'package:whoxachat/controller/pinned_message_controller.dart';
import 'package:whoxachat/controller/single_chat_controller.dart';
import 'package:whoxachat/controller/single_chat_media_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';

import 'package:whoxachat/src/global/chat_utils.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/pdf.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/Onlichat/ChatOnline.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:whoxachat/src/screens/chat/FileView.dart';
import 'package:whoxachat/src/screens/chat/GroupProfile.dart';
import 'package:whoxachat/src/screens/chat/chatvideo.dart';
import 'package:whoxachat/src/screens/chat/contact_send.dart';
import 'package:whoxachat/src/screens/chat/imageView.dart';
import 'package:whoxachat/src/screens/chat/shareable/common_permission_dialog.dart';
import 'package:whoxachat/src/screens/chat/message_report_popup.dart';
import 'package:whoxachat/src/screens/forward_message/forward_message_list.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:whoxachat/src/screens/save_contact.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/place_picker.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:whoxachat/model/chatdetails/single_chat_list_model.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:record/record.dart';
import 'package:whoxachat/src/screens/chat/sticker/data/sticker_service.dart';

class GroupChatMsg extends StatefulWidget {
  String? conversationID;
  String? mobileNum;
  String? gPusername;
  String? gDesc;
  String? gPPic;
  int? index;
  String? searchText;
  String? searchTime;
  String? messageid;
  bool? isMsgHighLight;
  String? verificationBadge;
  GroupChatMsg(
      {super.key,
      this.conversationID,
      this.mobileNum,
      this.gPusername,
      this.gDesc,
      this.gPPic,
      this.index,
      this.searchText,
      this.searchTime,
      this.messageid,
      this.isMsgHighLight,
      this.verificationBadge});

  @override
  State<GroupChatMsg> createState() => _GroupChatMsgState();
}

class _GroupChatMsgState extends State<GroupChatMsg> {
  Timer? timer;
  SingleChatContorller chatContorller = Get.put(SingleChatContorller());
  RoomIdController getRoomController = Get.put(RoomIdController());
  OnlineOfflineController controller = Get.find();
  GetAllDeviceContact getAllDeviceContact = Get.put(GetAllDeviceContact());
  ChatProfileController chatProfileController = Get.find();
  OnlineOfflineController onlieController = Get.find();
  ChatListController chatListController = Get.find();
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isThisScreen = false;
  bool isNavigating = false;
  PinMessageController pinMessageController = Get.put(PinMessageController());

  @override
  void initState() {
    Get.put(StickerService());
    isThisScreen = true;
    print("ID:${widget.conversationID}");
    print("NAME:${widget.gPusername}");
    print("Gdesc:${widget.gDesc}");
    print("PIC:${widget.gPPic}");
    loadGroupChatData();

    apis();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    // Initialize pin messages
    pinMessageController.getPinnedMessages(widget.conversationID!);
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Handle message highlighting from starred messages
      if (widget.isMsgHighLight == true && widget.messageid != null) {
        _handleMessageHighlighting();
      }
    });
  }

  void _handleMessageHighlighting() {
    // Wait for chat data to load, then find and highlight the message
    Future.delayed(Duration(milliseconds: 500), () {
      if (chatContorller.userdetailschattModel.value?.messageList != null) {
        int messageIndex =
            chatContorller.userdetailschattModel.value!.messageList!.indexWhere(
                (message) => message.messageId.toString() == widget.messageid);
        if (messageIndex != -1) {
          gotoindex = messageIndex;
          _scrollToIndex(gotoindex, callback: () {
            setState(() {
              highlightedIndex = gotoindex;
              isMsgHighLight = true;
            });
            Timer(const Duration(seconds: 3), () {
              setState(() {
                isMsgHighLight = false;
                highlightedIndex = null;
              });
            });
          });
        }
      }
    });
  }

  bool _isCameraPermissionGranted = false;
  bool _isLocationPermissionGranted = false;
  // Check if the contact permission is granted
  Future<void> _checkCameraPermission() async {
    var permission = await Permission.camera.request();

    if (permission.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
    } else if (permission.isDenied) {
      // If denied, show a message or retry
      print("Permission denied. Ask user to grant manually.");
    } else if (permission.isPermanentlyDenied) {
      // Open app settings if permanently denied
      // openAppSettings();

      PermissionUtil.showPermissionSettingsDialog(
          context,
          "Camera", // or "Location", "Microphone", etc.
          languageController.textTranslate,
          chatownColor,
          secondaryColor);
    }
  }

  // Check if the contact permission is granted
  Future<void> _checkLocationPermission() async {
    var permission = await Permission.location.request();

    if (permission.isGranted) {
      setState(() {
        _isLocationPermissionGranted = true;
      });
    } else if (permission.isDenied) {
      // If denied, show a message or retry
      print("Permission denied. Ask user to grant manually.");
    } else if (permission.isPermanentlyDenied) {
      // Open app settings if permanently denied
      // openAppSettings();
      PermissionUtil.showPermissionSettingsDialog(
          context,
          "Location", // or "Location", "Microphone", etc.
          languageController.textTranslate,
          chatownColor,
          secondaryColor);
    }
  }

  loadGroupChatData() {
    if (chatContorller.userdetailschattModel.value?.messageList?.isNotEmpty ??
        false) {
      chatContorller.userdetailschattModel.value!.messageList = [];
    }
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      await chatContorller.getdetailschat(
        widget.conversationID,
        onNewMessageReceived: (data) {
          if (isThisScreen == true) {
            print("onNewMessageReceived: messageId ${data.messageId}");
            print(
                "onNewMessageReceived: conversationID ${widget.conversationID}");
            socketIntilized.socket!.emit("messageViewed", {
              "conversation_id": widget.conversationID.toString(),
              "message_id": data.messageId,
            });
          }
        },
      );
      socketIntilized.socket!.on("update_message_read", (data) {
        print("data update_message_read: $data");
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (data["message_id"].toString().isNotEmpty) {
            debugPrint("message_id ${data["message_id"]}");
            if (chatContorller.userdetailschattModel.value?.messageList !=
                null) {
              debugPrint(
                  "message_id 1  ${chatContorller.userdetailschattModel.value!.messageList!.where((element) => element.messageId.toString() == data["message_id"].toString()).isEmpty}");
            }
            if (chatContorller
                    .userdetailschattModel.value?.messageList?.isNotEmpty ??
                false) {
              debugPrint(
                  "message_id 2  ${chatContorller.userdetailschattModel.value!.messageList![0].messageId}");
              chatContorller.userdetailschattModel.value!.messageList!
                  .where((element) =>
                      element.messageId.toString() ==
                      data["message_id"].toString())
                  .first
                  .messageRead = 1;
              chatContorller.userdetailschattModel.refresh();
            }
          }
        });
      });
      initlizedcontroller();
      if (widget.messageid != null) {
        int? messageIndex =
            chatContorller.userdetailschattModel.value!.messageList!.indexWhere(
                (message) => message.messageId.toString() == widget.messageid);
        if (messageIndex != -1) {
          gotoindex = messageIndex;
          _scrollToIndex(gotoindex, callback: () {
            setState(() {
              highlightedIndex = gotoindex;
              widget.isMsgHighLight = true;
            });
            Timer(const Duration(seconds: 2), () {
              setState(() {
                widget.isMsgHighLight = false;
              });
            });
          });
        }
      }
    });
  }

  Future<void> apis() async {
    var contactJson = json.encode(addContactController.mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);
  }

  bool matchContact(String num) {
    for (var i = 0; i < getAllDeviceContact.getList.length; i++) {
      if (num == getAllDeviceContact.getList[i].phoneNumber) {
        return true;
      }
    }
    return false;
  }

  List? chatMsgList;

  List chatID = [];
  List<MessageList> chatMessageList = [];
  final TextEditingController _searchController = TextEditingController();
  TextEditingController messagecontroller = TextEditingController();
  AudioController audioController = Get.put(AudioController());
  bool isKeyboard = false;
  String isSelectedmessage = "0";
  String isSearchSelect = "0";
  String isTextFieldHide = '0';
  bool isSendbutton = false;
  bool isHttpSendbutton = false;

  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int? gotoindex;
  AutoScrollController? listScrollController;
  List<List<int>>? randomList;

  // _scrollToIndex(index, {Function? callback}) async {
  //   await listScrollController?.scrollToIndex(index,
  //       preferPosition: AutoScrollPosition.begin);
  //   if (callback != null) {
  //     callback();
  //   }
  // }
  _scrollToIndex(index, {Function? callback}) async {
    print("_scrollToIndex called with index: $index");

    // First, always call the callback even if the index is 0
    // This ensures highlighting works for all indices
    if (callback != null) {
      callback();
    }

    // Then do the scrolling if necessary
    // if (index > 0) {
    //   await listScrollController?.scrollToIndex(index,
    //       duration: const Duration(milliseconds: 50),
    //       preferPosition: AutoScrollPosition.begin);
    //   print("Scrolled to index: $index");
    // } else {
    //   print("No need to scroll, already at index: $index");
    // }

    await listScrollController?.scrollToIndex(index,
        duration: const Duration(milliseconds: 50),
        preferPosition: AutoScrollPosition.begin);
    print("Scrolled to index: $index");
  }

  initlizedcontroller() async {
    listScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    listScrollController?.addListener(hideKeyboard);
    if (widget.index != 0) {
      await listScrollController?.scrollToIndex(widget.index!,
          preferPosition: AutoScrollPosition.begin);
    }
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  double HEIGHT = 96;
  final ValueNotifier<double> notifier = ValueNotifier(0);

  String? banner;

  bool isMsgHighLight = false;
  int? highlightedIndex;

  String chatdate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  ValueNotifier<String> dateNotifier = ValueNotifier<String>("");

  bool isKeyboardOpen() {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  // @override
  // void dispose() {
  //   isThisScreen = false;
  //   setState(() {});
  //   timer?.cancel();

  //   chatContorller.onClose();
  //   audioRecord.dispose();
  //   audioPlayer.dispose();
  //   socketIntilized.socket!.off(
  //     "update_message_read",
  //     (data) {
  //       print("data update_message_read: $data");
  //       if (data["message_id"].toString().isNotEmpty) {
  //         debugPrint("message_id ${data["message_id"]}");
  //         chatContorller.userdetailschattModel.value!.messageList!
  //             .where((element) =>
  //                 element.messageId.toString() == data["message_id"].toString())
  //             .first
  //             .messageRead = 1;
  //         chatContorller.userdetailschattModel.refresh();
  //       }
  //     },
  //   );
  //   super.dispose();
  // }

  @override
  void dispose() {
    // Cancel all timers first
    timer?.cancel();
    typingTimer?.cancel();

    // Set flags without using setState
    isThisScreen = false;

    // Remove socket listeners
    socketIntilized.socket!.off("update_message_read");

    // Call controller's onClose or dispose methods if needed
    chatContorller.onClose();
    audioRecord.dispose();
    audioPlayer.dispose();
    pinMessageController.onClose();
    // Finally call super.dispose()
    super.dispose();
  }

  String typingstart = "0";
  Timer? typingTimer;
  void resetTypingStatus() {
    setState(() {
      typingstart = "0";
    });
  }

  void startTypingTimer() {
    typingTimer = Timer(const Duration(seconds: 3), () {
      chatContorller.isTypingApi(widget.conversationID!, "0");
      controller.isTyping();
      resetTypingStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboard = isKeyboardOpen();
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Get.find<ChatListController>().forChatList();
        // Get.offAll(
        //   TabbarScreen(
        //     currentTab: 0,
        //   ),
        // );
        Future.microtask(() {
          Get.find<ChatListController>().forChatList();
          // Get.offAll(() => TabbarScreen(currentTab: 0)); //this is used for refresh the chatlist but already socket update the list
          Get.back();
        });
      },
      child: GestureDetector(
        onTap: () {
          //this is used to hide chat menu
          setState(() {
            click = false;
            closekeyboard();
          });
          print(click);
        },
        onVerticalDragEnd: (DragEndDetails details) {
          // Check if it's a downward drag (positive velocity)
          if (details.velocity.pixelsPerSecond.dy > 0) {
            setState(() {
              click = false;
              closekeyboard();
            });
            print("Slide down detected - menu closed");
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: isSelectedmessage == "0" ||
                    chatID.isEmpty ||
                    chatMessageList.isEmpty
                ? (isSearchSelect == "0"
                    ? _appbar(context)
                    : _appbarSearch(context))
                : _appbar1(context),
            body: Obx(() {
              return chatContorller.isLoading.value
                  ? loader(context)
                  : Column(
                      children: [
                        Flexible(
                            child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  opacity: 0.05,
                                  image: AssetImage(
                                      "assets/images/chat_back_img.png"),
                                  fit: BoxFit.cover)),
                          child: Stack(
                            children: [
                              NotificationListener<ScrollNotification>(
                                  // onNotification: (n) {
                                  //   if (n.metrics.pixels <= HEIGHT) {
                                  //     notifier.value = n.metrics.pixels;

                                  //     int firstVisibleIndex =
                                  //         (n.metrics.pixels /
                                  //                 (HEIGHT /
                                  //                     chatContorller
                                  //                         .userdetailschattModel
                                  //                         .value!
                                  //                         .messageList!
                                  //                         .length))
                                  //             .floor();
                                  //     if (firstVisibleIndex <
                                  //         chatContorller.userdetailschattModel
                                  //             .value!.messageList!.length) {
                                  //       String formattedDate = formatDate(
                                  //           convertToLocalDate(chatContorller
                                  //               .userdetailschattModel
                                  //               .value!
                                  //               .messageList![firstVisibleIndex]
                                  //               .createdAt!));
                                  //       dateNotifier.value = formattedDate;
                                  //     }
                                  //   }
                                  //   return false;
                                  // },
                                  onNotification: (ScrollNotification n) {
                                    // Handle scroll start notification
                                    if (n is ScrollStartNotification && click) {
                                      setState(() {
                                        click = false;
                                      });
                                    }

                                    // Ensure we only process notifications when within our scrollable area
                                    if (n.metrics.pixels <= HEIGHT) {
                                      notifier.value = n.metrics.pixels;

                                      // Calculate the visible index safely
                                      final totalMessages = chatContorller
                                              .userdetailschattModel
                                              .value
                                              ?.messageList
                                              ?.length ??
                                          0;

                                      // Guard against division by zero
                                      if (totalMessages == 0) {
                                        return false;
                                      }

                                      // Calculate the item height
                                      final itemHeight = HEIGHT / totalMessages;

                                      // Calculate first visible index and ensure it's not negative
                                      int firstVisibleIndex =
                                          (n.metrics.pixels / itemHeight)
                                              .floor();
                                      firstVisibleIndex = firstVisibleIndex < 0
                                          ? 0
                                          : firstVisibleIndex;

                                      // Ensure index is within bounds
                                      if (firstVisibleIndex < totalMessages &&
                                          chatContorller.userdetailschattModel
                                                  .value !=
                                              null &&
                                          chatContorller.userdetailschattModel
                                                  .value!.messageList !=
                                              null) {
                                        // Get message at the calculated index
                                        final message = chatContorller
                                            .userdetailschattModel
                                            .value!
                                            .messageList![firstVisibleIndex];

                                        // Format date if the message is a date type
                                        String formattedDate = "";
                                        if (message.messageType == 'date') {
                                          formattedDate = formatDate(
                                              convertToLocalDate(
                                                  message.message));
                                        }

                                        // Update date notifier with formatted date
                                        dateNotifier.value = formattedDate;
                                      }
                                    }

                                    // Return false to allow the notification to continue to be dispatched to further ancestors
                                    return false;
                                  },
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: (chatContorller
                                                    .userdetailschattModel
                                                    .value
                                                    ?.messageList
                                                    ?.isEmpty ??
                                                true) ||
                                            (chatContorller
                                                    .userdetailschattModel
                                                    .value
                                                    ?.messageList
                                                    ?.first
                                                    .message ==
                                                null)
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                    height: isKeyboard ||
                                                            click == true
                                                        ? MediaQuery.sizeOf(
                                                                    context)
                                                                .height *
                                                            0.1
                                                        : MediaQuery.sizeOf(
                                                                    context)
                                                                .height *
                                                            0.2),
                                                InkWell(
                                                  onTap: () {
                                                    widget.mobileNum == null &&
                                                            widget.mobileNum ==
                                                                ""
                                                        ? chatContorller
                                                            .sendMessageText(
                                                                "Hi",
                                                                widget
                                                                    .conversationID!,
                                                                "text",
                                                                widget.mobileNum
                                                                    .toString(),
                                                                '',
                                                                '')
                                                        : chatContorller
                                                            .sendMessageText(
                                                                "Hi",
                                                                widget
                                                                    .conversationID!,
                                                                "text",
                                                                "",
                                                                '',
                                                                '');
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.5,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          commonImageTexts(
                                                            image:
                                                                "assets/images/start_conversation.png",
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Column(
                                              children: [
                                                _searchResult.isNotEmpty ||
                                                        _searchController.text
                                                            .toLowerCase()
                                                            .isNotEmpty
                                                    ? Flexible(
                                                        child: ListView.builder(
                                                            shrinkWrap: true,
                                                            reverse: true,
                                                            controller:
                                                                listScrollController,
                                                            itemCount:
                                                                _searchResult
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return buildItem(
                                                                  index,
                                                                  _searchResult[
                                                                      index]);
                                                            }),
                                                      )
                                                    : Flexible(
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          reverse: true,
                                                          controller:
                                                              listScrollController,
                                                          itemCount: chatContorller
                                                                  .userdetailschattModel
                                                                  .value
                                                                  ?.messageList
                                                                  ?.length ??
                                                              0,
                                                          itemBuilder:
                                                              (context, index) {
                                                            for (int i = 0;
                                                                i <
                                                                    (chatContorller
                                                                            .userdetailschattModel
                                                                            .value
                                                                            ?.messageList
                                                                            ?.length ??
                                                                        0);
                                                                i++) {
                                                              if (isScroll ==
                                                                  true) {
                                                                gotoindex = i;
                                                                _scrollToIndex(
                                                                    gotoindex);
                                                                isScroll =
                                                                    false;
                                                              }
                                                            }

                                                            return AutoScrollTag(
                                                                key: ValueKey(
                                                                    index),
                                                                controller:
                                                                    listScrollController!,
                                                                index: index,
                                                                child: (chatContorller.userdetailschattModel.value?.messageList !=
                                                                            null &&
                                                                        index <
                                                                            (chatContorller.userdetailschattModel.value?.messageList?.length ??
                                                                                0))
                                                                    ? buildItem(
                                                                        index,
                                                                        chatContorller
                                                                            .userdetailschattModel
                                                                            .value!
                                                                            .messageList![index])
                                                                    : SizedBox.shrink());
                                                          },
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: ValueListenableBuilder<double>(
                                  valueListenable: notifier,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                        offset: const Offset(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20, right: 0),
                                          child: value < 1
                                              ? Container()
                                              : Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    40))),
                                                    height: 40,
                                                    width: 40,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        listScrollController!.jumpTo(
                                                            listScrollController!
                                                                .position
                                                                .minScrollExtent);
                                                      },
                                                      icon: const Icon(Icons
                                                          .arrow_circle_down),
                                                    ),
                                                  ),
                                                ),
                                        ));
                                  },
                                ),
                              ),
                              SelectedreplyText
                                  ? Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.99,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(00.0),
                                                topLeft:
                                                    Radius.circular(00.0))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.grey[200],
                                            ),
                                            Container(
                                              color: bg1,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 60,
                                                    width: 8,
                                                    decoration: BoxDecoration(
                                                        color: chatownColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0))),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    height: 55,
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.85,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(USERTEXT),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          capitalizeFirstLetter(
                                                              replyText),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: chatColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        SelectedreplyText =
                                                            false;
                                                        print(
                                                            SelectedreplyText);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 30,
                                                      width: 30,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                appColorBlack),
                                                      ),
                                                      child: const Icon(
                                                          Icons.close,
                                                          color: appColorBlack),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        )),
                        chatContorller.isSendMsg.value
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: loader(context),
                              )
                            : const SizedBox(),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: isTextFieldHide == "0"
                                ? (isSelectedmessage == "0"
                                    ? floatbuttonNew()
                                    : floatbutton1())
                                : const SizedBox.shrink())
                      ],
                    );
            })),
      ),
    );
  }

  Widget buildItem(int index, MessageList data) {
    if (data.deleteFromEveryone == true) {
      return getDeleteMessageByEveryoneWidget(index, data);
    } else if (data.deleteForMe != null &&
        data.deleteForMe!.isNotEmpty &&
        data.deleteForMe!
            .split(",")
            .contains(Hive.box(userdata).get(userId).toString())) {
      return getDeleteMessageByMeWidget(index, data);
    } else {
      switch (data.messageType) {
        case 'text':
          return data.replyId == 0
              ? getTextMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'image':
          return data.replyId == 0
              ? getImgMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'location':
          return data.replyId == 0
              ? getLocationMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'video':
          return data.replyId == 0
              ? getVideoMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'document':
          return data.replyId == 0
              ? getDocMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'audio':
          return data.replyId == 0
              ? getVoiceMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'gif':
          return data.replyId == 0
              ? getGifMessage(index, data)
              : getReplyMessage(index, data);
        case 'sticker':
          return data.replyId == 0
              ? getStickerMessageWidget(index, data)
              : getReplyMessage(index, data);
        case 'link':
          return data.replyId == 0
              ? getHttpLinkMessage(index, data)
              : getReplyMessage(index, data);
        case 'contact':
          return data.replyId == 0
              ? getContactMessage(index, data)
              : getReplyMessage(index, data);
        case 'date':
          return getDateWidget(index, data);
        case 'member_added':
          return getMemeberAdded(data);
        case 'member_removed':
          return getMemeberRemoved(data);
        case 'video_call':
          return data.replyId == 0
              ? getVideoCallWidget(index, data)
              : getReplyMessage(index, data);
        case 'audio_call':
          return data.replyId == 0
              ? getAudioCallWidget(index, data)
              : getReplyMessage(index, data);

        default:
          return const SizedBox.shrink();
      }
    }
  }

  Widget getVideoCallWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
      child: Stack(
        children: [
          Container(
            color: highlightedIndex == index &&
                    (isMsgHighLight || (widget.isMsgHighLight ?? false))
                ? secondaryColor
                : Colors.transparent,
            child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    data.myMessage == false
                        ? richText(
                            imageFile: data.senderData!.profileImage!,
                            fName: data.senderData!.firstName!,
                            lName: data.senderData!.lastName!)
                        : const SizedBox.shrink(),
                    data.myMessage == false
                        ? const SizedBox(height: 5)
                        : const SizedBox.shrink(),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 3, right: 3, top: 0, bottom: 0),
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          borderRadius: data.myMessage == false
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10))
                              : const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                          color: data.myMessage == false
                              ? grey1Color
                              : secondaryColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: const Radius.circular(8.0),
                                      bottomRight: data.myMessage == false
                                          ? const Radius.circular(8)
                                          : const Radius.circular(0.0),
                                      topLeft: const Radius.circular(8.0),
                                      bottomLeft: data.myMessage == false
                                          ? const Radius.circular(0)
                                          : const Radius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: data.myMessage == false
                                                  ? grey1Color
                                                  : secondaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              data.messageType == "video_call"
                                                  ? data.message == "1,0,0"
                                                      ? "assets/icons/mvc.png"
                                                      : data.message == "0,0,1"
                                                          ? data.senderData!
                                                                      .userId
                                                                      .toString() ==
                                                                  Hive.box(
                                                                          userdata)
                                                                      .get(
                                                                          userId)
                                                                      .toString()
                                                              ? "assets/icons/ovc.png"
                                                              : "assets/icons/ivc.png"
                                                          : data.senderData!
                                                                      .userId
                                                                      .toString() ==
                                                                  Hive.box(
                                                                          userdata)
                                                                      .get(
                                                                          userId)
                                                                      .toString()
                                                              ? "assets/icons/ovc.png"
                                                              : "assets/icons/ivc.png"
                                                  : "",
                                              height: 18,
                                            ).paddingAll(7),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data.messageType == "video_call"
                                                    ? data.message == "1,0,0"
                                                        ? "Missed Video Call"
                                                        : data.message ==
                                                                "0,0,1"
                                                            ? "Video Call"
                                                            : data.senderData!
                                                                        .userId
                                                                        .toString() ==
                                                                    Hive.box(
                                                                            userdata)
                                                                        .get(
                                                                            userId)
                                                                        .toString()
                                                                ? "Video Call"
                                                                : "Video Call"
                                                    : "",
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: appColorBlack,
                                                ),
                                              ),
                                              SizedBox(
                                                height: data.message == "0,0,1"
                                                    ? 2
                                                    : 0,
                                              ),
                                              data.message == "0,0,1"
                                                  ? Text(
                                                      "No answer",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 8,
                                                        color: appColorBlack
                                                            .withOpacity(0.34),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).paddingOnly(top: 3, bottom: 3),
                        ],
                      ),
                    ),
                    data.myMessage == false
                        ? SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
                          )
                        : SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
                          )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget getAudioCallWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
      child: Stack(
        children: [
          Container(
            color: highlightedIndex == index &&
                    (isMsgHighLight || (widget.isMsgHighLight ?? false))
                ? secondaryColor
                : Colors.transparent,
            child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    data.myMessage == false
                        ? richText(
                            imageFile: data.senderData!.profileImage!,
                            fName: data.senderData!.firstName!,
                            lName: data.senderData!.lastName!)
                        : const SizedBox.shrink(),
                    data.myMessage == false
                        ? const SizedBox(height: 5)
                        : const SizedBox.shrink(),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 3, right: 3, top: 0, bottom: 0),
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          borderRadius: data.myMessage == false
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10))
                              : const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                          color: data.myMessage == false
                              ? grey1Color
                              : secondaryColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: const Radius.circular(8.0),
                                      bottomRight: data.myMessage == false
                                          ? const Radius.circular(8)
                                          : const Radius.circular(0.0),
                                      topLeft: const Radius.circular(8.0),
                                      bottomLeft: data.myMessage == false
                                          ? const Radius.circular(0)
                                          : const Radius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: data.myMessage == false
                                                  ? grey1Color
                                                  : secondaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              data.messageType == "audio_call"
                                                  ? data.message == "1,0,0"
                                                      ? "assets/icons/mac.png"
                                                      : data.message == "0,0,1"
                                                          ? data.senderData!
                                                                      .userId
                                                                      .toString() ==
                                                                  Hive.box(
                                                                          userdata)
                                                                      .get(
                                                                          userId)
                                                                      .toString()
                                                              ? "assets/icons/oac.png"
                                                              : "assets/icons/iac.png"
                                                          : data.senderData!
                                                                      .userId
                                                                      .toString() ==
                                                                  Hive.box(
                                                                          userdata)
                                                                      .get(
                                                                          userId)
                                                                      .toString()
                                                              ? "assets/icons/oac.png"
                                                              : "assets/icons/iac.png"
                                                  : "",
                                              height: 18,
                                            ).paddingAll(7),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data.messageType == "audio_call"
                                                    ? data.message == "1,0,0"
                                                        ? "Missed Audio Call"
                                                        : data.message ==
                                                                "0,0,1"
                                                            ? "Audio Call"
                                                            : data.senderData!
                                                                        .userId
                                                                        .toString() ==
                                                                    Hive.box(
                                                                            userdata)
                                                                        .get(
                                                                            userId)
                                                                        .toString()
                                                                ? "Audio Call"
                                                                : "Audio Call"
                                                    : "",
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: appColorBlack,
                                                ),
                                              ),
                                              SizedBox(
                                                height: data.message == "0,0,1"
                                                    ? 2
                                                    : 0,
                                              ),
                                              data.message == "0,0,1"
                                                  ? Text(
                                                      "No answer",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 8,
                                                        color: appColorBlack
                                                            .withOpacity(0.34),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).paddingOnly(top: 3, bottom: 3),
                        ],
                      ),
                    ),
                    data.myMessage == false
                        ? SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
                          )
                        : SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
                          )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget getMemeberAdded(MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: (Alignment.topCenter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .82),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade200),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              data.message!,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getMemeberRemoved(MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: (Alignment.topCenter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .7),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade200),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              data.message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getDateWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: (Alignment.topCenter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * .6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey.shade200),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            formatDate(convertToLocalDate(data.message!)),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getDeleteMessageByEveryoneWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                        ? data.myMessage == false
                            ? 40
                            : 12
                        : 12,
                    right: 12,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? secondaryColor
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .7),
                                decoration: BoxDecoration(
                                  borderRadius: data.myMessage == false
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15))
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)),
                                  color: data.myMessage == false
                                      ? grey1Color
                                      : secondaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: const Text(
                                  "🚫 This message was deleted!",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: chatColor),
                                ),
                              ),
                              data.myMessage == false
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: Icon(
                                        Icons.done_all,
                                        color:
                                            data.messageRead.toString() == "1"
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                        size: 15,
                                      ))
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget getDeleteMessageByMeWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                        ? data.myMessage == false
                            ? 40
                            : 12
                        : 12,
                    right: 12,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? secondaryColor
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .7),
                                decoration: BoxDecoration(
                                  borderRadius: data.myMessage == false
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15))
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)),
                                  color: data.myMessage == false
                                      ? grey1Color
                                      : secondaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: const Text(
                                  "🚫 You deleted this message!",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: chatColor),
                                ),
                              ),
                              data.myMessage == false
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: Icon(
                                        Icons.done_all,
                                        color:
                                            data.messageRead.toString() == "1"
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                        size: 15,
                                      ))
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget getTextMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                        ? data.myMessage == false
                            ? 40
                            : 12
                        : 12,
                    right: 12,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? secondaryColor
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          data.myMessage == false
                              ? richText(
                                  imageFile: data.senderData!.profileImage!,
                                  fName: data.senderData!.firstName!,
                                  lName: data.senderData!.lastName!)
                              : const SizedBox.shrink(),
                          data.myMessage == false
                              ? const SizedBox(height: 5)
                              : const SizedBox.shrink(),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: data.myMessage == false
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15))
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)),
                                  color: data.myMessage == false
                                      ? grey1Color
                                      : secondaryColor,
                                ),
                                // child: Text(
                                //   capitalizeFirstLetter(data.message!),
                                //   style: const TextStyle(
                                //       fontSize: 14,
                                //       fontWeight: FontWeight.w400,
                                //       color: chatColor),
                                // ),
                                child: _buildMessageText(data.message,
                                    isMyMessage:
                                        data.myMessage! ? false : true),
                              ),
                              data.myMessage == false
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: Icon(
                                        Icons.done_all,
                                        color:
                                            data.messageRead.toString() == "1"
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                        size: 15,
                                      ))
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(String? message, {required bool isMyMessage}) {
    if (message == null) return const Text('');

    final capitalizedMessage = capitalizeFirstLetter(message);
    final isEmoji = isOnlyEmoji(message);

    return Text(
      capitalizedMessage,
      style: TextStyle(
        fontSize: 14, // 表情和文字消息都使用14px，保持一致
        fontWeight: FontWeight.w400,
        color: !isMyMessage ? appColorWhite : chatColor,
      ),
    );
  }

  Widget getImgMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? secondaryColor
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    data.myMessage == false
                        ? richText(
                            imageFile: data.senderData!.profileImage!,
                            fName: data.senderData!.firstName!,
                            lName: data.senderData!.lastName!)
                        : const SizedBox.shrink(),
                    data.myMessage == false
                        ? const SizedBox(height: 5)
                        : const SizedBox.shrink(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              curve: Curves.linear,
                              type: PageTransitionType.rightToLeft,
                              child: ImageView(
                                image: data.url!,
                                userimg: "",
                              )),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: data.myMessage == false
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))
                              : const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)),
                          color: data.myMessage == false
                              ? grey1Color
                              : secondaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: data.url!,
                                  imageBuilder: (context, imageProvider) =>
                                      Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                                data.myMessage == false
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        bottom: 3,
                                        right: 3,
                                        child: Icon(
                                          Icons.done_all,
                                          color:
                                              data.messageRead.toString() == "1"
                                                  ? Colors.blue
                                                  : Colors.grey.shade400,
                                          size: 15,
                                        ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget getLocationMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? secondaryColor
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                          ? data.myMessage == false
                              ? 40
                              : 12
                          : 12,
                      right: 12,
                      top: 0,
                      bottom: 0),
                  child: Stack(
                    alignment: data.myMessage == false
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    children: [
                      Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          data.myMessage == false
                              ? richText(
                                  imageFile: data.senderData!.profileImage!,
                                  fName: data.senderData!.firstName!,
                                  lName: data.senderData!.lastName!)
                              : const SizedBox.shrink(),
                          data.myMessage == false
                              ? const SizedBox(height: 5)
                              : const SizedBox.shrink(),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: data.myMessage == false
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomRight: Radius.circular(15))
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomLeft: Radius.circular(15)),
                                color: data.myMessage == false
                                    ? grey1Color
                                    : secondaryColor),
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
                                      child: data.latitude.toString() == "" ||
                                              data.longitude.toString() == ""
                                          ? Container(
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/images/map_Blurr.png"),
                                                      fit: BoxFit.cover)),
                                              child: Icon(
                                                Icons.error_outline,
                                                color: chatownColor
                                                    .withOpacity(0.6),
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
                                                  AsyncSnapshot<Uint8List>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    snapshot.hasData) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18)),
                                                    height: 100,
                                                    child: Stack(
                                                      children: [
                                                        GoogleMap(
                                                          zoomControlsEnabled:
                                                              false,
                                                          onTap: (argument) {
                                                            MapUtils.openMap(
                                                                double.parse(data
                                                                    .latitude!),
                                                                double.parse(data
                                                                    .longitude!));
                                                          },
                                                          mapType:
                                                              MapType.normal,
                                                          compassEnabled: false,
                                                          initialCameraPosition: CameraPosition(
                                                              target: LatLng(
                                                                  double.parse(data
                                                                      .latitude!),
                                                                  double.parse(data
                                                                      .longitude!)),
                                                              zoom: 15),
                                                          markers: {
                                                            Marker(
                                                              icon: BitmapDescriptor
                                                                  .fromBytes(
                                                                      snapshot
                                                                          .data!),
                                                              markerId:
                                                                  const MarkerId(
                                                                      'my_location'),
                                                              position: LatLng(
                                                                  double.parse(data
                                                                      .latitude!),
                                                                  double.parse(data
                                                                      .longitude!)),
                                                            ),
                                                          },
                                                        ),
                                                        data.myMessage == false
                                                            ? const SizedBox
                                                                .shrink()
                                                            : Positioned(
                                                                bottom: 3,
                                                                right: 3,
                                                                child: Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  color: data.messageRead
                                                                              .toString() ==
                                                                          "1"
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey
                                                                          .shade400,
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
                                    MapUtils.openMap(
                                        double.parse(data.latitude!),
                                        double.parse(data.longitude!));
                                  },
                                  child: Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                              data.myMessage == false ? 0 : 7),
                                          bottomRight: Radius.circular(
                                              data.myMessage == false ? 7 : 0)),
                                      gradient: LinearGradient(
                                        colors: data.myMessage == true
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
                                        Text(
                                          "View Location",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: data.myMessage == false
                                                  ? appColorBlack
                                                  : appColorWhite),
                                        ),
                                      ],
                                    ).paddingSymmetric(vertical: 5),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getVideoMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? secondaryColor
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoViewFix(
                            username: data.myMessage == false
                                ? "${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}"
                                : languageController.textTranslate('You'),
                            url: data.url!,
                            play: true,
                            mute: false,
                            date: convertUTCTimeTo12HourFormat(data.createdAt!),
                          ),
                        ));
                  },
                  child: Column(
                    crossAxisAlignment: data.myMessage == false
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      data.myMessage == false
                          ? richText(
                              imageFile: data.senderData!.profileImage!,
                              fName: data.senderData!.firstName!,
                              lName: data.senderData!.lastName!)
                          : const SizedBox.shrink(),
                      data.myMessage == false
                          ? const SizedBox(height: 5)
                          : const SizedBox.shrink(),
                      Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 176,
                            decoration: BoxDecoration(
                                borderRadius: data.myMessage == false
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomRight: Radius.circular(15))
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomLeft: Radius.circular(15)),
                                color: data.myMessage == false
                                    ? grey1Color
                                    : secondaryColor),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ClipRRect(
                                borderRadius: data.myMessage == false
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomRight: Radius.circular(15))
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomLeft: Radius.circular(15)),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: data.thumbnail!,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                    data.myMessage == false
                                        ? const SizedBox.shrink()
                                        : Positioned(
                                            bottom: 3,
                                            right: 3,
                                            child: Icon(
                                              Icons.done_all,
                                              color:
                                                  data.messageRead.toString() ==
                                                          "1"
                                                      ? Colors.blue
                                                      : Colors.grey.shade400,
                                              size: 15,
                                            ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: 68,
                              left: 55,
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VideoViewFix(
                                            username: data.myMessage == false
                                                ? "${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}"
                                                : languageController
                                                    .textTranslate('You'),
                                            url: data.url!,
                                            play: true,
                                            mute: false,
                                            date: convertUTCTimeTo12HourFormat(
                                                data.createdAt!),
                                          ),
                                        ));
                                  },
                                  child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: blurColor,
                                      foregroundColor: chatownColor,
                                      child: Image.asset(
                                          "assets/images/play2.png",
                                          height: 12)),
                                ),
                              )),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDocMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 5,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? secondaryColor
                  : Colors.transparent,
              child: Align(
                  alignment: data.myMessage == false
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: data.myMessage == false
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      data.myMessage == false
                          ? richText(
                              imageFile: data.senderData!.profileImage!,
                              fName: data.senderData!.firstName!,
                              lName: data.senderData!.lastName!)
                          : const SizedBox.shrink(),
                      data.myMessage == false
                          ? const SizedBox(height: 5)
                          : const SizedBox.shrink(),
                      Container(
                        padding: EdgeInsets.only(
                            left:
                                chatID.isNotEmpty || chatMessageList.isNotEmpty
                                    ? data.myMessage == false
                                        ? 35
                                        : 10
                                    : 3,
                            right: 3,
                            top: 0,
                            bottom: 0),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                            color: data.myMessage == false
                                ? grey1Color
                                : secondaryColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 240,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                            curve: Curves.linear,
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child:
                                                FileView(file: "${data.url}"),
                                          ));
                                    },
                                    child: SizedBox(
                                      width: Get.width * 0.50,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topRight: const Radius.circular(8.0),
                                          bottomRight: data.myMessage == false
                                              ? const Radius.circular(8)
                                              : const Radius.circular(0.0),
                                          topLeft: const Radius.circular(8.0),
                                          bottomLeft: data.myMessage == false
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
                                              FutureBuilder<
                                                  Map<String, dynamic>>(
                                                future: getPdfInfo(data.url!),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          extractFilename(
                                                                  data.url!)
                                                              .toString()
                                                              .split("-")
                                                              .last,
                                                          style:
                                                              const TextStyle(
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
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        )
                                                      ],
                                                    ).paddingOnly(left: 12);
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return const Text('');
                                                  } else if (snapshot.hasData) {
                                                    final int pageCount =
                                                        snapshot
                                                            .data!['pageCount'];
                                                    final String fileSize =
                                                        snapshot
                                                            .data!['fileSize'];
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
                                                                  left: 11),
                                                          child: Text(
                                                            extractFilename(
                                                                    data.url!)
                                                                .toString()
                                                                .split("-")
                                                                .last,
                                                            style:
                                                                const TextStyle(
                                                              color: chatColor,
                                                              fontSize: 14,
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
                              child: data.myMessage == false
                                  ? const SizedBox()
                                  : Icon(
                                      Icons.done_all,
                                      color: data.messageRead.toString() == "1"
                                          ? Colors.blue
                                          : Colors.grey.shade400,
                                      size: 15,
                                    ),
                            )
                          ],
                        ),
                      ),
                      data.myMessage == false
                          ? SizedBox(
                              child: timestpa(data.messageRead.toString(),
                                  data.createdAt!, data.isStarMessage!),
                            )
                          : SizedBox(
                              child: timestpa(data.messageRead.toString(),
                                  data.createdAt!, data.isStarMessage!),
                            )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget getVoiceMessageWidget(index, MessageList data) {
    return InkWell(
      onLongPress: () {
        if (chatID.isEmpty || chatMessageList.isEmpty) {
          msgDailogShow(data, data.senderData!);
        }
      },
      onTap: () {
        if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId.toString())
                ? chatID.remove(data.messageId.toString())
                : chatID.add(data.messageId.toString());

            chatMessageList.contains(data)
                ? chatMessageList.remove(data)
                : chatMessageList.add(data);

            print("MESSAGE_LISTTT:${chatMessageList.length}");
          });
        }
        print("ONTAPMSGID:$chatID");
      },
      child: Stack(
        children: [
          isSelectedmessage == "1"
              ? Positioned(
                  left: 10,
                  bottom: 35,
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          chatID.contains(data.messageId.toString())
                              ? chatID.remove(data.messageId.toString())
                              : chatID.add(data.messageId.toString());
                          chatMessageList.contains(data)
                              ? chatMessageList.remove(data)
                              : chatMessageList.add(data);
                        });
                        print("ONTAPMSGID:$chatID");
                      },
                      child: chatID.length == 0 || chatMessageList.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: chatID.contains(
                                          data.messageId.toString()) ||
                                      chatMessageList.contains(data)
                                  ? Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: bg1,
                                          gradient: LinearGradient(
                                              colors: [blackColor, black1Color],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter)),
                                      child:
                                          Image.asset("assets/images/right.png")
                                              .paddingAll(3))
                                  : Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border:
                                              Border.all(color: black1Color),
                                          color: bg1),
                                    ))),
                )
              : const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(
                left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                    ? data.myMessage == false
                        ? 40
                        : 0
                    : 10,
                right: 0,
                top: 0,
                bottom: 0),
            color: highlightedIndex == index &&
                    (isMsgHighLight || (widget.isMsgHighLight ?? false))
                ? secondaryColor
                : Colors.transparent,
            child: myVoiceWidget(data, index),
          ),
        ],
      ),
    );
  }

  Widget getGifMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? secondaryColor
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    data.myMessage == false
                        ? richText(
                            imageFile: data.senderData!.profileImage!,
                            fName: data.senderData!.firstName!,
                            lName: data.senderData!.lastName!)
                        : const SizedBox.shrink(),
                    data.myMessage == false
                        ? const SizedBox(height: 5)
                        : const SizedBox.shrink(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              curve: Curves.linear,
                              type: PageTransitionType.rightToLeft,
                              child: ImageView(
                                image: data.url!,
                                userimg: "",
                              )),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)),
                            color: data.myMessage == false
                                ? grey1Color
                                : secondaryColor),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: data.url!,
                                  imageBuilder: (context, imageProvider) =>
                                      Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                                data.myMessage == false
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        bottom: 3,
                                        right: 3,
                                        child: Icon(
                                          Icons.done_all,
                                          color:
                                              data.messageRead.toString() == "1"
                                                  ? Colors.blue
                                                  : Colors.grey.shade400,
                                          size: 15,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getStickerMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? secondaryColor
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              curve: Curves.linear,
                              type: PageTransitionType.rightToLeft,
                              child: ImageView(
                                image: data
                                    .url!, // Sticker URL is in message field
                                userimg: "",
                              )),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)),
                            color:
                                Colors.transparent), // Transparent for stickers
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: data
                                      .url!, // Sticker URL is in message field
                                  imageBuilder: (context, imageProvider) =>
                                      Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit
                                                .contain, // Contain for stickers to maintain aspect ratio
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.contain, // Contain for stickers
                                ),
                                data.myMessage == false
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        bottom: 3,
                                        right: 3,
                                        child: Icon(
                                          Icons.done_all,
                                          color:
                                              data.messageRead.toString() == "1"
                                                  ? chatownColor
                                                  : Colors.grey.shade400,
                                          size: 15,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getHttpLinkMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                        ? data.myMessage == false
                            ? 40
                            : 12
                        : 12,
                    right: 12,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? secondaryColor
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          data.myMessage == false
                              ? richText(
                                  imageFile: data.senderData!.profileImage!,
                                  fName: data.senderData!.firstName!,
                                  lName: data.senderData!.lastName!)
                              : const SizedBox.shrink(),
                          data.myMessage == false
                              ? const SizedBox(height: 5)
                              : const SizedBox.shrink(),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.width / 3.7,
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .8),
                                decoration: BoxDecoration(
                                    borderRadius: data.myMessage == false
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))
                                        : const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                    color: data.myMessage == false
                                        ? grey1Color
                                        : secondaryColor),
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 5, bottom: 5),
                                child: InkWell(
                                  onTap: () {
                                    launchURL(data.message!);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: FlutterLinkPreview(
                                          url: data.message!,
                                          builder: (info) {
                                            if (info is WebInfo) {
                                              return info.title == null &&
                                                      info.description == null
                                                  ? Text(
                                                      data.message!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: data.myMessage ==
                                                                false
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        if (info.image != null)
                                                          Container(
                                                            height: 58,
                                                            width: 57,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Image.network(
                                                                  info.image!,
                                                                  fit: BoxFit
                                                                      .cover),
                                                            ),
                                                          ),
                                                        const SizedBox(
                                                            width: 5),
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
                                                                    fontSize:
                                                                        14,
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
                                                                      fontSize:
                                                                          9,
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
                                          titleStyle: TextStyle(
                                            color: data.myMessage == false
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        data.message!,
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
                              data.myMessage == false
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: Icon(
                                        Icons.done_all,
                                        color:
                                            data.messageRead.toString() == "1"
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                        size: 15,
                                      ))
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());

              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 5,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                        ? data.myMessage == false
                            ? 35
                            : 10
                        : 3,
                    right: 3,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? secondaryColor
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          data.myMessage == false
                              ? richText(
                                  imageFile: data.senderData!.profileImage!,
                                  fName: data.senderData!.firstName!,
                                  lName: data.senderData!.lastName!)
                              : const SizedBox.shrink(),
                          data.myMessage == false
                              ? const SizedBox(height: 5)
                              : const SizedBox.shrink(),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .6),
                                decoration: BoxDecoration(
                                    borderRadius: data.myMessage == false
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                    color: data.myMessage == false
                                        ? grey1Color
                                        : secondaryColor),
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 200,
                                      decoration: BoxDecoration(
                                          borderRadius: matchContact(
                                                  data.sharedContactNumber!)
                                              ? BorderRadius.circular(10)
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
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
                                                        BorderRadius.circular(
                                                            35)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(35),
                                                  child:
                                                      CustomCachedNetworkImage(
                                                          imageUrl: data
                                                              .sharedContactProfileImage!,
                                                          placeholderColor:
                                                              chatownColor,
                                                          errorWidgeticon:
                                                              const Icon(
                                                            Icons.person,
                                                            size: 30,
                                                          )),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: Get.width * 0.30,
                                                    child: Text(
                                                      capitalizeFirstLetter(data
                                                          .sharedContactName!),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: chatColor),
                                                    ),
                                                  ),
                                                  Text(
                                                    data.sharedContactNumber!,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: chatColor),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          data.myMessage == false
                                              ? const SizedBox.shrink()
                                              : Positioned(
                                                  bottom: 3,
                                                  right: 3,
                                                  child: Icon(
                                                    Icons.done_all,
                                                    color: data.messageRead
                                                                .toString() ==
                                                            "1"
                                                        ? Colors.blue
                                                        : Colors.grey.shade400,
                                                    size: 15,
                                                  ))
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    InkWell(
                                      onTap: () {
                                        Get.to(() => SaveContact(
                                            name: data.sharedContactName!,
                                            number: data.sharedContactNumber!));
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                  data.myMessage == false
                                                      ? 0
                                                      : 7),
                                              bottomRight: Radius.circular(
                                                  data.myMessage == false
                                                      ? 7
                                                      : 0)),
                                          gradient: LinearGradient(
                                            colors: data.myMessage == true
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
                                              languageController.textTranslate(
                                                  'View contact'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: data.myMessage == true
                                                      ? appColorWhite
                                                      : appColorBlack),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget getReplyMessage(index, MessageList data) {
    return InkWell(
      onLongPress: () {
        if (chatID.isEmpty || chatMessageList.isEmpty) {
          msgDailogShow(data, data.senderData!);
        }
      },
      onTap: () {
        if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId.toString())
                ? chatID.remove(data.messageId.toString())
                : chatID.add(data.messageId.toString());

            chatMessageList.contains(data)
                ? chatMessageList.remove(data)
                : chatMessageList.add(data);

            print("MESSAGE_LISTTT:${chatMessageList.length}");
          });
        }
        print("ONTAPMSGID:$chatID");
      },
      child: replyMSGWidget(data, index, data.senderData!),
    );
  }

//================================================================= KEYBOARD =================================================================================

  bool click = false;

  Widget floatbuttonNew() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onTap: () {
                            isKeyboard = true;
                          },
                          maxLines: 4,
                          minLines: 1,
                          cursorColor: Colors.black,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                              color: isURL(messagecontroller.text.trim())
                                  ? const Color.fromARGB(255, 6, 6, 252)
                                  : Colors.black),
                          controller: messagecontroller,
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 5),
                              border: InputBorder.none,
                              hintText: languageController
                                  .textTranslate('Type Message'),
                              hintStyle: TextStyle(
                                  color: darkGreyColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
                              isDense: true),
                          onChanged: (value) {
                            setState(() {
                              if (value.trim().isEmpty) {
                                chatContorller.isTypingApi(
                                    widget.conversationID!, "0");

                                isSendbutton = false;
                                isHttpSendbutton = false;
                              } else if (isURL(value)) {
                                isSendbutton = true;
                                isHttpSendbutton = true;
                              } else {
                                isSendbutton = true;
                                isHttpSendbutton = false;
                              }
                              if (value.isNotEmpty &&
                                  isSendbutton &&
                                  typingstart == '0') {
                                print("START-TYPING-1");
                                typingstart = "1";
                                chatContorller.isTypingApi(
                                    widget.conversationID!, "1");
                                controller.isTyping();
                              }
                              typingTimer?.cancel();
                              startTypingTimer();
                              if (value.isNotEmpty &&
                                  isSendbutton &&
                                  typingstart == '0') {
                                print("START-TYPING-1");
                                typingstart = '1';
                                chatContorller.isTypingApi(
                                    widget.conversationID!, "1");
                                controller.isTyping();
                              }
                            });
                          },
                        ),
                      ),
                      Row(
                        children: [
                          // GestureDetector(
                          //   onTap: () {
                          //     chatContorller.showStickerPicker(
                          //         context,
                          //         widget.conversationID!,
                          //         widget.mobileNum.toString());
                          //   },
                          //   behavior: HitTestBehavior.opaque,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 8, horizontal: 5),
                          //     child: Image.asset(
                          //       "assets/icons/sticker_icon_chat.png",
                          //       height: 20,
                          //       color: darkGreyColor,
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 05),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                click = !click;
                                closekeyboard();
                              });
                            },
                            behavior: HitTestBehavior
                                .opaque, // Makes the entire container tappable
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 5),
                              child: Image.asset(
                                "assets/images/pin.png",
                                height: 20,
                                color: darkGreyColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              await _checkCameraPermission();
                              if (_isCameraPermissionGranted == false) {
                                // openAppSettings();
                                // If denied, show a message or retry
                                log("Permission denied. camera");
                              } else {
                                getImageFromCamera();
                                messagecontroller.clear();
                              }
                            },
                            child: Image.asset("assets/images/camera1.png",
                                height: 25, color: darkGreyColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                  onTap: () {
                    if (messagecontroller.text.isNotEmpty && isSendbutton) {
                      if (SelectedreplyText == true) {
                        try {
                          chatContorller.isSendMsg.value = true;
                          print(messagecontroller.text.trim());
                          print(widget.conversationID);
                          print('text');
                          print(widget.mobileNum);
                          chatContorller.sendMessageText(
                              messagecontroller.text.trim(),
                              widget.conversationID.toString(),
                              'text',
                              widget.mobileNum.toString(),
                              '',
                              reply_chatID);
                          SelectedreplyText = false;
                          chatContorller.isTypingApi(
                              widget.conversationID!, "0");
                          controller.isTyping();
                          typingstart = "0";
                          chatContorller.isSendMsg.value = false;
                          listScrollController!.jumpTo(
                              listScrollController!.position.minScrollExtent);
                        } catch (e) {
                          chatContorller.isSendMsg.value = false;
                          print(e);
                          showCustomToast(languageController
                              .textTranslate('Something Error1'));
                        }
                        messagecontroller.clear();
                      } else {
                        try {
                          chatContorller.isSendMsg.value = true;
                          print(messagecontroller.text.trim());
                          print(widget.conversationID);
                          print('text');
                          print(widget.mobileNum);
                          chatContorller.sendMessageText(
                              messagecontroller.text.trim(),
                              widget.conversationID.toString(),
                              'text',
                              widget.mobileNum.toString(),
                              '',
                              '');
                          chatContorller.isTypingApi(
                              widget.conversationID!, "0");
                          controller.isTyping();
                          typingstart = "0";
                          chatContorller.isSendMsg.value = false;
                          listScrollController!.jumpTo(
                              listScrollController!.position.minScrollExtent);
                        } catch (e) {
                          chatContorller.isSendMsg.value = false;
                          print(e);
                          showCustomToast("Something Error1");
                        }
                        messagecontroller.clear();
                      }
                    } else {
                      checkPermission();
                      bottoSheet();
                      closekeyboard();
                    }
                  },
                  child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              colors: [secondaryColor, chatownColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: messagecontroller.text.isNotEmpty && isSendbutton
                          ? Image.asset("assets/images/send.png",
                                  color: appColorWhite)
                              .paddingAll(12)
                          : Image.asset("assets/images/microphone-2.png",
                                  color: appColorWhite)
                              .paddingAll(12))),
            )
          ],
        ),
        // Platform.isIOS
        //     ? SizedBox(height: isKeyboard ? 20 : 30)
        //     : const SizedBox(height: 10),
        SizedBox(height: !click ? 30 : 0),
        click
            ? Container(
                height: 250,
                width: MediaQuery.of(context).size.width * 0.99,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // InkWell(
                          //   onTap: () {
                          //     getDocsFromLocal();
                          //     setState(() {
                          //       click = !click;
                          //     });
                          //   },
                          //   child: Container(
                          //     decoration: const BoxDecoration(
                          //         color: Colors.transparent),
                          //     child: Column(
                          //       children: [
                          //         Image.asset("assets/images/doc1.png",
                          //             color: secondaryColor, height: 50),
                          //         const SizedBox(height: 8),
                          //         Text(languageController.textTranslate('File'),
                          //             style: const TextStyle(
                          //                 color: chatColor,
                          //                 fontWeight: FontWeight.w400,
                          //                 fontSize: 13))
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  getDocsFromLocal();
                                  setState(() {
                                    click = !click;
                                  });
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: secondaryColor.withOpacity(0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                          'assets/images/document-text.png'),
                                    )),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageController.textTranslate('File'),
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )
                            ],
                          ),

                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  print("rplyType:$SelectedreplyText");
                                  getImageFromGallery1();
                                  setState(() {
                                    click = !click;
                                  });
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: secondaryColor.withOpacity(0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                          'assets/images/gallery1.png'),
                                    )),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageController.textTranslate('Photo'),
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )
                            ],
                          ),

                          // Container(
                          //   decoration:
                          //       const BoxDecoration(color: Colors.transparent),
                          //   child: Column(
                          //     children: [
                          //       InkWell(
                          //         onTap: () {
                          //           print("rplyType:$SelectedreplyText");
                          //           getImageFromGallery1();
                          //           setState(() {
                          //             click = !click;
                          //           });
                          //         },
                          //         child: Image(
                          //           height: 50,
                          //           image: const AssetImage(
                          //             'assets/images/photos.png',
                          //           ),
                          //           color: secondaryColor,
                          //         ),
                          //       ),
                          //       const SizedBox(
                          //         height: 8,
                          //       ),
                          //       Text(languageController.textTranslate('Photo'),
                          //           style: const TextStyle(
                          //               fontWeight: FontWeight.w400,
                          //               fontSize: 13))
                          //     ],
                          //   ),
                          // ),

                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  getImageFromGallery2();
                                  setState(() {
                                    click = !click;
                                  });
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: secondaryColor.withOpacity(0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                          'assets/images/video1.png'),
                                    )),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageController.textTranslate('Video'),
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )
                            ],
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     getImageFromGallery2();
                          //     setState(() {
                          //       click = !click;
                          //     });
                          //   },
                          //   child: Container(
                          //     decoration: const BoxDecoration(
                          //         color: Colors.transparent),
                          //     child: Column(
                          //       children: [
                          //         Image(
                          //           height: 50,
                          //           image: const AssetImage(
                          //             'assets/images/video_gallery.png',
                          //           ),
                          //           color: secondaryColor,
                          //         ),
                          //         const SizedBox(
                          //           height: 8,
                          //         ),
                          //         Text(
                          //             languageController.textTranslate('Video'),
                          //             style: const TextStyle(
                          //                 fontWeight: FontWeight.w400,
                          //                 fontSize: 13))
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  _selectGif();
                                  setState(() {
                                    click = !click;
                                  });
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: secondaryColor.withOpacity(0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child:
                                          Image.asset('assets/images/gif.png'),
                                    )),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageController.textTranslate('Gif'),
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )
                            ],
                          ),
                          // Container(
                          //   decoration:
                          //       const BoxDecoration(color: Colors.transparent),
                          //   child: Column(
                          //     children: [
                          //       InkWell(
                          //         onTap: () async {
                          //           _selectGif();
                          //           setState(() {
                          //             click = !click;
                          //           });
                          //         },
                          //         child: Image(
                          //           height: 50,
                          //           image: const AssetImage(
                          //             'assets/images/gif1.png',
                          //           ),
                          //           color: secondaryColor,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 10),
                          //       Text(languageController.textTranslate('Gif'),
                          //           style: const TextStyle(
                          //               fontWeight: FontWeight.w400,
                          //               fontSize: 13))
                          //     ],
                          //   ),
                          // ),

                          // Container(
                          //   decoration:
                          //       const BoxDecoration(color: Colors.transparent),
                          //   child: Column(
                          //     children: [
                          //       InkWell(
                          //         onTap: () async {
                          //           var status =
                          //               await Permission.location.status;

                          //           if (status.isDenied ||
                          //               status.isRestricted) {
                          //             status =
                          //                 await Permission.location.request();
                          //           }

                          //           if (status.isGranted) {
                          //             showPlacePicker();
                          //             setState(() {
                          //               click = !click;
                          //             });
                          //           } else if (status.isPermanentlyDenied) {
                          //             openAppSettings();
                          //           } else {
                          //             // Show a message if permission is denied
                          //             Fluttertoast.showToast(
                          //                 msg: languageController.textTranslate(
                          //                     'Location permission is required to pick a place.'));
                          //           }
                          //         },
                          //         child: Image(
                          //           height: 50,
                          //           image: const AssetImage(
                          //             'assets/images/loca1.png',
                          //           ),
                          //           color: secondaryColor,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 10),
                          //       Text(
                          //           languageController
                          //               .textTranslate('Location'),
                          //           style: const TextStyle(
                          //               fontWeight: FontWeight.w400,
                          //               fontSize: 13))
                          //     ],
                          //   ),
                          // ),

                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _checkLocationPermission();
                                  if (_isLocationPermissionGranted == false) {
                                    // openAppSettings();
                                    log("location permission not granted");
                                  } else {
                                    showPlacePicker();
                                    setState(() {
                                      click = !click;
                                    });
                                  }
                                  // var status = await Permission.location.status;

                                  // if (status.isDenied || status.isRestricted) {
                                  //   status =
                                  //       await Permission.location.request();
                                  // }

                                  // if (status.isGranted) {
                                  //   showPlacePicker();
                                  //   setState(() {
                                  //     click = !click;
                                  //   });
                                  // } else if (status.isPermanentlyDenied) {
                                  //   openAppSettings();
                                  // } else {
                                  //   // Show a message if permission is denied
                                  //   Fluttertoast.showToast(
                                  //       msg: languageController.textTranslate(
                                  //           'Location permission is required to pick a place.'));
                                  // }
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: secondaryColor.withOpacity(0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                          'assets/images/location2.png'),
                                    )),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageController.textTranslate('Location'),
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )
                            ],
                          ),
                          // InkWell(
                          //   onTap: () async {
                          //     var status = await Permission.location.status;

                          //     if (status.isDenied || status.isRestricted) {
                          //       status = await Permission.location.request();
                          //     }

                          //     if (status.isGranted) {
                          //       showPlacePicker();
                          //       setState(() {
                          //         click = !click;
                          //       });
                          //     } else if (status.isPermanentlyDenied) {
                          //       openAppSettings();
                          //     } else {
                          //       // Show a message if permission is denied
                          //       Fluttertoast.showToast(
                          //           msg: languageController.textTranslate(
                          //               'Location permission is required to pick a place.'));
                          //     }
                          //   },
                          //   child: Container(
                          //     decoration: const BoxDecoration(
                          //         color: Colors.transparent),
                          //     child: const Image(
                          //       height: 82,
                          //       image: AssetImage(
                          //         'assets/images/loca1.png',
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          Column(
                            children: [
                              InkWell(
                                // onTap: () {
                                //   setState(() {
                                //     click = !click;
                                //   });
                                //   Get.to(
                                //           () => ContactSend(
                                //                 conversationID:
                                //                     widget.conversationID!,
                                //                 mobileNum:
                                //                     widget.mobileNum.toString(),
                                //                 SelectedreplyText:
                                //                     SelectedreplyText,
                                //                 replyID: reply_chatID,
                                //               ),
                                //           transition: Transition.leftToRight)!
                                //       .then((_) {
                                //     listScrollController!.jumpTo(
                                //         listScrollController!
                                //             .position.minScrollExtent);
                                //   });
                                // },
                                onTap: () {
                                  setState(() {
                                    click = !click;
                                  });

                                  // First check contact permission
                                  PermissionUtil.checkContactPermission()
                                      .then((permissionGranted) {
                                    if (permissionGranted) {
                                      // Permission is granted, proceed with navigation
                                      Get.to(
                                              () => ContactSend(
                                                    conversationID:
                                                        widget.conversationID!,
                                                    mobileNum: widget.mobileNum
                                                        .toString(),
                                                    SelectedreplyText:
                                                        SelectedreplyText,
                                                    replyID: reply_chatID,
                                                  ),
                                              transition:
                                                  Transition.leftToRight)!
                                          .then((_) {
                                        listScrollController!.jumpTo(
                                            listScrollController!
                                                .position.minScrollExtent);
                                      });
                                    } else {
                                      // Permission not granted, show dialog
                                      PermissionUtil
                                          .showPermissionSettingsDialog(
                                              context,
                                              "Contact",
                                              languageController.textTranslate,
                                              chatownColor,
                                              secondaryColor);
                                    }
                                  });
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: secondaryColor.withOpacity(0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                          'assets/images/contact.png'),
                                    )),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageController.textTranslate('Contact'),
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )
                            ],
                          ),

                          // Container(
                          //   decoration:
                          //       const BoxDecoration(color: Colors.transparent),
                          //   child: Column(
                          //     children: [
                          //       InkWell(
                          //         onTap: () {
                          //           setState(() {
                          //             click = !click;
                          //           });
                          //           Get.to(
                          //                   () => ContactSend(
                          //                         conversationID:
                          //                             widget.conversationID!,
                          //                         mobileNum: widget.mobileNum
                          //                             .toString(),
                          //                         SelectedreplyText:
                          //                             SelectedreplyText,
                          //                         replyID: reply_chatID,
                          //                       ),
                          //                   transition: Transition.leftToRight)!
                          //               .then((_) {
                          //             listScrollController!.jumpTo(
                          //                 listScrollController!
                          //                     .position.minScrollExtent);
                          //           });
                          //         },
                          //         child: Image(
                          //           height: 50,
                          //           image: const AssetImage(
                          //             'assets/images/cont1.png',
                          //           ),
                          //           color: secondaryColor,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 10),
                          //       Text(
                          //           languageController.textTranslate('Contact'),
                          //           style: const TextStyle(
                          //               fontWeight: FontWeight.w400,
                          //               fontSize: 13))
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    )
                  ],
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Widget floatbutton1() {
    return chatID.isEmpty
        ? floatbuttonNew()
        : Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                  curve: Curves.linear,
                                  type: PageTransitionType.bottomToTop,
                                  child: ForwardMessage(
                                    chatid: chatID
                                        .toString()
                                        .removeAllWhitespace
                                        .replaceAll(']', '')
                                        .replaceAll('[', ''),
                                    isMsgType: true,
                                    forwardMsgList: chatMessageList,
                                  ),
                                ));
                            chatMessageList = [];
                          },
                          child: Image.asset("assets/images/forward.png",
                              height: 20, color: chatColor),
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          chatID.length.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Selected',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    )),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelectedmessage = "0";
                                chatID = [];
                                chatMessageList = [];
                              });
                            },
                            child: Text(
                              languageController.textTranslate('Cancel'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue),
                            )))
                  ],
                ),
                click
                    ? Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.99,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(00.0),
                                  topLeft: Radius.circular(00.0))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey[200],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        getDocsFromLocal();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent),
                                        child: Column(
                                          children: [
                                            Container(
                                                height: 50,
                                                width: 50,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: bg1),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Image(
                                                    image: AssetImage(
                                                      'assets/images/paperclip-2.png',
                                                    ),
                                                    color: chatColor,
                                                  ),
                                                )),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                                languageController
                                                    .textTranslate('File'),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14))
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              getImageFromGallery1();
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: bg1),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Image(
                                                  image: AssetImage(
                                                    'assets/images/gallery_1.png',
                                                  ),
                                                  color: chatColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                              languageController
                                                  .textTranslate('Photo'),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await _checkCameraPermission();
                                              if (_isCameraPermissionGranted ==
                                                  false) {
                                                // openAppSettings();
                                                log("Permission denied. camera");
                                              } else {
                                                Navigator.pop(context);
                                                getImageFromCamera();
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: bg1),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Image(
                                                  image: AssetImage(
                                                    'assets/images/camera_1.png',
                                                  ),
                                                  color: chatColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                              languageController
                                                  .textTranslate('Camera'),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        getImageFromGallery1();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: bg1),
                                              child: const Padding(
                                                padding: EdgeInsets.all(13.0),
                                                child: Image(
                                                    image: AssetImage(
                                                      'assets/images/video_1.png',
                                                    ),
                                                    color: chatColor),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                                languageController
                                                    .textTranslate('Video'),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14))
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              _selectGif();
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: bg1),
                                              child: Center(
                                                  child: Text(
                                                languageController
                                                    .textTranslate('GIF'),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: chatColor),
                                              )),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                              languageController
                                                  .textTranslate('Gif'),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14))
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        showPlacePicker();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: bg1),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: Image(
                                                  image: AssetImage(
                                                    'assets/images/location_1.png',
                                                  ),
                                                  color: chatColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                                languageController
                                                    .textTranslate('Location'),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          );
  }

//============================================================= AUDIO PLAYER VOICE MESSAGE ===============================================================
//============================================================= AUDIO PLAYER VOICE MESSAGE ===============================================================
//============================================================= AUDIO PLAYER VOICE MESSAGE ===============================================================
  String recordFilePath = '';
  String audioPath = '';
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  int i = 0;
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }

  Future<void> startRecord() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
      } else {
        showCustomToast(
            languageController.textTranslate('No microphone permission'));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Strat recording Error :::$e');
      }
    }
  }

  Future<void> stopRecord({bool isCancel = false}) async {
    try {
      String? path = await audioRecord.stop();
      audioController.end.value = DateTime.now();
      audioController.calcDuration();
      setState(() {
        audioPath = path!;
        audioPath;
        if (kDebugMode) {
          print("audiopath --> $audioPath");
        }
        if (isCancel == false) {
          if (SelectedreplyText == true) {
            chatContorller.sendMessageVoice(
                widget.conversationID!,
                "audio",
                File(audioPath),
                '',
                audioController.total,
                widget.mobileNum.toString(),
                '',
                reply_chatID,
                false);
            SelectedreplyText = false;
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
          } else {
            chatContorller.sendMessageVoice(
                widget.conversationID!,
                "audio",
                File(audioPath),
                '',
                audioController.total,
                widget.mobileNum.toString(),
                '',
                '',
                false);
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Stop recording Error :::$e');
      }
    }
  }

  void stopTimer() {
    seconds = 0;
    newtimer?.cancel();
  }

  bool button = false;

  _cancle() async {
    record = false;
    setState(() {
      button = false;
      record = false;
      record = false;
    });
  }

  bool record = false;
  int seconds = 0;
  Timer? newtimer;

  Future bottoSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.white,
        elevation: 0,
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState1) {
            void startTimer() {
              const oneSec = Duration(seconds: 1);
              newtimer = Timer.periodic(
                oneSec,
                (Timer timer) => setState(
                  () {
                    setState1(() {
                      seconds += 1;
                    });
                  },
                ),
              );
            }

            String formatTime(int seconds) {
              int minutes = seconds ~/ 60;
              int remainingSeconds = seconds % 60;
              return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
            }

            return SizedBox(
              width: Get.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      formatTime(
                        seconds,
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      record == true
                          ? lt.Lottie.asset(
                              'assets/Lottie ANIMATION/voice_record_animation.json',
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(
                              height: 120,
                              width: 120,
                            ),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            color: chatColor),
                        child: Center(
                            child: Image.asset("assets/images/microphone-2.png",
                                height: 40, color: Colors.white)),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      if (record) {
                        setState1(() {
                          record = false;
                        });
                        stopTimer();
                        stopRecord();
                        Navigator.pop(context);
                        print("44444");
                      } else {
                        var audioPlayer = AudioPlayer();
                        await audioPlayer
                            .play(AssetSource("audio/notification.wav"));
                        audioPlayer.onPlayerComplete.listen((a) {
                          setState1(() {
                            record = true;
                          });
                          audioController.start.value = DateTime.now();

                          startTimer();
                          startRecord();
                          audioController.isRecording.value = true;
                        });
                      }
                    },
                    child: Container(
                      width: 110,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                              colors: [secondaryColor, chatownColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: Center(
                        child: Text(
                          record
                              ? languageController.textTranslate('Send')
                              : languageController.textTranslate('Start'),
                          style: const TextStyle(color: appColorWhite),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () async {
                      stopRecord(isCancel: true);
                      stopTimer();
                      _cancle();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 110,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                              colors: [secondaryColor, chatownColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: Center(
                        child: Text(
                          languageController.textTranslate('Cancel'),
                          style: const TextStyle(color: appColorWhite),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget myVoiceWidget(MessageList data, index) {
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
      child: Column(
        children: [
          Align(
            alignment: (data.myMessage == false
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Column(
              crossAxisAlignment: data.myMessage == false
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                data.myMessage == false
                    ? richText(
                        imageFile: data.senderData!.profileImage!,
                        fName: data.senderData!.firstName!,
                        lName: data.senderData!.lastName!)
                    : const SizedBox.shrink(),
                data.myMessage == false
                    ? const SizedBox(height: 5)
                    : const SizedBox.shrink(),
                data.replyId == 0
                    ? _audio(
                        message: data.url!,
                        isCurrentUser: data.myMessage == false,
                        index: index,
                        duration: data.audioTime!,
                        data: data,
                      )
                    : _audioReply(
                        message: data.url!,
                        isCurrentUser: data.myMessage == false,
                        index: index,
                        duration: data.audioTime!),
                data.replyId == 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                    : const SizedBox.shrink()
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _audio({
    required String message,
    required bool isCurrentUser,
    required int index,
    required String duration,
    required MessageList data,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: isCurrentUser
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))
              : const BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
          color: isCurrentUser ? grey1Color : secondaryColor),
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
                            color: isCurrentUser ? grey1Color : secondaryColor,
                          )
                        : Icon(
                            CupertinoIcons.play_circle_fill,
                            color: isCurrentUser ? grey1Color : secondaryColor,
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
            child: data.myMessage == false
                ? const SizedBox()
                : Icon(
                    Icons.done_all,
                    color: data.messageRead.toString() == "1"
                        ? Colors.blue
                        : Colors.grey.shade400,
                    size: 15,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _audioReply({
    required String message,
    required bool isCurrentUser,
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
    );
  }

//================================================================== IMAGE SELECT FROM CAMERA =============================================
//================================================================== IMAGE SELECT FROM CAMERA =============================================
//================================================================== IMAGE SELECT FROM CAMERA =============================================
  final picker = ImagePicker();
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() async {
      if (pickedFile != null) {
        File image = File(pickedFile.path);
        final dir = await getTemporaryDirectory();
        final targetPath =
            "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        return FlutterImageCompress.compressAndGetFile(
          image.absolute.path,
          targetPath,
          quality: 50,
        ).then((value) {
          if (SelectedreplyText == true) {
            chatContorller.sendMessageIMGDoc(
                widget.conversationID,
                'image',
                value!.path,
                widget.mobileNum.toString(),
                '',
                reply_chatID,
                false);
            SelectedreplyText = false;
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
          } else {
            chatContorller.sendMessageIMGDoc(widget.conversationID, 'image',
                value!.path, widget.mobileNum.toString(), '', '', false);
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
          }
        });
      } else {}
    });
  }

//================================================================== IMAGE SELECT FROM GALLERY ============================================
  Future getImageFromGallery1() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowCompression: true,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      File image = File(pickedFile.files.single.path!);
      if (image.lengthSync() > 10 * 1024 * 1024) {
        showCustomToast("Selected image file size should be less than 10MB");
        return;
      } else {
        final dir = await getTemporaryDirectory();
        final targetPath =
            "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        return FlutterImageCompress.compressAndGetFile(
          image.absolute.path,
          targetPath,
          quality: 50,
        ).then((value) async {
          print("Compressed");
          print("RPLY:$SelectedreplyText");
          print(reply_chatID);
          if (SelectedreplyText == true) {
            chatContorller.sendMessageIMGDoc(
                widget.conversationID,
                'image',
                value!.path,
                widget.mobileNum.toString(),
                '',
                reply_chatID,
                false);
            SelectedreplyText = false;
          } else {
            chatContorller.sendMessageIMGDoc(widget.conversationID, 'image',
                value!.path, widget.mobileNum.toString(), '', '', false);
          }
        });
      }
    }
  }

//=================================================================== DOC SELECT FROM GALLERY =============================================
  File? doc;
  Future getDocsFromLocal() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf", "doc", "docx"],
        allowCompression: true,
        allowMultiple: false);

    setState(() {
      if (pickedFile != null) {
        doc = File(pickedFile.files.single.path!);

        if (SelectedreplyText == true) {
          chatContorller.sendMessageIMGDoc(widget.conversationID, 'document',
              doc!.path, widget.mobileNum.toString(), '', reply_chatID, false);
          SelectedreplyText = false;
        } else {
          chatContorller.sendMessageIMGDoc(widget.conversationID, 'document',
              doc!.path, widget.mobileNum.toString(), '', '', false);
        }
      } else {}
    });
  }

//============================================================= VIDEO SELECT FROM GALLERY ==============================================
  File? video;
  String? filePath;
  String compressedVideoPath = '';

  compressVideo() async {
    int fileSizeInBytes = video!.lengthSync();

    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    print('File Size: $fileSizeInMB MB');

    if (fileSizeInMB > 20.0) {
      print("¸ $filePath");

      final LightCompressor lightCompressor = LightCompressor();
      final Result response = await lightCompressor.compressVideo(
        path: filePath!,
        videoQuality: VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        video: Video(videoName: path.basename(filePath!)),
        android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
        ios: IOSConfig(saveInGallery: false),
      );

      if (response is OnSuccess) {
        final String outputFile = response.destinationPath;
        compressedVideoPath = outputFile;

        print('SUCESS');
        print("Response is Success");
      } else if (response is OnFailure) {
        print("FAILURE ${response.message}");
        compressedVideoPath = video!.absolute.path;
        print("Response is Failure");
      } else if (response is OnCancelled) {
        print("CANCELLED ${response.isCancelled}");
        print("Response is Cancelled");
      }
      print('RESPONS IS $response');

      print("compressedVideoPath $compressedVideoPath");
      setState(() {});
    } else {
      compressedVideoPath = video!.absolute.path;
      print("else pathcompress--->$compressedVideoPath");
    }
  }

  List compressedVideos = [];

  Future<void> getImageFromGallery2() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowCompression: true,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      chatContorller.isSendMsg.value = true;
      File image = File(pickedFile.files.single.path!);

      if (image.path.toLowerCase().endsWith(".mp4") ||
          image.path.toLowerCase().endsWith(".mov") ||
          image.path.toLowerCase().endsWith(".wmv") ||
          image.path.toLowerCase().endsWith(".avi") ||
          image.path.toLowerCase().endsWith(".mkv") ||
          image.path.toLowerCase().endsWith(".h.264") ||
          image.path.toLowerCase().endsWith(".hevc")) {
        filePath = image.path;
        video = image;

        await compressVideo();

        final value = await VideoThumbnail.thumbnailFile(
                video: filePath!, imageFormat: ImageFormat.PNG, quality: 100)
            .then((value) => value);
        print('Thumbnail Value is $value');

        compressedVideos = [compressedVideoPath, value];

        if (SelectedreplyText == true) {
          chatContorller.sendMessageVideo(
              widget.conversationID,
              "video",
              compressedVideos,
              widget.mobileNum.toString(),
              '',
              reply_chatID,
              false);
          SelectedreplyText = false;
          listScrollController!
              .jumpTo(listScrollController!.position.minScrollExtent);
        } else {
          chatContorller.sendMessageVideo(widget.conversationID, "video",
              compressedVideos, widget.mobileNum.toString(), '', '', false);
          listScrollController!
              .jumpTo(listScrollController!.position.minScrollExtent);
        }
      } else {
        print("Selected file is not a supported video format");
      }
    }
  }

//============================================ GIF SELECT =============================================================
  void _selectGif() async {
    const giphyApiKey = 'M74S0wxPj9sOl30judPKMjTU6GkmmjpC';

    final gif = await Giphy.getGif(
        context: context,
        apiKey: giphyApiKey,
        type: GiphyType.gifs,
        rating: GiphyRating.g,
        lang: GiphyLanguage.english,
        keepState: true,
        showPreview: true,
        searchHintText: "search",
        usePlatformBottomSheet: true,
        gridSpacing: 4.0,
        gridType: GridType.squareFixedColumns);

    if (gif != null) {
      chatContorller.isSendMsg.value = true;
      setState(() {
        downloadAndSaveGif(gif.images.original!.url);
        print("SELECTED_GIF:_${gif.images.original!.url}");
      });
      WidgetsBinding.instance.addPostFrameCallback((duration) {});
    }
  }

  void downloadAndSaveGif(String gifUrl) async {
    try {
      http.Response response = await http.get(Uri.parse(gifUrl));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        if (SelectedreplyText == true) {
          chatContorller.sendMessageGIF(widget.conversationID, 'gif', bytes, '',
              widget.mobileNum.toString(), '', reply_chatID);
          SelectedreplyText = false;
          listScrollController!
              .jumpTo(listScrollController!.position.minScrollExtent);
        } else {
          chatContorller.sendMessageGIF(widget.conversationID, 'gif', bytes, '',
              widget.mobileNum.toString(), '', '');
          listScrollController!
              .jumpTo(listScrollController!.position.minScrollExtent);
        }

        print(bytes.toString());
      } else {
        print('Error downloading GIF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading or saving GIF: $e');
    }
  }

//=============================================== LOCATION SELECT FROM GOOGLE =================================================================
  String? _address;
  String? _placeLat;
  String? _placeLong;

  // void showPlacePicker() async {
  //   LocationResult result = await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => PlacePicker(
  //         "AIzaSyAMZ4GbRFYSevy7tMaiH5s0JmMBBXc0qBA",
  //       ),
  //     ),
  //   );

  //   setState(() {
  //     _address = result.formattedAddress.toString();
  //     _placeLat = result.latLng!.latitude.toString();
  //     _placeLong = result.latLng!.longitude.toString();
  //   });
  //   if (SelectedreplyText == true) {
  //     chatContorller.sendMessageLocation(
  //         widget.conversationID!,
  //         "location",
  //         _placeLat!,
  //         _placeLong!,
  //         widget.mobileNum.toString(),
  //         '',
  //         reply_chatID);
  //     SelectedreplyText = false;
  //   } else {
  //     chatContorller.sendMessageLocation(widget.conversationID!, "location",
  //         _placeLat!, _placeLong!, widget.mobileNum.toString(), '', '');
  //   }
  // }

  void showPlacePicker() async {
    // Define custom theme for PlacePicker
    final customTheme = ThemeData(
      primaryColor: Colors.blue, // Change this to your app's primary color
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      // inputDecorationTheme: InputDecorationTheme(
      //   filled: true,
      //   fillColor: Colors.grey[100],
      //   border: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: BorderSide.none,
      //   ),
      //   focusedBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: BorderSide(color: Colors.blue, width: 2),
      //   ),
      // ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );

    LocationResult? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Theme(
          data: customTheme, // Apply the custom theme
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('Select Location'),
              automaticallyImplyLeading: true,
              // Custom back button can be re-enabled if needed
              // leading: IconButton(
              //   icon: Icon(Icons.arrow_back),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ),
            body: PlacePicker(
              "AIzaSyAMZ4GbRFYSevy7tMaiH5s0JmMBBXc0qBA",
            ),
          ),
        ),
      ),
    );

    // Only update state if a result was returned (not null)
    if (result != null) {
      setState(() {
        _address = result.formattedAddress.toString();
        _placeLat = result.latLng!.latitude.toString();
        _placeLong = result.latLng!.longitude.toString();
      });

      if (SelectedreplyText == true) {
        chatContorller.sendMessageLocation(
            widget.conversationID!,
            "location",
            _placeLat!,
            _placeLong!,
            widget.mobileNum.toString(),
            '',
            reply_chatID);
        SelectedreplyText = false;
        listScrollController!
            .jumpTo(listScrollController!.position.minScrollExtent);
      } else {
        chatContorller.sendMessageLocation(widget.conversationID!, "location",
            _placeLat!, _placeLong!, widget.mobileNum.toString(), '', '');
        listScrollController!
            .jumpTo(listScrollController!.position.minScrollExtent);
      }
    }
  }

//===========================================================                   ====================================================================================
//=========================================================== LONG PRESS DAILOG ====================================================================================
//===========================================================                   ====================================================================================
  String replyText = '';
  String reply_chatID = '';
  String USERTEXT = '';
  bool SelectedreplyText = false;
  String rplyTime = '';
  Future msgDailogShow(MessageList data, SenderData users) {
    bool isAlreadyPinned =
        pinMessageController.isMessagePinned(data.messageId.toString());
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            insetPadding: const EdgeInsets.all(15),
            alignment: Alignment.bottomCenter,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: bg1,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  data.messageType == "location"
                      ? "📌 ${languageController.textTranslate('Location')}"
                      : data.messageType == "video"
                          ? "🎥 ${languageController.textTranslate('Video')}"
                          : data.messageType == "image"
                              ? capitalizeFirstLetter(
                                  "📷 ${languageController.textTranslate('Photo')}")
                              : data.messageType == "document"
                                  ? capitalizeFirstLetter("📄 Documenet")
                                  : data.messageType == "audio"
                                      ? capitalizeFirstLetter(
                                          "🔊 ${languageController.textTranslate('Voice message')}")
                                      : data.messageType == "link"
                                          ? capitalizeFirstLetter(data.message!)
                                          : data.messageType == "gif"
                                              ? languageController
                                                  .textTranslate('GIF')
                                              : data.messageType == "contact"
                                                  ? languageController
                                                      .textTranslate('Contact')
                                                  : capitalizeFirstLetter(
                                                      data.message!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: chatColor,
                  ),
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                data.messageType != "location" &&
                        data.messageType != "image" &&
                        data.messageType != "video" &&
                        data.messageType != "document" &&
                        data.messageType != "audio" &&
                        data.messageType != "gif" &&
                        data.messageType != "contact"
                    ? SizedBox(
                        height: 45,
                        child: InkWell(
                          onTap: () {
                            setState(() {});
                            Navigator.pop(context);
                            Clipboard.setData(
                                ClipboardData(text: data.message!));
                            showCustomToast("Message copied");
                          },
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              Image.asset("assets/images/copy.png",
                                  height: 18, color: chatColor),
                              const SizedBox(width: 10),
                              Text(
                                languageController.textTranslate('Copy'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            ],
                          ),
                        ))
                    : const SizedBox.shrink(),
                data.messageType != "location" &&
                        data.messageType != "image" &&
                        data.messageType != "video" &&
                        data.messageType != "docdocument" &&
                        data.messageType != "audio" &&
                        data.messageType != "gif" &&
                        data.messageType != "contact"
                    ? Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[200],
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                    height: 45,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          SelectedreplyText = !SelectedreplyText;
                          USERTEXT = data.myMessage == false
                              ? "${users.firstName} ${users.lastName!}"
                              : languageController.textTranslate('You');
                          replyText = (data.messageType == "text"
                              ? data.message
                              : data.messageType == "location"
                                  ? "📌 ${languageController.textTranslate('Location')}"
                                  : data.messageType == "image"
                                      ? "📷 ${languageController.textTranslate('Photo')}"
                                      : data.messageType == "video"
                                          ? "🎥 ${languageController.textTranslate('Video')}"
                                          : data.messageType == "docdocument"
                                              ? "📄 Documenet"
                                              : data.messageType == "audio"
                                                  ? "🔊 ${languageController.textTranslate('Voice message')}"
                                                  : data.messageType == "gif"
                                                      ? languageController
                                                          .textTranslate('GIF')
                                                      : data.messageType ==
                                                              "sticker"
                                                          ? languageController
                                                              .textTranslate(
                                                                  'STICKER')
                                                          : data.messageType ==
                                                                  "contact"
                                                              ? languageController
                                                                  .textTranslate(
                                                                      'Contact')
                                                              : data.message)!;
                          reply_chatID = data.messageId.toString();

                          print("TEXT:$replyText");
                          print("RPLYTIME:$rplyTime");
                          print("RPLY$SelectedreplyText");
                          print("SELECT_MSG_ID:$reply_chatID");
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Image.asset("assets/images/reply.png",
                              height: 18, color: chatColor),
                          const SizedBox(width: 10),
                          Text(
                            languageController.textTranslate('Reply'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    )),
                data.messageType == "sticker"
                    ? SizedBox()
                    : Column(
                        children: [
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          SizedBox(
                            height: 45,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  chatID.add(data.messageId.toString());
                                  chatMessageList.add(data);
                                  isSelectedmessage = "1";
                                  print("MSGID:${data.messageId}");
                                  print(
                                      "MESSAGE_LIST:${chatMessageList.length}");
                                });
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Image.asset("assets/images/forward1.png",
                                      height: 18, color: chatColor),
                                  const SizedBox(width: 10),
                                  Text(
                                    languageController.textTranslate('Forward'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
                SizedBox(
                  height: 45,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        chatID.add(data.messageId.toString());
                        chatMessageList.add(data);
                        isSelectedmessage = "1";
                        print("MSGID:${data.messageId}");
                        print("MESSAGE_LIST:$chatMessageList");
                      });
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Image.asset("assets/images/trash1.png",
                            height: 18, color: chatColor),
                        const SizedBox(width: 10),
                        Text(
                          languageController.textTranslate('Delete'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
                SizedBox(
                  height: 45,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      if (data.isStarMessage != false) {
                        print("******");
                        chatContorller.removeStarApi(data.messageId.toString());
                      } else {
                        chatContorller.addStarApi(
                          data.messageId.toString(),
                          widget.conversationID,
                        );
                        print("+++++++");
                      }
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        data.isStarMessage != false
                            ? Image.asset("assets/images/star-slash.png",
                                color: chatColor, height: 18)
                            : Image.asset("assets/images/starUnfill.png",
                                color: chatColor, height: 18),
                        const SizedBox(width: 10),
                        Text(
                          data.isStarMessage != false
                              ? languageController
                                  .textTranslate('Unstar Message')
                              : languageController
                                  .textTranslate('Star Message'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                SizedBox(
                  height: 45,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      if (isAlreadyPinned) {
                        // If already pinned, unpin it
                        pinMessageController.removePinMessage(
                          widget.conversationID!,
                          data.messageId.toString(),
                        );
                      } else {
                        // If not pinned, show the pin dialog
                        showPinMessageDialog(
                          context,
                          data.messageId.toString(),
                          widget.conversationID!,
                          pinMessageController,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(
                          !isAlreadyPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                          color: chatColor,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isAlreadyPinned
                              ? languageController
                                  .textTranslate('Unpin Message')
                              : languageController.textTranslate('Pin Message'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                SizedBox(
                  height: 45,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      // Show message report popup
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return MessageReportPopup(
                            messageId: data.messageId.toString(),
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.report,
                          color: chatColor,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          languageController.textTranslate('Report this'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//=============================================================                      =======================================================================
//============================================================= REPLY MESSAGE DESIGN =======================================================================
//=============================================================                      =======================================================================
// belowe login to set messageid and reply id same to show message type
  String isMatching(String msgID) {
    for (int i = 0;
        i < chatContorller.userdetailschattModel.value!.messageList!.length;
        i++) {
      if (chatContorller
              .userdetailschattModel.value!.messageList![i].messageId ==
          int.parse(msgID)) {
        if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "text") {
          return chatContorller
              .userdetailschattModel.value!.messageList![i].message!;
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "image") {
          return "📷 ${languageController.textTranslate('Photo')}";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "location") {
          return "📌 Location";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "document") {
          return "📄 ${languageController.textTranslate('Document')}";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "video") {
          return "🎥 ${languageController.textTranslate('Video')}";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "audio") {
          return "🔊 ${languageController.textTranslate('Audio')}";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "link") {
          return chatContorller
              .userdetailschattModel.value!.messageList![i].message!;
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "gif") {
          return languageController.textTranslate('GIF');
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "contact") {
          return languageController.textTranslate('Contact');
        }
      }
    }
    return "message removed";
  }

// belowe logic to set who's message replied user name show
  String isUserMatch(String msgID, int userID) {
    for (var i = 0;
        i < chatContorller.userdetailschattModel.value!.messageList!.length;
        i++) {
      if (chatContorller
              .userdetailschattModel.value!.messageList![i].messageId ==
          int.parse(msgID)) {
        if (chatContorller.userdetailschattModel.value!.messageList![i]
                .senderData!.userId ==
            userID) {
          if ("${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}" ==
              "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}") {
            return languageController.textTranslate('You');
          } else {
            return "${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}";
          }
        } else {
          if ("${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}" ==
              "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}") {
            return languageController.textTranslate('You');
          } else {
            return "${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}";
          }
        }
      }
    }
    return languageController.textTranslate('You');
  }

  Widget replyMSGWidget(MessageList data, int index, SenderData users) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          isSelectedmessage == "1"
              ? Positioned(
                  left: 10,
                  bottom: 35,
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          chatID.contains(data.messageId.toString())
                              ? chatID.remove(data.messageId.toString())
                              : chatID.add(data.messageId.toString());
                          chatMessageList.contains(data)
                              ? chatMessageList.remove(data)
                              : chatMessageList.add(data);
                        });
                        print("ONTAPMSGID:$chatID");
                      },
                      child: chatID.length == 0 || chatMessageList.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: chatID.contains(
                                          data.messageId.toString()) ||
                                      chatMessageList.contains(data)
                                  ? Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: bg1,
                                          gradient: LinearGradient(
                                              colors: [blackColor, black1Color],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter)),
                                      child:
                                          Image.asset("assets/images/right.png")
                                              .paddingAll(3))
                                  : Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border:
                                              Border.all(color: black1Color),
                                          color: bg1),
                                    ))),
                )
              : const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(
                left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                    ? data.myMessage == false
                        ? 40
                        : 12
                    : 12,
                right: 12,
                top: 0,
                bottom: 0),
            color: highlightedIndex == index &&
                    (isMsgHighLight || (widget.isMsgHighLight ?? false))
                ? secondaryColor
                : Colors.transparent,
            child: Column(
              children: [
                Align(
                  alignment: (data.myMessage == false
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Column(
                    crossAxisAlignment: data.myMessage == false
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      data.myMessage == false
                          ? richText(
                              imageFile: data.senderData!.profileImage!,
                              fName: data.senderData!.firstName!,
                              lName: data.senderData!.lastName!)
                          : const SizedBox.shrink(),
                      data.myMessage == false
                          ? const SizedBox(height: 5)
                          : const SizedBox.shrink(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .6),
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, top: 0, bottom: 0),
                            decoration: BoxDecoration(
                                borderRadius: data.myMessage == false
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10))
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                color: data.myMessage == false
                                    ? grey1Color
                                    : secondaryColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    for (int i = 0;
                                        i <
                                            chatContorller.userdetailschattModel
                                                .value!.messageList!.length;
                                        i++) {
                                      if (chatContorller
                                              .userdetailschattModel
                                              .value!
                                              .messageList![i]
                                              .messageId ==
                                          data.replyId) {
                                        gotoindex = i;
                                        _scrollToIndex(gotoindex, callback: () {
                                          setState(() {
                                            highlightedIndex = gotoindex;
                                            isMsgHighLight = true;
                                          });
                                          Timer(const Duration(seconds: 2), () {
                                            setState(() {
                                              isMsgHighLight = false;
                                            });
                                          });
                                        });
                                        print("GOTOINDEX: $gotoindex");
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, top: 5),
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
                                            RichText(
                                                textAlign: TextAlign.start,
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text: isUserMatch(
                                                        data.replyId.toString(),
                                                        users.userId!),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black),
                                                  )
                                                ])),
                                            const SizedBox(height: 5),
                                            Text(
                                              isMatching(
                                                  data.replyId.toString()),
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: data.messageType == "text"
                                      ? Text(
                                          data.message!,
                                          style: TextStyle(
                                              color: data.myMessage == false
                                                  ? appColorBlack
                                                  : appColorWhite),
                                        ).paddingOnly(
                                          left: 15,
                                          top: 5,
                                          bottom: 5,
                                        )
                                      : data.messageType == "document"
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      curve: Curves.linear,
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                      child: FileView(
                                                          file: data.url!),
                                                    ));
                                              },
                                              child: Row(
                                                children: [
                                                  const Image(
                                                    height: 30,
                                                    image: AssetImage(
                                                        'assets/images/pdf.png'),
                                                  ),
                                                  Expanded(
                                                    child: FutureBuilder<
                                                        Map<String, dynamic>>(
                                                      future:
                                                          getPdfInfo(data.url!),
                                                      builder:
                                                          (context, snapshot) {
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
                                                                extractFilename(
                                                                        data.url!)
                                                                    .toString()
                                                                    .split("-")
                                                                    .last,
                                                                style:
                                                                    const TextStyle(
                                                                  color:
                                                                      chatColor,
                                                                  fontSize: 14,
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
                                                                  fontSize: 10,
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
                                                          return const Text('');
                                                        } else if (snapshot
                                                            .hasData) {
                                                          final int pageCount =
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
                                                                  fontSize: 10,
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
                                                  ),
                                                  const SizedBox(height: 15)
                                                ],
                                              ),
                                            )
                                          : data.messageType == "image"
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          curve: Curves.linear,
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: ImageView(
                                                            image: data.url!,
                                                            userimg: users
                                                                .profileImage!,
                                                          )),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    width: 210,
                                                    height: 150,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CachedNetworkImage(
                                                        imageUrl: data.url!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Stack(
                                                          children: [
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
                                                          ],
                                                        ),
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child:
                                                              CupertinoActivityIndicator(),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : data.messageType == "video"
                                                  ? Stack(
                                                      children: [
                                                        SizedBox(
                                                          width: 210,
                                                          height: 150,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: data
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
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                            top: 50,
                                                            left: 74,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              VideoViewFix(
                                                                        username:
                                                                            "${capitalizeFirstLetter(users.firstName!)} ${capitalizeFirstLetter(users.lastName!)}",
                                                                        url: data
                                                                            .url!,
                                                                        play:
                                                                            true,
                                                                        mute:
                                                                            false,
                                                                        date: convertUTCTimeTo12HourFormat(
                                                                            data.createdAt!),
                                                                      ),
                                                                    ));
                                                              },
                                                              child: CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundColor:
                                                                      blurColor,
                                                                  foregroundColor:
                                                                      chatownColor,
                                                                  child: Image.asset(
                                                                      "assets/images/play2.png",
                                                                      height:
                                                                          12)),
                                                            ))
                                                      ],
                                                    )
                                                  : data.messageType ==
                                                          "location"
                                                      ? InkWell(
                                                          onTap: () {
                                                            MapUtils.openMap(
                                                                double.parse(data
                                                                    .latitude!),
                                                                double.parse(data
                                                                    .longitude!));
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minHeight:
                                                                        10.0,
                                                                    minWidth:
                                                                        10.0,
                                                                    maxWidth:
                                                                        250),
                                                            child: Container(
                                                              height: 130,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: data.latitude ==
                                                                              "" ||
                                                                          data.longitude ==
                                                                              ""
                                                                      ? Container(
                                                                          decoration:
                                                                              const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/map_Blurr.png"), fit: BoxFit.cover)),
                                                                          child:
                                                                              Icon(
                                                                            Icons.error_outline,
                                                                            color:
                                                                                chatownColor.withOpacity(0.6),
                                                                            size:
                                                                                50,
                                                                          ),
                                                                        )
                                                                      : FutureBuilder<
                                                                          Uint8List>(
                                                                          future:
                                                                              getBytesFromAsset(
                                                                            'assets/images/location_for_google.png',
                                                                            70,
                                                                            70,
                                                                          ),
                                                                          builder:
                                                                              (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                                                                            if (snapshot.connectionState == ConnectionState.done &&
                                                                                snapshot.hasData) {
                                                                              return Container(
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
                                                                                height: 100,
                                                                                child: GoogleMap(
                                                                                  zoomControlsEnabled: false,
                                                                                  onTap: (argument) {
                                                                                    MapUtils.openMap(double.parse(data.latitude!), double.parse(data.longitude!));
                                                                                  },
                                                                                  mapType: MapType.normal,
                                                                                  compassEnabled: false,
                                                                                  initialCameraPosition: CameraPosition(target: LatLng(double.parse(data.latitude!), double.parse(data.longitude!)), zoom: 15),
                                                                                  markers: {
                                                                                    Marker(
                                                                                      icon: BitmapDescriptor.fromBytes(snapshot.data!),
                                                                                      markerId: const MarkerId('my_location'),
                                                                                      position: LatLng(double.parse(data.latitude!), double.parse(data.longitude!)),
                                                                                    ),
                                                                                  },
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              return const Center(child: CupertinoActivityIndicator());
                                                                            }
                                                                          },
                                                                        )),
                                                            ),
                                                          ),
                                                        )
                                                      : data.messageType ==
                                                              "audio"
                                                          ? myVoiceWidget(
                                                              data, index)
                                                          : data.messageType ==
                                                                  "link"
                                                              ? FlutterLinkPreview(
                                                                  url: data
                                                                      .message!,
                                                                  builder:
                                                                      (info) {
                                                                    if (info
                                                                        is WebInfo) {
                                                                      return info.title == null &&
                                                                              info.description == null
                                                                          ? Text(
                                                                              data.message!,
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: data.myMessage == false ? Colors.white : Colors.black,
                                                                              ),
                                                                            )
                                                                          : Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                if (info.image != null)
                                                                                  Container(
                                                                                    height: 58,
                                                                                    width: 57,
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
                                                                  titleStyle:
                                                                      TextStyle(
                                                                    color: data.myMessage ==
                                                                            false
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )
                                                              : data.messageType ==
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
                                                                                image: data.url!,
                                                                                userimg: users.profileImage!,
                                                                              )),
                                                                        );
                                                                      },
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            150,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            imageUrl:
                                                                                data.url!,
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Stack(
                                                                              children: [
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            placeholder: (context, url) =>
                                                                                const Center(
                                                                              child: CupertinoActivityIndicator(),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(Icons.error),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : data.messageType ==
                                                                          "contact"
                                                                      ? Column(
                                                                          children: [
                                                                            Container(
                                                                              height: 50,
                                                                              width: 210,
                                                                              decoration: BoxDecoration(borderRadius: matchContact(data.sharedContactNumber!) ? BorderRadius.circular(10) : const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
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
                                                                                          imageUrl: data.sharedContactProfileImage!,
                                                                                          placeholderColor: chatownColor,
                                                                                          errorWidgeticon: const Icon(
                                                                                            Icons.person,
                                                                                            size: 30,
                                                                                          )),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 5),
                                                                                  Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        capitalizeFirstLetter(data.sharedContactName!),
                                                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                      ),
                                                                                      Text(
                                                                                        capitalizeFirstLetter(data.sharedContactNumber!),
                                                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 3),
                                                                            matchContact(data.sharedContactNumber!)
                                                                                ? const SizedBox.shrink()
                                                                                : InkWell(
                                                                                    onTap: () {
                                                                                      Get.to(() => SaveContact(name: data.sharedContactName!, number: data.sharedContactNumber!));
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 30,
                                                                                      width: 200,
                                                                                      decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)), color: Colors.white),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          const SizedBox(height: 3),
                                                                                          Text(
                                                                                            languageController.textTranslate('View contact'),
                                                                                            textAlign: TextAlign.center,
                                                                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: data.myMessage == false ? appColorBlack : appColorWhite),
                                                                                          ),
                                                                                        ],
                                                                                      ),
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
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypingMessage() {
    List<String> typingUserNames = onlieController.typingList
        .map((typingUser) {
          return chatProfileController.users
                      .where(
                        (chatUser) =>
                            chatUser.user!.userId!.toString() ==
                            typingUser.userId!.toString(),
                      )
                      .first
                      .user!
                      .userId !=
                  Hive.box(userdata).get(userId)
              ? chatProfileController.users
                  .where(
                    (chatUser) =>
                        chatUser.user!.userId!.toString() ==
                        typingUser.userId!.toString(),
                  )
                  .first
                  .user!
                  .userName
              : "";
        })
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList();

    if (typingUserNames.length == 1) {
      return "${typingUserNames.first} is typing...";
    } else if (typingUserNames.length > 1) {
      String userNames = typingUserNames.join(', ');
      return "$userNames are typing...";
    } else {
      return "";
    }
  }

//==========================================================================================================================================================
//==========================================================================================================================================================
//==========================================================================================================================================================
  AppBar _appbar(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.grey.shade200)),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              // isKeyboard = false;
              // closeKeyboard();
              // // Get.find<ChatListController>().forChatList();
              // // Get.offAll(
              // //   TabbarScreen(
              // //     currentTab: 0,
              // //   ),
              // // );
              // Future.microtask(() {
              //   Get.find<ChatListController>().forChatList();
              //   // Get.offAll(() => TabbarScreen(currentTab: 0));
              //   Get.back();
              // });

              // chatContorller.userdetailschattModel.value!.messageList!.clear();
              // print(
              //     "xxxxxx:${chatContorller.userdetailschattModel.value!.messageList!.clear}");
              isKeyboard = false;
              closeKeyboard();
              if (!isNavigating) {
                isNavigating = true;

                // Safely clear message list
                if (chatContorller.userdetailschattModel.value != null) {
                  chatContorller.userdetailschattModel.value!.messageList
                      ?.clear();
                }

                // Schedule navigation for next frame
                Future.microtask(() {
                  Get.find<ChatListController>().forChatList();
                  // Get.offAll(() => TabbarScreen(currentTab: 0));
                  Get.back();
                });
              }
            },
            child: Image.asset("assets/images/arrow-left.png",
                height: 22, color: chatColor),
          ),
          InkWell(
            onTap: () {
              Get.to(
                () => GroupProfile(
                    conversationID: widget.conversationID!,
                    gPPic: widget.gPPic,
                    gPusername: widget.gPusername,
                    gDesc: widget.gDesc,
                    grpIsVerified:
                        widget.verificationBadge != '' ? true : false,
                    badgeUrl: widget.verificationBadge != ''
                        ? widget.verificationBadge
                        : ''),
              )!
                  .then((value) {
                if (value == "1") {
                  setState(() {
                    isSearchSelect = "1";
                    isTextFieldHide = "1";
                  });
                }
              });
            },
            child: Row(
              children: [
                const SizedBox(width: 3),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey.shade200),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CustomCachedNetworkImage(
                      imageUrl: widget.gPPic!,
                      placeholderColor: chatownColor,
                      errorWidgeticon: const Icon(
                        Icons.groups,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 142,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   capitalizeFirstLetter(widget.gPusername!),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //       color: chatColor,
                      //       fontWeight: FontWeight.w500,
                      //       overflow: TextOverflow.ellipsis,
                      //       fontSize: 16),
                      // ),
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.40,
                      //   child: Expanded(
                      //     child: Row(
                      //       children: [
                      //         Flexible(
                      //           child: Text(
                      //             capitalizeFirstLetter(widget.gPusername!),
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //             style: const TextStyle(
                      //               color: chatColor,
                      //               fontWeight: FontWeight.w500,
                      //               overflow: TextOverflow.ellipsis,
                      //               fontSize: 16,
                      //             ),
                      //           ),
                      //         ),
                      //         if (widget.verificationBadge != "")
                      //           VerificationLogoWidget(
                      //             logoUrl: widget.verificationBadge,
                      //             size: 16,
                      //             margin: const EdgeInsets.only(left: 2),
                      //           ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // Original problematic code (from paste-2.txt)
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.40,
                      //   child: Expanded( // <-- This is the problem
                      //     child: Row(
                      //       children: [
                      //         Flexible(
                      //           child: Text(
                      //             capitalizeFirstLetter(widget.gPusername!),
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //             style: const TextStyle(
                      //               color: chatColor,
                      //               fontWeight: FontWeight.w500,
                      //               overflow: TextOverflow.ellipsis,
                      //               fontSize: 16,
                      //             ),
                      //           ),
                      //         ),
                      //         if (widget.verificationBadge != "" &&
                      //             widget.verificationBadge != null)
                      //           VerificationLogoWidget(
                      //             logoUrl: widget.verificationBadge,
                      //             size: 16,
                      //             margin: const EdgeInsets.only(left: 2),
                      //           ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * 0.40,
                      //   child: Expanded( // <-- This is the problem
                      //     child: Row(
                      //       children: [
                      //         Flexible(
                      //           child: Text(
                      //             capitalizeFirstLetter(widget.gPusername!),
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //             style: const TextStyle(
                      //               color: chatColor,
                      //               fontWeight: FontWeight.w500,
                      //               overflow: TextOverflow.ellipsis,
                      //               fontSize: 16,
                      //             ),
                      //           ),
                      //         ),
                      //         if (widget.verificationBadge != "" &&
                      //             widget.verificationBadge != null)
                      //           VerificationLogoWidget(
                      //             logoUrl: widget.verificationBadge,
                      //             size: 16,
                      //             margin: const EdgeInsets.only(left: 2),
                      //           ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // Original problematic code (from paste-2.txt)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                capitalizeFirstLetter(widget.gPusername!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: chatColor,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        final typingUsers = onlieController.typingList
                            .where((user) =>
                                user.conversationId ==
                                widget.conversationID.toString())
                            .toList();

                        return typingUsers.isNotEmpty
                            ? Text(
                                _getTypingMessage(),
                                style: TextStyle(
                                    fontSize: 12, color: chatownColor),
                              )
                            : const SizedBox.shrink();
                      }),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            InkWell(
                onTap: () async {
                  var status = await Permission.notification.status;

                  if (status.isDenied || status.isRestricted) {
                    status = await Permission.notification.request();
                  }
                  if (status.isGranted) {
                    await getRoomController.getRoomModelApi(
                        conversationID: widget.conversationID,
                        callType: "audio_call");
                    print(
                        "ROOMID 2 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => AudioCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.conversationID ?? "",
                          isCaller: true,
                          receiverImage: widget.gPPic!,
                          receiverUserName: widget.gPusername!,
                          isGroupCall: "true",
                          badgelogo: widget.verificationBadge,
                        ));
                  } else if (status.isPermanentlyDenied) {
                    // openAppSettings();
                    PermissionUtil.showPermissionSettingsDialog(
                        context,
                        "Notification",
                        languageController.textTranslate,
                        chatownColor,
                        secondaryColor);
                  } else {
                    // Show a message if permission is denied
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Notification permission is required to Group Audio call.'));
                  }
                },
                child: Image.asset(
                  "assets/images/call_1.png",
                  color: chatColor,
                  height: MediaQuery.of(context).size.height * 0.027,
                )),
            const SizedBox(
              width: 12,
            ),
            InkWell(
                onTap: () async {
                  var status = await Permission.notification.status;

                  if (status.isDenied || status.isRestricted) {
                    status = await Permission.notification.request();
                  }
                  if (status.isGranted) {
                    await getRoomController.getRoomModelApi(
                        conversationID: widget.conversationID,
                        callType: "video_call");
                    print(
                        "ROOMID 1 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => VideoCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.conversationID ?? "",
                          isCaller: true,
                          isGroupCall: "true",
                        ));
                  } else if (status.isPermanentlyDenied) {
                    // openAppSettings();
                    PermissionUtil.showPermissionSettingsDialog(
                        context,
                        "Notification",
                        languageController.textTranslate,
                        chatownColor,
                        secondaryColor);
                  } else {
                    // Show a message if permission is denied
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Notification permission is required to Group Video call.'));
                  }
                },
                child: Image.asset(
                  "assets/images/video_1.png",
                  color: chatColor,
                  height: MediaQuery.of(context).size.height * 0.027,
                )),
            _popMenu(context),
            const SizedBox.shrink()
          ],
        )
      ],
    );
  }

  AppBar _appbarSearch(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.grey.shade200)),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: commonSearchField(
        context: context,
        controller: _searchController,
        onChanged: (String searchText) {
          if (searchText.isEmpty) {
            _searchResult.clear();
            _searchController.clear();
          } else {
            onSearchTextChanged(searchText);
          }
        },
        hintText: languageController.textTranslate('What are you looking for?'),
        isSuffixIconShow: true,
      ),
      //     Container(
      //   height: 50,
      //   width: MediaQuery.of(context).size.width * 0.8,
      //   decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(7),
      //       color: Colors.grey.shade200),
      //   child: TextField(
      //     controller: _searchController,
      //     onChanged: (String searchText) {
      //       if (searchText.isEmpty) {
      //         _searchResult.clear();
      //         _searchController.clear();
      //       } else {
      //         onSearchTextChanged(searchText);
      //       }
      //     },
      //     decoration: InputDecoration(
      //       suffixIcon: const Padding(
      //         padding: EdgeInsets.all(17),
      //         child: Image(
      //           image: AssetImage('assets/icons/search.png'),
      //         ),
      //       ),
      //       hintText:
      //           '  ${languageController.textTranslate('What are you looking for?')}',
      //       hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      //       filled: true,
      //       fillColor: Colors.transparent,
      //       border: const OutlineInputBorder(borderSide: BorderSide.none),
      //     ),
      //   ),
      // ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: InkWell(
              onTap: () {
                setState(() {
                  isSearchSelect = '0';
                  isTextFieldHide = '0';

                  _searchResult.clear();
                  _searchController.clear();
                });
              },
              child: const Icon(Icons.close, color: chatColor, size: 25)),
        )
      ],
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail
        in chatContorller.userdetailschattModel.value!.messageList!) {
      if (userDetail.message
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
      }
    }

    setState(() {});
  }

  AppBar _appbar1(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.grey.shade200)),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              Get.find<ChatListController>().forChatList();
              Get.offAll(
                TabbarScreen(
                  currentTab: 0,
                ),
              );
              chatContorller.userdetailschattModel.value!.messageList!.clear();
              print(
                  "xxxxxx:${chatContorller.userdetailschattModel.value!.messageList!.clear}");
              chatID = [];
              chatMessageList = [];
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: chatColor,
              size: 18,
            ),
          ),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 35,
                  width: 35,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: checkForNull(widget.conversationID) != null
                        ? CachedNetworkImage(
                            imageUrl: widget.gPPic!,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                              color: chatownColor,
                            )),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          )
                        : Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                                color: chatColor, shape: BoxShape.circle),
                            child: const Icon(
                              Icons.person,
                              size: 25,
                              color: chatColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 142,
                  child: Text(
                    capitalizeFirstLetter(widget.gPusername!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: chatColor,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 13.0),
          child: InkWell(
            onTap: () {
              deleteMessage(context);
            },
            child: Image.asset("assets/images/trash.png",
                height: 24, color: chatColor),
          ),
        )
      ],
    );
  }

  deleteMessage(BuildContext context) {
    return showDialog(
      barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            insetPadding: const EdgeInsets.all(8),
            alignment: Alignment.bottomCenter,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: SizedBox(
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    languageController
                        .textTranslate('Are you sure you want to Delete?'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Are you sure you want to delete your message?",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: appgrey2,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            try {
                              chatContorller.isSendMsg.value = true;
                              chatContorller.deleteChatApi(chatID, false,
                                  widget.conversationID.toString());

                              for (var id in chatID) {
                                chatContorller
                                    .userdetailschattModel.value!.messageList!
                                    .where((element) =>
                                        element.messageId.toString() ==
                                        id.toString())
                                    .first
                                    .deleteForMe = Hive.box(
                                        userdata)
                                    .get(userId)
                                    .toString();
                              }
                              chatContorller.userdetailschattModel.refresh();

                              setState(() {
                                isSelectedmessage = "0";
                                chatID = [];
                                chatMessageList = [];
                              });
                              chatContorller.isSendMsg.value = false;
                            } catch (e) {
                              setState(() {
                                isSelectedmessage = "0";
                                chatID = [];
                                chatMessageList = [];
                              });
                              chatContorller.isSendMsg.value = false;
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: chatownColor, width: 1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Text(
                              languageController.textTranslate('Delete for me'),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: chatColor),
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            try {
                              chatContorller.isSendMsg.value = true;
                              chatContorller.deleteChatApi(chatID, true,
                                  widget.conversationID.toString());

                              chatID.map((id) {
                                chatContorller
                                    .userdetailschattModel.value!.messageList!
                                    .where((element) =>
                                        element.messageId.toString() ==
                                        id.toString())
                                    .first
                                    .deleteFromEveryone = true;
                              }).toList();
                              chatContorller.userdetailschattModel.refresh();

                              setState(() {
                                isSelectedmessage = "0";
                                chatID = [];
                                chatMessageList = [];
                              });
                              chatContorller.isSendMsg.value = false;
                            } catch (e) {
                              setState(() {
                                isSelectedmessage = "0";
                                chatID = [];
                                chatMessageList = [];
                              });
                              chatContorller.isSendMsg.value = false;
                            }
                            Navigator.pop(context);
                            Get.find<ChatListController>().forChatList();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                    colors: [secondaryColor, chatownColor],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)),
                            child: Center(
                                child: Text(
                              languageController
                                  .textTranslate('Delete for everyone'),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: chatColor),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _popMenu(BuildContext context) {
    return PopupMenuButton(
      shadowColor: Colors.grey,
      color: Colors.white,
      elevation: 0.8,
      icon: const Icon(
        Icons.more_vert,
        color: chatColor,
        size: 24,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.to(() => GroupProfile(
                        conversationID: widget.conversationID!,
                        gPPic: widget.gPPic,
                        gPusername: widget.gPusername,
                        gDesc: widget.gDesc,
                        grpIsVerified:
                            widget.verificationBadge != '' ? true : false,
                        badgeUrl: widget.verificationBadge != ''
                            ? widget.verificationBadge
                            : ''))!
                    .then((value) {
                  if (value == "1") {
                    setState(() {
                      isSearchSelect = "1";
                      isTextFieldHide = "1";
                    });
                  }
                });
              });
            },
            child: Text(
              languageController.textTranslate('View contact'),
              style: TextStyle(color: appColorBlack),
            )),
        PopupMenuItem(
            onTap: () {
              if (chatContorller.userdetailschattModel.value != null &&
                  chatContorller.userdetailschattModel.value!.messageList !=
                      null &&
                  chatContorller
                      .userdetailschattModel.value!.messageList!.isNotEmpty) {
                var lastMessage = chatContorller
                    .userdetailschattModel.value!.messageList!.reversed.last;
                print("LAST_MSGID:${lastMessage.messageId}");
                chatContorller.clearAllChatApi(
                    conversationid: widget.conversationID!,
                    messageID: lastMessage.messageId.toString());
                chatContorller.userdetailschattModel.value?.messageList
                    ?.clear();
              }
              isKeyboard = false;
            },
            child: Text(languageController.textTranslate('Clear chat'))),
        PopupMenuItem(
            onTap: () {
              setState(() {
                isSearchSelect = "1";
                isTextFieldHide = "1";
              });
            },
            child: Text(languageController.textTranslate('Search chat'))),
      ],
    );
  }
}

List _searchResult = [];
