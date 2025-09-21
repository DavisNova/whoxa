// // ignore_for_file: deprecated_member_use, file_names, depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, unnecessary_new, prefer_const_constructors, sort_child_properties_last, prefer_final_fields, prefer_typing_uninitialized_variables, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_string_escapes, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_is_empty, no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, duplicate_ignore, use_super_parameters, prefer_if_null_operators, curly_braces_in_flow_control_structures, unnecessary_const, unnecessary_this, must_be_immutable, no_logic_in_create_state, avoid_function_literals_in_foreach_calls, unnecessary_string_interpolations, avoid_single_cascade_in_expression_statements, prefer_const_declarations, unnecessary_null_comparison, prefer_const_constructors_in_immutables, await_only_futures
// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/audio_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/incoming_call_screen.dart';
// import 'package:whoxachat/src/screens/call/web_rtc/video_call_screen.dart';

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   final RoomIdController roomIdController = Get.put(RoomIdController());

//   createanddisplaynotification(RemoteMessage message) async {
//     try {
//       print("display_notifcation");
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       NotificationDetails notificationDetails = NotificationDetails(
//         iOS: DarwinNotificationDetails(
//           presentSound: true,
//           presentAlert: true,
//           presentBadge: true,
//         ),
//         android: (message.data['call_type'] == 'video_call' &&
//                     message.data['missed_call'] == "false") ||
//                 (message.data['call_type'] == 'audio_call' &&
//                     message.data['missed_call'] == "false")
//             ? AndroidNotificationDetails(
//                 "meyaooapp",
//                 "meyaoochannel",
//                 importance: Importance.max,
//                 priority: Priority.high,
//                 icon: "@mipmap/ic_launcher",
//                 enableVibration: true,
//                 vibrationPattern: Int64List.fromList(
//                     [0, 1000, 500, 2000, 500, 3000, 500, 4000]),
//                 actions: [
//                   AndroidNotificationAction(
//                     "accept",
//                     '📞 Accept',
//                     cancelNotification: false,
//                     allowGeneratedReplies: true,
//                     showsUserInterface: true,
//                     titleColor: Colors.green,
//                   ),
//                   const AndroidNotificationAction(
//                     "decline",
//                     '🚫 Decline',
//                     cancelNotification: false,
//                     allowGeneratedReplies: true,
//                     showsUserInterface: true,
//                     titleColor: Colors.red,
//                   ),
//                 ],
//               )
//             : AndroidNotificationDetails(
//                 "meyaooapp",
//                 "meyaoochannel",
//                 importance: Importance.max,
//                 priority: Priority.high,
//                 icon: "@mipmap/ic_launcher",
//               ),
//       );
//       await notificationsPlugin.show(
//         id,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//         payload: json.encode(message.data),
//       );

//       InitializationSettings initializationSettings = InitializationSettings(
//         android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//         iOS: DarwinInitializationSettings(
//           onDidReceiveLocalNotification: (id, title, body, payload) {
//             return;
//           },
//         ),
//       );

//       notificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveBackgroundNotificationResponse: (details) async {
//           Map data = json.decode(details.payload!);
//           if (details.actionId == 'accept') {
//             print("accept");
//             if (data['call_type'] == 'video_call') {
//               print("FirebaseMessaging.service 1 video call");

//               Get.off(VideoCallScreen(
//                 roomID: data['room_id'],
//                 conversation_id: data['conversation_id'],
//                 isGroupCall: data['is_group'].toString(),
//               ));
//             } else if (data['call_type'] == 'audio_call') {
//               print("FirebaseMessaging.service 1 video call");

//               Get.off(AudioCallScreen(
//                 roomID: data['room_id'],
//                 conversation_id: data['conversation_id'],
//                 receiverImage: data["sender_profile_image"],
//                 receiverUserName: data["senderName"],
//                 isGroupCall: data['is_group'].toString(),
//               ));
//             }
//           } else if (details.actionId == 'decline') {
//             print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
//             if (data['call_type'] == 'video_call') {
//               if (data['is_group'] == "true") {
//                 Get.back();
//               } else {
//                 roomIdController.callCutByReceiver(
//                   conversationID: data['conversation_id'],
//                   message_id: data['message_id'],
//                   caller_id: data['senderId'],
//                 );
//               }
//             } else if (data['call_type'] == 'audio_call') {
//               if (data['is_group'] == "true") {
//                 Get.back();
//               } else {
//                 roomIdController.callCutByReceiver(
//                   conversationID: data['conversation_id'],
//                   message_id: data['message_id'],
//                   caller_id: data['senderId'],
//                 );
//               }
//             }
//           } else {
//             if (data['call_type'] == 'video_call') {
//               Get.to(IncomingCallScrenn(
//                 roomID: data['room_id'],
//                 callerImage: data['sender_profile_image'],
//                 senderName: data['senderName'],
//                 conversation_id: data['conversation_id'],
//                 message_id: data['message_id'],
//                 caller_id: data['senderId'],
//                 isGroupCall: data['is_group'],
//               ));
//             } else if (data['call_type'] == 'audio_call') {
//               Get.to(IncomingCallScrenn(
//                 roomID: data['room_id'],
//                 callerImage: data['sender_profile_image'],
//                 senderName: data['senderName'],
//                 conversation_id: data['conversation_id'],
//                 message_id: data['message_id'],
//                 caller_id: data['senderId'],
//                 forVideoCall: false,
//                 receiverImage: data['receiver_profile_image'],
//                 isGroupCall: data['is_group'],
//               ));
//             }
//           }
//           LocalNotificationService.notificationsPlugin.cancelAll();
//         },
//         onDidReceiveNotificationResponse: (details) {
//           Map data = json.decode(details.payload!);
//           if (details.actionId == 'accept') {
//             print("accept");
//             if (data['call_type'] == 'video_call') {
//               print("FirebaseMessaging.service 2 video call");
//               Get.off(VideoCallScreen(
//                 roomID: data['room_id'],
//                 conversation_id: data['conversation_id'],
//                 isGroupCall: data['is_group'].toString(),
//               ));
//             } else if (data['call_type'] == 'audio_call') {
//               print("FirebaseMessaging.service 1 video call");

//               Get.off(AudioCallScreen(
//                 roomID: data['room_id'],
//                 conversation_id: data['conversation_id'],
//                 receiverImage: data["sender_profile_image"],
//                 receiverUserName: data["senderName"],
//                 isGroupCall: data['is_group'].toString(),
//               ));
//             }
//           } else if (details.actionId == 'decline') {
//             print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_insideapp");
//             if (data['call_type'] == 'video_call') {
//               if (data['is_group'] == "true") {
//                 Get.back();
//               } else {
//                 roomIdController.callCutByReceiver(
//                   conversationID: data['conversation_id'],
//                   message_id: data['message_id'],
//                   caller_id: data['senderId'],
//                 );
//               }
//             } else if (data['call_type'] == 'audio_call') {
//               if (data['is_group'] == "true") {
//                 Get.back();
//               } else {
//                 roomIdController.callCutByReceiver(
//                   conversationID: data['conversation_id'],
//                   message_id: data['message_id'],
//                   caller_id: data['senderId'],
//                 );
//               }
//             }
//           } else {
//             if (data['call_type'] == 'video_call') {
//               Get.to(IncomingCallScrenn(
//                 roomID: data['room_id'],
//                 callerImage: data['sender_profile_image'],
//                 senderName: data['senderName'],
//                 conversation_id: data['conversation_id'],
//                 message_id: data['message_id'],
//                 caller_id: data['senderId'],
//                 isGroupCall: data['is_group'],
//               ));
//             } else if (data['call_type'] == 'audio_call') {
//               Get.to(IncomingCallScrenn(
//                 roomID: data['room_id'],
//                 callerImage: data['sender_profile_image'],
//                 senderName: data['senderName'],
//                 conversation_id: data['conversation_id'],
//                 message_id: data['message_id'],
//                 caller_id: data['senderId'],
//                 forVideoCall: false,
//                 receiverImage: data['receiver_profile_image'],
//                 isGroupCall: data['is_group'],
//               ));
//             }
//           }
//           LocalNotificationService.notificationsPlugin.cancelAll();
//         },
//       );
//     } on Exception catch (e) {
//       print(e);
//     }
//   }
// }
