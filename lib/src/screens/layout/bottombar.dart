// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use, unused_field, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:whoxachat/main.dart';
import 'package:whoxachat/src/global/services/userblockcheck_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/add_contact_controller.dart';
import 'package:whoxachat/controller/all_block_list_controller.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/controller/online_controller.dart';
import 'package:whoxachat/controller/single_chat_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';

import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/chat/chats.dart';
import 'package:whoxachat/src/screens/layout/contact_new.dart';
import 'package:whoxachat/src/screens/layout/story/stroy.dart';
import 'package:whoxachat/src/screens/user/profile.dart';
import 'package:whoxachat/src/screens/calllist/call_list.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class TabbarScreen extends StatefulWidget {
  int? currentTab;
  Widget currentPage = const Chats();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TabbarScreen({super.key, this.currentTab}) {
    currentTab = currentTab ?? 0;
  }
  @override
  _TabbarScreenState createState() {
    return _TabbarScreenState();
  }
}

class _TabbarScreenState extends State<TabbarScreen>
    with WidgetsBindingObserver {
  bool _isFirstLoad = true;

  OnlineOfflineController controller = Get.put(OnlineOfflineController());
  ChatListController chatListController = Get.put(ChatListController());
  GetAllDeviceContact getAllDeviceContact = Get.put(GetAllDeviceContact());
  RoomIdController getRoomController = Get.put(RoomIdController());
  AddContactController addContactController = Get.put(AddContactController());
  SingleChatContorller singleChatContorller = Get.put(SingleChatContorller());
  AllBlockListController allBlockListController =
      Get.put(AllBlockListController());
  AllStaredMsgController allStaredMsgController =
      Get.put(AllStaredMsgController());
  AvatarController avatarController = Get.put(AvatarController());

  String _timeZone = 'Fetching time zone...';

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = const Chats();
          break;
        case 1:
          widget.currentPage = const StorySectionScreen();
          break;
        case 2:
          widget.currentPage = const call_history();
          break;
        case 3:
          widget.currentPage = FlutterContactsExample(isValue: false);
          break;
        case 4:
          widget.currentPage = const Profile();
          break;
      }

      //check userblock by admin
      UserStatusService.checkAndHandleUserStatus(context);
    });
  }

  String _fcmtoken = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> _getToken() async {
    if (Platform.isIOS) {
      await firebaseMessaging.getAPNSToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
      });
    } else if (Platform.isAndroid) {
      await firebaseMessaging.getToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
      });
    }

    return true;
  }

  bool isLoading = false;
  final ApiHelper apiHelper = ApiHelper();
  UserProfileModel userProfileModel = UserProfileModel();
  editApiCall() async {
    await _getToken();
    closeKeyboard();

    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);
    request.fields['device_token'] = _fcmtoken;
    request.fields['one_signal_player_id'] =
        OneSignal.User.pushSubscription.id!;

    print(request.fields);

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    print(responseData);

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userBio, userProfileModel.resData!.bio.toString());
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

