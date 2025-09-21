// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/user/avatars_popup.dart';

class PickImagePopup extends StatefulWidget {
  const PickImagePopup({super.key});

  @override
  State<PickImagePopup> createState() => _PickImagePopupState();
}

class _PickImagePopupState extends State<PickImagePopup> {
  final AvatarController avatarController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.white,
      elevation: 0,
      contentPadding:
          const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Photo',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333)),
            ),
            const SizedBox(
              height: 20,
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
                const SizedBox(
                  width: 40,
                ),
                GestureDetector(
                  onTap: () {
                    pickAvatarsPopup();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: chatownColor.withOpacity(0.16),
                        ),
                        child: Obx(
                            // () => CachedNetworkImage(
                            //   imageUrl: Hive.box(userdata).get(userGender) ==
                            //           "female"
                            //       ? avatarController.avatarsData
                            //           .where((avatar) =>
                            //               avatar.avatarGender == "female" &&
                            //               avatar.defaultAvtar == true)
                            //           .first
                            //           .avtarMedia!
                            //       : avatarController.avatarsData
                            //           .where((avatar) =>
                            //               avatar.avatarGender == "male")
                            //           .first
                            //           .avtarMedia!,
                            //   height: 30,
                            //   width: 30,
                            //   errorWidget: (context, url, error) =>
                            //       const Icon(Icons.person, color: chatColor),
                            // ),
                            () => CachedNetworkImage(
                                  imageUrl: Hive.box(userdata)
                                              .get(userGender) ==
                                          "female"
                                      ? avatarController.avatarsData
                                              .where((avatar) =>
                                                  avatar.avatarGender ==
                                                      "female" &&
                                                  avatar.defaultAvtar == true)
                                              .firstOrNull
                                              ?.avtarMedia ??
                                          '' // Use firstOrNull with null safety
                                      : avatarController.avatarsData
                                              .where((avatar) =>
                                                  avatar.avatarGender == "male")
                                              .firstOrNull
                                              ?.avtarMedia ??
                                          '', // Use firstOrNull with null safety
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit
                                      .cover, // Add this to control how the image fits
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person,
                                          color: chatColor, size: 30),
                                )).paddingAll(13),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Avatar',
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
          ],
        ),
      ),
    );
  }

  File? image;
  final picker = ImagePicker();
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        Get.back(result: {
          "image": image,
        });
      } else {}
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        Get.back(result: {
          "image": image,
        });
      } else {
        print('No image selected.');
      }
    });
  }

  pickAvatarsPopup() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AvatarsPopup(
            image: image,
          );
        });
  }
}
