// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:whoxachat/app.dart';
// import 'package:whoxachat/controller/pinned_message_controller.dart';
// import 'package:whoxachat/src/global/global.dart';

// Future<void> showPinMessageDialog(
//   BuildContext context,
//   String messageId,
//   String conversationId,
//   PinMessageController pinController,
// ) {
//   // Create a local RxString to track which button is currently loading
//   RxString loadingButtonDuration = ''.obs;

//   return showDialog(
//     context: context,
//     barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
//     builder: (BuildContext context) {
//       return BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//         child: AlertDialog(
//           insetPadding: const EdgeInsets.all(15),
//           alignment: Alignment.bottomCenter,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: Text(
//             languageController.textTranslate('Pin Message'),
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: chatColor,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 languageController.textTranslate(
//                     'How long do you want to keep this message pinned?'),
//                 style: TextStyle(fontSize: 14, color: Colors.grey[800]),
//               ),
//               SizedBox(height: 20),
//               _buildPinDurationButton(
//                 context,
//                 '1_day',
//                 languageController.textTranslate('1 Day'),
//                 Icons.watch_later_outlined,
//                 messageId,
//                 conversationId,
//                 pinController,
//                 loadingButtonDuration,
//               ),
//               SizedBox(height: 10),
//               _buildPinDurationButton(
//                 context,
//                 '7_days',
//                 languageController.textTranslate('7 Days'),
//                 Icons.calendar_month_outlined,
//                 messageId,
//                 conversationId,
//                 pinController,
//                 loadingButtonDuration,
//               ),
//               SizedBox(height: 10),
//               _buildPinDurationButton(
//                 context,
//                 '1_month',
//                 languageController.textTranslate('1 Month'),
//                 Icons.event_outlined,
//                 messageId,
//                 conversationId,
//                 pinController,
//                 loadingButtonDuration,
//               ),
//               SizedBox(height: 10),
//               _buildPinDurationButton(
//                 context,
//                 'lifetime',
//                 languageController.textTranslate('Forever'),
//                 Icons.all_inclusive,
//                 messageId,
//                 conversationId,
//                 pinController,
//                 loadingButtonDuration,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 languageController.textTranslate('Cancel'),
//                 style:
//                     TextStyle(color: chatownColor, fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Widget _buildPinDurationButton(
//   BuildContext context,
//   String duration,
//   String label,
//   IconData icon,
//   String messageId,
//   String conversationId,
//   PinMessageController pinController,
//   RxString loadingButtonDuration,
// ) {
//   return Obx(() {
//     bool isThisButtonLoading = loadingButtonDuration.value == duration;

//     return InkWell(
//       onTap: pinController.isPinningMessage.value
//           ? null
//           : () async {
//               // Set this specific button as loading
//               loadingButtonDuration.value = duration;

//               // Call the pin message function
//               bool success = await pinController.addPinMessage(
//                 conversationId,
//                 messageId,
//                 duration,
//               );

//               // Clear the loading state (in case dialog is still open)
//               loadingButtonDuration.value = '';

//               if (success) {
//                 Navigator.of(context).pop();
//               }
//             },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: chatownColor),
//             SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//             ),
//             Spacer(),
//             if (isThisButtonLoading)
//               SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(chatownColor),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   });
// }

import 'dart:ui';
import 'package:whoxachat/src/global/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/pinned_message_controller.dart';

Future<void> showPinMessageDialog(
  BuildContext context,
  String messageId,
  String conversationId,
  PinMessageController pinController,
) {
  // Create local RxString to track selected option and loading state
  RxString selectedDuration = ''.obs;
  RxBool isLoading = false.obs;

  return showDialog(
    context: context,
    barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(15),
          alignment: Alignment.bottomCenter,
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Choose how long you pin want to last?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Pin messages anytime',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                Obx(() => _buildPinDurationOption(
                      context: context,
                      duration: '1_day',
                      label: '1 day',
                      isSelected: selectedDuration.value == '1_day',
                      onTap: () => selectedDuration.value = '1_day',
                    )),
                Divider(height: 1, color: Colors.grey[200]),
                Obx(() => _buildPinDurationOption(
                      context: context,
                      duration: '7_days',
                      label: '7 days',
                      isSelected: selectedDuration.value == '7_days',
                      onTap: () => selectedDuration.value = '7_days',
                    )),
                Divider(height: 1, color: Colors.grey[200]),
                Obx(() => _buildPinDurationOption(
                      context: context,
                      duration: '1_month',
                      label: '1 month',
                      isSelected: selectedDuration.value == '1_month',
                      onTap: () => selectedDuration.value = '1_month',
                    )),
                Divider(height: 1, color: Colors.grey[200]),
                Obx(() => _buildPinDurationOption(
                      context: context,
                      duration: 'lifetime',
                      label: 'Lifetime',
                      isSelected: selectedDuration.value == 'lifetime',
                      onTap: () => selectedDuration.value = 'lifetime',
                    )),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: secondaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                              onPressed: selectedDuration.value.isEmpty ||
                                      isLoading.value
                                  ? null
                                  : () async {
                                      isLoading.value = true;

                                      bool success =
                                          await pinController.addPinMessage(
                                        conversationId,
                                        messageId,
                                        selectedDuration.value,
                                      );

                                      isLoading.value = false;

                                      if (success) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                              child: isLoading.value
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Pin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildPinDurationOption({
  required BuildContext context,
  required String duration,
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? secondaryColor : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}
