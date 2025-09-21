// // ignore_for_file: file_names, library_prefixes

// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:whoxachat/controller/online_controller.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/global/strings.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketIntilized {
//   OnlineOfflineController controller = Get.put(OnlineOfflineController());
//   IO.Socket? socket;
//   initlizedsocket() async {
//     socket = IO.io(
//         '${socketBaseUrl()}/?token=${Hive.box(userdata).get(authToken).toString()}',
//         <String, dynamic>{
//           'transports': ['websocket'],
//           'path': '/socket'
//         });
//     log('${socketBaseUrl()}/?user_id=${Hive.box(userdata).get(authToken).toString()} USER ID ');
//     if (kDebugMode) {
//       print("Socket Activated");
//     }
//     controller.forData();
//     controller.offlineUser();
//     controller.isTyping();
//   }
// }

// ignore_for_file: file_names, library_prefixes
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/controller/online_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIntilized {
  OnlineOfflineController controller = Get.put(OnlineOfflineController());
  IO.Socket? socket;

  // Add to your SocketIntilized class
  void logSocketDetails() {
    log("Socket connected: ${socket?.connected ?? false}");
    log("Socket id: ${socket?.id}");
    log("Socket URL: ${socketBaseUrl()}");
  }

  initlizedsocket() async {
    final url =
        '${socketBaseUrl()}/?token=${Hive.box(userdata).get(authToken).toString()}';
    log('Socket URL: $url');

    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'path': '/socket',
      'autoConnect': true,
    });

    log('Socket URL: ${socketBaseUrl()}/?token=${Hive.box(userdata).get(authToken).toString()}');

    // Add socket connection event listeners
    socket!.onConnect((_) {
      log('Socket Connected');
      if (kDebugMode) {
        print('🟢 Socket connection established');
      }
    });

    socket!.onDisconnect((_) {
      log('Socket Disconnected');
      if (kDebugMode) {
        print('🔴 Socket disconnected');
      }
    });

    socket!.onConnectError((error) {
      log('Socket Connection Error: $error');
      if (kDebugMode) {
        print('⚠️ Socket connection error: $error');
      }
    });

    socket!.onError((error) {
      log('Socket Error: $error');
      if (kDebugMode) {
        print('❌ Socket error: $error');
      }
    });

    // Log all incoming events (useful for debugging)
    socket!.onAny((event, data) {
      log('Socket Event: $event, Data: $data');
      if (kDebugMode) {
        print('📩 Socket event: $event');
      }
    });

    if (kDebugMode) {
      print("Socket Activated");
    }

    controller.forData();
    controller.offlineUser();
    controller.isTyping();
  }

  // Method to check if socket is connected
  bool isConnected() {
    return socket?.connected ?? false;
  }

  // Method to manually connect socket
  void connect() {
    socket?.connect();
    log('Manual socket connection initiated');
  }

  // Method to manually disconnect socket
  void disconnect() {
    socket?.disconnect();
    log('Manual socket disconnection initiated');
  }

  // Method to emit an event with debug logging
  void emitWithLogging(String event, dynamic data) {
    log('Emitting event: $event with data: $data');
    socket?.emit(event, data);
  }
}
