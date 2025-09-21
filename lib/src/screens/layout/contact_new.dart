// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, prefer_is_empty, must_be_immutable, deprecated_member_use, unused_field, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/add_contact_controller.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/userchatlist_model/userchatlist_model.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/screens/Group/add_gp_member.dart';
import 'package:whoxachat/src/screens/chat/create_group.dart';
import 'package:whoxachat/src/screens/chat/shareable/common_permission_dialog.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:whoxachat/src/screens/user/search_user_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

class FlutterContactsExample extends StatefulWidget {
  bool isValue;
  FlutterContactsExample({super.key, required this.isValue});

  @override
  _FlutterContactsExampleState createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  List<Contact>? _contacts;

  TextEditingController controller = TextEditingController();
  String searchText = '';
  GetAllDeviceContact getAllDeviceContact = Get.find();
  AddContactController addContactController = Get.find();
  ChatListController chatListController = Get.find();
  List<Contact> filteredContacts = [];
  bool _isPermissionGranted = false;

  @override
  void initState() {
    Get.put(ChatListController());
    _checkContactPermission();

    apis();
    log(Hive.box(userdata).get(userMobile), name: "USER-MOBILE");
    super.initState();
  }

  @override
  dispose() {
    // debugPrint("Inside the Dispose of contacts");
    getAllDeviceContact.myContact();
    super.dispose();
  }

  Future<void> _checkContactPermission() async {
    var permission = await Permission.contacts.request();

    if (permission.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
    } else if (permission.isDenied) {
      // If denied, show a message or retry
      print("Permission denied. Ask user to grant manually.");
    } else if (permission.isPermanentlyDenied) {
      // Open app settings if permanently denied
      // openAppSettings();
      PermissionUtil.showPermissionSettingsDialog(
          context,
          "Location", // or "Location", "Microphone", etc.
          languageController.textTranslate,
          chatownColor,
          secondaryColor);
    }
  }

  Future<void> apis() async {
    log("MY_DEVICE_CONTACS: ${addContactController.mobileContacts}");

    chatListController.forChatList();
  }

