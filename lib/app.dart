// ignore_for_file: avoid_print, empty_catches, unused_local_variable, use_build_context_synchronously, depend_on_referenced_packages, unused_import, unused_field

// import 'dart:developer';
// import 'dart:io';

// // import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';

// import 'package:whoxachat/controller/get_delete_story.dart';
// import 'package:whoxachat/controller/launguage_controller.dart';
// import 'package:whoxachat/src/Notification/notifiactions_handler.dart';
// import 'package:whoxachat/src/Notification/notification_service.dart';
// import 'package:whoxachat/src/Notification/one_signal_service.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/global/strings.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
// import 'package:whoxachat/src/screens/user/create_profile.dart';
// import 'package:whoxachat/src/screens/user/profile.dart';
// import 'package:whoxachat/welcome.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';

// import 'src/screens/layout/bottombar.dart';

// LanguageController languageController = Get.find();

// class AppScreen extends StatefulWidget {
//   const AppScreen({super.key});

//   @override
//   State<AppScreen> createState() => _AppScreenState();
// }

// class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
//   GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());
//   String? _currentUuid;
//   late final Uuid _uuid;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     // requestPermissions(); due to multiple request of permission this code is not work
//     // requestAndCheckPermissions();
//     print(
//         "OneSignal pushSubscription optedIn ${OneSignal.User.pushSubscription.optedIn}");
//     print(
//         "OneSignal pushSubscription id ${OneSignal.User.pushSubscription.id}");
//     print(
//         "OneSignal pushSubscription token ${OneSignal.User.pushSubscription.token}");

//     OnesignalService().onNotifiacation();
//     OnesignalService().onNotificationClick();

//     // _checkPermissions(); due to multiple request of permission this code is not work
//     // FirebaseMessagingService().setUpFirebase();

//     deleteStroy.getDelete();
//     log("AuthToken: ${Hive.box(userdata).get(authToken)}");
//   }

//   // ignore: unused_element
//   Future<void> _checkPermissions() async {
//     if (await Permission.contacts.request().isGranted) {
//       addContactController.getContactsFromGloble();
//     } else {
//       if (Platform.isAndroid) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content:
//                   Text('Contacts permission is required to use this feature')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _handleCurrentScreen();
//   }

//   Widget _handleCurrentScreen() {
//     var box = Hive.box(userdata);

//     if (box.get(authToken) != null &&
//         box.get(lastName) != null &&
//         box.get(lastName)!.isNotEmpty &&
//         box.get(firstName) != null &&
//         box.get(firstName)!.isNotEmpty) {
//       print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
//       return TabbarScreen();
//     } else if (box.get(authToken) == null &&
//         box.get(lastName) == null &&
//         box.get(firstName) == null) {
//       print("☺☺☺☺GO TO WELCOME SCREEN☺☺☺☺");
//       return const Welcome();
//     } else {
//       print("☺☺☺☺GO TO CREATE PROFILE☺☺☺☺");
//       return AddPersonaDetails(isRought: false, isback: false);
//     }
//   }

//   // Future<void> requestPermissions() async {
//   //   await Permission.notification.request();

//   //   await Permission.camera.request();

//   //   await Permission.microphone.request();

//   //   await Permission.storage.request();

//   //   await Permission.photos.request();
//   // }

//   Future<void> requestAndCheckPermissions() async {
//     try {
//       // Request all permissions together
//       Map<Permission, PermissionStatus> statuses = await [
//         Permission.notification,
//         Permission.camera,
//         Permission.microphone,
//         Permission.storage,
//         Permission.photos,
//         Permission.contacts,
//       ].request();

