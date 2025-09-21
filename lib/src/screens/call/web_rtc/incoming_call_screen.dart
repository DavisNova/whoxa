// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_print, deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whoxachat/Models/calls_Model/joined_users_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:lottie/lottie.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class IncomingCallScrenn extends StatefulWidget {
  String roomID;
  String callerImage;
  String senderName;
  String conversation_id;
  String caller_id;
  String message_id;
  bool forVideoCall = true;
  String? receiverImage;
  String isGroupCall;
  VerificationType? verificationType;
  IncomingCallScrenn({
    super.key,
    required this.roomID,
    required this.callerImage,
    required this.senderName,
    required this.conversation_id,
    required this.caller_id,
    required this.message_id,
    this.forVideoCall = true,
    this.receiverImage,
    required this.verificationType,
    required this.isGroupCall,
  });

  @override
  State<IncomingCallScrenn> createState() => _IncomingCallScrennState();
}

class _IncomingCallScrennState extends State<IncomingCallScrenn> {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RoomIdController roomIdController = getx.Get.put(RoomIdController());
  String badgeUrl = '';

  @override
  void initState() {
    log("=== INCOMING CALL SCREEN DATA LOG ===");
    ("Room ID: ${widget.roomID}");
    log("Caller ID: ${widget.caller_id}");
    log("Caller Name: ${widget.senderName}");
    log("Caller Image URL: ${widget.callerImage}");
    log("Conversation ID: ${widget.conversation_id}");
    log("Message ID: ${widget.message_id}");
    log("Call Type: ${widget.forVideoCall ? 'Video Call' : 'Audio Call'}");
    log("Is Group Call: ${widget.isGroupCall}");
    if (widget.receiverImage != null) {
      log("Receiver Image URL: ${widget.receiverImage}");
    }
    log("verificationType from incoming call: ${widget.verificationType}");
    log("=====================================");
    initializeLocalRender();
    localCamera();
    if (widget.verificationType != null) {
      badgeUrl = widget.verificationType?.logo ?? '';
    }
    super.initState();
  }

  Future<void> initializeLocalRender() async {
    await localRenderer.initialize();
  }

  localCamera() {
    navigator.mediaDevices.getUserMedia({
      "video": widget.forVideoCall == true
          ? Platform.isAndroid
              ? true
              : {
                  'mandatory': {
                    'minWidth': '640',
                    'minHeight': '480',
                    'minFrameRate': '30',
                  },
                  'facingMode': 'user',
                }
          : false,
      "audio": true
    }).then((mediaStream) async {
      localRenderer.srcObject = mediaStream;
      setState(() {});
      await Helper.setSpeakerphoneOn(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorBlack,
      body: Stack(
        children: [
          SizedBox(
            height: getx.Get.height,
            width: getx.Get.width,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: widget.forVideoCall == true
                  ? RTCVideoView(
                      localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.callerImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: appIconColor,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Icons.person,
                              size: 30,
                            );
                          },
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.white.withOpacity(0.053),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: appColorWhite,
                    ),
                    Text(
                      languageController.textTranslate('End-to-end encrypted'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: appColorWhite,
                        fontFamily: "Poppins",
                      ),
                    ),
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appColorBlack.withOpacity(0.07),
                            ),
                            color: appColorBlack.withOpacity(0.10),
                          ),
                          child: Image.asset(
                            "assets/icons/profile-add.png",
                            color: appColorWhite,
                            height: 16,
                            width: 16,
                          ).paddingAll(9),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 73,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.senderName,
                        style: const TextStyle(
                          color: appColorWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 9,
                ),
                Text(
                  widget.forVideoCall == true
                      ? "Incoming Video Call"
                      : "Incoming Audio Call",
                  style: const TextStyle(
                    color: appColorWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "Poppins",
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/Lottie ANIMATION/caller_bg_animation.json',
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColorWhite,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CustomCachedNetworkImage(
                          imageUrl: widget.callerImage,
                          size: 129,
                          errorWidgeticon: const Icon(
                            Icons.person,
                            size: 30,
                          ),
                        ),
                      ).paddingAll(4),
                    ),
                  ],
                ),
                SizedBox(
                  height: getx.Get.height * 0.31,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        OneSignal.Notifications.clearAll();
                        stopRingtone();

                        if (widget.isGroupCall == "true") {
                          getx.Get.find<ChatListController>().forChatList();
                          getx.Get.offAll(
                            TabbarScreen(
                              currentTab: 0,
                            ),
                          );
                        } else {
                          roomIdController.callCutByReceiver(
                            conversationID: widget.conversation_id,
                            message_id: widget.message_id,
                            caller_id: widget.caller_id,
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                'assets/Lottie ANIMATION/call_cut_animation.json',
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    color: colorE04300),
                                child: Center(
                                    child: Image.asset(
                                  "assets/icons/call_reject.png",
                                  height: 24,
                                  width: 24,
                                )),
                              ),
                              const Positioned(
                                bottom: 5,
                                child: Text(
                                  "Reject",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: appColorWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        OneSignal.Notifications.clearAll();
                        OneSignal.Notifications.clearAll();
                        stopRingtone();

                        if (widget.forVideoCall == true) {
                          // Log the data being passed to VideoCallScreen
                          log("=== VIDEO CALL NAVIGATION LOG ===");
                          log("Room ID: ${widget.roomID}");
                          log("Conversation ID: ${widget.conversation_id}");
                          log("Is Group Call: ${widget.isGroupCall}");
                          log("===============================");

                          getx.Get.off(
                            VideoCallScreen(
                              roomID: widget.roomID,
                              conversation_id: widget.conversation_id,
                              isGroupCall: widget.isGroupCall,
                            ),
                          );
                        } else {
                          // Log the data being passed to AudioCallScreen
                          log("=== AUDIO CALL NAVIGATION LOG ===");
                          log("Room ID: ${widget.roomID}");
                          log("Conversation ID: ${widget.conversation_id}");
                          log("Receiver Image: ${widget.callerImage}");
                          log("Receiver Username: ${widget.senderName}");
                          log("Is Group Call: ${widget.isGroupCall}");
                          log("===============================");

                          getx.Get.off(
                            AudioCallScreen(
                              roomID: widget.roomID,
                              conversation_id: widget.conversation_id,
                              receiverImage: widget.callerImage,
                              receiverUserName: widget.senderName,
                              isGroupCall: widget.isGroupCall,
                              badgelogo: widget.verificationType?.logo ?? '',
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                'assets/Lottie ANIMATION/call_recieve_animation.json',
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    color: color3CE000),
                                child: Center(
                                    child: Image.asset(
                                  "assets/icons/call_confirm.png",
                                  height: 24,
                                  width: 24,
                                )),
                              ),
                              const Positioned(
                                bottom: 5,
                                child: Text(
                                  "Accept",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: appColorWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    localRenderer.srcObject!.getTracks().forEach((track) => track.stop());
    localRenderer.srcObject!.getAudioTracks().forEach((track) => track.stop());
    localRenderer.srcObject!.getVideoTracks().forEach((track) => track.stop());

    localRenderer.dispose();

    super.dispose();
  }
}
