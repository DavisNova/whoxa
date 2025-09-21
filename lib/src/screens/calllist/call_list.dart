// ignore_for_file: camel_case_types, avoid_print, unused_field

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/call_history_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class call_history extends StatefulWidget {
  const call_history({super.key});

  @override
  State<call_history> createState() => _call_historyState();
}

class _call_historyState extends State<call_history>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int selectedindex = 0;
  CallHistoryController callController = Get.put(CallHistoryController());
  final RoomIdController roomIdController = Get.find();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    roomIdController.callHistory();

    _tabController?.addListener(() {
      setState(() {
        selectedindex = _tabController?.index ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Image.network(
              languageController.appSettingsData[0].appLogo!,
              height: 45,
            ),
            automaticallyImplyLeading: false,
          )),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: Colors.white),
            child: Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  ButtonsTabBar(
                    controller: _tabController,
                    borderWidth: 1,
                    unselectedBorderColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [secondaryColor, chatownColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    unselectedBackgroundColor: Colors.transparent,
                    unselectedLabelStyle: const TextStyle(
                      color: appgrey2,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    onTap: (p0) {
                      setState(() {
                        selectedindex = p0;
                      });
                      print("INDEX:$selectedindex");
                    },
                    tabs: [
                      Tab(
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 25,
                            ),
                            Image.asset(
                              'assets/images/call_1.png',
                              width: 16,
                              height: 16,
                              color:
                                  selectedindex == 0 ? Colors.black : appgrey2,
                            ),
                            Text(
                              "  ${languageController.textTranslate('All Call')}         ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedindex == 0
                                    ? Colors.black
                                    : appgrey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Image.asset(
                              'assets/images/call-remove.png',
                              width: 16,
                              height: 16,
                              color:
                                  selectedindex == 1 ? Colors.black : appgrey2,
                            ),
                            Text(
                              "   ${languageController.textTranslate('Missed Call')}     ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedindex == 1
                                    ? Colors.black
                                    : appgrey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        allCalls(),
                        missedCalls(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  allCalls() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Obx(
          () => roomIdController.callHistoryData.isEmpty &&
                  roomIdController.isCallHistoryLoading.value == true
              ? loader(context)
              : Expanded(
                  child: roomIdController.callHistoryData.isEmpty
                      ? Center(
                          child: commonImageTexts(
                            image: "assets/images/image_1.png",
                            text1: languageController
                                .textTranslate("No Calls Found"),
                            text2: languageController.textTranslate(
                                "You can find all logs call here."),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: roomIdController.callHistoryData.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                if (roomIdController
                                        .callHistoryData[index].callType ==
                                    "video_call") {
                                  var status =
                                      await Permission.notification.status;

                                  if (status.isDenied || status.isRestricted) {
                                    status =
                                        await Permission.notification.request();
                                  }
                                  if (status.isGranted) {
                                    await Get.find<RoomIdController>()
                                        .getRoomModelApi(
                                            conversationID: roomIdController
                                                .callHistoryData[index]
                                                .conversationId
                                                .toString(),
                                            callType: "video_call");
                                    print(
                                        "ROOMID 1 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                                    if (roomIdController.callHistoryData[index]
                                            .conversation!.isGroup ==
                                        true) {
                                      Get.to(() => VideoCallScreen(
                                            roomID: Get.find<RoomIdController>()
                                                .roomModel
                                                .value!
                                                .roomId,
                                            conversation_id: roomIdController
                                                .callHistoryData[index]
                                                .conversationId
                                                .toString(),
                                            isCaller: true,
                                            isGroupCall: "true",
                                          ));
                                    } else {
                                      Get.to(() => VideoCallScreen(
                                            roomID: Get.find<RoomIdController>()
                                                .roomModel
                                                .value!
                                                .roomId,
                                            conversation_id: roomIdController
                                                .callHistoryData[index]
                                                .conversationId
                                                .toString(),
                                            isCaller: true,
                                            isGroupCall: "false",
                                          ));
                                    }
                                  } else if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  } else {
                                    // Show a message if permission is denied
                                    Fluttertoast.showToast(
                                      msg: languageController.textTranslate(
                                        roomIdController.callHistoryData[index]
                                                    .conversation!.isGroup ==
                                                true
                                            ? "Notification permission is required to Group Video call."
                                            : 'Notification permission is required to Video call.',
                                      ),
                                    );
                                  }
                                } else {
                                  var status =
                                      await Permission.notification.status;

                                  if (status.isDenied || status.isRestricted) {
                                    status =
                                        await Permission.notification.request();
                                  }
                                  if (status.isGranted) {
                                    await Get.find<RoomIdController>()
                                        .getRoomModelApi(
                                            conversationID: roomIdController
                                                .callHistoryData[index]
                                                .conversationId
                                                .toString(),
                                            callType: "audio_call");
                                    print(
                                        "ROOMID 2 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                                    if (roomIdController.callHistoryData[index]
                                            .conversation!.isGroup ==
                                        true) {
                                      Get.to(() => AudioCallScreen(
                                            roomID: Get.find<RoomIdController>()
                                                .roomModel
                                                .value!
                                                .roomId,
                                            conversation_id: roomIdController
                                                .callHistoryData[index]
                                                .conversationId
                                                .toString(),
                                            isCaller: true,
                                            receiverImage: roomIdController
                                                .callHistoryData[index]
                                                .conversation!
                                                .groupProfileImage!,
                                            receiverUserName: roomIdController
                                                .callHistoryData[index]
                                                .conversation!
                                                .groupName!,
                                            isGroupCall: "true",
                                            badgelogo: roomIdController
                                                .callHistoryData[index]
                                                .user!
                                                .verificationType!
                                                .logo,
                                          ));
                                    } else {
                                      Get.to(() => AudioCallScreen(
                                            roomID: Get.find<RoomIdController>()
                                                .roomModel
                                                .value!
                                                .roomId,
                                            conversation_id: roomIdController
                                                .callHistoryData[index]
                                                .conversationId
                                                .toString(),
                                            isCaller: true,
                                            receiverImage: roomIdController
                                                .callHistoryData[index]
                                                .user!
                                                .profileImage!,
                                            receiverUserName: roomIdController
                                                .callHistoryData[index]
                                                .user!
                                                .userName!,
                                            isGroupCall: "false",
                                            badgelogo: roomIdController
                                                .callHistoryData[index]
                                                .user!
                                                .verificationType!
                                                .logo,
                                          ));
                                    }
                                  } else if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  } else {
                                    // Show a message if permission is denied
                                    Fluttertoast.showToast(
                                        msg: languageController.textTranslate(
                                            roomIdController
                                                        .callHistoryData[index]
                                                        .conversation!
                                                        .isGroup ==
                                                    true
                                                ? "Notification permission is required to Group Audio call."
                                                : 'Notification permission is required to Audio call.'));
                                  }
                                }
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomCachedNetworkImage(
                                        size: 50,
                                        imageUrl: roomIdController
                                                    .callHistoryData[index]
                                                    .conversation!
                                                    .isGroup ==
                                                true
                                            ? roomIdController
                                                .callHistoryData[index]
                                                .conversation!
                                                .groupProfileImage!
                                            : roomIdController
                                                .callHistoryData[index]
                                                .user!
                                                .profileImage!,
                                        placeholderColor: chatownColor,
                                        errorWidgeticon: const Icon(
                                          Icons.groups,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .conversation!
                                                            .isGroup ==
                                                        true
                                                    ? roomIdController
                                                        .callHistoryData[index]
                                                        .conversation!
                                                        .groupName!
                                                    : "${roomIdController.callHistoryData[index].user!.firstName!} ${roomIdController.callHistoryData[index].user!.lastName!}",
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: Color(0xff0B0B0B),
                                                ),
                                              ),
                                              // Add verification badge if this is a user (not a group) and they have verification data
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Image.asset(
                                                roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .callType ==
                                                        "video_call"
                                                    ? roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .missedCall ==
                                                            "1"
                                                        ? "assets/icons/missed_video_call.png"
                                                        : roomIdController
                                                                    .callHistoryData[
                                                                        index]
                                                                    .callDecline ==
                                                                "1"
                                                            ? "assets/icons/missed_video_call.png"
                                                            : roomIdController
                                                                        .callHistoryData[
                                                                            index]
                                                                        .userId ==
                                                                    Hive.box(
                                                                            userdata)
                                                                        .get(
                                                                            userId)
                                                                ? "assets/icons/outgoing_video_call.png"
                                                                : "assets/icons/incoming_video_call.png"
                                                    : roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .missedCall ==
                                                            "1"
                                                        ? "assets/icons/missed_audio_call.png"
                                                        : roomIdController
                                                                    .callHistoryData[
                                                                        index]
                                                                    .callDecline ==
                                                                "1"
                                                            ? "assets/icons/missed_audio_call.png"
                                                            : roomIdController
                                                                        .callHistoryData[
                                                                            index]
                                                                        .userId ==
                                                                    Hive.box(
                                                                            userdata)
                                                                        .get(
                                                                            userId)
                                                                ? "assets/icons/outgoing_audio_call.png"
                                                                : "assets/icons/incoming_audio_call.png",
                                                height: 14,
                                                width: 14,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .callType ==
                                                        "video_call"
                                                    ? roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .missedCall ==
                                                            "1"
                                                        ? "Missed Video Call"
                                                        : roomIdController
                                                                    .callHistoryData[
                                                                        index]
                                                                    .callDecline ==
                                                                "1"
                                                            ? "Video Call Declined"
                                                            : roomIdController
                                                                        .callHistoryData[
                                                                            index]
                                                                        .userId ==
                                                                    Hive.box(
                                                                            userdata)
                                                                        .get(
                                                                            userId)
                                                                ? "Outgoing Video Call"
                                                                : "Incoming Video Call"
                                                    : roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .missedCall ==
                                                            "1"
                                                        ? "Missed Audio Call"
                                                        : roomIdController
                                                                    .callHistoryData[
                                                                        index]
                                                                    .callDecline ==
                                                                "1"
                                                            ? "Audio Call Declined"
                                                            : roomIdController
                                                                        .callHistoryData[
                                                                            index]
                                                                        .userId ==
                                                                    Hive.box(
                                                                            userdata)
                                                                        .get(
                                                                            userId)
                                                                ? "Outgoing Audio Call"
                                                                : "Incoming Audio Call",
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: Color(0xffA4A4A4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatDateCallHistorry(
                                                convertToLocalDate(
                                                    roomIdController
                                                        .callHistoryData[index]
                                                        .updatedAt)),
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 9,
                                              color: Color(0xff606060),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            convertUTCTimeTo12HourFormat(
                                              roomIdController
                                                  .callHistoryData[index]
                                                  .updatedAt!,
                                            ),
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 8,
                                              color: Color(0xff606060),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ).paddingSymmetric(
                                      horizontal: 20, vertical: 7),
                                  index ==
                                          roomIdController
                                                  .callHistoryData.length -
                                              1
                                      ? const SizedBox(
                                          height: 20,
                                        )
                                      : Divider(
                                          color: Colors.grey.shade300,
                                        )
                                ],
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  missedCalls() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Obx(
          () => roomIdController.callHistoryData.isEmpty &&
                  roomIdController.isCallHistoryLoading.value == true
              ? loader(context)
              : Expanded(
                  child: roomIdController.callHistoryData
                          .where((element) {
                            return element.missedCall == "1";
                          })
                          .toList()
                          .isEmpty
                      ? Expanded(
                          child: Center(
                            child: commonImageTexts(
                              image: "assets/images/image_1.png",
                              text1: languageController
                                  .textTranslate("No Missed Calls Found"),
                              text2: languageController.textTranslate(
                                  "You will find missed call here."),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: roomIdController.callHistoryData.length,
                          itemBuilder: (context, index) {
                            return roomIdController
                                        .callHistoryData[index].missedCall ==
                                    "0"
                                ? const SizedBox.shrink()
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          CustomCachedNetworkImage(
                                            size: 50,
                                            imageUrl: roomIdController
                                                        .callHistoryData[index]
                                                        .conversation!
                                                        .isGroup ==
                                                    true
                                                ? roomIdController
                                                    .callHistoryData[index]
                                                    .conversation!
                                                    .groupProfileImage!
                                                : roomIdController
                                                    .callHistoryData[index]
                                                    .user!
                                                    .profileImage!,
                                            placeholderColor: chatownColor,
                                            errorWidgeticon: const Icon(
                                              Icons.groups,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .conversation!
                                                                .isGroup ==
                                                            true
                                                        ? roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .conversation!
                                                            .groupName!
                                                        : "${roomIdController.callHistoryData[index].user!.firstName!} ${roomIdController.callHistoryData[index].user!.lastName!}",
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15,
                                                      color: Color(0xff0B0B0B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .callType ==
                                                            "video_call"
                                                        ? "assets/icons/missed_video_call.png"
                                                        : "assets/icons/missed_audio_call.png",
                                                    height: 14,
                                                    width: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .callType ==
                                                            "video_call"
                                                        ? "Missed Video Call"
                                                        : "Missed Audio Call",
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xffA4A4A4),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                formatDateCallHistorry(
                                                    convertToLocalDate(
                                                        roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .updatedAt)),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 9,
                                                  color: Color(0xff606060),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                convertUTCTimeTo12HourFormat(
                                                  roomIdController
                                                      .callHistoryData[index]
                                                      .updatedAt!,
                                                ),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 8,
                                                  color: Color(0xff606060),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ).paddingSymmetric(
                                          horizontal: 20, vertical: 7),
                                      index ==
                                              roomIdController
                                                      .callHistoryData.length -
                                                  1
                                          ? const SizedBox(
                                              height: 20,
                                            )
                                          : Divider(
                                              color: Colors.grey.shade300,
                                            )
                                    ],
                                  );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