  void filterContacts(String query) {
    if (_contacts != null) {
      setState(() {
        filteredContacts = _contacts!
            .where((contact) =>
                contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  bool isChat = false;
  String getUserID(String mobileNum) {
    for (int i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (chatListController.userChatListModel.value!.chatList![i].isGroup ==
          false) {
        if (mobileNum ==
            chatListController
                .userChatListModel.value!.chatList![i].phoneNumber) {
          return chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString();
        }
        isChat = true;
      }
    }
    return '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Image.network(
          languageController.appSettingsData[0].appLogo!,
          height: 45,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Get.to(() => const SearchUserScreen());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: appColorWhite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: commonSearchField(
                        context: context,
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toLowerCase().trim();
                          });
                        },
                        hintText: languageController
                            .textTranslate('Search name or number'),
                      ),
                      //     Container(
                      //   height: 50,
                      //   width: MediaQuery.of(context).size.width * 0.9,
                      //   decoration: BoxDecoration(
                      //       color: const Color.fromRGBO(238, 238, 238, 1),
                      //       borderRadius: BorderRadius.circular(10)),
                      //   child: TextField(
                      //     controller: controller,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         searchText = value.toLowerCase().trim();
                      //       });
                      //     },
                      //     decoration: InputDecoration(
                      //       prefixIcon: const Padding(
                      //         padding: EdgeInsets.all(17),
                      //         child: Image(
                      //           image: AssetImage('assets/icons/search.png'),
                      //         ),
                      //       ),
                      //       hintText: languageController
                      //           .textTranslate('Search name or number'),
                      //       hintStyle: const TextStyle(
                      //           fontSize: 12, color: Colors.grey),
                      //       filled: true,
                      //       fillColor: Colors.transparent,
                      //       border: const OutlineInputBorder(
                      //         borderSide: BorderSide.none,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {
                  Get.to(() => AddMembersinGroup1());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Row(
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Center(
                              child: Image.asset(
                                "assets/images/group1.png",
                                color: chatownColor,
                              ),
                            )),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        languageController.textTranslate('New Group'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: chatownColor,
                  onRefresh: () async {
                    var contactJson =
                        json.encode(addContactController.mobileContacts);
                    await getAllDeviceContact.myContact();
                    await getAllDeviceContact.getAllContactApi(
                        contact: contactJson);
                  },
                  child: Obx(
                    () => addContactController
                                    .isGetContectsFromDeviceLoading.value ==
                                true &&
                            (getAllDeviceContact
                                        .myContactsData.value.myContactList ==
                                    null ||
                                addContactController.allcontacts.isEmpty)
                        ? loader(context)
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //   controller.text.trim().isEmpty
                                //       ? contactDesign()
                                //       : const SizedBox.shrink(),
                                //   getAllDeviceContact.myContactsData.value
                                //                   .myContactList !=
                                //               null &&
                                //           getAllDeviceContact.myContactsData.value
                                //               .myContactList!.isNotEmpty
                                //       ? contactsWidget()
                                //       : const SizedBox.shrink(),
                                //   controller.text.trim().isEmpty
                                //       ? const SizedBox(height: 5)
                                //       : const SizedBox.shrink(),
                                //   controller.text.trim().isEmpty
                                //       ? Divider(
                                //           thickness: 1.5,
                                //           color: Colors.grey.shade200,
                                //         )
                                //       : const SizedBox.shrink(),
                                //   controller.text.trim().isEmpty
                                //       ? Padding(
                                //           padding: const EdgeInsets.only(
                                //               left: 18, top: 10),
                                //           child: Text(
                                //             '${languageController.textTranslate('Invite to whoxa Messenger')} ',
                                //             style: const TextStyle(
                                //                 fontSize: 16,
                                //                 fontWeight: FontWeight.w600),
                                //           ),
                                //         )
                                //       : const SizedBox.shrink(),
                                //   controller.text.trim().isEmpty
                                //       ? const SizedBox(height: 5)
                                //       : const SizedBox.shrink(),
                                //   inviteFriend(searchText)
                                // ],

                                // controller.text.trim().isEmpty
                                //     ?
                                contactDesign(),
                                // : const SizedBox.shrink(),
                                // : SizedBox(
                                //     height: 100,
                                //     child: Center(
                                //         child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       children: [
                                //         Text(languageController.textTranslate(
                                //             'You don\'t have any contact using this app.')),
                                //       ],
                                //     )),
                                //   ),
                                getAllDeviceContact.myContactsData.value
                                            .myContactList !=
                                        null
                                    //     &&
                                    // getAllDeviceContact.myContactsData
                                    //     .value.myContactList!.isNotEmpty
                                    ? contactsWidget()
                                    : (getAllDeviceContact.myContactsData.value
                                                .myContactList != null &&
                                            getAllDeviceContact.myContactsData.value
                                                .myContactList!.isEmpty &&
                                            controller.text.isNotEmpty)
                                        ? Text('No search found')
                                        : (getAllDeviceContact.myContactsData.value
                                                .myContactList != null &&
                                            getAllDeviceContact.myContactsData.value
                                                .myContactList!.isEmpty)
                                            ? Text('No contact found')
                                            : const SizedBox.shrink(),
                                controller.text.trim().isEmpty
                                    ? const SizedBox(height: 5)
                                    : const SizedBox.shrink(),
                                controller.text.trim().isEmpty
                                    ? Divider(
                                        thickness: 1.5,
                                        color: Colors.grey.shade200,
                                      )
                                    : const SizedBox.shrink(),
                                // controller.text.trim().isEmpty
                                //     ?
                                getFilteredContacts(searchText).isEmpty
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 18, top: 10),
                                        child: Text(
                                          '${languageController.textTranslate('Invite to ${languageController.appSettingsData[0].appName!}')} ',
                                          // '${languageController.textTranslate('Invite Friend to ${appName}')} ',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                // : const SizedBox.shrink(),
                                // controller.text.trim().isEmpty
                                //     ?
                                getFilteredContacts(searchText).isEmpty
                                    ? SizedBox.shrink()
                                    : const SizedBox(height: 5),
                                // : const SizedBox.shrink(),
                                getFilteredContacts(searchText).isEmpty
                                    ? SizedBox.shrink()
                                    : inviteFriend(searchText)
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget contactsWidget() {
  //   return getAllDeviceContact.isGetMYContectLoading.value == true
  //       ? loader(context)
  //       : getAllDeviceContact.myContactsData.value.myContactList!.isNotEmpty
  //           ? ListView.separated(
  //               padding: const EdgeInsets.all(0),
  //               itemCount: getAllDeviceContact
  //                   .myContactsData.value.myContactList!
  //                   .where((contact) => contact.fullName!
  //                       .toLowerCase()
  //                       .contains(searchText.toLowerCase()))
  //                   .length,
  //               shrinkWrap: true,
  //               physics: const NeverScrollableScrollPhysics(),
  //               separatorBuilder: (context, index) {
  //                 var filteredContacts = getAllDeviceContact
  //                     .myContactsData.value.myContactList!
  //                     .where((contact) => contact.fullName!
  //                         .toLowerCase()
  //                         .contains(searchText.toLowerCase()))
  //                     .toList();

  //                 if (filteredContacts.isEmpty) {
  //                   return const SizedBox.shrink();
  //                 }

  //                 var contact = filteredContacts[index];
  //                 return getAllDeviceContact.myContactsData.value.myContactList!
  //                         .any((element) =>
  //                             element.phoneNumber.toString() ==
  //                             Hive.box(userdata).get(userMobile))
  //                     ? Hive.box(userdata).get(userMobile) ==
  //                             contact.phoneNumber.toString()
  //                         ? const SizedBox.shrink()
  //                         : Divider(
  //                             color: Colors.grey.shade300,
  //                           )
  //                     : index !=
  //                             getAllDeviceContact.myContactsData.value
  //                                     .myContactList!.length -
  //                                 1
  //                         ? Divider(
  //                             color: Colors.grey.shade300,
  //                           )
  //                         : const SizedBox.shrink();
  //               },
  //               itemBuilder: (BuildContext context, int index) {
  //                 var filteredContacts = getAllDeviceContact
  //                     .myContactsData.value.myContactList!
  //                     .where((contact) => contact.fullName!
  //                         .toLowerCase()
  //                         .contains(searchText.toLowerCase()))
  //                     .toList();

  //                 if (filteredContacts.isEmpty) {
  //                   return const SizedBox.shrink();
  //                 }

  //                 var contact = filteredContacts[index];
  //                 return Hive.box(userdata).get(userMobile) ==
  //                         contact.phoneNumber.toString()
  //                     ? const SizedBox.shrink()
  //                     : Column(
  //                         children: <Widget>[
  //                           ListTile(
  //                             onTap: () {
  //                               // Safely check if model and chatList exist
  //                               final chatListModel =
  //                                   chatListController.userChatListModel.value;
  //                               if (chatListModel == null) {
  //                                 print('Chat list model is null');
  //                                 return;
  //                               }

  //                               final chatList = chatListModel.chatList;
  //                               if (chatList == null) {
  //                                 print('Chat list is null');
  //                                 return;
  //                               }

  //                               // Safely check user details
  //                               final userDetails = contact.userDetails;
  //                               if (userDetails == null) {
  //                                 print('User details are null');
  //                                 return;
  //                               }

  //                               final userId = userDetails.userId?.toString();
  //                               if (userId == null || userId.isEmpty) {
  //                                 print('User ID is null or empty');
  //                                 return;
  //                               }

  //                               final fullName = contact.fullName ?? 'Unknown';
  //                               final profileImage = userDetails.profileImage;
  //                               final phoneNumber =
  //                                   contact.phoneNumber?.toString() ?? '';

  //                               if (chatList.isEmpty) {
  //                                 print('Chat list is empty');
  //                                 Get.to(() => SingleChatMsg(
  //                                       conversationID: '',
  //                                       username: fullName,
  //                                       userPic: profileImage,
  //                                       mobileNum: phoneNumber,
  //                                       index: 0,
  //                                       userID: userId,
  //                                     ));
  //                               } else {
  //                                 final matchingChats = chatList.where(
  //                                     (element) =>
  //                                         userId == element.userId?.toString());

  //                                 if (matchingChats.isNotEmpty) {
  //                                   ChatList data = matchingChats.first;
  //                                   Get.to(() => SingleChatMsg(
  //                                         conversationID:
  //                                             data.conversationId?.toString() ??
  //                                                 '',
  //                                         username: fullName,
  //                                         userPic: profileImage,
  //                                         mobileNum: phoneNumber,
  //                                         index: 0,
  //                                         isBlock: data.isBlock,
  //                                         userID: userId,
  //                                       ));
  //                                 } else {
  //                                   Get.to(() => SingleChatMsg(
  //                                         conversationID: '',
  //                                         username: fullName,
  //                                         userPic: profileImage,
  //                                         mobileNum: phoneNumber,
  //                                         index: 0,
  //                                         userID: userId,
  //                                       ));
  //                                 }
  //                               }
  //                             },
  //                             // onTap: () {
  //                             //   if (chatListController.userChatListModel.value!
  //                             //       .chatList!.isEmpty) {
  //                             //     print('asdasd');
  //                             //     Get.to(() => SingleChatMsg(
  //                             //           conversationID: '',
  //                             //           username: contact.fullName!,
  //                             //           userPic:
  //                             //               contact.userDetails!.profileImage,
  //                             //           mobileNum:
  //                             //               contact.phoneNumber.toString(),
  //                             //           index: 0,
  //                             //           userID: contact.userDetails!.userId
  //                             //               .toString(),
  //                             //         ));
  //                             //   } else {
  //                             //     if (chatListController
  //                             //         .userChatListModel.value!.chatList!
  //                             //         .where((element) =>
  //                             //             contact.userDetails!.userId
  //                             //                 .toString() ==
  //                             //             element.userId!.toString())
  //                             //         .isNotEmpty) {
  //                             //       ChatList data = chatListController
  //                             //           .userChatListModel.value!.chatList!
  //                             //           .where((element) =>
  //                             //               contact.userDetails!.userId
  //                             //                   .toString() ==
  //                             //               element.userId!.toString())
  //                             //           .first;
  //                             //       Get.to(() => SingleChatMsg(
  //                             //             conversationID:
  //                             //                 data.conversationId.toString(),
  //                             //             username: contact.fullName!,
  //                             //             userPic:
  //                             //                 contact.userDetails!.profileImage,
  //                             //             mobileNum:
  //                             //                 contact.phoneNumber.toString(),
  //                             //             index: 0,
  //                             //             isBlock: data.isBlock,
  //                             //             userID: data.userId.toString(),
  //                             //           ));
  //                             //     } else {
  //                             //       Get.to(
  //                             //         () => SingleChatMsg(
  //                             //           conversationID: '',
  //                             //           username: contact.fullName!,
  //                             //           userPic:
  //                             //               contact.userDetails!.profileImage,
  //                             //           mobileNum:
  //                             //               contact.phoneNumber.toString(),
  //                             //           index: 0,
  //                             //           userID: contact.userDetails!.userId!
  //                             //               .toString(),
  //                             //         ),
  //                             //       );
  //                             //     }
  //                             //   }
  //                             // },
  //                             leading: Container(
  //                               height: 45,
  //                               width: 45,
  //                               decoration: BoxDecoration(
  //                                 color: Colors.grey.shade200,
  //                                 shape: BoxShape.circle,
  //                               ),
  //                               child: ClipRRect(
  //                                   borderRadius: BorderRadius.circular(100),
  //                                   child: CustomCachedNetworkImage(
  //                                       imageUrl:
  //                                           contact.userDetails!.profileImage!,
  //                                       placeholderColor: chatownColor,
  //                                       errorWidgeticon:
  //                                           const Icon(Icons.person))),
  //                             ),
  //                             title: Text(
  //                               contact.fullName!,
  //                               style: const TextStyle(
  //                                 fontSize: 15.0,
  //                                 fontFamily: 'Poppins',
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                             subtitle: Container(
  //                               padding: const EdgeInsets.only(top: 2.0),
  //                               child: Text(
  //                                 contact.phoneNumber.toString(),
  //                                 style: const TextStyle(
  //                                     fontSize: 13,
  //                                     color: Color.fromRGBO(73, 73, 73, 1)),
  //                               ),
  //                             ),
  //                             trailing: Image.asset("assets/images/Chat1.png",
  //                                 height: 10),
  //                           ),
  //                         ],
  //                       );
  //               },
  //             )
  //           : SizedBox(
  //               height: 100,
  //               child: Center(
  //                   child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(languageController.textTranslate(
  //                       'You do not have any contact in whoxa!')),
  //                 ],
  //               )),
  //             );
  // }

  // Widget contactsWidget() {
  //   // Add debugging info first
  //   log("isGetMYContectLoading: ${getAllDeviceContact.isGetMYContectLoading.value}",
  //       name: "WIDGET");
  //   log("myContactsData.value null? ${getAllDeviceContact.myContactsData.value == null}",
  //       name: "WIDGET");
  //   log("myContactList null? ${getAllDeviceContact.myContactsData.value.myContactList == null}",
  //       name: "WIDGET");

  //   if (getAllDeviceContact.myContactsData.value.myContactList != null) {
  //     log("myContactList length: ${getAllDeviceContact.myContactsData.value.myContactList!.length}",
  //         name: "WIDGET");
  //   }

  //   // Now return the actual widget with a safer null check
  //   return getAllDeviceContact.isGetMYContectLoading.value == true
  //       ? loader(context)
  //       : getAllDeviceContact.myContactsData.value.myContactList != null &&
  //               getAllDeviceContact
  //                   .myContactsData.value.myContactList!.isNotEmpty
  //           ? ListView.builder(
  //               padding: const EdgeInsets.all(0),
  //               itemCount: getAllDeviceContact
  //                   .myContactsData.value.myContactList!
  //                   .where((contact) =>
  //                       contact.fullName != null &&
  //                       contact.fullName!
  //                           .toLowerCase()
  //                           .contains(searchText.toLowerCase()))
  //                   .length,
  //               shrinkWrap: true,
  //               physics: const NeverScrollableScrollPhysics(),
  //               itemBuilder: (BuildContext context, int index) {
  //                 // Get filtered contacts based on search text
  //                 var filteredContacts = getAllDeviceContact
  //                     .myContactsData.value.myContactList!
  //                     .where((contact) =>
  //                         contact.fullName != null &&
  //                         contact.fullName!
  //                             .toLowerCase()
  //                             .contains(searchText.toLowerCase()))
  //                     .toList();

  //                 if (filteredContacts.isEmpty) {
  //                   return const SizedBox.shrink();
  //                 }

  //                 var contact = filteredContacts[index];

  //                 // Skip showing current user's contact
  //                 if (Hive.box(userdata).get(userMobile) ==
  //                     contact.phoneNumber.toString()) {
  //                   return const SizedBox.shrink();
  //                 }

  //                 return Column(
  //                   children: <Widget>[
  //                     ListTile(
  //                       onTap: () {
  //                         // Safely check if model and chatList exist
  //                         final chatListModel =
  //                             chatListController.userChatListModel.value;
  //                         if (chatListModel == null) {
  //                           print('Chat list model is null');
  //                           return;
  //                         }

  //                         final chatList = chatListModel.chatList;
  //                         if (chatList == null) {
  //                           print('Chat list is null');
  //                           return;
  //                         }

  //                         // Safely check user details
  //                         final userDetails = contact.userDetails;
  //                         if (userDetails == null) {
  //                           print('User details are null');
  //                           return;
  //                         }

  //                         final userId = userDetails.userId?.toString();
  //                         if (userId == null || userId.isEmpty) {
  //                           print('User ID is null or empty');
  //                           return;
  //                         }

  //                         final fullName = contact.fullName ?? 'Unknown';
  //                         final profileImage = userDetails.profileImage;
  //                         final phoneNumber =
  //                             contact.phoneNumber?.toString() ?? '';

  //                         if (chatList.isEmpty) {
  //                           print('Chat list is empty');
  //                           Get.to(() => SingleChatMsg(
  //                                 conversationID: '',
  //                                 username: fullName,
  //                                 userPic: profileImage,
  //                                 mobileNum: phoneNumber,
  //                                 index: 0,
  //                                 userID: userId,
  //                                 verificationBadge:
  //                                     contact.userDetails?.verificationType !=
  //                                             null
  //                                         ? contact.userDetails
  //                                             ?.verificationType?.logo
  //                                         : '',
  //                               ));
  //                         } else {
  //                           final matchingChats = chatList.where((element) =>
  //                               userId == element.userId?.toString());

  //                           if (matchingChats.isNotEmpty) {
  //                             ChatList data = matchingChats.first;
  //                             Get.to(() => SingleChatMsg(
  //                                   conversationID:
  //                                       data.conversationId?.toString() ?? '',
  //                                   username: fullName,
  //                                   userPic: profileImage,
  //                                   mobileNum: phoneNumber,
  //                                   index: 0,
  //                                   isBlock: data.isBlock,
  //                                   userID: userId,
  //                                   verificationBadge:
  //                                       contact.userDetails?.verificationType !=
  //                                               null
  //                                           ? contact.userDetails
  //                                               ?.verificationType?.logo
  //                                           : '',
  //                                 ));
  //                           } else {
  //                             Get.to(() => SingleChatMsg(
  //                                   conversationID: '',
  //                                   username: fullName,
  //                                   userPic: profileImage,
  //                                   mobileNum: phoneNumber,
  //                                   index: 0,
  //                                   userID: userId,
  //                                   verificationBadge:
  //                                       contact.userDetails?.verificationType !=
  //                                               null
  //                                           ? contact.userDetails
  //                                               ?.verificationType?.logo
  //                                           : '',
  //                                 ));
  //                           }
  //                         }
  //                       },
  //                       leading: Container(
  //                         height: 45,
  //                         width: 45,
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey.shade200,
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(100),
  //                             child: contact.userDetails!.profileImage != null
  //                                 ? CustomCachedNetworkImage(
  //                                     imageUrl:
  //                                         contact.userDetails!.profileImage!,
  //                                     placeholderColor: chatownColor,
  //                                     errorWidgeticon: const Icon(Icons.person))
  //                                 : Icon(Icons.person, color: chatownColor)),
  //                       ),
  //                       title: Row(
  //                         children: [
  //                           Flexible(
  //                             child: Text(
  //                               contact.fullName ?? 'Unknown',
  //                               style: const TextStyle(
  //                                 fontSize: 15.0,
  //                                 fontFamily: 'Poppins',
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                           // Add the verification logo widget here
  //                           if (contact.userDetails?.verificationType != null &&
  //                               contact.userDetails?.verificationType?.logo !=
  //                                   null)
  //                             VerificationLogoWidget(
  //                               logoUrl: contact
  //                                   .userDetails!.verificationType!.logo!,
  //                               size: 16,
  //                               margin: const EdgeInsets.only(left: 2),
  //                             ),
  //                         ],
  //                       ),
  //                       subtitle: Container(
  //                         padding: const EdgeInsets.only(top: 2.0),
  //                         child: Text(
  //                           contact.phoneNumber.toString(),
  //                           style: const TextStyle(
  //                               fontSize: 13,
  //                               color: Color.fromRGBO(73, 73, 73, 1)),
  //                         ),
  //                       ),
  //                       trailing:
  //                           Image.asset("assets/images/Chat1.png", height: 10),
  //                     ),
  //                     if (index != filteredContacts.length - 1)
  //                       Divider(
  //                         color: Colors.grey.shade300,
  //                       )
  //                   ],
  //                 );
  //               },
  //             )
  //           : Column(
  //               children: [
  //                 Text("Debug Info:",
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 Text(
  //                     "Loading: ${getAllDeviceContact.isGetMYContectLoading.value}"),
  //                 Text(
  //                     "myContactList null: ${getAllDeviceContact.myContactsData.value.myContactList == null}"),
  //                 Text(
  //                     "If not null, length: ${getAllDeviceContact.myContactsData.value.myContactList?.length ?? 'N/A'}"),
  //                 SizedBox(height: 20),
  //                 Text(languageController.textTranslate(
  //                     'You do not have any contact in whoxa!')),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     // Force refresh contacts
  //                     getAllDeviceContact.myContact(isAddData: false);
  //                   },
  //                   child: Text("Refresh Contacts"),
  //                 ),
  //               ],
  //             );
  // }

  // Widget contactsWidget() {
  //   return
  //       // (getAllDeviceContact.isGetMYContectLoading.value == true)
  //       //     ? loader(context)
  //       //     :
  //       getAllDeviceContact.myContactsData.value.myContactList!.isNotEmpty
  //           ? Column(
  //               children: [
  //                 ListView.separated(
  //                   padding: const EdgeInsets.all(0),
  //                   itemCount: getAllDeviceContact
  //                       .myContactsData.value.myContactList!.length,
  //                   // .where((contact) => contact.fullName!
  //                   //     .toLowerCase()
  //                   //     .contains(searchText.toLowerCase()))
  //                   // .length,
  //                   shrinkWrap: true,
  //                   physics: const NeverScrollableScrollPhysics(),
  //                   separatorBuilder: (context, index) {
  //                     var filteredContacts = getAllDeviceContact
  //                         .myContactsData.value.myContactList!;
  //                     // .where((contact) => contact.fullName!
  //                     //     .toLowerCase()
  //                     //     .contains(searchText.toLowerCase()))
  //                     // .toList();
  //
  //                     if (filteredContacts.isEmpty) {
  //                       return const SizedBox.shrink();
  //                     }
  //
  //                     var contact = filteredContacts[index];
  //                     return getAllDeviceContact
  //                             .myContactsData.value.myContactList!
  //                             .any((element) =>
  //                                 element.phoneNumber.toString() ==
  //                                 Hive.box(userdata).get(userMobile))
  //                         ? Hive.box(userdata).get(userMobile) ==
  //                                 contact.phoneNumber.toString()
  //                             ? const SizedBox.shrink()
  //                             : Divider(
  //                                 color: Colors.grey.shade300,
  //                               )
  //                         : index !=
  //                                 getAllDeviceContact.myContactsData.value
  //                                         .myContactList!.length -
  //                                     1
  //                             ? Divider(
  //                                 color: Colors.grey.shade300,
  //                               )
  //                             : const SizedBox.shrink();
  //                   },
  //                   itemBuilder: (BuildContext context, int index) {
  //                     var filteredContacts = getAllDeviceContact
  //                         .myContactsData.value.myContactList!;
  //                     // .where((contact) => contact.fullName!
  //                     //     .toLowerCase()
  //                     //     .contains(searchText.toLowerCase()))
  //                     // .toList();
  //
  //                     if (filteredContacts.isEmpty) {
  //                       return const SizedBox.shrink();
  //                     }
  //
  //                     var contact = filteredContacts[index];
  //                     return Hive.box(userdata).get(userMobile) ==
  //                             contact.phoneNumber.toString()
  //                         ? const SizedBox.shrink()
  //                         : Column(
  //                             children: <Widget>[
  //                               ListTile(
  //                                 onTap: () {
  //                                   if (chatListController.userChatListModel
  //                                       .value!.chatList!.isEmpty) {
  //                                     Get.to(() => SingleChatMsg(
  //                                           conversationID: '',
  //                                           username: contact.fullName!,
  //                                           userPic: contact
  //                                               .userDetails!.profileImage,
  //                                           mobileNum:
  //                                               contact.phoneNumber.toString(),
  //                                           index: 0,
  //                                           userID: contact.userDetails!.userId
  //                                               .toString(),
  //                                           verificationBadge: contact
  //                                                       .userDetails
  //                                                       ?.verificationType !=
  //                                                   null
  //                                               ? contact.userDetails
  //                                                   ?.verificationType?.logo
  //                                               : '',
  //                                         ));
  //                                   } else {
  //                                     if (chatListController
  //                                         .userChatListModel.value!.chatList!
  //                                         .where((element) =>
  //                                             contact.userDetails!.userId
  //                                                 .toString() ==
  //                                             element.userId!.toString())
  //                                         .isNotEmpty) {
  //                                       ChatList data = chatListController
  //                                           .userChatListModel.value!.chatList!
  //                                           .where((element) =>
  //                                               contact.userDetails!.userId
  //                                                   .toString() ==
  //                                               element.userId!.toString())
  //                                           .first;
  //                                       Get.to(() => SingleChatMsg(
  //                                             conversationID: data
  //                                                 .conversationId
  //                                                 .toString(),
  //                                             username: contact.fullName!,
  //                                             userPic: contact
  //                                                 .userDetails!.profileImage,
  //                                             mobileNum: contact.phoneNumber
  //                                                 .toString(),
  //                                             index: 0,
  //                                             isBlock: data.isBlock,
  //                                             userID: data.userId.toString(),
  //                                             verificationBadge:
  //                                                 data.varificationType != null
  //                                                     ? data.varificationType!
  //                                                         .logo
  //                                                     : '',
  //                                           ));
  //                                     } else {
  //                                       Get.to(
  //                                         () => SingleChatMsg(
  //                                           conversationID: '',
  //                                           username: contact.fullName!,
  //                                           userPic: contact
  //                                               .userDetails!.profileImage,
  //                                           mobileNum:
  //                                               contact.phoneNumber.toString(),
  //                                           index: 0,
  //                                           userID: contact.userDetails!.userId!
  //                                               .toString(),
  //                                           verificationBadge: contact
  //                                                       .userDetails
  //                                                       ?.verificationType !=
  //                                                   null
  //                                               ? contact.userDetails
  //                                                   ?.verificationType?.logo
  //                                               : '',
  //                                         ),
  //                                       );
  //                                     }
  //                                   }
  //                                 },
  //                                 leading: Container(
  //                                   height: 45,
  //                                   width: 45,
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.grey.shade200,
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                   child: ClipRRect(
  //                                       borderRadius:
  //                                           BorderRadius.circular(100),
  //                                       child: CustomCachedNetworkImage(
  //                                           imageUrl: contact
  //                                               .userDetails!.profileImage!,
  //                                           placeholderColor: chatownColor,
  //                                           errorWidgeticon:
  //                                               const Icon(Icons.person))),
  //                                 ),
  //                                 title: Row(
  //                                   children: [
  //                                     Text(
  //                                       contact.fullName,
  //                                       style: const TextStyle(
  //                                         fontSize: 15.0,
  //                                         fontFamily: 'Poppins',
  //                                         fontWeight: FontWeight.w500,
  //                                       ),
  //                                     ),
  //                                     if (contact
  //                                             .userDetails!.verificationType !=
  //                                         null)
  //                                       VerificationLogoWidget(
  //                                         logoUrl: contact.userDetails!
  //                                             .verificationType!.logo,
  //                                         size: 16,
  //                                         margin:
  //                                             const EdgeInsets.only(left: 2),
  //                                       ),
  //                                   ],
  //                                 ),
  //                                 subtitle: Container(
  //                                   padding: const EdgeInsets.only(top: 2.0),
  //                                   child: Text(
  //                                     contact.phoneNumber.toString(),
  //                                     style: const TextStyle(
  //                                         fontSize: 13,
  //                                         color: Color.fromRGBO(73, 73, 73, 1)),
  //                                   ),
  //                                 ),
  //                                 trailing: Image.asset(
  //                                     "assets/images/Chat1.png",
  //                                     height: 10),
  //                               ),
  //                             ],
  //                           );
  //                   },
  //                 ),
  //                 // getAllDeviceContact
  //                 //             .myContactsData.value.pagination!.currentPage! <
  //                 //         getAllDeviceContact
  //                 //             .myContactsData.value.pagination!.totalPages!
  //                 //     ? (getAllDeviceContact.isGetMYContectLoading.value ==
  //                 //             true)
  //                 //         ? SizedBox(
  //                 //             height: 25,
  //                 //             width: 25,
  //                 //             child: Center(
  //                 //               child: CircularProgressIndicator(
  //                 //                 color: chatownColor,
  //                 //               ),
  //                 //             ),
  //                 //           )
  //                 //         : GestureDetector(
  //                 //             onTap: () {
  //                 //               getAllDeviceContact.myContact(
  //                 //                   isAddData: true, fullName: controller.text);
  //                 //             },
  //                 //             child: Text(
  //                 //               "Show More",
  //                 //               style: const TextStyle(
  //                 //                 fontSize: 15.0,
  //                 //                 fontFamily: 'Poppins',
  //                 //                 fontWeight: FontWeight.w500,
  //                 //               ),
  //                 //             ).paddingOnly(top: 12),
  //                 //           )
  //                 //     : SizedBox.shrink()
  //               ],
  //             )
  //           : Text('No data found');
  //   // SizedBox(
  //   //     height: 100,
  //   //     child: Center(
  //   //         child: Row(
  //   //       mainAxisAlignment: MainAxisAlignment.center,
  //   //       children: [
  //   //         Text(languageController.textTranslate(
  //   //             'You do not have any contact in whoxa!')),
  //   //       ],
  //   //     )),
  //   //   );
  // }

  Widget contactsWidget() {
    // First check if data is loading
    if (getAllDeviceContact.isGetMYContectLoading.value) {
      return loader(context);
    }

    // Safely check if contact list exists
    final contactList = getAllDeviceContact.myContactsData.value.myContactList;
    if (contactList == null) {
      return Center(
        child: Text(
          languageController.textTranslate('No contact data available'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
    }

    // Handle empty contact list
    if (contactList.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            languageController
                .textTranslate('You do not have any contact in whoxa!'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Filter contacts based on search text
    final filteredContacts = contactList
        .where((contact) =>
            contact.fullName != null &&
            contact.fullName.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    // Handle when search has no matches
    if (filteredContacts.isEmpty && searchText.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            languageController.textTranslate('No contacts match your search'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Current user's phone number from Hive storage
    final currentUserPhone = Hive.box(userdata).get(userMobile) as String?;

    // Build the complete widget with list and pagination
    return Column(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(0),
          itemCount: filteredContacts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return Divider(color: Colors.grey.shade300);
          },
          itemBuilder: (BuildContext context, int index) {
            // Get contact from filtered list to avoid index issues
            var contact = filteredContacts[index];

            // Skip current user's contact
            if (currentUserPhone != null &&
                currentUserPhone == contact.phoneNumber.toString()) {
              return const SizedBox.shrink();
            }

            // Safely access user details with proper null handling
            final userDetails = contact.userDetails;
            if (userDetails == null) {
              return const SizedBox.shrink();
            }

            final userId = userDetails.userId?.toString();
            final profileImage = userDetails.profileImage;
            final fullName = contact.fullName;
            final phoneNumber = contact.phoneNumber.toString();

            if (userId == null || userId.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListTile(
              onTap: () {
                // Safely access chat list model
                final chatListModel =
                    chatListController.userChatListModel.value;
                if (chatListModel == null) {
                  debugPrint('Chat list model is null');
                  // Create new chat directly
                  Get.to(() => SingleChatMsg(
                        conversationID: '',
                        username: fullName,
                        userPic: profileImage,
                        mobileNum: phoneNumber,
                        index: 0,
                        userID: userId,
                        verificationBadge:
                            userDetails.verificationType?.logo ?? '',
                      ));
                  return;
                }

                final chatList = chatListModel.chatList;
                if (chatList == null || chatList.isEmpty) {
                  // Create new chat if chat list is empty
                  Get.to(() => SingleChatMsg(
                        conversationID: '',
                        username: fullName,
                        userPic: profileImage,
                        mobileNum: phoneNumber,
                        index: 0,
                        userID: userId,
                        verificationBadge:
                            userDetails.verificationType?.logo ?? '',
                      ));
                  return;
                }

                // Find existing conversation if any
                final matchingChats = chatList
                    .where((element) => userId == element.userId?.toString());

                if (matchingChats.isNotEmpty) {
                  // Open existing chat
                  ChatList data = matchingChats.first;
                  Get.to(() => SingleChatMsg(
                        conversationID: data.conversationId?.toString() ?? '',
                        username: fullName,
                        userPic: profileImage,
                        mobileNum: phoneNumber,
                        index: 0,
                        isBlock: data.isBlock,
                        userID: userId,
                        verificationBadge: data.varificationType?.logo ?? '',
                      ));
                } else {
                  // Create new chat
                  Get.to(() => SingleChatMsg(
                        conversationID: '',
                        username: fullName,
                        userPic: profileImage,
                        mobileNum: phoneNumber,
                        index: 0,
                        userID: userId,
                        verificationBadge:
                            userDetails.verificationType?.logo ?? '',
                      ));
                }
              },
              leading: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: userDetails.profileImage != null
                      ? CustomCachedNetworkImage(
                          imageUrl: userDetails.profileImage,
                          placeholderColor: chatownColor,
                          errorWidgeticon: const Icon(Icons.person),
                        )
                      : Icon(Icons.person, color: chatownColor),
                ),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Verification badge if available
                ],
              ),
              subtitle: Container(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(73, 73, 73, 1),
                  ),
                ),
              ),
              trailing: Image.asset("assets/images/Chat1.png", height: 10),
            );
          },
        ),

        // // Pagination section - explicitly check all conditions
        // if (getAllDeviceContact.myContactsData.value?.pagination != null)
        //   Builder(
        //     builder: (context) {
        //       final pagination = getAllDeviceContact.myContactsData.value!.pagination!;
        //
        //       // Check if there are more pages
        //       if (pagination.currentPage != null &&
        //           pagination.totalPages != null &&
        //           pagination.currentPage! < pagination.totalPages!) {
        //
        //         // Show loading indicator or "Show More" button
        //         if (getAllDeviceContact.isGetMYContectLoading.value) {
        //           return SizedBox(
        //             height: 25,
        //             width: 25,
        //             child: Center(
        //               child: CircularProgressIndicator(
        //                 color: chatownColor,
        //               ),
        //             ),
        //           );
        //         } else {
        //           return GestureDetector(
        //             onTap: () {
        //               getAllDeviceContact.myContact(
        //                 isAddData: true,
        //                // fullName: controller.text,
        //               );
        //             },
        //             child: Padding(
        //               padding: const EdgeInsets.only(top: 12),
        //               child: Text(
        //                 languageController.textTranslate("Show More"),
        //                 style: const TextStyle(
        //                   fontSize: 15.0,
        //                   fontFamily: 'Poppins',
        //                   fontWeight: FontWeight.w500,
        //                 ),
        //               ),
        //             ),
        //           );
        //         }
        //       }
        //
        //       // Return empty widget if we're on the last page
        //       return const SizedBox.shrink();
        //     },
        //   ),
      ],
    );
  }

  // Widget contactsWidget() {
  //   return getAllDeviceContact.isGetMYContectLoading.value == true
  //       ? loader(context)
  //       : getAllDeviceContact.myContactsData.value.myContactList != null &&
  //               getAllDeviceContact
  //                   .myContactsData.value.myContactList!.isNotEmpty
  //           ? ListView.builder(
  //               padding: const EdgeInsets.all(0),
  //               itemCount: getAllDeviceContact
  //                   .myContactsData.value.myContactList!
  //                   .where((contact) =>
  //                       contact.fullName != null &&
  //                       contact.fullName!
  //                           .toLowerCase()
  //                           .contains(searchText.toLowerCase()))
  //                   .length,
  //               shrinkWrap: true,
  //               physics: const NeverScrollableScrollPhysics(),
  //               itemBuilder: (BuildContext context, int index) {
  //                 // Get filtered contacts based on search text
  //                 var filteredContacts = getAllDeviceContact
  //                     .myContactsData.value.myContactList!
  //                     .where((contact) =>
  //                         contact.fullName != null &&
  //                         contact.fullName!
  //                             .toLowerCase()
  //                             .contains(searchText.toLowerCase()))
  //                     .toList();

  //                 if (filteredContacts.isEmpty) {
  //                   return const SizedBox.shrink();
  //                 }

  //                 var contact = filteredContacts[index];

  //                 // Skip showing current user's contact
  //                 if (Hive.box(userdata).get(userMobile) ==
  //                     contact.phoneNumber.toString()) {
  //                   return const SizedBox.shrink();
  //                 }

  //                 return Column(
  //                   children: <Widget>[
  //                     ListTile(
  //                       onTap: () {
  //                         // Safely check if model and chatList exist
  //                         final chatListModel =
  //                             chatListController.userChatListModel.value;
  //                         if (chatListModel == null) {
  //                           print('Chat list model is null');
  //                           return;
  //                         }

  //                         final chatList = chatListModel.chatList;
  //                         if (chatList == null) {
  //                           print('Chat list is null');
  //                           return;
  //                         }

  //                         // Safely check user details
  //                         final userDetails = contact.userDetails;
  //                         if (userDetails == null) {
  //                           print('User details are null');
  //                           return;
  //                         }

  //                         final userId = userDetails.userId?.toString();
  //                         if (userId == null || userId.isEmpty) {
  //                           print('User ID is null or empty');
  //                           return;
  //                         }

  //                         final fullName = contact.fullName ?? 'Unknown';
  //                         final profileImage = userDetails.profileImage;
  //                         final phoneNumber =
  //                             contact.phoneNumber?.toString() ?? '';

  //                         if (chatList.isEmpty) {
  //                           print('Chat list is empty');
  //                           Get.to(() => SingleChatMsg(
  //                                 conversationID: '',
  //                                 username: fullName,
  //                                 userPic: profileImage,
  //                                 mobileNum: phoneNumber,
  //                                 index: 0,
  //                                 userID: userId,
  //                               ));
  //                         } else {
  //                           final matchingChats = chatList.where((element) =>
  //                               userId == element.userId?.toString());

  //                           if (matchingChats.isNotEmpty) {
  //                             ChatList data = matchingChats.first;
  //                             Get.to(() => SingleChatMsg(
  //                                   conversationID:
  //                                       data.conversationId?.toString() ?? '',
  //                                   username: fullName,
  //                                   userPic: profileImage,
  //                                   mobileNum: phoneNumber,
  //                                   index: 0,
  //                                   isBlock: data.isBlock,
  //                                   userID: userId,
  //                                 ));
  //                           } else {
  //                             Get.to(() => SingleChatMsg(
  //                                   conversationID: '',
  //                                   username: fullName,
  //                                   userPic: profileImage,
  //                                   mobileNum: phoneNumber,
  //                                   index: 0,
  //                                   userID: userId,
  //                                 ));
  //                           }
  //                         }
  //                       },
  //                       leading: Container(
  //                         height: 45,
  //                         width: 45,
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey.shade200,
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(100),
  //                             child: contact.userDetails!.profileImage != null
  //                                 ? CustomCachedNetworkImage(
  //                                     imageUrl:
  //                                         contact.userDetails!.profileImage!,
  //                                     placeholderColor: chatownColor,
  //                                     errorWidgeticon: const Icon(Icons.person))
  //                                 : Icon(Icons.person, color: chatownColor)),
  //                       ),
  //                       title: Text(
  //                         contact.fullName ?? 'Unknown',
  //                         style: const TextStyle(
  //                           fontSize: 15.0,
  //                           fontFamily: 'Poppins',
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                       subtitle: Container(
  //                         padding: const EdgeInsets.only(top: 2.0),
  //                         child: Text(
  //                           contact.phoneNumber.toString(),
  //                           style: const TextStyle(
  //                               fontSize: 13,
  //                               color: Color.fromRGBO(73, 73, 73, 1)),
  //                         ),
  //                       ),
  //                       trailing:
  //                           Image.asset("assets/images/Chat1.png", height: 10),
  //                     ),
  //                     if (index != filteredContacts.length - 1)
  //                       Divider(
  //                         color: Colors.grey.shade300,
  //                       )
  //                   ],
  //                 );
  //               },
  //             )
  //           : SizedBox(
  //               height: 100,
  //               child: Center(
  //                   child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(languageController.textTranslate(
  //                       'You do not have any contact in whoxa!')),
  //                 ],
  //               )),
  //             );
  // }

  bool isMatchinginvite(String userNumber) {
    for (int i = 0; i < getAllDeviceContact.getList.length; i++) {
      List<String> numbers = userNumber.split(',');
      for (String listNumber in numbers) {
        if (listNumber == getAllDeviceContact.getList[i].phoneNumber) {
          return false;
        }
      }
    }
    return true;
  }

  List<Contact> getFilteredContacts(String searchText) {
    List<Contact> filteredContacts = [];
    for (int i = 0; i < addContactController.allcontacts.length; i++) {
      Contact contact = addContactController.allcontacts[i];
      if (isMatchinginvite(
              getMobile(contact.phones.map((e) => e.number).toString())) &&
          (contact.displayName.toLowerCase().contains(searchText))) {
        filteredContacts.add(contact);
      }
    }
    return filteredContacts;
  }

  Widget inviteFriend(String searchText) {
    List<Contact> filteredContacts = getFilteredContacts(searchText);
    return _isPermissionGranted == false
        ? Column(
            children: [
              sizeBoxHeight(20),
              Image.asset(
                "assets/images/no_contact.png",
                height: getProportionateScreenHeight(201),
                width: getProportionateScreenHeight(134),
              ),
              sizeBoxHeight(15),
              const Text(
                "You Don’t have permission to access contacts, go to settings and change the permission",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: appColorBlack,
                ),
              ).paddingSymmetric(horizontal: 50),
              sizeBoxHeight(15),
            ],
          )
        : addContactController.isGetContectsFromDeviceLoading.value == true &&
                addContactController.allcontacts.isEmpty
            ? loader(context)
            : addContactController.allcontacts.isEmpty
                ? Column(
                    children: [
                      sizeBoxHeight(20),
                      Image.asset(
                        "assets/images/no_contact.png",
                        height: getProportionateScreenHeight(201),
                        width: getProportionateScreenHeight(134),
                      ),
                      sizeBoxHeight(15),
                      const Text(
                        "You don’t have any Contacts on your device.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                          color: appColorBlack,
                        ),
                      ).paddingSymmetric(horizontal: 50),
                      sizeBoxHeight(15),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: filteredContacts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      var contact = filteredContacts[index];

                      return Column(
                        children: <Widget>[
                          getMobile(Hive.box(userdata).get(userMobile)) ==
                                  getMobile(contact.phones
                                      .map((e) => e.number)
                                      .toString())
                              ? const SizedBox.shrink()
                              : ListTile(
                                  onTap: () {
                                    inviteMe(contact.phones
                                        .map((e) => e.number)
                                        .toString());
                                  },
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            colors: [
                                              blackColor,
                                              black1Color,
                                            ],
                                            stops: const [
                                              1.0,
                                              3.0
                                            ],
                                            begin: FractionalOffset.topLeft,
                                            end: FractionalOffset.bottomRight,
                                            tileMode: TileMode.repeated)),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Center(
                                          child: Text(
                                            contact.displayName != null
                                                ? contact.displayName[0]
                                                : "?",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontFamily: "MontserratBold",
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Container(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        getMobile(contact.phones
                                            .map((e) => e.number)
                                            .toString()),
                                        maxLines: 1,
                                        style: const TextStyle(
                                            color:
                                                Color.fromRGBO(73, 73, 73, 1)),
                                      )),
                                  trailing: Text(
                                    languageController.textTranslate('Invite'),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: chatownColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                          if (index != filteredContacts.length - 1)
                            Divider(
                              color: Colors.grey.shade300,
                            )
                        ],
                      );
                    },
                  );
  }

  inviteMe(phone) async {
    String uri =
        'sms:$phone?body=${languageController.appSettingsData[0].tellAFriendLink}';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      String uri =
          'sms:$phone?body=${languageController.appSettingsData[0].tellAFriendLink}';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }
  // inviteMe(phone) async {
  //   String uri =
  //       'sms:$phone?body=${"‎Hey there! Join me on our Whoxa app!\nChat with friends, share photos & videos instantly.\nDownload now.\nLet's stay connected!"}';
  //   if (await canLaunch(uri)) {
  //     await launch(uri);
  //   } else {
  //     String uri =
  //         'sms:$phone?body=${"‎Hey there! Join me on our Whoxa app!\nChat with friends, share photos & videos instantly.\nDownload now.\nLet's stay connected!"}';
  //     if (await canLaunch(uri)) {
  //       await launch(uri);
  //     } else {
  //       throw 'Could not launch $uri';
  //     }
  //   }
  // }

  Widget contactDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: Text(
            languageController.textTranslate('Contacts on Whoxa'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future images() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, kk) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            title: Center(
              child: Text(
                languageController.textTranslate('Group Info'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: chatColor,
                ),
              ),
            ),
            content: const SizedBox(height: 243, child: create_group()),
          );
        });
      },
    );
  }
}
