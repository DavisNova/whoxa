// ignore_for_file: unused_field, avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/call_history_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/Models/calllistmodel.dart';

class AllCallList extends StatefulWidget {
  const AllCallList({super.key});

  @override
  State<AllCallList> createState() => _AllCallListState();
}

class _AllCallListState extends State<AllCallList> {
  CallHistoryController callController = Get.put(CallHistoryController());

  @override
  void initState() {
    callController.callHistoryApi();
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
    return Scaffold(body: Obx(() {
      return callController.isLoading.value
          ? loader(context)
          : callController.callListModel.value!.messagesList!.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset("assets/images/no_call_history.png",
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
                          .callListModel.value!.messagesList!.length,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return allwidget(callController
                            .callListModel.value!.messagesList![index]);
                      }),
                );
    }));
  }

  Widget allwidget(MessagesList allList) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: appgrey),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomCachedNetworkImage(
                    imageUrl: allList.profilePic!,
                    errorWidgeticon: Icon(
                      allList.groupname == "" ? Icons.person : Icons.groups_2,
                      size: 30,
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                allList.groupname == ""
                    ? Text(
                        allNumbers.contains(allList.mobileNumber!)
                            ? allNames[
                                getIndexFromNumber(allList.mobileNumber!)]
                            : capitalizeFirstLetter(allList.username!),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      )
                    : Text(
                        allList.groupname!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                const SizedBox(height: 5),
                Text(
                  formatDateTime(DateTime.parse(allList.timestamp!)),
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
                allList.callType == "audio_call" &&
                        allList.message == "" &&
                        allList.isComeing == "Outgoing"
                    ? const Image(
                        image: AssetImage('assets/images/call-outgoing.png'),
                        height: 20,
                      )
                    : allList.callType == "audio_call" &&
                            allList.message == "" &&
                            allList.isComeing == "Incoming"
                        ? const Image(
                            image:
                                AssetImage('assets/images/call-incoming.png'),
                            height: 20,
                          )
                        : allList.callType == "audio_call" &&
                                allList.message == "missed call"
                            ? const Image(
                                image:
                                    AssetImage('assets/images/NotRecive.png'),
                                height: 13,
                              )
                            : allList.callType == "video_call" &&
                                    allList.message == "" &&
                                    allList.isComeing == "Incoming"
                                ? const Image(
                                    image:
                                        AssetImage('assets/images/videoo.png'),
                                    height: 20,
                                  )
                                : allList.callType == "video_call" &&
                                        allList.message == "" &&
                                        allList.isComeing == "Outgoing"
                                    ? const Image(
                                        image: AssetImage(
                                            'assets/images/videoo.png'),
                                        height: 20,
                                      )
                                    : allList.callType == "video_call" &&
                                            allList.message == "missed call"
                                        ? const Image(
                                            image: AssetImage(
                                                'assets/images/videocall_missed.png'),
                                            height: 20,
                                          )
                                        : allList.callType ==
                                                    "group_audio_call" &&
                                                allList.message == "" &&
                                                allList.isComeing == "Outgoing"
                                            ? const Image(
                                                image: AssetImage(
                                                    'assets/images/call-outgoing.png'),
                                                height: 20,
                                              )
                                            : allList.callType ==
                                                        "group_audio_call" &&
                                                    allList.message == "" &&
                                                    allList.isComeing ==
                                                        "Incoming"
                                                ? const Image(
                                                    image: AssetImage(
                                                        'assets/images/call-incoming.png'),
                                                    height: 20,
                                                  )
                                                : allList.callType ==
                                                            "group_audio_call" &&
                                                        allList.message ==
                                                            "missed call"
                                                    ? const Image(
                                                        image: AssetImage(
                                                            'assets/images/NotRecive.png'),
                                                        height: 20,
                                                      )
                                                    : allList.callType ==
                                                                "group_video_call" &&
                                                            allList.message ==
                                                                "" &&
                                                            allList.isComeing ==
                                                                "Incoming"
                                                        ? const Image(
                                                            image: AssetImage(
                                                                'assets/images/videoo.png'),
                                                            height: 20,
                                                          )
                                                        : allList.callType ==
                                                                    "group_video_call" &&
                                                                allList.message ==
                                                                    "" &&
                                                                allList.isComeing ==
                                                                    "Outgoing"
                                                            ? const Image(
                                                                image: AssetImage(
                                                                    'assets/images/videoo.png'),
                                                                height: 20,
                                                              )
                                                            : allList.callType ==
                                                                        "group_video_call" &&
                                                                    allList.message ==
                                                                        "missed call"
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