//=============================================================== UTC TIME ZONE =========================================================
//=============================================================== UTC TIME ZONE =========================================================
//=============================================================== UTC TIME ZONE =========================================================
  // Future<void> _fetchTimeZone() async {
  //   try {
  //     Position position = await _getCurrentLocation();
  //     String timeZone =
  //         await _getTimeZoneFromApi(position.latitude, position.longitude);
  //     setState(() {
  //       _timeZone = timeZone;
  //     });

  //     await Hive.box(userdata).put(utcLocaName, timeZone);
  //     log("UTC_NAME:${Hive.box(userdata).get(utcLocaName)}");
  //   } catch (e) {
  //     setState(() {
  //       _timeZone = 'Error fetching time zone: $e';
  //     });
  //   }
  // }

  // Future<Position> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     throw Exception('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       throw Exception('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     throw Exception('Location permissions are permanently denied');
  //   }

  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }

  // Future<String> _getTimeZoneFromApi(double latitude, double longitude) async {
  //   const String apiKey = 'AIzaSyAMZ4GbRFYSevy7tMaiH5s0JmMBBXc0qBA';
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/timezone/json?location=$latitude,$longitude&timestamp=${DateTime.now().millisecondsSinceEpoch ~/ 1000}&key=$apiKey';

  //   int retries = 3;
  //   while (retries > 0) {
  //     try {
  //       final response = await http.get(Uri.parse(url));
  //       if (response.statusCode == 200) {
  //         final data = json.decode(response.body);
  //         return data['timeZoneId'];
  //       } else {
  //         throw Exception(
  //             'Failed to get time zone data: ${response.statusCode}');
  //       }
  //     } on SocketException catch (_) {
  //       if (retries == 1) {
  //         throw Exception('Network error');
  //       }
  //       await Future.delayed(const Duration(seconds: 2));
  //     } on TimeoutException catch (_) {
  //       if (retries == 1) {
  //         throw Exception('Timeout error');
  //       }
  //       await Future.delayed(const Duration(seconds: 2));
  //     }
  //     retries--;
  //   }
  //   throw Exception('Failed to get time zone data after retries');
  // }

  //   @override
  // initState() {
  //   widget.currentPage =
  //       widget.currentTab! == 4 ? const Profile() : const Chats();
  //   WidgetsBinding.instance.addObserver(this);
  //   setState(() {
  //     isLoading = true; // Set loading to true at the beginning for first time load issue
  //   });

  //   if (Hive.box(userdata).get(authToken) == '' &&
  //       Hive.box(userdata).get(authToken) == null) {
  //     socketIntilized.initlizedsocket();
  //   }
  //   editApiCall();
  //   _fetchTimeZone();

  //   permissionAcessPhone();
  //   getRoomController.callHistory();

  //   getAllDeviceContact.myContact();
  //   var contactJson = json.encode(addContactController.mobileContacts);
  //   getAllDeviceContact.getAllContactApi(contact: contactJson);
  //   super.initState();
  // }

  // Improved implementation for location handling

  Future<void> _fetchTimeZone() async {
    try {
      Position position = await _getCurrentLocation();
      String timeZone =
          await _getTimeZoneFromApi(position.latitude, position.longitude);
      setState(() {
        _timeZone = timeZone;
        isLoading = false; // Make sure to set loading to false here
      });

      await Hive.box(userdata).put(utcLocaName, timeZone);
      log("UTC_NAME:${Hive.box(userdata).get(utcLocaName)}");
    } catch (e) {
      setState(() {
        _timeZone = 'Error fetching time zone: $e';
        isLoading = false; // Important: Also set loading to false on error
      });
      // Use a default timezone when there's an error
      await Hive.box(userdata).put(utcLocaName, "UTC");
      log("Error setting timezone, using default: $e");
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // First check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Don't throw an exception, handle gracefully
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Don't throw exception, return error
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Don't throw exception, return error
      return Future.error('Location permissions are permanently denied');
    }

    // When we reach here, permissions are granted and we can get the location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5), // Add a timeout to prevent hanging
    );
  }

// Improved time zone API handling with better error handling
  Future<String> _getTimeZoneFromApi(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyAMZ4GbRFYSevy7tMaiH5s0JmMBBXc0qBA';
    final String url =
        'https://maps.googleapis.com/maps/api/timezone/json?location=$latitude,$longitude&timestamp=${DateTime.now().millisecondsSinceEpoch ~/ 1000}&key=$apiKey';

    int retries = 3;
    while (retries > 0) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('API request timed out');
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            return data['timeZoneId'];
          } else {
            log("API returned non-OK status: ${data['status']}");
            return 'UTC'; // Return a default on API error
          }
        } else {
          log("Failed to get time zone data: ${response.statusCode}");
          return 'UTC'; // Return a default on HTTP error
        }
      } on SocketException catch (e) {
        log("Network error: $e");
        if (retries == 1) {
          return 'UTC'; // Return default on last retry
        }
        await Future.delayed(const Duration(seconds: 2));
      } on TimeoutException catch (e) {
        log("Timeout error: $e");
        if (retries == 1) {
          return 'UTC'; // Return default on last retry
        }
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        log("Unexpected error: $e");
        if (retries == 1) {
          return 'UTC'; // Return default on last retry
        }
        await Future.delayed(const Duration(seconds: 2));
      }
      retries--;
    }
    return 'UTC'; // Default fallback
  }

  @override
  void initState() {
    super.initState();

    widget.currentPage =
        widget.currentTab! == 4 ? const Profile() : const Chats();
    WidgetsBinding.instance.addObserver(this);

    setState(() {
      isLoading = true; // Set loading to true at the beginning
    });

    if (Hive.box(userdata).get(authToken) == '' &&
        Hive.box(userdata).get(authToken) == null) {
      socketIntilized.initlizedsocket();
    }

    // Run critical operations that need to be tracked for loading state
    _initializeApp();
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UserStatusService.checkAndHandleUserStatus(
            context); //user block by admin status check

        _isFirstLoad = false; // Mark first load as complete
      });
    }

    // These operations can run independently without tracking
    getAllDeviceContact.myContact();
    var contactJson = json.encode(addContactController.mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);
  }

