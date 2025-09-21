// ignore_for_file: avoid_types_as_parameter_names, avoid_function_literals_in_foreach_calls, empty_catches, prefer_typing_uninitialized_variables, avoid_print, library_prefixes, must_be_immutable, file_names, unused_field, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/my_contacts_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/Models/get_contact_model.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/Group/create_gp.dart';

class AddMembersinGroup1 extends StatefulWidget {
  String? grpId;
  AddMembersinGroup1({super.key, this.grpId});

  @override
  State<AddMembersinGroup1> createState() => _AddMembersinGroup1State();
}

class _AddMembersinGroup1State extends State<AddMembersinGroup1> {
  GetAllDeviceContact getAllDeviceContact = Get.find();
  ChatListController chatListController = Get.find();
  List<MyContactList> filteredChatList = [];
  List<NewContactList> filteredContactList = [];
  String searchQuery = '';
  List contactID = [];
  List<SelectedContact> contactData = [];

  @override
  void initState() {
    addMeInSelectedContactList();
    var contactJson = json.encode(addContactController.mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);

    // Safely initialize filteredChatList
    filteredChatList =
        getAllDeviceContact.myContactsData.value.myContactList ?? [];

    // Safely initialize filteredContactList
    filteredContactList = getAllDeviceContact.getList;
    super.initState();
  }

  addMeInSelectedContactList() {
    contactData.add(
      SelectedContact(
        userId: Hive.box(userdata).get(userId),
        userName: "You",
        profileImage: Hive.box(userdata).get(userImage).toString(),
      ),
    );
  }

