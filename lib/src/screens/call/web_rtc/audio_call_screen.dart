// ignore_for_file: must_be_immutable, depend_on_referenced_packages, constant_identifier_names, avoid_print, non_constant_identifier_names, unused_field, deprecated_member_use

//
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:whoxachat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/native_controller/audio_native_controller.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/call/web_rtc/joiend_users.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:peerdart/peerdart.dart';
import 'package:uuid/uuid.dart';

class AudioCallScreen extends StatefulWidget {
  String? roomID;
  String? isGroupCall;
  String conversation_id;
  String receiverImage;
  String receiverUserName;
  bool isCaller = false;
  String? badgelogo;
  AudioCallScreen(
      {super.key,
      this.roomID,
      this.isGroupCall,
      required this.conversation_id,
      required this.receiverImage,
      required this.receiverUserName,
      required this.badgelogo,
      this.isCaller = false});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  Peer? myPeer;
  Map<String, MediaConnection> peers = {};

  RTCVideoRenderer localRenderer = RTCVideoRenderer();

  final Map<String, RTCVideoRenderer> remoteRenderers = {};

  final RoomIdController roomIdController = getx.Get.put(RoomIdController());

  String? peerid;
  bool inCall = false;
  bool isScreenBig = true;
  bool isReciverConnect = false;
  bool isCallCutByMe = false;
  bool isCallCutCall = false;

