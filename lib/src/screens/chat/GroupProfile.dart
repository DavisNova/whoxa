//

// ignore_for_file: avoid_print, must_be_immutable, use_build_context_synchronously, non_constant_identifier_names, file_names, use_full_hex_values_for_flutter_colors, unused_field
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/single_chat_controller.dart';
import 'package:whoxachat/controller/single_chat_media_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/chat_profile_model.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:whoxachat/src/screens/chat/Media.dart';
import 'package:whoxachat/src/screens/chat/allstarred_msg_list.dart';
import 'package:whoxachat/src/screens/chat/chatvideo.dart';
import 'package:whoxachat/src/screens/chat/group_memberlist.dart';
import 'package:whoxachat/src/screens/chat/group_profile_update.dart';
import 'package:whoxachat/src/screens/chat/imageView.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class GroupProfile extends StatefulWidget {
  String conversationID;
  String? gPusername;
  String? gPPic;
  String? gDesc;
  bool? grpIsVerified;
  String? badgeUrl;
  GroupProfile(
      {super.key,
      required this.conversationID,
      required this.gPusername,
      required this.gPPic,
      required this.gDesc,
      required this.grpIsVerified,
      required this.badgeUrl});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  ChatListController chatListController = Get.put(ChatListController());
  ChatProfileController chatProfileController =
      Get.put(ChatProfileController());
  AllStaredMsgController allStaredMsgController = Get.find();
  bool isLoading = false;
  bool isParticipantsOpen = true;
  bool isShowOptions = false;
  final ScrollController _scrollController = ScrollController();
  bool hasVerificationRequest = false;
  @override
  void initState() {
    print("GROUP_ID: ${widget.conversationID}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProfileController
          .getProfileDATA(widget.conversationID)
          .whenComplete(() {
        getAdmin();
      });
      allStaredMsgController.getAllStarMsg(widget.conversationID);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.isScrollingNotifier.value) {
        setState(() {
          isShowOptions = false;
        });
      } else {}
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool isIamAdmin = false;
  getAdmin() {
    for (int i = 0;
        i <
            chatProfileController.profileModel.value!.conversationDetails!
                .conversationsUsers!.length;
        i++) {
      if (Hive.box(userdata).get(userId) ==
          chatProfileController.profileModel.value!.conversationDetails!
              .conversationsUsers![i].user!.userId) {
        if (chatProfileController.profileModel.value!.conversationDetails!
                .conversationsUsers![i].isAdmin ==
            false) {
          setState(() {
            isIamAdmin = false;
          });
        } else {
          setState(() {
            isIamAdmin = true;
          });
        }

        print("MYADMIN$isIamAdmin");
      }
    }
  }

  Future<bool> submitVerificationRequest(
      String conversationID, String grpname) async {
    try {
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> requestData = {
        'conversation_id': conversationID,
        'full_name': grpname,
      };

      print('Sending verification request: $requestData');

      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/request-subscription-group'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
        },
        body: jsonEncode(requestData),
      );

      // Print the complete response data
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Try to parse the JSON response
        try {
          final responseData = jsonDecode(response.body);
          print('Parsed response data: $responseData');
        } catch (e) {
          print('Could not parse response JSON: $e');
        }

        print('Verification request submitted successfully');
        setState(() {
          hasVerificationRequest = true;
        });

        Fluttertoast.showToast(
          msg: 'Verification request submitted successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        return true;
      } else {
        print('Failed to submit verification request: ${response.statusCode}');

        // Try to parse error response if possible
        try {
          final errorData = jsonDecode(response.body);
          print('Error response data: $errorData');
        } catch (e) {
          print('Could not parse error response: $e');
        }

        Fluttertoast.showToast(
          msg: 'Failed to submit verification request. Please try again.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error submitting verification request: $e');
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isShowOptions = false;
        });
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        bottomNavigationBar: isIamAdmin == true
            ? BottomAppBar(
                elevation: 0,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Addparticipants(),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: Obx(() {
          return chatProfileController.isLoading.value
              ? loader(context)
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Stack(
                    children: [
                      // SizedBox(
                      //   height: Get.height * 0.27,
                      //   width: double.infinity,
                      //   child: Image.asset(
                      //     cacheHeight: 140,
                      //     "assets/images/back_img1.png",
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      getProfileUpperField(),
                      // _coverImg(''),
                      Column(
                        children: [
                          SizedBox(height: Get.height * 0.15),
                          Center(
                              child: profilePic(chatProfileController
                                  .profileModel.value!.conversationDetails!)),
                          groupprofiledetails(chatProfileController
                              .profileModel.value!.conversationDetails!),
                        ],
                      ),
                      Positioned(
                          top: 40,
                          left: 5,
                          child: IconButton(
                              onPressed: () {
                                Get.find<SingleChatContorller>()
                                    .userdetailschattModel
                                    .value!
                                    .messageList = [];
                                Get.find<SingleChatContorller>()
                                    .getdetailschat(widget.conversationID);
                                Navigator.pop(context);
                              },
                              icon:
                                  const Icon(Icons.arrow_back_ios, size: 19))),
                      Positioned(
                          top: 52,
                          right: 10,
                          child: Obx(() {
                            return chatProfileController.isLoading.value
                                ? const Icon(
                                    Icons.more_vert,
                                    color: chatColor,
                                    size: 24,
                                  ).paddingOnly(right: 5)
                                : isShowOptions == false
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isShowOptions = true;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: chatColor,
                                          size: 24,
                                        ).paddingOnly(right: 5),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        margin: const EdgeInsets.only(
                                            right: 5, top: 2),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    barrierColor:
                                                        const Color.fromRGBO(
                                                            30, 30, 30, 0.37),
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 5.0,
                                                                sigmaY: 5.0),
                                                        child: AlertDialog(
                                                          insetPadding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape:
                                                              const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  20),
                                                            ),
                                                          ),
                                                          content: SizedBox(
                                                            width: Get.width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const SizedBox(
                                                                    height: 10),
                                                                const Text(
                                                                  "Are you sure you want to Remove?",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                const SizedBox(
                                                                    height: 15),
                                                                Text(
                                                                  "Are you exit from ${chatProfileController.profileModel.value!.conversationDetails!.groupName!} group?",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          appgrey2,
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            40,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.35,
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(color: chatownColor, width: 1),
                                                                            borderRadius: BorderRadius.circular(12)),
                                                                        child: Center(
                                                                            child: Text(
                                                                          languageController
                                                                              .textTranslate('Cancel'),
                                                                          style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: chatColor),
                                                                        )),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        chatProfileController.exitGroupApi(
                                                                            cID:
                                                                                widget.conversationID);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            40,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.35,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                12),
                                                                            gradient:
                                                                                LinearGradient(colors: [
                                                                              secondaryColor,
                                                                              chatownColor
                                                                            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                                                                        child: Center(
                                                                            child: Text(
                                                                          languageController
                                                                              .textTranslate('Exit'),
                                                                          style: const TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: chatColor),
                                                                        )),
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
                                                },
                                                child: Text(languageController
                                                    .textTranslate(
                                                        'Group exit'))),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => group_profile(
                                                            dp: chatProfileController
                                                                .profileModel
                                                                .value!
                                                                .conversationDetails!
                                                                .groupProfileImage!,
                                                            groupid: widget
                                                                .conversationID,
                                                            name: chatProfileController
                                                                .profileModel
                                                                .value!
                                                                .conversationDetails!
                                                                .groupName!,
                                                            gDesc:
                                                                widget.gDesc ??
                                                                    ''),
                                                      )).then((value) {
                                                    chatProfileController
                                                        .getProfileDATAUpdate(
                                                            widget
                                                                .conversationID);
                                                  });
                                                },
                                                child: Text(languageController
                                                    .textTranslate(
                                                        'Group edit'))),
                                          ],
                                        ),
                                      );
                          }))
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageController.textTranslate('Description'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          const SizedBox(height: 10),
          // Description widget
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: widget.gDesc!.isNotEmpty
                ? Text(
                    widget.gDesc ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  )
                : Text(
                    languageController
                        .textTranslate('No description available'),
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget Addparticipants() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GetMembersinGroup(grpId: widget.conversationID),
            ));
      },
      child: Container(
        height: 47,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
                colors: [secondaryColor, chatownColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Center(
          child: Text(
            languageController.textTranslate('Add Participants'),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget groupprofiledetails(ConversationDetails data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buttonContainer(
                onTap: () async {
                  var status = await Permission.notification.status;

                  if (status.isDenied || status.isRestricted) {
                    status = await Permission.notification.request();
                  }
                  if (status.isGranted) {
                    await Get.find<RoomIdController>().getRoomModelApi(
                        conversationID: widget.conversationID,
                        callType: "audio_call");
                    print(
                        "ROOMID 2 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => AudioCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.conversationID,
                          isCaller: true,
                          receiverImage: widget.gPPic!,
                          receiverUserName: widget.gPusername!,
                          isGroupCall: "true",
                          badgelogo: widget.badgeUrl,
                        ));
                  } else if (status.isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    // Show a message if permission is denied
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Notification permission is required to Group Audio call.'));
                  }
                },
                img: "assets/images/call_1.png",
                title: "Audio"),
            const SizedBox(
              width: 30,
            ),
            buttonContainer(
                onTap: () async {
                  var status = await Permission.notification.status;

                  if (status.isDenied || status.isRestricted) {
                    status = await Permission.notification.request();
                  }
                  if (status.isGranted) {
                    await Get.find<RoomIdController>().getRoomModelApi(
                        conversationID: widget.conversationID,
                        callType: "video_call");
                    print(
                        "ROOMID 1 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => VideoCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.conversationID,
                          isCaller: true,
                          isGroupCall: "true",
                        ));
                  } else if (status.isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    // Show a message if permission is denied
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Notification permission is required to Group Video call.'));
                  }
                },
                img: "assets/images/video_1.png",
                title: "Video"),
            const SizedBox(
              width: 30,
            ),
            buttonContainer(
                onTap: () {
                  Get.back(result: "1");
                },
                img: "assets/icons/search-normal.png",
                title: languageController.textTranslate('Search'))
          ],
        ),
        const SizedBox(height: 10),
        buildDescriptionSection(),
        const SizedBox(
          height: 10,
        ),
        mediaContainer(),
        const SizedBox(
          height: 10,
        ),
        stareContainer(),
        const SizedBox(height: 10),
        memberListWidget()
      ],
    );
  }

  Widget profilePic(ConversationDetails data) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CustomCachedNetworkImage(
                  imageUrl: data.groupProfileImage!,
                  errorWidgeticon: const Icon(Icons.groups, size: 50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const SizedBox(height: 25),
          Text(
            capitalizeFirstLetter('${data.groupName}'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          // Add verification badge for group
        ],
      ),
    );
  }

  bool isBlockUser(String conversationID) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (chatListController.userChatListModel.value!.chatList![i].isGroup ==
          false) {
        if (conversationID ==
            chatListController
                .userChatListModel.value!.chatList![i].conversationId
                .toString()) {
          return chatListController
              .userChatListModel.value!.chatList![i].isBlock!;
        }
      }
    }
    return false;
  }

  Future<void> showAnimatedDialog(ConversationsUsers data) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Get.find<SingleChatContorller>()
                        .userdetailschattModel
                        .value!
                        .messageList = [];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SingleChatMsg(
                                verificationBadge:
                                    data.user!.verificationType != null
                                        ? data.user!.verificationType?.logo
                                        : '',
                                conversationID: chatListController
                                        .userChatListModel.value!.chatList!
                                        .where((element) =>
                                            element.userId == data.user!.userId)
                                        .isEmpty
                                    ? chatListController.userArchiveListModel
                                        .value!.archiveList!
                                        .where((element) =>
                                            element.userId == data.user!.userId)
                                        .first
                                        .conversationId!
                                        .toString()
                                    : chatListController
                                        .userChatListModel.value!.chatList!
                                        .where((element) =>
                                            element.userId == data.user!.userId)
                                        .first
                                        .conversationId!
                                        .toString(),
                                username: data.user!.userName,
                                userPic: data.user!.profileImage,
                                index: 0,
                                isMsgHighLight: false,
                                isBlock: isBlockUser(
                                  chatListController
                                          .userChatListModel.value!.chatList!
                                          .where((element) =>
                                              element.userId ==
                                              data.user!.userId)
                                          .isEmpty
                                      ? chatListController.userArchiveListModel
                                          .value!.archiveList!
                                          .where((element) =>
                                              element.userId ==
                                              data.user!.userId)
                                          .first
                                          .conversationId!
                                          .toString()
                                      : chatListController
                                          .userChatListModel.value!.chatList!
                                          .where((element) =>
                                              element.userId ==
                                              data.user!.userId)
                                          .first
                                          .conversationId!
                                          .toString(),
                                ),
                                userID: data.user!.userId.toString(),
                              )),
                    ).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 30),
                data.isAdmin == true
                    ? InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          chatProfileController.makeAdminApi(
                              widget.conversationID,
                              data.user!.userId.toString(),
                              true.toString());
                          setState(() {
                            getAdmin();
                          });
                        },
                        child: const Text(
                          'Dismiss As Admin',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          chatProfileController.makeAdminApi(
                              widget.conversationID,
                              data.user!.userId.toString(),
                              "");
                          setState(() {
                            getAdmin();
                          });
                        },
                        child: const Text(
                          'Make Group Admin',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    showDialog(
                      barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                      context: context,
                      builder: (BuildContext context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: AlertDialog(
                            insetPadding: const EdgeInsets.all(8),
                            alignment: Alignment.bottomCenter,
                            backgroundColor: Colors.white,
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
                                  const Text(
                                    "Are you sure you want to Remove?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Are you sure you want to remove ${data.user!.userName} from this group?",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: appgrey2,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: chatownColor,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Center(
                                              child: Text(
                                            languageController
                                                .textTranslate('Cancel'),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: chatColor),
                                          )),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          chatProfileController.removeAdminApi(
                                              widget.conversationID,
                                              data.user!.userId.toString());
                                          chatProfileController.users
                                              .remove(data);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    secondaryColor,
                                                    chatownColor
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter)),
                                          child: const Center(
                                              child: Text(
                                            'Remove',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: chatColor),
                                          )),
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
                  },
                  child: Text(
                    languageController.textTranslate('Remove from group'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.red),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: appgrey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 1.0,
                          spreadRadius: 0.0,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.black,
                    )),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget chatcard(ConversationsUsers data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: InkWell(
        onTap: () {
          if (data.user!.userId != Hive.box(userdata).get(userId) &&
              isIamAdmin == true) {
            showAnimatedDialog(data);
          } else {
            null;
          }
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CustomCachedNetworkImage(
                              imageUrl: data.user!.profileImage.toString(),
                              errorWidgeticon: const Icon(
                                CupertinoIcons.person_fill,
                                size: 30,
                              ))),
                    ]),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                                Hive.box(userdata).get(userId).toString() ==
                                        data.user!.userId.toString()
                                    ? languageController.textTranslate('You')
                                    : capitalizeFirstLetter(
                                        data.user!.userName!),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                          ],
                        ),
                        // Text(
                        //     Hive.box(userdata).get(userId).toString() ==
                        //             data.user!.userId.toString()
                        //         ? languageController.textTranslate('You')
                        //         : capitalizeFirstLetter(data.user!.userName!),
                        //     textAlign: TextAlign.left,
                        //     style: const TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 14,
                        //       color: Colors.black,
                        //     )),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 155,
                          height: 30,
                          child: Text(
                            data.user!.bio!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                data.isAdmin == true
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10, top: 7),
                        child: Text(
                          languageController.textTranslate('Admin'),
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget participants() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: chatProfileController.users.length,
            itemBuilder: (BuildContext context, int index) {
              return chatcard(chatProfileController.users[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget mediaContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Media(
                      peeid: widget.conversationID,
                      peername: chatProfileController.profileModel.value!
                          .conversationDetails!.groupName!)));
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageController.textTranslate('Media, links and docs'),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(
                      chatProfileController.totalCount.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: appgrey2,
                    ),
                  ],
                )
              ],
            ).paddingSymmetric(horizontal: 20, vertical: 10),
            SizedBox(
              height: 100,
              child: chatProfileController
                      .profileModel.value!.mediaData!.isEmpty
                  ? Center(
                      child: Text(
                        languageController
                            .textTranslate("You haven't share any media"),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: chatProfileController
                              .profileModel.value!.mediaData!.length
                              .clamp(0, 4),
                          padding: const EdgeInsets.only(left: 20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return chatProfileController
                                    .profileModel.value!.mediaData![index].url
                                    .toString()
                                    .contains(".mp4")
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoViewFix(
                                              username:
                                                  "${capitalizeFirstLetter("")} ${capitalizeFirstLetter("")}",
                                              url: chatProfileController
                                                  .profileModel
                                                  .value!
                                                  .mediaData![index]
                                                  .url!,
                                              play: true,
                                              mute: false,
                                              date: "",
                                            ),
                                          ));
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                          ),
                                          child: ClipRRect(
                                            child: CachedNetworkImage(
                                              imageUrl: chatProfileController
                                                  .profileModel
                                                  .value!
                                                  .mediaData![index]
                                                  .thumbnail!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            top: 40,
                                            child: Image.asset(
                                                "assets/images/play1.png",
                                                height: 22,
                                                color: chatColor))
                                      ],
                                    ),
                                  ).paddingOnly(right: 10)
                                : InkWell(
                                    onTap: () {
                                      log(chatProfileController.profileModel
                                          .value!.mediaData![index].url!);
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            curve: Curves.linear,
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: ImageView(
                                              image: chatProfileController
                                                  .profileModel
                                                  .value!
                                                  .mediaData![index]
                                                  .url!,
                                              userimg: "",
                                            )),
                                      );
                                    },
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                        ),
                                        child: ClipRRect(
                                          child: CachedNetworkImage(
                                            imageUrl: chatProfileController
                                                .profileModel
                                                .value!
                                                .mediaData![index]
                                                .url!,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                  ).paddingOnly(right: 10);
                          }),
                    ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  Widget stareContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: InkWell(
        onTap: () {
          allStaredMsgController.getAllStarMsg(widget.conversationID);
          Get.to(
              () => AllStarredMsgList(
                  conversationid: widget.conversationID, isPersonal: true),
              transition: Transition.rightToLeft);
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/icons/star2.png", color: chatColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    languageController.textTranslate('Started Messages'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Row(
                children: [
                  Obx(() {
                    return Text(
                      allStaredMsgController.allStarred.isEmpty
                          ? "0"
                          : allStaredMsgController.allStarred.length.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: appgrey2,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //verification badge
  // Widget grpverification() {
  //   return Container(
  //     decoration: const BoxDecoration(color: Colors.white, boxShadow: [
  //       BoxShadow(
  //         blurRadius: 0.5,
  //         spreadRadius: 0,
  //         offset: Offset(0, 0.4),
  //         color: Color.fromRGBO(239, 239, 239, 1),
  //       )
  //     ]),
  //     child: InkWell(
  //       onTap: () {
  //         // allStaredMsgController.getAllStarMsg(widget.conversationID);
  //         // Get.to(
  //         //     () => AllStarredMsgList(
  //         //         conversationid: widget.conversationID, isPersonal: true),
  //         //     transition: Transition.rightToLeft);
  //       },
  //       child: Padding(
  //         padding:
  //             const EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 10),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Image.asset("assets/icons/star2.png", color: chatColor),
  //                 const SizedBox(
  //                   width: 10,
  //                 ),
  //                 Text(
  //                   languageController.textTranslate('Started Messages'),
  //                   style: const TextStyle(
  //                       fontSize: 15, fontWeight: FontWeight.w400),
  //                 ),
  //               ],
  //             ),
  //             Row(
  //               children: [
  //                 Obx(() {
  //                   return Text(
  //                     allStaredMsgController.allStarred.isEmpty
  //                         ? "0"
  //                         : allStaredMsgController.allStarred.length.toString(),
  //                     style: const TextStyle(
  //                       color: Colors.grey,
  //                       fontSize: 13.5,
  //                       fontWeight: FontWeight.w400,
  //                     ),
  //                   );
  //                 }),
  //                 const Icon(
  //                   Icons.arrow_forward_ios_rounded,
  //                   size: 15,
  //                   color: appgrey2,
  //                 ),
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget memberListWidget() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${chatProfileController.profileModel.value!.conversationDetails!.conversationsUsers!.length.toString()} ${languageController.textTranslate('Group Members')}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ).paddingOnly(left: 23, top: 10),
          participants()
        ],
      ),
    );
  }
}
