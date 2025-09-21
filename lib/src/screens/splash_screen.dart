// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:whoxachat/app.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/Notification/one_signal_service.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     navigateToScreen();
//     super.initState();
//   }

//   navigateToScreen() async {
//     Future.delayed(
//       const Duration(seconds: 3),
//       () {
//         Get.offAll(
//           const AppScreen(),
//           transition: Transition.downToUp,
//         );
//         OnesignalService().initialize();
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the screen dimensions
//     final screenSize = MediaQuery.of(context).size;
//     final height = screenSize.height;
//     final width = screenSize.width;

//     // Determine logo sizes based on screen size
//     final mainLogoHeight = height * 0.2; // 20% of screen height
//     final mainLogoWidth = width * 0.6; // 60% of screen width

//     // Bottom logo sizing - fixed size rather than percentage to avoid stretching
//     final bottomLogoWidth = width * 0.4; // 40% of screen width

//     // Spacing adjustment based on screen height
//     final bottomSpacing = height * 0.03; // 3% of screen height

//     return Scaffold(
//       backgroundColor: appColorWhite,
//       body: SafeArea(
//         child: Stack(
//           alignment: AlignmentDirectional.center,
//           children: [
//             // Main logo in the center
//             Center(
//               child: Obx(
//                 () => languageController.isAppSettingsLoading.value == true
//                     ? const CircularProgressIndicator() // Show loading indicator
//                     : Image.network(
//                         languageController.appSettingsData[0].appLogo!,
//                         height: mainLogoHeight,
//                         width: mainLogoWidth,
//                         fit: BoxFit.contain,
//                         errorBuilder: (context, error, stackTrace) {
//                           // Fallback in case network image fails to load
//                           return Icon(
//                             Icons.image_not_supported,
//                             size: mainLogoHeight * 0.7,
//                             color: Colors.grey,
//                           );
//                         },
//                       ),
//               ),
//             ),
//             // Bottom branding
//             Positioned(
//               bottom: bottomSpacing,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'from',
//                     style: TextStyle(
//                       color: Colors.blue,
//                       fontSize: width * 0.045,
//                     ),
//                   ),
//                   SizedBox(height: height * 0.001),
//                   // Using PNG image with fixed width
//                   Row(
//                     children: [
//                       Image.asset(
//                         'assets/icons/orbiselite.png',
//                         width: MediaQuery.of(context).size.width * 0.1,
//                         fit: BoxFit.contain,
//                       ),
//                       SizedBox(width: height * 0.005),
//                       Text(
//                         "Orbis Elite",
//                         style: TextStyle(
//                           color: Color(0xFFb78f6c),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/Notification/one_signal_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    navigatToScreen();
    super.initState();
  }

  navigatToScreen() async {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Get.offAll(
          const AppScreen(),
          transition: Transition.downToUp,
        );
        OnesignalService().initialize();
      },
    );
  }

  // Quietly check if any permissions are missing without showing UI

  // Handle permissions for users that already have accounts
  // This doesn't navigate away, just shows dialogs

  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;

    // Determine logo sizes based on screen size
    final mainLogoHeight = height * 0.2; // 20% of screen height
    final mainLogoWidth = width * 0.6; // 60% of screen width

    return Scaffold(
      backgroundColor: appColorWhite,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            // Main logo in the center
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => languageController.isAppSettingsLoading.value == true
                        // ? const CircularProgressIndicator() // Show loading indicator
                        ? SizedBox.shrink()
                        : Image.network(
                            languageController.appSettingsData[0].appLogo!,
                            height: mainLogoHeight,
                            width: mainLogoWidth,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback in case network image fails to load
                              return Icon(
                                Icons.image_not_supported,
                                size: mainLogoHeight * 0.7,
                                color: Colors.grey,
                              );
                            },
                          ),
                  ),
                  // SizedBox(height: 30),
                  // // Show loading status
                  // // CircularProgressIndicator(),
                  // SizedBox(height: 15),
                  // Text(
                  //   _statusMessage,
                  //   style: TextStyle(
                  //     color: Colors.grey[700],
                  //     fontSize: 16,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
