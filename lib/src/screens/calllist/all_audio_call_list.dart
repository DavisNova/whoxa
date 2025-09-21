// ignore_for_file: avoid_print, unused_field

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:whoxachat/Models/get_all_audiocall_list_model.dart';
import 'package:whoxachat/controller/call_history_controller.dart';
import 'package:whoxachat/src/global/global.dart';

class AllAudioCallList extends StatefulWidget {
  const AllAudioCallList({super.key});

  @override
  State<AllAudioCallList> createState() => _AllAudioCallListState();
}

class _AllAudioCallListState extends State<AllAudioCallList> {
  CallHistoryController callController = Get.put(CallHistoryController());

  @override
  void initState() {
    callController.callHistoryApiAudio();
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
            : callController.audioCallListModel.value!.missedCallList!.isEmpty
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
                            .audioCallListModel.value!.missedCallList!.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return missedwidget(callController.audioCallListModel
                              .value!.missedCallList![index]);
                        }),
                  );
      }),
    );
  }

  Widget missedwidget(MissedCallList missCallList) {
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
                    imageUrl: missCallList.profilePic!,
                    errorWidgeticon: Icon(
                      missCallList.groupname == ""
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
                  allNumbers.contains(missCallList.mobileNumber!)
                      ? allNames[getIndexFromNumber(missCallList.mobileNumber!)]
                      : capitalizeFirstLetter(missCallList.username!),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  formatDateTime(DateTime.parse(missCallList.timestamp!)),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: appgrey2),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image(
                  image: AssetImage('assets/images/NotRecive.png'),
                  height: 13,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