  void filterSearchResults(String query) {
    List<MyContactList> chatSearchResults = [];
    List<NewContactList> contactSearchResults = [];

    if (query.isNotEmpty) {
      chatSearchResults = (getAllDeviceContact
          .myContactsData.value.myContactList ?? [])
          .where((chat) =>
              chat.fullName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      contactSearchResults = getAllDeviceContact.getList
          .where((contact) =>
              contact.fullName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      chatSearchResults =
          getAllDeviceContact.myContactsData.value.myContactList!;
      contactSearchResults = getAllDeviceContact.getList;
    }

    setState(() {
      searchQuery = query;
      filteredChatList = chatSearchResults;
      filteredContactList = contactSearchResults;
    });
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: secondaryColor.withOpacity(0.05),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor.withOpacity(0.04),
                  chatownColor.withOpacity(0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: chatColor,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  languageController.textTranslate('Add Participants'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
                const Spacer(),
                containerWidget(
                  onTap: () async {
                    if (contactData.isNotEmpty) {
                      final result = await Get.to(() => MyWidget(
                          contactData: contactData, contactID: contactID));
                      setState(() {
                        contactData.length = result;
                      });
                    } else {
                      showCustomToast("Please select members");
                    }
                  },
                  title: languageController.textTranslate('Next'),
                ),
              ],
            ).paddingOnly(top: 30).paddingSymmetric(
                  horizontal: 28,
                ),
          ),
          const Divider(
            color: Color(0xffE9E9E9),
            height: 1,
          ),
          const SizedBox(height: 20),
          commonSearchField(
            context: context,
            controller: _searchController,
            onChanged: filterSearchResults,
            hintText: languageController.textTranslate('Search name or number'),
          ),
          // Container(
          //     width: MediaQuery.of(context).size.width * 0.90,
          //     decoration: const BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.only(
          //             topRight: Radius.circular(0.0),
          //             topLeft: Radius.circular(0.0))),
          //     child: SizedBox(
          //       height: 45,
          //       width: MediaQuery.of(context).size.width * 0.9,
          //       child: TextField(
          //           cursorColor: Colors.black,
          //           readOnly: false,
          //           onChanged: filterSearchResults,
          //           decoration: InputDecoration(
          //             enabledBorder: OutlineInputBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //                 borderSide: const BorderSide(
          //                   color: Color.fromARGB(255, 238, 238, 238),
          //                 )),
          //             focusedBorder: OutlineInputBorder(
          //                 borderSide: const BorderSide(
          //                   color: Color.fromARGB(255, 238, 238, 238),
          //                 ),
          //                 borderRadius: BorderRadius.circular(10)),
          //             contentPadding:
          //                 const EdgeInsets.only(top: 1, left: 15, bottom: 1),
          //             hintText: languageController
          //                 .textTranslate('Search name or number'),
          //             hintStyle: const TextStyle(
          //                 fontSize: 12,
          //                 color: Colors.grey,
          //                 fontWeight: FontWeight.w400),
          //             filled: true,
          //             fillColor: const Color.fromARGB(255, 238, 238, 238),
          //             prefixIcon: const Padding(
          //               padding: EdgeInsets.all(13),
          //               child: Image(
          //                 image: AssetImage('assets/icons/search.png'),
          //               ),
          //             ),
          //           )),
          //     )),
          const SizedBox(height: 10),
          contactData.isEmpty ? const SizedBox.shrink() : selectedUsersList(),
          contactData.isEmpty
              ? const SizedBox.shrink()
              : Divider(color: Colors.grey.shade300),
          Expanded(
              child: filteredChatList.isEmpty
                  ? commonImageTexts(
                      image: "assets/images/no_contact_found_1.png",
                      text1: languageController.textTranslate("No Users found"),
                      text2: languageController
                          .textTranslate("Invite more users or add them"),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (searchQuery.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 20),
                              child: Text(
                                languageController
                                    .textTranslate('Frequently Contacted'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                          recentContactWidget(context),
                        ],
                      ),
                    ))
        ]),
      ),
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
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredChatList.length,
          // itemBuilder: (context, index) {
          //   return filteredChatList[index].userDetails!.userId.toString() ==
          //           Hive.box(userdata).get(userId).toString()
          //       ? const SizedBox.shrink()
          //       : recentchatcard(filteredChatList[index], index);
          // },
          // Modify this line in your ListView.builder itemBuilder
          itemBuilder: (context, index) {
            // Check if user ID exists before accessing it
            final chatUserDetails = filteredChatList[index].userDetails;
            if (chatUserDetails == null) {
              return const SizedBox.shrink(); // Skip invalid entries
            }

            // Safely get current user ID from Hive
            final currentUserId = Hive.box(userdata).get(userId)?.toString() ?? "";
            final chatUserId = chatUserDetails.userId?.toString() ?? "";

            // Compare IDs and return appropriate widget
            return chatUserId == currentUserId
                ? const SizedBox.shrink()
                : recentchatcard(filteredChatList[index], index);
          },
        ),
      ),
    );
  }

  Widget recentchatcard(MyContactList data, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            contactID.contains(data.userDetails!.userId.toString())
                ? contactID.remove(data.userDetails!.userId.toString())
                : contactID.add(data.userDetails!.userId.toString());
          });
          setState(() {
            SelectedContact selectedContact = SelectedContact(
              userId: data.userDetails?.userId ?? 0,
              userName: data.fullName,
              profileImage: data.userDetails?.profileImage ?? '',
            );

            bool isSelect = contactData.contains(selectedContact);

            isSelect
                ? contactData.remove(selectedContact)
                : contactData.insert(0, selectedContact);
          });
          print("CONTACT_ID:$contactID");
          print("CONTACT-DATA:$contactData");
        },
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 0),
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    data.userDetails?.profileImage ?? '',
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
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            capitalizeFirstLetter(data.fullName),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Add the verification logo widget here
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.phoneNumber,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color.fromRGBO(73, 73, 73, 1)),
                    ),
                  ],
                ),
              ),
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: contactID.contains((data.userDetails?.userId ?? 0).toString()) ||
                              contactData.contains(SelectedContact(
                                  userId: data.userDetails?.userId ?? 0,
                                  userName: data.fullName,
                                  profileImage:
                                      data.userDetails?.profileImage ?? ''))
                          ? Colors.white
                          : chatownColor,
                    ),
                    shape: BoxShape.circle,
                    color: contactID.contains((data.userDetails?.userId ?? 0).toString()) ||
                            contactData.contains(SelectedContact(
                                userId: data.userDetails?.userId ?? 0,
                                userName: data.fullName,
                                profileImage: data.userDetails?.profileImage ?? ''))
                        ? chatownColor
                        : Colors.white),
                child: Icon(Icons.check,
                    size: 15,
                    color: contactID.contains((data.userDetails?.userId ?? 0).toString()) ||
                            contactData.contains(SelectedContact(
                                userId: data.userDetails?.userId ?? 0,
                                userName: data.fullName,
                                profileImage: data.userDetails?.profileImage ?? ''))
                        ? Colors.black
                        : Colors.white),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
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
          itemCount: filteredContactList.length,
          itemBuilder: (BuildContext context, int index) {
            return chatcard(filteredContactList[index]).paddingZero;
          },
        ),
      ),
    );
  }

  Widget chatcard(NewContactList data) {
    if (isMatching(data.userId.toString())) {
      return Hive.box(userdata).get(userMobile) == data.phoneNumber!
          ? const SizedBox.shrink()
          : Padding(
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
                      setState(() {
                        SelectedContact selectedContact = SelectedContact(
                          userId: data.userId!,
                          userName: data.userName!,
                          profileImage: data.profileImage!,
                        );

                        bool isSelect = contactData.contains(selectedContact);

                        isSelect
                            ? contactData.remove(selectedContact)
                            : contactData.add(selectedContact);
                      });
                    },
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 0),
                          Container(
                            height: 45,
                            width: 45,
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
                                const SizedBox(height: 17),
                                Text(
                                  capitalizeFirstLetter(data.fullName ?? ''),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      data.phoneNumber!,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color.fromRGBO(73, 73, 73, 1),
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
                                  color: contactID.contains(data.userId) ||
                                          contactData.contains(SelectedContact(
                                              userId: data.userId!,
                                              userName: data.userName!,
                                              profileImage: data.profileImage!))
                                      ? Colors.white
                                      : chatownColor,
                                ),
                                shape: BoxShape.circle,
                                color: contactID.contains(data.userId) ||
                                        contactData.contains(SelectedContact(
                                            userId: data.userId!,
                                            userName: data.userName!,
                                            profileImage: data.profileImage!))
                                    ? chatownColor
                                    : Colors.white),
                            child: Icon(Icons.check,
                                size: 15,
                                color: contactID.contains(data.userId) ||
                                        contactData.contains(SelectedContact(
                                            userId: data.userId!,
                                            userName: data.userName!,
                                            profileImage: data.profileImage!))
                                    ? Colors.black
                                    : Colors.white),
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

  Widget selectedUsersList() {
    return SizedBox(
        height: 80,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ListView.builder(
            itemCount: contactData.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, top: 9),
            itemBuilder: (context, index) {
              return InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  if (contactData[index].userId.toString() !=
                      Hive.box(userdata).get(userId).toString()) {
                    setState(() {
                      contactData.removeAt(index);
                    });
                  }
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              contactData[index].profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                        Hive.box(userdata).get(userId) ==
                                contactData[index].userId
                            ? const SizedBox.shrink()
                            : Positioned(
                                top: 1,
                                right: 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      contactData.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.black),
                                        color: chatownColor),
                                    child: const Center(
                                      child: Icon(Icons.close,
                                          color: Colors.black, size: 7),
                                    ),
                                  ),
                                ))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      contactData[index].userName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500),
                    )
                  ],
                ).paddingOnly(right: 20),
              );
            },
          ),
        ));
  }
}
