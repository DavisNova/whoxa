// ignore_for_file: avoid_types_as_parameter_names, avoid_function_literals_in_foreach_calls, empty_catches, prefer_typing_uninitialized_variables, avoid_print, library_prefixes, must_be_immutable, file_names, unused_field

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/controller/group_create_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/userchatlist_model/userchatlist_model.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/Models/get_contact_model.dart';

class AddMembersinGroup extends StatefulWidget {
  String? grpId;
  AddMembersinGroup({super.key, this.grpId});

  @override
  State<AddMembersinGroup> createState() => _AddMembersinGroupState();
}

class _AddMembersinGroupState extends State<AddMembersinGroup> {
  GetAllDeviceContact getAllDeviceContact = Get.find();
  ChatListController chatListController = Get.find();
  GroupCreateController gpCreateController = Get.find();
  @override
  void initState() {
    var contactJson = json.encode(addContactController.mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);

    super.initState();
  }

  List contactID = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          languageController.textTranslate('Add Participants'),
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    languageController.textTranslate('Cancel'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: create(),
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.90,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0.0),
                    topLeft: Radius.circular(0.0))),
            child: SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                  readOnly: false,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 238, 238, 238),
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 238, 238, 238),
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                          const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                      hintText: languageController.textTranslate('Search'),
                      hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 238, 238, 238),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                      ))),
            )),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 20),
                child: Text(
                  languageController.textTranslate('Recent contacts'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              recentContactWidget(context),
              if (hasMatchingContacts())
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    languageController
                        .textTranslate('Contacts on Whoxa'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              if (hasMatchingContacts()) listOfContactWidget(context),
            ],
          ),
        ))
      ]),
    );
  }

//======================================================== RECENT CHAT CONTACT ===========================================
//======================================================== RECENT CHAT CONTACT ===========================================
//======================================================== RECENT CHAT CONTACT ===========================================
  Container recentContactWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              chatListController.userChatListModel.value!.chatList!.length,
          itemBuilder: (context, index) {
            if (chatListController.userChatListModel.value?.chatList == null) {
              return const SizedBox.shrink();
            }
            return recentchatcard(
                chatListController.userChatListModel.value!.chatList![index],
                index);
          },
        ),
      ),
    );
  }

  Widget recentchatcard(ChatList data, index) {
    if (data.isGroup == false) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          onTap: () {
            setState(() {
              contactID.contains(data.userId)
                  ? contactID.remove(data.userId)
                  : contactID.add(data.userId);
            });
            print("CONTACT_ID:$contactID");
          },
          child: SizedBox(
            height: 85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 0),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      data.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      Text(
                        capitalizeFirstLetter(data.userName!),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.phoneNumber!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: contactID.contains(data.userId)
                            ? Colors.white
                            : Colors.blueAccent,
                      ),
                      shape: BoxShape.circle,
                      color: contactID.contains(data.userId)
                          ? Colors.blueAccent
                          : Colors.white),
                  child: const Icon(Icons.check, size: 15, color: Colors.white),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

//================================================================= CONTACT LIST =============================================
//================================================================= CONTACT LIST =============================================
//================================================================= CONTACT LIST =============================================
  bool isMatching(String userid) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (chatListController.userChatListModel.value!.chatList![i].userId
              .toString() ==
          userid) {
        return false;
      }
    }
    return true;
  }

  bool hasMatchingContacts() {
    for (var contact in getAllDeviceContact.getList) {
      if (isMatching(contact.userId.toString())) {
        return true;
      }
    }
    return false;
  }

  Container listOfContactWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          padding: EdgeInsets.zero,
          itemCount: getAllDeviceContact.getList.length,
          itemBuilder: (BuildContext context, int index) {
            return chatcard(getAllDeviceContact.getList[index]).paddingZero;
          },
        ),
      ),
    );
  }

  Widget chatcard(NewContactList data) {
    if (isMatching(data.userId.toString())) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  contactID.contains(data.userId)
                      ? contactID.remove(data.userId)
                      : contactID.add(data.userId);
                });
              },
              child: SizedBox(
                height: 85,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 0),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          data.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Text(
                            capitalizeFirstLetter(data.userName!),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                data.phoneNumber!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: contactID.contains(data.userId)
                                ? Colors.blueAccent
                                : Colors.white,
                          ),
                          shape: BoxShape.circle,
                          color: contactID.contains(data.userId)
                              ? Colors.white
                              : Colors.blueAccent),
                      child: const Icon(Icons.check,
                          size: 15, color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget create() {
    return Obx(() {
      return gpCreateController.isMember.value
          ? loader(context)
          : InkWell(
              onTap: () async {
                FocusScope.of(context).unfocus();
                log(persons.length.toString());

                if (contactID.isNotEmpty) {
                  await gpCreateController.addToGroupMember(
                      widget.grpId!, contactID);
                } else {
                  showCustomToast(
                      languageController.textTranslate('Please select member'));
                }
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: chatownColor,
                ),
                child: Center(
                  child: Text(
                    languageController.textTranslate("Create"),
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
              ),
            );
    });
  }
}
