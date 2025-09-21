// ignore_for_file: unused_field, avoid_print

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:whoxachat/Models/get_all_videocall_list_model.dart';
import 'package:whoxachat/controller/call_history_controller.dart';
import 'package:whoxachat/src/global/global.dart';

class AllVideoCallList extends StatefulWidget {
  const AllVideoCallList({super.key});

  @override
  State<AllVideoCallList> createState() => _AllVideoCallListState();
}

class _AllVideoCallListState extends State<AllVideoCallList> {
  CallHistoryController callController = Get.put(CallHistoryController());

  @override
  void initState() {
    callController.callHistoryApiVideo();
    _fetchContacts();
    super.initState();
  }

  List<Contact>? _contacts;
  bool _permissionDenied = false;
  List<String> allNumbers = [];
  List<String> allNames = [];

  Future _fetchContacts() async {
    print("in fetch data");
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      print("in if statement");
      setState(() => _permissionDenied = true);
    } else {
      print("in else statement");
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);

      log("length ${_contacts!.length}");
      for (int i = 0; i < _contacts!.length; i++) {
        final val = await FlutterContacts.getContact(_contacts![i].id);

        allNumbers.add(val!.phones.isNotEmpty
            ? val.phones.first.normalizedNumber.trim()
            : '');
        allNames.add(val.displayName);
        log("SINGLE ${val.phones.single.number}");
        log("NORMALIZED NUMBER 1 ${val.phones.first.normalizedNumber}");
        log("NORMALIZED NUMBER ${val.phones.last.normalizedNumber}");

        log("ALL NUMBER ${allNumbers[i].trim()}");
        log("index $i");
        log("Name ${_contacts![i].id}");
      }
    }
  }

  int getIndexFromNumber(String name) {
    if (_contacts != null) {
      for (int i = 0; i < allNumbers.length; i++) {
        if (allNumbers.elementAt(i) == name) {
          return i;
        }
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return callController.isLoading.value
            ? loader(context)
            : callController.videoCallListModel.value!.videoCallList!.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Image.asset(
                              "assets/images/no_call_history.png",
                              height: 300),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: callController
                            .videoCallListModel.value!.videoCallList!.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return videocallwidget(callController
                              .videoCallListModel.value!.videoCallList![index]);
                        }),
                  );
      }),
    );
  }

  Widget videocallwidget(VideoCallList videoCallList) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomCachedNetworkImage(
                    imageUrl: videoCallList.profilePic!,
                    errorWidgeticon: Icon(
                      videoCallList.groupname == ""
                          ? Icons.person
                          : Icons.groups_2,
                      size: 30,
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoCallList.groupname == ""
                      ? allNumbers.contains(videoCallList.mobileNumber!)
                          ? allNames[
                              getIndexFromNumber(videoCallList.mobileNumber!)]
                          : capitalizeFirstLetter(videoCallList.username!)
                      : capitalizeFirstLetter(videoCallList.groupname!),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  formatDateTime(DateTime.parse(videoCallList.timestamp!)),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: appgrey2),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                videoCallList.callType == "video_call" &&
                        videoCallList.message == ""
                    ? const Image(
                        image: AssetImage('assets/images/videoo.png'),
                        height: 20,
                      )
                    : videoCallList.callType == "group_video_call"
                        ? const Image(
                            image: AssetImage('assets/images/videoo.png'),
                            height: 20,
                          )
                        : videoCallList.callType == "group_video_call" &&
                                videoCallList.message == "missed call"
                            ? const Image(
                                image: AssetImage(
                                    'assets/images/videocall_missed.png'),
                                height: 20,
                              )
                            : videoCallList.callType == "video_call" &&
                                    videoCallList.message == "missed call"
                                ? const Image(
                                    image: AssetImage(
                                        'assets/images/videocall_missed.png'),
                                    height: 20,
                                  )
                                : videoCallList.callType == "video_call" &&
                                        videoCallList.message ==
                                            "missed call" &&
                                        videoCallList.isComeing == "Outgoing"
                                    ? const Image(
                                        image: AssetImage(
                                            'assets/images/videocall_missed.png'),
                                        height: 20,
                                      )
                                    : const SizedBox()
              ],
            ),
          )
        ],
      ),
    );
  }
}
