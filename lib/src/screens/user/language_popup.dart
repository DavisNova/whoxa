// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:whoxachat/app.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/global/strings.dart';
// import 'package:whoxachat/src/screens/layout/bottombar.dart';

// class LanguagePopUp extends StatefulWidget {
//   const LanguagePopUp({super.key});

//   @override
//   State<LanguagePopUp> createState() => _LanguagePopUpState();
// }

// class _LanguagePopUpState extends State<LanguagePopUp> {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       insetPadding: const EdgeInsets.all(20),
//       alignment: Alignment.bottomCenter,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       contentPadding: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       content: Obx(
//         () => SizedBox(
//           height: languageController.languagesData.length > 5
//               ? Get.height * 0.48
//               : null,
//           width: Get.width,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 languageController.textTranslate("App Language"),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ).paddingSymmetric(vertical: 30),
//               const Divider(
//                 color: Color(0xffF1F1F1),
//                 height: 1,
//               ),
//               languageController.languagesData.length < 6
//                   ? ListView.separated(
//                       shrinkWrap: true,
//                       scrollDirection: Axis.vertical,
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: languageController.languagesData.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () async {
//                             await Hive.box(userdata).put(
//                                 lnId,
//                                 languageController.languagesData[index].statusId
//                                     .toString());
//                             await languageController.getLanguageTranslation(
//                                 lnId: languageController
//                                     .languagesData[index].statusId
//                                     .toString());
//                             languageController.languageTranslationsData
//                                 .refresh();
//                             Get.offAll(TabbarScreen(
//                               currentTab: 4,
//                             ));
//                           },
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Container(
//                                 height: 20,
//                                 width: 20,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                     colors: [secondaryColor, chatownColor],
//                                   ),
//                                 ),
//                                 child: Container(
//                                   margin: const EdgeInsets.all(1.5),
//                                   decoration: languageController
//                                               .languagesData[index].language !=
//                                           languageController
//                                               .languageTranslationsData
//                                               .value
//                                               .language
//                                       ? const BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: appColorWhite,
//                                         )
//                                       : BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                               color: appColorWhite, width: 3.5),
//                                           gradient: LinearGradient(
//                                             begin: Alignment.topLeft,
//                                             end: Alignment.bottomRight,
//                                             colors: [
//                                               secondaryColor,
//                                               chatownColor
//                                             ],
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 10,
//                               ),
//                               Text(
//                                 languageController
//                                     .languagesData[index].language!,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               )
//                             ],
//                           ).paddingSymmetric(horizontal: 20, vertical: 20),
//                         );
//                       },
//                       separatorBuilder: (BuildContext context, int index) {
//                         return index ==
//                                 languageController.languagesData.length - 1
//                             ? const SizedBox.shrink()
//                             : const Divider(
//                                 color: Color(0xffF1F1F1),
//                                 height: 1,
//                               );
//                       },
//                     )
//                   : Expanded(
//                       child: ListView.separated(
//                         shrinkWrap: true,
//                         scrollDirection: Axis.vertical,
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: languageController.languagesData.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return GestureDetector(
//                             behavior: HitTestBehavior.translucent,
//                             onTap: () async {
//                               await Hive.box(userdata).put(
//                                   lnId,
//                                   languageController
//                                       .languagesData[index].statusId
//                                       .toString());
//                               await languageController.getLanguageTranslation(
//                                   lnId: languageController
//                                       .languagesData[index].statusId
//                                       .toString());
//                               languageController.languageTranslationsData
//                                   .refresh();
//                               Get.offAll(TabbarScreen(
//                                 currentTab: 4,
//                               ));
//                             },
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   height: 20,
//                                   width: 20,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                       colors: [secondaryColor, chatownColor],
//                                     ),
//                                   ),
//                                   child: Container(
//                                     margin: const EdgeInsets.all(1.5),
//                                     decoration: languageController
//                                                 .languagesData[index]
//                                                 .language !=
//                                             languageController
//                                                 .languageTranslationsData
//                                                 .value
//                                                 .language
//                                         ? const BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: appColorWhite,
//                                           )
//                                         : BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             border: Border.all(
//                                                 color: appColorWhite,
//                                                 width: 3.5),
//                                             gradient: LinearGradient(
//                                               begin: Alignment.topLeft,
//                                               end: Alignment.bottomRight,
//                                               colors: [
//                                                 secondaryColor,
//                                                 chatownColor
//                                               ],
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 Text(
//                                   languageController
//                                       .languagesData[index].language!,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 )
//                               ],
//                             ).paddingSymmetric(horizontal: 20, vertical: 20),
//                           );
//                         },
//                         separatorBuilder: (BuildContext context, int index) {
//                           return index ==
//                                   languageController.languagesData.length - 1
//                               ? const SizedBox.shrink()
//                               : const Divider(
//                                   color: Color(0xffF1F1F1),
//                                   height: 1,
//                                 );
//                         },
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';

class LanguagePopUp extends StatefulWidget {
  const LanguagePopUp({super.key});

  @override
  State<LanguagePopUp> createState() => _LanguagePopUpState();
}

class _LanguagePopUpState extends State<LanguagePopUp> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.white,
      elevation: 0,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: Obx(
        () {
          // Sort the languages alphabetically by name
          final sortedLanguages = List.from(languageController.languagesData)
            ..sort((a, b) => a.language!.compareTo(b.language!));

          return SizedBox(
            height: sortedLanguages.length > 5 ? Get.height * 0.48 : null,
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageController.textTranslate("App Language"),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ).paddingSymmetric(vertical: 30),
                const Divider(
                  color: Color(0xffF1F1F1),
                  height: 1,
                ),
                sortedLanguages.length < 6
                    ? ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: sortedLanguages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              await Hive.box(userdata).put(lnId,
                                  sortedLanguages[index].statusId.toString());
                              await languageController.getLanguageTranslation(
                                  lnId: sortedLanguages[index]
                                      .statusId
                                      .toString());
                              languageController.languageTranslationsData
                                  .refresh();
                              Get.offAll(TabbarScreen(
                                currentTab: 4,
                              ));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [secondaryColor, chatownColor],
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(1.5),
                                    decoration:
                                        sortedLanguages[index].language !=
                                                languageController
                                                    .languageTranslationsData
                                                    .value
                                                    .language
                                            ? const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: appColorWhite,
                                              )
                                            : BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: appColorWhite,
                                                    width: 3.5),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    secondaryColor,
                                                    chatownColor
                                                  ],
                                                ),
                                              ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  sortedLanguages[index].language!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ).paddingSymmetric(horizontal: 20, vertical: 20),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return index == sortedLanguages.length - 1
                              ? const SizedBox.shrink()
                              : const Divider(
                                  color: Color(0xffF1F1F1),
                                  height: 1,
                                );
                        },
                      )
                    : Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: sortedLanguages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                await Hive.box(userdata).put(lnId,
                                    sortedLanguages[index].statusId.toString());
                                await languageController.getLanguageTranslation(
                                    lnId: sortedLanguages[index]
                                        .statusId
                                        .toString());
                                languageController.languageTranslationsData
                                    .refresh();
                                Get.offAll(TabbarScreen(
                                  currentTab: 4,
                                ));
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [secondaryColor, chatownColor],
                                      ),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(1.5),
                                      decoration:
                                          sortedLanguages[index].language !=
                                                  languageController
                                                      .languageTranslationsData
                                                      .value
                                                      .language
                                              ? const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: appColorWhite,
                                                )
                                              : BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: appColorWhite,
                                                      width: 3.5),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      secondaryColor,
                                                      chatownColor
                                                    ],
                                                  ),
                                                ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    sortedLanguages[index].language!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ).paddingSymmetric(horizontal: 20, vertical: 20),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return index == sortedLanguages.length - 1
                                ? const SizedBox.shrink()
                                : const Divider(
                                    color: Color(0xffF1F1F1),
                                    height: 1,
                                  );
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