// Separate method to handle async initialization with proper error handling
  Future<void> _initializeApp() async {
    try {
      // Execute critical operations one by one
      await editApiCall();
      await _fetchTimeZone();
      await permissionAcessPhone();
      await getRoomController.callHistory();

      // Only update loading state when safely back on the main thread
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      log("Error in initialization: $error");
      // Ensure loading indicator is removed even on error
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  checkChatList() async {
    if (widget.currentTab! == 0) {
      await Future.delayed(
        const Duration(seconds: 2),
        () {
          chatListController.forChatList();
          print("refresh chat list 1");
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _getIndianUtcTime() {
    final now =
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('State☺☺☺☺☺☺☺☺☺☺☺☺☺☺: $state');
    setState(() {
      if (state == AppLifecycleState.detached) {
        isOnline = "Online";

        controller.forData();
        print("state: $state");
      } else if (state == AppLifecycleState.inactive) {
        isOnline = _getIndianUtcTime();
        controller.offlineUser();
        print("state: $state");
      } else if (state == AppLifecycleState.paused) {
        isOnline = _getIndianUtcTime();
        controller.offlineUser();
        print("state: $state");
      } else if (state == AppLifecycleState.resumed) {
        isOnline = "Online";

        controller.forData();
        print("state: $state");
      }
    });
  }

  permissionAcessPhone() async {
    var permission = await Permission.contacts.request();
    if (permission.isGranted) {
      await addContactController.getContactsFromGloble();
      print("@@@@@@@@@@@: ${addContactController.mobileContacts.runtimeType}");
      log("MY_DEVICE_CONTACS: ${addContactController.mobileContacts}");
    } else {
      permissionAcessPhone();
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return PopScope(
  //     canPop: true,
  //     child: Scaffold(
  //         key: widget.scaffoldKey,
  //         body: widget.currentPage,
  //         bottomNavigationBar: Container(
  //           decoration: BoxDecoration(boxShadow: [
  //             BoxShadow(
  //                 color: Colors.grey.shade300,
  //                 offset: const Offset(0.0, 4.0),
  //                 blurRadius: 15,
  //                 spreadRadius: 0)
  //           ]),
  //           child: ClipRRect(
  //             borderRadius: const BorderRadius.only(
  //               topRight: Radius.circular(0),
  //               topLeft: Radius.circular(0),
  //             ),
  //             child: BottomNavigationBar(
  //               selectedIconTheme: IconThemeData(color: chatownColor),
  //               selectedItemColor: Colors.white,
  //               selectedFontSize: 10,
  //               unselectedFontSize: 10,
  //               unselectedLabelStyle: const TextStyle(color: Colors.white),
  //               selectedLabelStyle: const TextStyle(
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 10),
  //               backgroundColor: Colors.white,
  //               type: BottomNavigationBarType.fixed,
  //               currentIndex: widget.currentTab!,
  //               onTap: (int i) {
  //                 _selectTab(i);
  //               },
  //               items: <BottomNavigationBarItem>[
  //                 _buildNavItem(
  //                   index: 0,
  //                   currentTab: widget.currentTab!!,
  //                   iconPath: 'assets/images/message-text.png',
  //                   label: 'Chat',
  //                   bubblePath: 'assets/icons/Union.png',
  //                 ),
  //                 _buildNavItem(
  //                   index: 1,
  //                   currentTab: widget.currentTab!,
  //                   iconPath: 'assets/images/status2.png',
  //                   label: 'Status',
  //                   bubblePath: 'assets/icons/Union.png',
  //                 ),
  //                 _buildNavItem(
  //                   index: 2,
  //                   currentTab: widget.currentTab!,
  //                   iconPath: 'assets/images/call_1.png',
  //                   label: 'Call',
  //                   bubblePath: 'assets/icons/Union.png',
  //                 ),
  //                 _buildNavItem(
  //                   index: 3,
  //                   currentTab: widget.currentTab!,
  //                   iconPath: 'assets/images/contacts.png',
  //                   label: 'Contact',
  //                   bubblePath: 'assets/icons/Union.png',
  //                 ),
  //                 _buildNavItem(
  //                   index: 4,
  //                   currentTab: widget.currentTab!,
  //                   iconPath: 'assets/images/setting.png',
  //                   label: 'Profile',
  //                   bubblePath: 'assets/icons/Union.png',
  //                 ),
  //               ],
  //             ),
  //           ),
  //         )),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
          key: widget.scaffoldKey,
          body: widget.currentPage,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0.0, 4.0),
                  blurRadius: 15,
                  spreadRadius: 0)
            ]),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(0),
                topLeft: Radius.circular(0),
              ),
              child: BottomNavigationBar(
                selectedIconTheme: IconThemeData(color: secondaryColor),
                selectedItemColor: Colors.black,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                unselectedLabelStyle: const TextStyle(color: Colors.white),
                selectedLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 10),
                backgroundColor: Colors.white,
                type: BottomNavigationBarType.fixed,
                currentIndex: widget.currentTab!,
                onTap: (int i) {
                  _selectTab(i);
                },
                items: <BottomNavigationBarItem>[
                  widget.currentTab == 0
                      ? BottomNavigationBarItem(
                          icon: Container(
                            width: 27,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            child: Stack(
                              children: [
                                Image(
                                        image: const AssetImage(
                                            "assets/icons/chat_s.png"),
                                        color: secondaryColor,
                                        width: 20)
                                    .paddingOnly(
                                  top: 2,
                                ),
                                const Image(
                                        image: AssetImage(
                                            'assets/images/message-text.png'),
                                        color: appColorBlack,
                                        width: 24)
                                    .paddingOnly(left: 1.3),
                              ],
                            ),
                          ),
                          label: languageController.textTranslate('Chat'))
                      : BottomNavigationBarItem(
                          icon: const Image(
                            image: AssetImage('assets/images/message-text.png'),
                            width: 24,
                            color: chatColor,
                          ),
                          label: languageController.textTranslate('Chat')),
                  widget.currentTab == 1
                      ? BottomNavigationBarItem(
                          icon: Container(
                            width: 27,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            child: Stack(
                              children: [
                                Image(
                                        image: const AssetImage(
                                            "assets/icons/status_s.png"),
                                        color: secondaryColor,
                                        width: 20)
                                    .paddingOnly(
                                  top: 3,
                                ),
                                const Image(
                                        image: AssetImage(
                                            'assets/images/status2.png'),
                                        color: appColorBlack,
                                        width: 24)
                                    .paddingOnly(left: 1.3),
                              ],
                            ),
                          ),
                          label: languageController.textTranslate('Status'))
                      : BottomNavigationBarItem(
                          icon: const Image(
                              image: AssetImage('assets/images/status2.png'),
                              width: 24,
                              color: chatColor),
                          label: languageController.textTranslate('Status')),
                  widget.currentTab == 2
                      ? BottomNavigationBarItem(
                          icon: Container(
                            width: 27,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            child: Stack(
                              children: [
                                Image(
                                        image: const AssetImage(
                                            "assets/icons/call_s.png"),
                                        color: secondaryColor,
                                        width: 20)
                                    .paddingOnly(
                                  top: 3,
                                ),
                                const Image(
                                        image: AssetImage(
                                            'assets/images/call_1.png'),
                                        color: appColorBlack,
                                        width: 24)
                                    .paddingOnly(left: 1.3),
                              ],
                            ),
                          ),
                          label: languageController.textTranslate('Call'))
                      : BottomNavigationBarItem(
                          icon: const Image(
                            image: AssetImage('assets/images/call_1.png'),
                            width: 24,
                            color: chatColor,
                          ),
                          label: languageController.textTranslate('Call')),
                  widget.currentTab == 3
                      ? BottomNavigationBarItem(
                          icon: Container(
                            width: 27,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            child: Stack(
                              children: [
                                Image(
                                        image: const AssetImage(
                                            "assets/icons/contact_s.png"),
                                        color: secondaryColor,
                                        width: 20)
                                    .paddingOnly(
                                  top: 6,
                                ),
                                const Image(
                                        image: AssetImage(
                                            'assets/images/contacts.png'),
                                        color: appColorBlack,
                                        width: 24)
                                    .paddingOnly(left: 1.3),
                              ],
                            ),
                          ),
                          label: languageController.textTranslate('Contact'))
                      : BottomNavigationBarItem(
                          icon: const Image(
                            image: AssetImage('assets/images/contacts.png'),
                            width: 25,
                            color: Colors.black,
                          ),
                          label: languageController.textTranslate('Contact')),
                  widget.currentTab == 4
                      ? BottomNavigationBarItem(
                          icon: Container(
                            width: 27,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            child: Stack(
                              children: [
                                Image(
                                        image: const AssetImage(
                                            "assets/icons/profile_s.png"),
                                        color: secondaryColor,
                                        width: 20)
                                    .paddingOnly(
                                  top: 3,
                                ),
                                const Image(
                                        image: AssetImage(
                                            'assets/images/setting.png'),
                                        color: appColorBlack,
                                        width: 24)
                                    .paddingOnly(left: 1.3),
                              ],
                            ),
                          ),
                          label: languageController.textTranslate('Profile'))
                      : BottomNavigationBarItem(
                          icon: const Image(
                            image: AssetImage('assets/images/setting.png'),
                            width: 24,
                            color: Colors.black,
                          ),
                          label: languageController.textTranslate('Profile'),
                        ),
                ],
              ),
            ),
          )),
    );
  }
}

