// // ignore_for_file: avoid_print

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';
// import 'package:whoxachat/src/Notification/notification_service.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';

// class FirebaseMessagingService {
//   void setUpFirebase() {
//     FirebaseMessaging.instance.getInitialMessage().then(
//       (message) {
//         print("FirebaseMessaging.instance.getInitialMessage");
//         if (message != null) {
//           print("New Notification");
//           print("FirebaseMessaging.onMessageOpenedApp.listen");
//           print('data--->> ${message.data}');
//           print('title-----> ${message.notification!.title}');
//           print(message.data['message']);
//           if (message.data['call_type'] == 'video_call') {
//             print("onMessageOpenedApp video call screen");
//             if (message.data['missed_call'] == "true") {
//               Get.back();
//             } else {
//               Get.to(IncomingCallScrenn(
//                 roomID: message.data['room_id'],
//                 callerImage: message.data['sender_profile_image'],
//                 senderName: message.data['senderName'],
//                 conversation_id: message.data['conversation_id'],
//                 message_id: message.data['message_id'],
//                 caller_id: message.data['senderId'],
//                 isGroupCall: message.data['is_group'],
//               ));
//             }
//           } else if (message.data['call_type'] == 'audio_call') {
//             print("onMessageOpenedApp audio call screen");
//             if (message.data['missed_call'] == "true") {
//               Get.back();
//             } else {
//               Get.to(IncomingCallScrenn(
//                 roomID: message.data['room_id'],
//                 callerImage: message.data['sender_profile_image'],
//                 senderName: message.data['senderName'],
//                 conversation_id: message.data['conversation_id'],
//                 message_id: message.data['message_id'],
//                 caller_id: message.data['senderId'],
//                 forVideoCall: false,
//                 receiverImage: message.data['receiver_profile_image'],
//                 isGroupCall: message.data['is_group'],
//               ));
//             }
//           }
//         }
//       },
//     );
//     FirebaseMessaging.onMessage.listen(
//       (message) async {
//         print("FirebaseMessaging.onMessage.listen");
//         if (message.notification != null) {
//           print(message.notification!.title);
//           print(message.data['message']);
//           print("NOTIFICATION:::: ${message.data}");

//           LocalNotificationService.notificationsPlugin.cancelAll();
//           LocalNotificationService().createanddisplaynotification(message);

//           if (message.data['call_type'] == 'video_call') {
//             print("FirebaseMessaging.onMessage video call");
//             if (message.data['missed_call'] == 'true') {
//               Get.back();
//             } else {
//               Get.to(IncomingCallScrenn(
//                 roomID: message.data['room_id'],
//                 callerImage: message.data['sender_profile_image'],
//                 senderName: message.data['senderName'],
//                 conversation_id: message.data['conversation_id'],
//                 message_id: message.data['message_id'],
//                 caller_id: message.data['senderId'],
//                 isGroupCall: message.data['is_group'],
//               ));
//             }
//           } else if (message.data['call_type'] == 'audio_call') {
//             print("FirebaseMessaging.onMessage audio call screen");
//             if (message.data['missed_call'] == "true") {
//               Get.back();
//             } else {
//               Get.to(IncomingCallScrenn(
//                 roomID: message.data['room_id'],
//                 callerImage: message.data['sender_profile_image'],
//                 senderName: message.data['senderName'],
//                 conversation_id: message.data['conversation_id'],
//                 message_id: message.data['message_id'],
//                 caller_id: message.data['senderId'],
//                 forVideoCall: false,
//                 receiverImage: message.data['receiver_profile_image'],
//                 isGroupCall: message.data['is_group'],
//               ));
//             }
//           }
//         }
//       },
//     );

//     FirebaseMessaging.onMessageOpenedApp.listen(
//       (message) async {
//         print("FirebaseMessaging.onMessageOpenedApp.listen");
//         if (message.notification != null) {
//           print('title-----> ${message.notification!.title}');
//           print(message.data['message']);
//           print('data--->> ${message.data}');

//           if (message.data['call_type'] == 'video_call') {
//             print("FirebaseMessaging.onMessageOpenedApp 1 video call");
//             if (message.data['missed_call'] == 'true') {
//               Get.back();
//             } else {
//               Get.to(IncomingCallScrenn(
//                 roomID: message.data['room_id'],
//                 callerImage: message.data['sender_profile_image'],
//                 senderName: message.data['senderName'],
//                 conversation_id: message.data['conversation_id'],
//                 message_id: message.data['message_id'],
//                 caller_id: message.data['senderId'],
//                 isGroupCall: message.data['is_group'],
//               ));
//             }
//           } else if (message.data['call_type'] == 'audio_call') {
//             print("FirebaseMessaging.onMessageOpenedApp audio call screen");
//             if (message.data['missed_call'] == "true") {
//               Get.back();
//             } else {
//               Get.to(IncomingCallScrenn(
//                 roomID: message.data['room_id'],
//                 callerImage: message.data['sender_profile_image'],
//                 senderName: message.data['senderName'],
//                 conversation_id: message.data['conversation_id'],
//                 message_id: message.data['message_id'],
//                 caller_id: message.data['senderId'],
//                 forVideoCall: false,
//                 receiverImage: message.data['receiver_profile_image'],
//                 isGroupCall: message.data['is_group'],
//               ));
//             }
//           }
//         }
//       },
//     );
//   }
// }
