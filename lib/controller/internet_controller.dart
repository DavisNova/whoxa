// import 'dart:developer';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';

// class InternetController extends GetxController {
//   var isOnline = false.obs;

//   @override
//   void onInit() {
//    
//     Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//       checkInternet();
//     });
//     checkInternet();
//     super.onInit();
//   }

//   checkInternetStart() async {
//     var value = await Connectivity().checkConnectivity();
//     if (value != ConnectivityResult.none) {
//       isOnline.value = await InternetConnectionChecker().hasConnection;
//       if (kDebugMode) {
//         print("INTERNET CONNECTION ${isOnline.value}");
//       }
//     } else if (value == ConnectivityResult.wifi) {
//       isOnline.value = await InternetConnectionChecker().hasConnection;
//     } else {
//       isOnline.value = await InternetConnectionChecker().hasConnection;

//       if (kDebugMode) {
//         print("INTERNET CONNECTION ${isOnline.value}");
//       }
//     }
//   }

//   checkInternet() async {
//    
//     var subscription = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) async {
//       if (result != ConnectivityResult.none) {
//         isOnline.value = await InternetConnectionChecker().hasConnection;
//         log("VALUE OF ONLINE ${isOnline.value}");
//       } else {
//         isOnline.value = await InternetConnectionChecker().hasConnection;
//         log("VALUE OF ONLINE : ${isOnline.value}");
//        
//       }
//     });
//   }
// }
