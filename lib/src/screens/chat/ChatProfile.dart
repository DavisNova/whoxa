// ignore_for_file: use_build_context_synchronously, avoid_print, must_be_immutable, file_names, unused_element, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/user/widget/banner_img_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/single_chat_media_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/chat_profile_model.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:whoxachat/src/screens/chat/Media.dart';
import 'package:whoxachat/src/screens/chat/allstarred_msg_list.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/screens/chat/chatvideo.dart';
import 'package:whoxachat/src/screens/chat/imageView.dart';
import 'package:whoxachat/src/screens/chat/report_popup.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/src/screens/chat/shareable/common_permission_dialog.dart';
import 'package:whoxachat/src/screens/chat/shareable/shimmer_profile_loader.dart';
import 'package:http/http.dart' as http;

class ChatProfile extends StatefulWidget {
  String? fullName;
  String? profileimg;
  String? peeid;
  String? status;
  String? phnnum;
  String? userId;
  String? verificationBadgeUrl;
  ChatProfile(
      {super.key,
      this.fullName,
      this.profileimg,
      this.peeid,
      this.phnnum,
      this.status,
      this.userId,
      this.verificationBadgeUrl});
  @override
  State<ChatProfile> createState() => _ChatProfileState();
}

class _ChatProfileState extends State<ChatProfile> {
  AllStaredMsgController allStaredMsgController = Get.find();
  ChatListController chatListController = Get.find();
  ChatProfileController chatProfileController =
      Get.put(ChatProfileController());
  bool isLoading = false;
  File? image;
  final picker = ImagePicker();
  String peerBanner = '';
  @override
  void initState() {
    print("UID:${widget.userId}");
    print("ID:${widget.peeid}");
    print("PH:${widget.phnnum}");
    chatProfileController.getProfileDATA(widget.peeid!);
    allStaredMsgController.getAllStarMsg(widget.peeid);
    allStaredMsgController.getReportTypes();

    if (widget.peeid!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        chatProfileController.profileModel.value!.mediaData = [];
        chatProfileController.profileModel.value!.linkData = [];
        chatProfileController.profileModel.value!.documentData = [];
        allStaredMsgController.allStarred.value = [];
      });
    }
    fetchUserDetailsAPI();
    super.initState();
  }

  fetchUserDetailsAPI() async {
    print('user profile called >>');
    closeKeyboard();

    setState(() {
      isLoading = true;
    });

    final ApiHelper apiHelper = ApiHelper();
    UserProfileModel userProfileModel = UserProfileModel();
    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.fields['user_id'] = widget.userId ?? '';
    request.fields['peer'] = 'true';
    request.headers.addAll(headers);

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    log('userdetails api call tab bar : $userData ');
    userProfileModel = UserProfileModel.fromJson(userData);

    if (userProfileModel.success == true) {
      peerBanner = userProfileModel.resData?.profileBanner ?? '';
      print('peerBanner: ${userProfileModel.resData?.profileBanner}');
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: Obx(() {
        return chatProfileController.isLoading.value && isLoading
            ? ChatProfilePlaceholder()
            : SingleChildScrollView(
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
                    // _coverImg(peerBanner),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: Get.height * 0.15),
                        widget.peeid!.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          width: 95,
                                          height: 95,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: CustomCachedNetworkImage(
                                            imageUrl: widget.profileimg!,
                                            errorWidgeticon:
                                                const Icon(Icons.groups),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Row(
                                    //   children: [
                                    //     Text(ds
                                    //       widget.fullName!,
                                    //       style: const TextStyle(
                                    //           fontWeight: FontWeight.w500,
                                    //           fontSize: 18),
                                    //     ),
                                    //   ],
                                    // ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.fullName!,
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          ),
                                        ),
                                        // Add verification badge for group
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(widget.phnnum!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : widget.peeid!.isEmpty
                                ? const SizedBox.shrink()
                                : (chatProfileController.profileModel.value
                                            ?.conversationDetails !=
                                        null)
                                    ? Center(
                                        child: profilePicWidget(
                                            chatProfileController.profileModel
                                                .value!.conversationDetails!))
                                    : const SizedBox.shrink(),
                        widget.peeid!.isEmpty
                            ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      buttonContainer(
                                          onTap: () async {},
                                          img: "assets/images/call_1.png",
                                          title: languageController
                                              .textTranslate('Audio')),
                                      const SizedBox(width: 30),
                                      buttonContainer(
                                          onTap: () async {},
                                          img: "assets/images/video_1.png",
                                          title: languageController
                                              .textTranslate('Video')),
                                      const SizedBox(width: 30),
                                      buttonContainer(
                                          onTap: () {},
                                          img: "assets/icons/search-normal.png",
                                          title: languageController
                                              .textTranslate('Search'))
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // bioAndCreatedAt(data),
                                  // const SizedBox(
                                  //   height: 20,
                                  // ),
                                  mediaContainer(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  stareContainer(),
                                  const SizedBox(
                                    height: 36,
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          showDialog(
                                            barrierColor: const Color.fromRGBO(
                                                30, 30, 30, 0.37),
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Stack(
                                                children: [
                                                  BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 5.0,
                                                        sigmaY: 5.0),
                                                    child: Container(
                                                      color:
                                                          const Color.fromRGBO(
                                                              30, 30, 30, 0.37),
                                                    ),
                                                  ),
                                                  AlertDialog(
                                                    insetPadding:
                                                        const EdgeInsets.all(8),
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    content: SizedBox(
                                                      height: 150,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              height: 10),
                                                          Text(
                                                            chatListController
                                                                        .blockModel
                                                                        .value!
                                                                        .isBlock ==
                                                                    true
                                                                ? languageController
                                                                    .textTranslate(
                                                                        'Are you sure you want to Unblock?')
                                                                : languageController
                                                                    .textTranslate(
                                                                        'Are you sure you want to Block?'),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16),
                                                          ),
                                                          const SizedBox(
                                                              height: 15),
                                                          Text(
                                                            chatListController
                                                                        .blockModel
                                                                        .value!
                                                                        .isBlock ==
                                                                    true
                                                                ? "${languageController.textTranslate('Are you sure you want to unblock profile of')}  @${widget.fullName}?"
                                                                : "${languageController.textTranslate('Are you sure you want to block profile of')}  @${widget.fullName}?",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: appgrey2,
                                                                fontSize: 13),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 38,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.35,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              chatownColor,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    languageController
                                                                        .textTranslate(
                                                                            'Cancel'),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color:
                                                                            chatColor),
                                                                  )),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  setState(
                                                                      () {});
                                                                  chatListController
                                                                      .blockUserApi(
                                                                          widget
                                                                              .userId);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.35,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      gradient: LinearGradient(
                                                                          colors: [
                                                                            secondaryColor,
                                                                            chatownColor
                                                                          ],
                                                                          begin: Alignment
                                                                              .topCenter,
                                                                          end: Alignment
                                                                              .bottomCenter)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    chatListController.blockModel.value!.isBlock ==
                                                                            true
                                                                        ? languageController.textTranslate(
                                                                            'Unblock')
                                                                        : languageController
                                                                            .textTranslate('Block'),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color:
                                                                            chatColor),
                                                                  )),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 0.5,
                                                  spreadRadius: 0,
                                                  offset: Offset(0, 0.4),
                                                  color: Color.fromRGBO(
                                                      239, 239, 239, 1),
                                                )
                                              ]),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 25,
                                                top: 15,
                                                right: 25,
                                                bottom: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "assets/icons/block.png",
                                                      height: 18,
                                                      width: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      chatListController
                                                                  .blockModel
                                                                  .value!
                                                                  .isBlock ==
                                                              true
                                                          ? 'Unblock ${widget.fullName}'
                                                          : 'Block ${widget.fullName}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Color(0xffFF2525),
                                                        fontFamily: "Poppins",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // reportPopup();
                                          // allStaredMsgController
                                          //     .selectedReportIndex.value = -1;
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 0.5,
                                                  spreadRadius: 0,
                                                  offset: Offset(0, 0.4),
                                                  color: Color.fromRGBO(
                                                      239, 239, 239, 1),
                                                )
                                              ]),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 25,
                                                top: 15,
                                                right: 25,
                                                bottom: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "assets/icons/report.png",
                                                      height: 18,
                                                      width: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Report ${widget.fullName}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Color(0xffFF2525),
                                                        fontFamily: "Poppins",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(
                                      //   height: 1,
                                      // ),
                                      // Container(
                                      //   decoration: const BoxDecoration(
                                      //       color: Colors.white,
                                      //       boxShadow: [
                                      //         BoxShadow(
                                      //           blurRadius: 0.5,
                                      //           spreadRadius: 0,
                                      //           offset: Offset(0, 0.4),
                                      //           color: Color.fromRGBO(
                                      //               239, 239, 239, 1),
                                      //         )
                                      //       ]),
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.only(
                                      //         left: 25,
                                      //         top: 15,
                                      //         right: 25,
                                      //         bottom: 15),
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceBetween,
                                      //       children: [
                                      //         Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment
                                      //                   .spaceBetween,
                                      //           crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //           children: [
                                      //             Image.asset(
                                      //               "assets/icons/delete.png",
                                      //               height: 18,
                                      //               width: 18,
                                      //             ),
                                      //             const SizedBox(
                                      //               width: 10,
                                      //             ),
                                      //             Text(
                                      //               '${languageController.textTranslate('Delete')} ${widget.fullName!}',
                                      //               style: const TextStyle(
                                      //                 fontSize: 12,
                                      //                 fontWeight:
                                      //                     FontWeight.w400,
                                      //                 color: Color(0xffFF2525),
                                      //                 fontFamily: "Poppins",
                                      //               ),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              )
                            : Center(
                                child: profiledetails(chatProfileController
                                    .profileModel.value!.conversationDetails!)),
                      ],
                    ),
                    Positioned(
                        top: 40,
                        left: 5,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios, size: 19))),
                  ],
                ),
              );
      }),
    );
  }

  Widget profilePicWidget(ConversationDetails data) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: data.isGroup == false
                    ? CustomCachedNetworkImage(
                        imageUrl:
                            data.conversationsUsers![0].user!.profileImage!,
                        errorWidgeticon: const Icon(Icons.person),
                      )
                    : CustomCachedNetworkImage(
                        imageUrl: data.groupProfileImage!,
                        errorWidgeticon: const Icon(Icons.groups),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          data.isGroup == false
              ? Text(
                  data.conversationsUsers![0].user!.userName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                )
              : Text(
                  data.groupName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                ),
          const SizedBox(height: 10),
          data.isGroup == false
              ? Text(
                  "${data.conversationsUsers![0].user!.countryCode.toString()} ${data.conversationsUsers![0].user!.phoneNumber.toString()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey,
                  ))
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _coverImg(String peerBanner) {
    return CoverImageWidget(
      imageUrl: peerBanner != '' && peerBanner.isNotEmpty ? peerBanner : null,
    );
  }

  Widget profiledetails(ConversationDetails data) {
    String matchNum(String number) {
      for (var i = 0; i < data.conversationsUsers!.length; i++) {
        if (number == data.conversationsUsers![i].user!.userName) {
          return data.conversationsUsers![i].user!.bio!;
        }
      }
      return '';
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonContainer(
                onTap: () async {
                  chatListController.blockModel.value!.isBlock == true
                      ? Fluttertoast.showToast(
                          msg: languageController.textTranslate(
                              'User blocked, not able to voice call'))
                      : '';
                  var status = await Permission.notification.status;

                  if (status.isDenied || status.isRestricted) {
                    status = await Permission.notification.request();
                  }
                  if (status.isGranted) {
                    await Get.find<RoomIdController>().getRoomModelApi(
                        conversationID: widget.peeid, callType: "audio_call");
                    print(
                        "ROOMID 2 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => AudioCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.peeid ?? "",
                          isCaller: true,
                          receiverImage: widget.profileimg!,
                          receiverUserName: widget.fullName!,
                          isGroupCall: "false",
                          badgelogo: widget.verificationBadgeUrl,
                        ));
                  } else if (status.isPermanentlyDenied) {
                    // openAppSettings();
                    PermissionUtil.showPermissionSettingsDialog(
                        context,
                        "Notification", // or "Location", "Microphone", etc.
                        languageController.textTranslate,
                        chatownColor,
                        secondaryColor);
                  } else {
                    // Show a message if permission is denied
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Notification permission is required to Audio call.'));
                  }
                },
                img: "assets/images/call_1.png",
                title: languageController.textTranslate('Audio')),
            const SizedBox(width: 30),
            buttonContainer(
                onTap: () async {
                  chatListController.blockModel.value!.isBlock == true
                      ? Fluttertoast.showToast(
                          msg: languageController.textTranslate(
                              'User blocked, not able to video call'))
                      : '';
                  var status = await Permission.notification.status;

                  if (status.isDenied || status.isRestricted) {
                    status = await Permission.notification.request();
                  }
                  if (status.isGranted) {
                    await Get.find<RoomIdController>().getRoomModelApi(
                        conversationID: widget.peeid, callType: "video_call");
                    print(
                        "ROOMID 1 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => VideoCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.peeid ?? "",
                          isCaller: true,
                          isGroupCall: "false",
                        ));
                  } else if (status.isPermanentlyDenied) {
                    PermissionUtil.showPermissionSettingsDialog(
                        context,
                        "Notification", // or "Location", "Microphone", etc.
                        languageController.textTranslate,
                        chatownColor,
                        secondaryColor);
                  } else {
                    // Show a message if permission is denied
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Notification permission is required to Video call.'));
                  }
                },
                img: "assets/images/video_1.png",
                title: languageController.textTranslate('Video')),
            const SizedBox(width: 30),
            buttonContainer(
                onTap: () {
                  Get.back(result: "1");
                },
                img: "assets/icons/search-normal.png",
                title: languageController.textTranslate('Search'))
          ],
        ),
        const SizedBox(height: 20),
        bioAndCreatedAt(data),
        const SizedBox(
          height: 20,
        ),
        mediaContainer(),
        const SizedBox(
          height: 20,
        ),
        stareContainer(),
        const SizedBox(
          height: 36,
        ),
        others(data),
      ],
    );
  }

  Widget others(ConversationDetails data) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            showDialog(
              barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: const Color.fromRGBO(30, 30, 30, 0.37),
                      ),
                    ),
                    AlertDialog(
                      insetPadding: const EdgeInsets.all(8),
                      alignment: Alignment.bottomCenter,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      content: SizedBox(
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              chatListController.blockModel.value!.isBlock ==
                                      true
                                  ? languageController.textTranslate(
                                      'Are you sure you want to Unblock?')
                                  : languageController.textTranslate(
                                      'Are you sure you want to Block?'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              chatListController.blockModel.value!.isBlock ==
                                      true
                                  ? "${languageController.textTranslate('Are you sure you want to unblock profile of')}  @${widget.fullName}?"
                                  : "${languageController.textTranslate('Are you sure you want to block profile of')}  @${widget.fullName}?",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 38,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: chatownColor, width: 1),
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
                                  onTap: () {
                                    setState(() {});
                                    chatListController
                                        .blockUserApi(widget.peeid);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                            colors: [
                                              secondaryColor,
                                              chatownColor
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
                                    child: Center(
                                        child: Text(
                                      chatListController
                                                  .blockModel.value!.isBlock ==
                                              true
                                          ? languageController
                                              .textTranslate('Unblock')
                                          : languageController
                                              .textTranslate('Block'),
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
                  ],
                );
              },
            );
          },
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                blurRadius: 0.5,
                spreadRadius: 0,
                offset: Offset(0, 0.4),
                color: Color.fromRGBO(239, 239, 239, 1),
              )
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 15, right: 25, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/block.png",
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        chatListController.blockModel.value!.isBlock == true
                            ? 'Unblock ${data.conversationsUsers![0].user!.userName!}'
                            : 'Block ${data.conversationsUsers![0].user!.userName!}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffFF2525),
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 1,
        ),
        GestureDetector(
          onTap: () {
            reportPopup();
            allStaredMsgController.selectedReportIndex.value = -1;
          },
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                blurRadius: 0.5,
                spreadRadius: 0,
                offset: Offset(0, 0.4),
                color: Color.fromRGBO(239, 239, 239, 1),
              )
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 15, right: 25, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/report.png",
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Report ${data.conversationsUsers![0].user!.userName!}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffFF2525),
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 1,
        ),
        // Container(
        //   decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        //     BoxShadow(
        //       blurRadius: 0.5,
        //       spreadRadius: 0,
        //       offset: Offset(0, 0.4),
        //       color: Color.fromRGBO(239, 239, 239, 1),
        //     )
        //   ]),
        //   child: Padding(
        //     padding:
        //         const EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: [
        //             Image.asset(
        //               "assets/icons/delete.png",
        //               height: 18,
        //               width: 18,
        //             ),
        //             const SizedBox(
        //               width: 10,
        //             ),
        //             Text(
        //               '${languageController.textTranslate('Delete')} ${data.conversationsUsers![0].user!.userName!}',
        //               style: const TextStyle(
        //                 fontSize: 12,
        //                 fontWeight: FontWeight.w400,
        //                 color: Color(0xffFF2525),
        //                 fontFamily: "Poppins",
        //               ),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget bioAndCreatedAt(ConversationDetails data) {
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
          allStaredMsgController.getAllStarMsg(widget.peeid);
          Get.to(
            () => AllStarredMsgList(
                conversationid: widget.peeid, isPersonal: true),
            transition: Transition.rightToLeft,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, top: 10, right: 25, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width * 0.80,
                child: Text(
                  data.conversationsUsers![0].user!.bio!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      fontFamily: "Poppins",
                      color: Color(0xff000000)),
                ),
              ),
              Row(
                children: [
                  Text(
                    "Logged in",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 9,
                        fontFamily: "Poppins",
                        color: const Color(0xff000000).withOpacity(0.26)),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    dateFormate(
                      convertToLocalDate(
                          data.conversationsUsers![0].user!.createdAt),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 9,
                        fontFamily: "Poppins",
                        color: const Color(0xff000000).withOpacity(0.26)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget mediaContainer() {
    if (widget.peeid!.isEmpty) {
      //   // WidgetsBinding.instance.addPostFrameCallback((_) async {
      chatProfileController.profileModel.value!.mediaData = [];
      chatProfileController.profileModel.value!.linkData = [];
      chatProfileController.profileModel.value!.documentData = [];
      //   // });
    }
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
                  builder: (context) =>
                      Media(peeid: widget.peeid, peername: widget.fullName)));
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
          if (widget.peeid!.isNotEmpty) {
            allStaredMsgController.getAllStarMsg(widget.peeid);
          } else {
            allStaredMsgController.allStarred.value = [];
          }
          Get.to(
              () => AllStarredMsgList(
                  conversationid: widget.peeid, isPersonal: true),
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
                    languageController.textTranslate('Starred Messages'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Row(
                children: [
                  widget.peeid!.isEmpty
                      ? const Text(
                          "0",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : Obx(() {
                          return Text(
                            allStaredMsgController.allStarred.isEmpty
                                ? "0"
                                : allStaredMsgController.allStarred.length
                                    .toString(),
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

  Widget blockButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: InkWell(
        onTap: () {
          showDialog(
            barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: const Color.fromRGBO(30, 30, 30, 0.37),
                    ),
                  ),
                  AlertDialog(
                    insetPadding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomCenter,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            chatListController.blockModel.value!.isBlock == true
                                ? languageController.textTranslate(
                                    'Are you sure you want to Unblock?')
                                : languageController.textTranslate(
                                    'Are you sure you want to Block?'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            chatListController.blockModel.value!.isBlock == true
                                ? "${languageController.textTranslate('Are you sure you want to unblock profile of')}  @${widget.fullName}?"
                                : "${languageController.textTranslate('Are you sure you want to block profile of')}  @${widget.fullName}?",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: appgrey2,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 38,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: chatownColor, width: 1),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                      child: Text(
                                    languageController.textTranslate('Cancel'),
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
                                onTap: () {
                                  setState(() {});
                                  chatListController.blockUserApi(widget.peeid);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                          colors: [
                                            secondaryColor,
                                            chatownColor
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter)),
                                  child: Center(
                                      child: Text(
                                    chatListController
                                                .blockModel.value!.isBlock ==
                                            true
                                        ? languageController
                                            .textTranslate('Unblock')
                                        : languageController
                                            .textTranslate('Block'),
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
                ],
              );
            },
          );
        },
        child: Container(
          height: 45,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  colors: [secondaryColor, chatownColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Center(
            child: Obx(() {
              return Text(
                chatListController.blockModel.value!.isBlock == true
                    ? 'UnBlock'
                    : languageController.textTranslate('Block'),
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              );
            }),
          ),
        ),
      ),
    );
  }

  reportPopup() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ReportPopup(
            conversationId: widget.peeid!,
            userId: chatProfileController
                .profileModel.value!.conversationDetails!.conversationsUsers!
                .where((element) =>
                    element.user!.profileImage == widget.profileimg!)
                .first
                .user!
                .userId
                .toString(),
          );
        });
  }
}
