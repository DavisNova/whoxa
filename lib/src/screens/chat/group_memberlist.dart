// ignore_for_file: must_be_immutable, avoid_print, use_build_context_synchronously, unused_field, unused_local_variable, library_prefixes
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/controller/group_create_controller.dart';
import 'package:whoxachat/controller/single_chat_media_controller.dart';
import 'package:whoxachat/model/chat_profile_model.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:whoxachat/src/global/global.dart';

class GetMembersinGroup extends StatefulWidget {
  String? grpId;
  GetMembersinGroup({super.key, this.grpId});

  @override
  State<GetMembersinGroup> createState() => _GetMembersinGroupState();
}

class _GetMembersinGroupState extends State<GetMembersinGroup> {
  GetAllDeviceContact getAllDeviceContact = Get.find();
  ChatProfileController chatProfileController = Get.find();
  GroupCreateController gpCreateController = Get.put(GroupCreateController());
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
        backgroundColor: appColorWhite,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 50,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, size: 17),
        ),
        title: Text(
          languageController.textTranslate('Add Participants'),
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Obx(() {
                return gpCreateController.isMember.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.black),
                        ),
                      )
                    : containerWidget(
                        onTap: () {
                          contactID.isNotEmpty
                              ? gpCreateController.addToGroupMember(
                                  widget.grpId!, contactID)
                              : showCustomToast(languageController
                                  .textTranslate('Please select member'));
                        },
                        title: languageController.textTranslate('Next'),
                      );
              }))
        ],
      ),
      body: Obx(() {
        return SafeArea(
            child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
              child: Column(
            children: [getlistOfContactWidget(context), contactList()],
          )),
        ));
      }),
    );
  }

//======================================= AlREADY ADDED GROUP MEMBERS LIST ======================================

  Container getlistOfContactWidget(BuildContext context) {
    String? loggedInUserId = Hive.box(userdata).get(userId).toString();
    return chatProfileController.isLoading.value
        ? Container()
        : Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemCount: chatProfileController.users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Hive.box(userdata).get(userId) ==
                              chatProfileController.users[index].user!.userId
                                  .toString()
                          ? const SizedBox.shrink()
                          : chatcard(chatProfileController.users[index]);
                    })),
          );
  }

//==================================================================================================================================
  bool isAlreadyAddedRemove(String number) {
    for (int i = 0; i < chatProfileController.users.length; i++) {
      if (number == chatProfileController.users[i].user!.phoneNumber) {
        return false;
      }
    }
    return true;
  }

  Widget contactList() {
    final allContacts = getAllDeviceContact.myContactsData.value.myContactList!;

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: allContacts.length,
            itemBuilder: (BuildContext context, int index) {
              final contact = allContacts[index];

              return chatProfileController.users
                      .where((element) =>
                          element.user!.userId! == contact.userDetails!.userId)
                      .toList()
                      .isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                contactID.contains(contact.userDetails!.userId!)
                                    ? contactID
                                        .remove(contact.userDetails!.userId!)
                                    : contactID
                                        .add(contact.userDetails!.userId!);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                  color: (index != allContacts.length - 1)
                                      ? Colors.grey
                                      : Colors.transparent,
                                  width: 0.2,
                                ),
                              )),
                              height: 70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                    width: 0,
                                  ),
                                  Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: CustomCachedNetworkImage(
                                            imageUrl: contact
                                                .userDetails!.profileImage,
                                            placeholderColor: chatownColor,
                                            errorWidgeticon:
                                                const Icon(Icons.person))),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 17,
                                        ),
                                        Text(
                                          contact.fullName,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              contact.phoneNumber,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
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
                                          color: contactID.contains(
                                                  contact.userDetails!.userId!)
                                              ? Colors.white
                                              : chatownColor,
                                        ),
                                        shape: BoxShape.circle,
                                        color: contactID.contains(
                                                contact.userDetails!.userId!)
                                            ? chatownColor
                                            : Colors.white),
                                    child: Icon(Icons.check,
                                        size: 15,
                                        color: contactID.contains(
                                                contact.userDetails!.userId!)
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          )),
    );
  }

  Widget chatcard(ConversationsUsers data) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.2,
          ),
        )),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 0,
            ),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CustomCachedNetworkImage(
                      imageUrl: data.user!.profileImage!,
                      placeholderColor: chatownColor,
                      errorWidgeticon: const Icon(Icons.person))),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 17),
                  Text(
                    Hive.box(userdata).get(userId) == data.user!.userId
                        ? languageController.textTranslate('You')
                        : capitalizeFirstLetter(data.user!.userName!),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Text(
                        data.user!.phoneNumber!,
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
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: secondaryColor),
              child: const Icon(
                Icons.check,
                size: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              width: 5,
            )
          ],
        ),
      ),
    );
  }

  Widget block() {
    return Obx(() {
      return gpCreateController.isMember.value
          ? loader(context)
          : InkWell(
              onTap: () {
                contactID.isNotEmpty
                    ? gpCreateController.addToGroupMember(
                        widget.grpId!, contactID)
                    : showCustomToast(languageController
                        .textTranslate('Please select member'));
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
                    languageController.textTranslate('Add Participants'),
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