//       // Check if contacts permission was granted and perform contact-related actions
//       if (statuses[Permission.contacts]?.isGranted ?? false) {
//         addContactController.getContactsFromGloble();
//       } else if (Platform.isAndroid) {
//         // Only show this message if we're on Android
//         if (mounted) {
//           // Check if widget is still mounted
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text(
//                     'Contacts permission is required to use this feature')),
//           );
//         }
//       }
//     } catch (e) {
//       // Handle any errors that might occur during permission requests
//       print("Error requesting permissions: $e");
//     }
//   }
// }

// // ignore_for_file: avoid_print, empty_catches, unused_local_variable, use_build_context_synchronously, depend_on_referenced_packages, unused_import, unused_field

// import 'dart:developer';
// import 'dart:io';

// // import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:whoxachat/welcome.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';

// import 'package:whoxachat/controller/get_delete_story.dart';
// import 'package:whoxachat/controller/launguage_controller.dart';
// import 'package:whoxachat/src/Notification/notifiactions_handler.dart';
// import 'package:whoxachat/src/Notification/notification_service.dart';
// import 'package:whoxachat/src/Notification/one_signal_service.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/global/strings.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
// import 'package:whoxachat/src/screens/user/FinalLogin.dart';
// import 'package:whoxachat/src/screens/user/create_profile.dart';
// import 'package:whoxachat/src/screens/user/profile.dart';

// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';

// import 'src/screens/layout/bottombar.dart';

// LanguageController languageController = Get.find();

// class AppScreen extends StatefulWidget {
//   const AppScreen({super.key});

//   @override
//   State<AppScreen> createState() => _AppScreenState();
// }

// class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
//   GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());
//   String? _currentUuid;
//   late final Uuid _uuid;
//   bool _checkingPermissions = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     // Initialize services
//     OnesignalService().onNotifiacation();
//     OnesignalService().onNotificationClick();

//     // Check OneSignal status
//     _checkOneSignalStatus();

//     // Check permissions after a short delay to allow the UI to render
//     Future.delayed(Duration(milliseconds: 300), () {
//       _checkAndRequestPermissionsIfNeeded();
//     });

//     // Delete story logic
//     deleteStroy.getDelete();
//     log("AuthToken: ${Hive.box(userdata).get(authToken)}");
//   }

//   void _checkOneSignalStatus() {
//     print(
//         "OneSignal pushSubscription optedIn ${OneSignal.User.pushSubscription.optedIn}");
//     print(
//         "OneSignal pushSubscription id ${OneSignal.User.pushSubscription.id}");
//     print(
//         "OneSignal pushSubscription token ${OneSignal.User.pushSubscription.token}");
//   }

//   Future<void> _checkAndRequestPermissionsIfNeeded() async {
//     if (_checkingPermissions) return;
//     _checkingPermissions = true;

//     try {
//       // Get permission status
//       final bool permissionsRequested = await _werePermissionsRequested();
//       final bool anyPermissionsMissing = await _checkAnyPermissionsMissing();

//       // Check if we need to show permissions screen
//       if (!permissionsRequested || anyPermissionsMissing) {
//         if (mounted) {
//           // If we haven't requested permissions yet, or some are still missing,
//           // navigate to the Welcome screen for permission handling
//           print(
//               "AppScreen: Some permissions are missing, navigating to Welcome screen for permissions");
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const Welcome(fromAppScreen: true),
//             ),
//           );
//         }
//       } else {
//         // All permissions have been handled already
//         // We can perform contact-specific operations that require permissions
//         print("AppScreen: All permissions already granted, proceeding");
//         _checkContactsPermission();
//       }
//     } catch (e) {
//       print("Error checking permissions: $e");
//     } finally {
//       _checkingPermissions = false;
//     }
//   }

//   // Check if we've already gone through the permission request flow
//   Future<bool> _werePermissionsRequested() async {
//     try {
//       return Hive.box('userdata')
//           .get('permissions_requested', defaultValue: false);
//     } catch (e) {
//       print("Error checking permissions_requested flag: $e");
//       return false;
//     }
//   }

//   // Specifically check contacts permission for the contacts-related functionality
//   Future<void> _checkContactsPermission() async {
//     final status = await Permission.contacts.status;
//     if (status.isGranted) {
//       // Only try to get contacts if permission is explicitly granted
//       addContactController.getContactsFromGloble();
//     } else if (Platform.isAndroid && mounted) {
//       // Only show this message on Android
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Contacts permission is required to use this feature'),
//         ),
//       );
//     }
//   }

//   // Check if any required permissions are missing
//   Future<bool> _checkAnyPermissionsMissing() async {
//     List<Permission> requiredPermissions = [
//       Permission.notification,
//       Permission.camera,
//       Permission.microphone,
//       Permission.storage,
//       Permission.photos,
//       Permission.contacts,
//       Permission.location,
//     ];

//     for (var permission in requiredPermissions) {
//       final status = await permission.status;
//       if (!status.isGranted) {
//         print("Permission missing: ${permission.toString()} (status: $status)");
//         return true; // At least one permission is missing
//       }
//     }

//     return false; // All permissions are granted
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _handleCurrentScreen();
//   }

//   // Widget _handleCurrentScreen() {
//   //   var box = Hive.box(userdata);

//   //   if (box.get(authToken) != null &&
//   //       box.get(lastName) != null &&
//   //       box.get(lastName)!.isNotEmpty &&
//   //       box.get(firstName) != null &&
//   //       box.get(firstName)!.isNotEmpty) {
//   //     print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
//   //     return TabbarScreen();
//   //   } else if (box.get(authToken) == null &&
//   //       box.get(lastName) == null &&
//   //       box.get(firstName) == null) {
//   //     print("☺☺☺☺GO TO WELCOME SCREEN☺☺☺☺");
//   //     return const Welcome();
//   //   } else {
//   //     print("☺☺☺☺GO TO CREATE PROFILE☺☺☺☺");
//   //     return AddPersonaDetails(isRought: false, isback: false);
//   //   }
//   // }

//   Widget _handleCurrentScreen() {
//     var box = Hive.box(userdata);

//     final bool hasAuthToken = box.get(authToken) != null;
//     final bool hasLastName =
//         box.get(lastName) != null && box.get(lastName)!.isNotEmpty;
//     final bool hasFirstName =
//         box.get(firstName) != null && box.get(firstName)!.isNotEmpty;
//     final bool permissionsRequested =
//         box.get('permissions_requested', defaultValue: false);

//     // Check if user is fully logged in with profile
//     if (hasAuthToken && hasLastName && hasFirstName) {
//       print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
//       return TabbarScreen();
//     }
//     // Check if this is the first time user who needs to see Welcome screen
//     else if (!hasAuthToken &&
//         !hasLastName &&
//         !hasFirstName &&
//         !permissionsRequested) {
//       print("☺☺☺☺GO TO WELCOME SCREEN (first time user)☺☺☺☺");
//       return const Welcome(
//           fromAppScreen:
//               false); // Important: not from AppScreen to ensure Flogin is shown after permissions
//     }
//     // Check if user has token but needs to create profile
//     else if (hasAuthToken && (!hasLastName || !hasFirstName)) {
//       print("☺☺☺☺GO TO CREATE PROFILE☺☺☺☺");
//       return AddPersonaDetails(isRought: false, isback: false);
//     }
//     // User has completed permissions flow but still needs to login
//     else if (!hasAuthToken && permissionsRequested) {
//       print("☺☺☺☺GO TO LOGIN PAGE (permissions already handled)☺☺☺☺");
//       return const Flogin();
//     }
//     // Default fallback
//     else {
//       print("☺☺☺☺DEFAULT FALLBACK TO WELCOME☺☺☺☺");
//       return const Welcome();
//     }
//   }
// }

// import 'dart:developer';
// import 'dart:io';

// import 'package:whoxachat/welcome.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
// import 'package:whoxachat/controller/get_delete_story.dart';
// import 'package:whoxachat/controller/launguage_controller.dart';
// import 'package:whoxachat/src/Notification/notifiactions_handler.dart';
// import 'package:whoxachat/src/Notification/notification_service.dart';
// import 'package:whoxachat/src/Notification/one_signal_service.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/global/strings.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';
// import 'package:whoxachat/src/screens/user/FinalLogin.dart';
// import 'package:whoxachat/src/screens/user/create_profile.dart';
// import 'package:whoxachat/src/screens/user/profile.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';
// import 'src/screens/layout/bottombar.dart';

// LanguageController languageController = Get.find();

// class AppScreen extends StatefulWidget {
//   const AppScreen({super.key});

//   @override
//   State<AppScreen> createState() => _AppScreenState();
// }

// class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
//   GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());
//   String? _currentUuid;
//   late final Uuid _uuid;
//   bool _checkingPermissions = false;
//   bool _initialCheckComplete = false;
//   late Widget _currentScreen;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     // Set initial loading screen
//     _currentScreen = const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );

//     // Initialize services
//     OnesignalService().onNotifiacation();
//     OnesignalService().onNotificationClick();

//     // Check OneSignal status
//     _checkOneSignalStatus();

//     // Initialize app state
//     _initializeAppState();

//     // Delete story logic
//     deleteStroy.getDelete();
//     log("AuthToken: ${Hive.box(userdata).get(authToken)}");
//   }

//   Future<void> _initializeAppState() async {
//     try {
//       // Wait for permission check to complete before deciding which screen to show
//       await _checkAndHandlePermissions();

//       if (mounted) {
//         final screenToShow = await _determineAppScreen();
//         setState(() {
//           _initialCheckComplete = true;
//           _currentScreen = screenToShow;
//         });
//       }
//     } catch (e) {
//       print("Error in _initializeAppState: $e");
//       if (mounted) {
//         final screenToShow = await _determineAppScreen();
//         setState(() {
//           _initialCheckComplete = true;
//           _currentScreen = screenToShow; // Fall back to standard logic
//         });
//       }
//     }
//   }

//   void _checkOneSignalStatus() {
//     print(
//         "OneSignal pushSubscription optedIn ${OneSignal.User.pushSubscription.optedIn}");
//     print(
//         "OneSignal pushSubscription id ${OneSignal.User.pushSubscription.id}");
//     print(
//         "OneSignal pushSubscription token ${OneSignal.User.pushSubscription.token}");
//   }

//   Future<void> _checkAndHandlePermissions() async {
//     if (_checkingPermissions) return;
//     _checkingPermissions = true;

//     try {
//       // Get permission status
//       final bool permissionsRequested = await _werePermissionsRequested();
//       final bool anyPermissionsMissing = await _checkAnyPermissionsMissing();

//       // If permissions are all granted, we perform necessary operations
//       if (permissionsRequested && !anyPermissionsMissing) {
//         await _handleGrantedPermissions();
//       }

//       // Note: We don't navigate here. We just set the flag and let _determineAppScreen handle navigation.
//     } catch (e) {
//       print("Error checking permissions: $e");
//     } finally {
//       _checkingPermissions = false;
//     }
//   }

//   // Only perform operations that require permissions when all permissions are granted
//   Future<void> _handleGrantedPermissions() async {
//     await _checkContactsPermission();
//     // Add any other permission-dependent operations here
//   }

//   // Check if we've already gone through the permission request flow
//   Future<bool> _werePermissionsRequested() async {
//     try {
//       return Hive.box('userdata')
//           .get('permissions_requested', defaultValue: false);
//     } catch (e) {
//       print("Error checking permissions_requested flag: $e");
//       return false;
//     }
//   }

//   // Specifically check contacts permission for the contacts-related functionality
//   Future<void> _checkContactsPermission() async {
//     final status = await Permission.contacts.status;
//     if (status.isGranted) {
//       // Only try to get contacts if permission is explicitly granted
//       await addContactController.getContactsFromGloble();
//     }
//   }

//   // Check if any required permissions are missing
//   Future<bool> _checkAnyPermissionsMissing() async {
//     List<Permission> requiredPermissions = [
//       Permission.notification,
//       Permission.camera,
//       Permission.microphone,
//       Permission.storage,
//       Permission.photos,
//       Permission.contacts,
//       Permission.location,
//     ];

//     for (var permission in requiredPermissions) {
//       final status = await permission.status;
//       if (!status.isGranted) {
//         print("Permission missing: ${permission.toString()} (status: $status)");
//         return true; // At least one permission is missing
//       }
//     }

//     return false; // All permissions are granted
//   }

//   // This function determines which screen to show based on app state
//   Future<Widget> _determineAppScreen() async {
//     var box = Hive.box(userdata);

//     final bool hasAuthToken = box.get(authToken) != null;
//     final bool hasLastName =
//         box.get(lastName) != null && box.get(lastName)!.isNotEmpty;
//     final bool hasFirstName =
//         box.get(firstName) != null && box.get(firstName)!.isNotEmpty;
//     final bool permissionsRequested =
//         box.get('permissions_requested', defaultValue: false);

//     // Check permissions status
//     final bool anyPermissionsMissing = await _checkAnyPermissionsMissing();

//     // Permission flow needed
//     if (!permissionsRequested || anyPermissionsMissing) {
//       print("☺☺☺☺GO TO WELCOME SCREEN FOR PERMISSIONS☺☺☺☺");
//       return const Welcome(fromAppScreen: true);
//     }
//     // User is fully logged in with profile
//     else if (hasAuthToken && hasLastName && hasFirstName) {
//       print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
//       return TabbarScreen();
//     }
//     // User has token but needs to create profile
//     else if (hasAuthToken && (!hasLastName || !hasFirstName)) {
//       print("☺☺☺☺GO TO CREATE PROFILE☺☺☺☺");
//       return AddPersonaDetails(isRought: false, isback: false);
//     }
//     // User has completed permissions flow but still needs to login
//     else if (!hasAuthToken) {
//       print("☺☺☺☺GO TO LOGIN PAGE (permissions already handled)☺☺☺☺");
//       return const Flogin();
//     }
//     // Default fallback
//     else {
//       print("☺☺☺☺DEFAULT FALLBACK TO WELCOME☺☺☺☺");
//       return const Welcome();
//     }
//   }

//   // Handle navigation to permission screen from the main UI
//   void _navigateToPermissionScreen() {
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const Welcome(fromAppScreen: true),
//         ),
//       ).then((_) {
//         // Refresh state when returning from permission screen
//         _initializeAppState();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // During initial loading, show loading screen
//     if (!_initialCheckComplete) {
//       return _currentScreen; // Shows loading indicator
//     }

//     // After initial check is complete, we can handle changes dynamically
//     return _currentScreen;
//   }
// }

// app.dart
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/controller/get_delete_story.dart';
import 'package:whoxachat/controller/launguage_controller.dart';
import 'package:whoxachat/src/Notification/notifiactions_handler.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:whoxachat/src/screens/user/FinalLogin.dart';
import 'package:whoxachat/src/screens/user/create_profile.dart';
import 'package:whoxachat/welcome.dart';
import 'package:uuid/uuid.dart';

LanguageController languageController = Get.find();

// This function will be called from main.dart or SplashScreen
// to pre-determine which screen to show *before* building any UI
Widget determineInitialScreen() {
  var box = Hive.box(userdata);

  final bool hasAuthToken = box.get(authToken) != null;
  final bool hasLastName =
      box.get(lastName) != null && box.get(lastName)!.isNotEmpty;
  final bool hasFirstName =
      box.get(firstName) != null && box.get(firstName)!.isNotEmpty;
  final bool permissionsRequested =
      box.get('permissions_requested', defaultValue: false);

  // User is fully logged in with profile
  if (hasAuthToken && hasLastName && hasFirstName) {
    print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
    return TabbarScreen();
  }
  // User has token but needs to create profile
  else if (hasAuthToken && (!hasLastName || !hasFirstName)) {
    print("☺☺☺☺GO TO CREATE PROFILE☺☺☺☺");
    return AddPersonaDetails(isRought: false, isback: false);
  }
  // User has completed permissions but needs to login
  else if (!hasAuthToken && permissionsRequested) {
    print("☺☺☺☺GO TO LOGIN PAGE☺☺☺☺");
    return const Flogin();
  }
  // Default fallback - user needs to grant permissions
  else {
    print("☺☺☺☺DEFAULT TO WELCOME SCREEN☺☺☺☺");
    return const Welcome();
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
  GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());
  String? _currentUuid;
  late final Uuid _uuid;
  late final Widget _initialScreen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize notification services
    OnesignalService().onNotifiacation();
    OnesignalService().onNotificationClick();

    // Delete story logic
    deleteStroy.getDelete();
    log("AuthToken: ${Hive.box(userdata).get(authToken)}");

    // Pre-determine which screen to show
    _initialScreen = determineInitialScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No conditional logic in build - just return the pre-determined screen
    return _initialScreen;
  }
}