  @override
  void initState() {
    super.initState();
    callingRingtone();
    _initializeRenderers();
    checkIsRemoteUsersJoined();
    roomIdController.joinUsers(
      isCaller: widget.isCaller,
      isGroupCall: bool.parse(widget.isGroupCall!),
      callback: () {
        log("callback call");
        if (roomIdController.connnectdUsersData.length == 1) {
          log("remoteRenderers length first ${remoteRenderers.length}");

          Future.delayed(
            const Duration(seconds: 2),
            () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  endedCall(context);
                }
              });
              disposeLocalRender();
              disposeRemoteRender();
              getx.Get.find<ChatListController>().forChatList();
            },
          );
        }
      },
    );
    // Add periodic debug checks
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _debugConnectionStatus();
    });
  }

  late Future _delayedCheckFuture;

  checkIsRemoteUsersJoined() async {
    _delayedCheckFuture = Future.delayed(
      const Duration(seconds: 45),
      () {
        if (remoteRenderers.isEmpty) {
          if (widget.isCaller == true) {
            stopRingtone();
          }
          if (isReciverConnect == false &&
              widget.isCaller == true &&
              isCallCutCall == false) {
            print("callCutByMe calling...");
            roomIdController.callCutByMe(
                conversationID: widget.conversation_id, callType: "audio_call");
          }

          setState(() {
            inCall = false;
          });
          disposeLocalRender();
          disposeRemoteRender();
          getx.Get.find<ChatListController>().forChatList();
          getx.Get.offAll(
            TabbarScreen(
              currentTab: 0,
            ),
          );
        }
      },
    );
  }

  callingRingtone() async {
    if (widget.isCaller == true && remoteRenderers.isEmpty) {
      await Helper.setSpeakerphoneOn(false);
      AudioManager.setEarpiece();

      if (Platform.isAndroid) {
        FlutterRingtonePlayer().play(
          fromAsset: 'assets/audio/calling.mp3',
          looping: true,
        );
      } else {
        AudioManager.playAudio(
          audioFile: 'calling.mp3',
        );
      }
    }
  }

  Future<void> _initializeRenderers() async {
    await localRenderer.initialize();
    print("ROOMID ${widget.roomID}");
    await _initPeer();
  }

  static const CLOUD_HOST = ApiHelper.baseUrlIp;
  static const CLOUD_PORT = 4001;

  static const defaultConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': "turn:$CLOUD_HOST:4001",
        'username': "peerjs",
        'credential': "peerjsp"
      }
    ],
  };

  Future<void> _initPeer() async {
    try {
      myPeer = Peer(
        id: "${const Uuid().v4()}/${Hive.box(userdata).get(userId).toString()}",
        options: PeerOptions(
          port: CLOUD_PORT,
          host: CLOUD_HOST,
          secure: false,
          path: '/',
        ),
      );
    } catch (e) {
      print('Unhandled exception in _initPeer: $e');
    }

    myPeer!.on("open").listen((event) {
      setState(() {
        peerid = event.toString();
      });
      print("PEERID☺☺☺☺☺☺☺:$event");
      socketIntilized.socket!
          .emit("join-call", {"room_id": widget.roomID, "user_id": event});
    });

// Update the connectNewUser method
    connectNewUser(String userId, MediaStream mediaStream) async {
      print('ATTEMPTING to connect to user: $userId');
      try {
        final call = myPeer!.call(userId, mediaStream);
        print('Connection initiated with ID: ${call.connectionId}');

        // Store the connection immediately
        peers[userId] = call;
        print("Peer connection added. Total peers: ${peers.length}");

        call.on<MediaStream>("stream").listen((stream) async {
          print("STREAM RECEIVED from peer: ${call.peer}");
          print(
              "Stream details - ID: ${stream.id}, Audio tracks: ${stream.getAudioTracks().length}");

          // Use a consistent key for the renderer
          String rendererId = call.peer;
          print("Using rendererId: $rendererId");

          if (!remoteRenderers.containsKey(rendererId)) {
            print("Creating new renderer for: $rendererId");
            RTCVideoRenderer renderer = RTCVideoRenderer();
            try {
              await renderer.initialize();
              print("Renderer initialized successfully");

              if (mounted) {
                setState(() {
                  remoteRenderers[rendererId] = renderer;
                  print(
                      "Renderer added to map. Total renderers: ${remoteRenderers.length}");
                });
              }
            } catch (e) {
              print("ERROR initializing renderer: $e");
              return;
            }
          }

          // Now assign the stream (use the correct key - rendererId not userId)
          if (remoteRenderers.containsKey(rendererId)) {
            print("Assigning stream to renderer for: $rendererId");
            setState(() {
              remoteRenderers[rendererId]!.srcObject = stream;
            });
            print("Stream assigned successfully");
          } else {
            print("ERROR: Renderer not found for: $rendererId");
          }
        });

        call.on("error").listen((error) {
          print("ERROR in call: $error");
        });

        call.on("close").listen((onData) {
          print("Call closed for peer: $userId");
          // Rest of your close handler...
        });
      } catch (e) {
        print("ERROR establishing call: $e");
      }
    }

    navigator.mediaDevices.getUserMedia({"video": false, "audio": true}).then(
        (mediaStream) async {
      localRenderer.srcObject = mediaStream;
      print('my stream $mediaStream');
      await Helper.setSpeakerphoneOn(false);

      // Update the incoming call handler
      myPeer!.on<MediaConnection>("call").listen((call) {
        print("call from ${call.peer} to $peerid");
        print('my stream $mediaStream');
        call.answer(mediaStream);

        call.on<MediaStream>("stream").listen((remoteStream) async {
          String rendererId = call.peer;
          print("Got stream from incoming call, peer: $rendererId");

          if (!remoteRenderers.containsKey(rendererId)) {
            print("Creating new renderer for incoming call from: $rendererId");
            RTCVideoRenderer renderer = RTCVideoRenderer();
            await renderer.initialize();

            setState(() {
              remoteRenderers[rendererId] = renderer;
              remoteRenderers[rendererId]!.srcObject = remoteStream;
              print("Renderer created and stream assigned for: $rendererId");
            });
          } else {
            setState(() {
              remoteRenderers[rendererId]!.srcObject = remoteStream;
              print("Stream assigned to existing renderer for: $rendererId");
            });
          }

          // Start timer if not caller and not already started
          if (widget.isCaller == false && _seconds == 0) {
            startTimer();
          }

          print("remoteRenderers length ${remoteRenderers.length}");
          print("remoteStream $remoteStream");
        });

        print("call peer ${call.peer}");
        peers[call.peer] = call;
      });

      if (widget.isCaller == false) {
        startTimer();
      }
      // socketIntilized.socket!.on(
      //   "user-connected-to-call",
      //   (userId) {
      //     if (widget.isCaller == true) {
      //       stopRingtone();
      //     }
      //     print("PEERID☺☺☺☺☺☺☺ remote: $userId");

      //     connectNewUser(userId, mediaStream);
      //     isReciverConnect = true;
      //   },
      // );
      // Update the socket event handler in _initPeer method
      socketIntilized.socket!.on(
        "user-connected-to-call",
        (data) {
          print("RECEIVED user-connected-to-call data: $data");

          // Extract the user_id properly
          String userId;
          if (data is Map) {
            // If data is a map, extract the user_id field
            userId = data['user_id']?.toString() ?? '';
            print("Extracted userId from map: $userId");
          } else {
            // If data is already a string
            userId = data.toString();
            print("Using data directly as userId: $userId");
          }

          if (userId.isNotEmpty) {
            if (widget.isCaller == true) {
              stopRingtone();
            }
            print("Connecting to remote peer: $userId");

            connectNewUser(userId, mediaStream);
            isReciverConnect = true;

            // Start timer if caller
            if (widget.isCaller == true && _seconds == 0) {
              startTimer();
            }
          } else {
            print(
                "ERROR: Invalid userId in user-connected-to-call event: $data");
          }
        },
      );
    });
// Update the user disconnection handler to use proper syntax
    socketIntilized.socket!.on("user-disconnected-from-call", (userId) {
      print("disconnected $userId");
      print("peers $peers");

      if (peers[userId] != null) {
        print("disconnected userid $userId");
        peers[userId]!.close();

        if (remoteRenderers[userId] != null) {
          remoteRenderers[userId]!.dispose();
          remoteRenderers.remove(userId);

          setState(() {});

          if (remoteRenderers.isEmpty) {
            socketIntilized.socket!.emit("leave-call",
                {"room_id": widget.roomID, "user_id": myPeer!.id});
            disposeLocalRender();
            disposeRemoteRender();
            getx.Get.find<ChatListController>().forChatList();
            getx.Get.offAll(
              TabbarScreen(
                currentTab: 0,
              ),
            );
          }
        }

        print("disconnected peers[userId] ${peers[userId]}");
        print("remoteRenderers length ${remoteRenderers.length}");
      } else {
        print("peers else $peers");
      }
    });

    socketIntilized.socket!.on("call_decline", (data) {
      print("call_decline data : $data");

      stopRingtone();
      getx.Get.find<ChatListController>().forChatList();
      getx.Get.offAll(
        TabbarScreen(
          currentTab: 0,
        ),
      );
      disposeLocalRender();
      disposeRemoteRender();
      setState(() {
        myPeer!.dispose();
      });
    });
  }

  void _endCall() {
    if (widget.isCaller == true) {
      isCallCutCall = true;
      setState(() {});
      stopRingtone();
    }
    if (isReciverConnect == false && widget.isCaller == true) {
      print("callCutByMe calling...");
      roomIdController.callCutByMe(
          conversationID: widget.conversation_id, callType: "audio_call");
    }
    peers = {};
    socketIntilized.socket!
        .emit("leave-call", {"room_id": widget.roomID, "user_id": myPeer!.id});

    setState(() {
      inCall = false;
    });

    disposeLocalRender();
    disposeRemoteRender();

    getx.Get.find<ChatListController>().forChatList();
    getx.Get.offAll(
      TabbarScreen(
        currentTab: 0,
      ),
    );
  }

  bool microphone = false;
  void _toggleMicrophone() {
    microphone = !microphone;
    localRenderer.srcObject!.getAudioTracks()[0].enabled == true
        ? localRenderer.srcObject!.getAudioTracks()[0].enabled = false
        : localRenderer.srcObject!.getAudioTracks()[0].enabled = true;
    setState(() {});
  }

  bool specker = false;
  void _toggleSpecker() async {
    specker == true
        ? await Helper.setSpeakerphoneOn(false)
        : await Helper.setSpeakerphoneOn(true);
    specker = !specker;
    setState(() {});
  }

  void _toggleScreenSize() {
    setState(() {
      isScreenBig = !isScreenBig;
    });
  }

  Timer? _timer;
  int _seconds = 0;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String getFormattedTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleScreenSize,
      child: Scaffold(
        backgroundColor: appColorBlack,
        body: Stack(
          children: [
            forTwo(),
            Positioned(
                top: 145,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    // Text(
                    //   widget.receiverUserName,
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.w500,
                    //     fontSize: 20,
                    //     color: appColorWhite,
                    //     fontFamily: "Poppins",
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.receiverUserName,
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
                      languageController.textTranslate('Audio Calling'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: appColorWhite,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 9,
                    ),
                    Text(
                      remoteRenderers.isEmpty
                          ? "00:00"
                          : getFormattedTime(_seconds),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: appColorWhite,
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
                              imageUrl: widget.receiverImage,
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
                  ],
                )),
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
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
                        fontFamily: "Poppins",
                        color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      joinUsers();
                    },
                    child: ClipRRect(
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
                            height: 16,
                            width: 16,
                            color: appColorWhite,
                          ).paddingAll(9),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Positioned(
            //   top: 40,
            //   left: 20,
            //   right: 20,
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.2),
            //       borderRadius: BorderRadius.circular(15),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         const Icon(
            //           Icons.arrow_back,
            //           color: Colors.white,
            //         ),
            //         Container(
            //           child: Text(
            //             languageController
            //                 .textTranslate('End-to-end encrypted'),
            //             style: const TextStyle(
            //               fontWeight: FontWeight.w400,
            //               fontSize: 12,
            //               fontFamily: "Poppins",
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //         GestureDetector(
            //           onTap: () {
            //             joinUsers();
            //           },
            //           child: ClipRRect(
            //             borderRadius:
            //                 const BorderRadius.all(Radius.circular(100)),
            //             child: BackdropFilter(
            //               filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            //               child: Container(
            //                 decoration: BoxDecoration(
            //                   shape: BoxShape.circle,
            //                   border: Border.all(
            //                     color: appColorBlack.withOpacity(0.07),
            //                   ),
            //                   color: appColorBlack.withOpacity(0.10),
            //                 ),
            //                 child: Image.asset(
            //                   "assets/icons/profile-add.png",
            //                   height: 16,
            //                   width: 16,
            //                   color: Colors.white,
            //                 ).paddingAll(9),
            //               ),
            //             ),
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            Positioned(
              bottom: 20,
              left: 40,
              right: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColorWhite.withOpacity(0.36),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        callOptionsContainer(
                          image: microphone == false
                              ? "assets/icons/mice_off.png"
                              : "assets/icons/mice_on.png",
                          onTap: _toggleMicrophone,
                        ),
                        callOptionsContainer(
                          image: specker == false
                              ? "assets/icons/volume_off.png"
                              : "assets/icons/volume_on.png",
                          onTap: _toggleSpecker,
                        ),
                        GestureDetector(
                          onTap: _endCall,
                          child: Image.asset(
                            "assets/icons/call_end.png",
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  joinUsers() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
          return const JoinedUsers();
        });
  }

  Widget forTwo() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.receiverImage,
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
    );
  }

  endedCall(BuildContext context) {
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
              width: getx.Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    languageController
                        .textTranslate('This call has already ended.'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Text(
                    languageController.textTranslate('Please call again.'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            getx.Get.offAll(
                              TabbarScreen(
                                currentTab: 0,
                              ),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: chatownColor, width: 1),
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
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            getx.Get.offAll(
                              TabbarScreen(
                                currentTab: 0,
                              ),
                            );
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
                              languageController.textTranslate('Call Again'),
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

  Future<void> disposeLocalRender() async {
    if (localRenderer.srcObject != null) {
      final audioTracks = localRenderer.srcObject!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        for (var track in audioTracks) {
          track.stop();
        }
      }

      final videoTracks = localRenderer.srcObject!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        for (var track in videoTracks) {
          track.stop();
        }
      }

      localRenderer.srcObject!.getAudioTracks().clear();
      localRenderer.srcObject!.getVideoTracks().clear();
    }

    await localRenderer.dispose();
  }

  Future<void> disposeRemoteRender() async {
    remoteRenderers.forEach((key, renderer) async {
      if (renderer.srcObject != null) {
        final audioTracks = renderer.srcObject!.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          for (var track in audioTracks) {
            print('Stopping audio track for renderer $key');
            track.stop();
          }
        }

        final videoTracks = renderer.srcObject!.getVideoTracks();
        if (videoTracks.isNotEmpty) {
          for (var track in videoTracks) {
            print('Stopping video track for renderer $key');
            track.stop();
          }
        }

        renderer.srcObject!.getAudioTracks().clear();
        renderer.srcObject!.getVideoTracks().clear();
      } else {
        print('No srcObject found for renderer $key');
      }

      await renderer.dispose();
      print('Renderer $key disposed');
    });
  }

  @override
  void dispose() {
    disposeLocalRender();
    disposeRemoteRender();
    myPeer!.dispose();
    _delayedCheckFuture = Future.value();
    _timer?.cancel();
    super.dispose();
  }

  // Add this debug method to your class
  void _debugConnectionStatus() {
    print("\n===== AUDIO CALL STATUS =====");
    print("LOCAL AUDIO: ${localRenderer.srcObject != null ? 'YES' : 'NO'}");

    if (localRenderer.srcObject != null) {
      final audioTracks = localRenderer.srcObject!.getAudioTracks();
      print(
          "  Local audio tracks: ${audioTracks.length} (enabled: ${audioTracks.isNotEmpty ? audioTracks[0].enabled : 'N/A'})");
    }

    print("REMOTE RENDERERS: ${remoteRenderers.length}");
    remoteRenderers.forEach((key, renderer) {
      print(
          "  Renderer for peer $key: has stream = ${renderer.srcObject != null}");
      if (renderer.srcObject != null) {
        final audioTracks = renderer.srcObject!.getAudioTracks();
        print(
            "    Audio tracks: ${audioTracks.length} (enabled: ${audioTracks.isNotEmpty ? audioTracks[0].enabled : 'N/A'})");
      }
    });

    print("PEER CONNECTIONS: ${peers.length}");
    peers.forEach((userId, connection) {
      print(
          "  Connection with $userId: ACTIVE");
    });
    print("============================\n");
  }
}
