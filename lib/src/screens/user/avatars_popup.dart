// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

class AvatarsPopup extends StatefulWidget {
  File? image;
  AvatarsPopup({super.key, this.image});

  @override
  State<AvatarsPopup> createState() => _AvatarsPopupState();
}

class _AvatarsPopupState extends State<AvatarsPopup> {
  final AvatarController avatarController = Get.find();

  int selectedIndex = (-1);

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
              'Select Avatar Photo',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333)),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => Container(
                constraints: BoxConstraints(maxHeight: Get.height * 0.72),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: avatarController.avatarsData.length,
                  itemBuilder: (context, index) {
                    return Obx(
                      () => avatarController
                              .avatarsData[index].avtarMedia!.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: Hive.box(userdata).get(userImage) ==
                                          "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
                                      widget.image == null &&
                                      Hive.box(userdata).get(userGender) ==
                                          "male" &&
                                      avatarController.avatarsData[index].avatarGender! ==
                                          "male" &&
                                      avatarController.avatarsData[index].defaultAvtar! ==
                                          true &&
                                      selectedIndex == -1
                                  ? Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: chatownColor, width: 2),
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: CachedNetworkImage(
                                              imageUrl: avatarController
                                                  .avatarsData[index]
                                                  .avtarMedia!,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        height: 75,
                                                        width: 75,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Color(
                                                                    0XFFE7B12D),
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                      )).paddingSymmetric(
                                              horizontal: index == 0 ? 0 : 7),
                                        ),
                                        Positioned(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: appColorWhite,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient:
                                                      LinearGradient(colors: [
                                                    secondaryColor,
                                                    chatownColor,
                                                  ])),
                                              child: const Icon(
                                                Icons.check_rounded,
                                                size: 13,
                                              ).paddingAll(3),
                                            ).paddingAll(4),
                                          ),
                                        )
                                      ],
                                    )
                                  : Hive.box(userdata).get(userImage) ==
                                              "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
                                          widget.image == null &&
                                          Hive.box(userdata).get(userGender) ==
                                              "female" &&
                                          avatarController.avatarsData[index].avatarGender! ==
                                              "female" &&
                                          avatarController.avatarsData[index]
                                                  .defaultAvtar! ==
                                              true &&
                                          selectedIndex == -1
                                      ? Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: chatownColor,
                                                    width: 2),
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: CachedNetworkImage(
                                                  imageUrl: avatarController
                                                      .avatarsData[index]
                                                      .avtarMedia!,
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Container(
                                                        height: 75,
                                                        width: 75,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Color(
                                                                    0XFFE7B12D),
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                      )).paddingSymmetric(
                                                  horizontal:
                                                      index == 0 ? 0 : 7),
                                            ),
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
                                                          colors: [
                                                            secondaryColor,
                                                            chatownColor
                                                          ])),
                                                  child: const Icon(
                                                    Icons.check_rounded,
                                                    size: 13,
                                                  ).paddingAll(3),
                                                ).paddingAll(4),
                                              ),
                                            )
                                          ],
                                        )
                                      : selectedIndex != -1 &&
                                              selectedIndex == index
                                          ? Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: chatownColor,
                                                        width: 2),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: CachedNetworkImage(
                                                      imageUrl: avatarController
                                                          .avatarsData[index]
                                                          .avtarMedia!,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                            height: 75,
                                                            width: 75,
                                                            decoration: const BoxDecoration(
                                                                color: Color(
                                                                    0XFFE7B12D),
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: const Icon(
                                                              Icons.person,
                                                              size: 20,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          )).paddingSymmetric(
                                                      horizontal:
                                                          index == 0 ? 0 : 7),
                                                ),
                                                Positioned(
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: appColorWhite,
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              LinearGradient(
                                                                  colors: [
                                                                secondaryColor,
                                                                chatownColor
                                                              ])),
                                                      child: const Icon(
                                                        Icons.check_rounded,
                                                        size: 13,
                                                      ).paddingAll(3),
                                                    ).paddingAll(4),
                                                  ),
                                                )
                                              ],
                                            )
                                          : Hive.box(userdata)
                                                      .get(userImage)!
                                                      .isNotEmpty &&
                                                  Hive.box(userdata).get(userImage) !=
                                                      "https://control.whoxamessenger.com/uploads/not-found-images/profile-image.png" &&
                                                  avatarController.avatarsData
                                                      .where((avatar) =>
                                                          avatar.avtarMedia ==
                                                          Hive.box(userdata).get(userImage))
                                                      .map((avatar) => avatar.avtarMedia!)
                                                      .isNotEmpty &&
                                                  Hive.box(userdata).get(userImage) == avatarController.avatarsData[index].avtarMedia &&
                                                  selectedIndex == -1 &&
                                                  widget.image == null
                                              ? Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: chatownColor,
                                                            width: 2),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: CachedNetworkImage(
                                                          imageUrl:
                                                              avatarController
                                                                  .avatarsData[
                                                                      index]
                                                                  .avtarMedia!,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                                height: 75,
                                                                width: 75,
                                                                decoration: const BoxDecoration(
                                                                    color: Color(
                                                                        0XFFE7B12D),
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child:
                                                                    const Icon(
                                                                  Icons.person,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              )).paddingSymmetric(
                                                          horizontal: index == 0
                                                              ? 0
                                                              : 7),
                                                    ),
                                                    Positioned(
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: appColorWhite,
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient:
                                                                  LinearGradient(
                                                                      colors: [
                                                                    secondaryColor,
                                                                    chatownColor
                                                                  ])),
                                                          child: const Icon(
                                                            Icons.check_rounded,
                                                            size: 13,
                                                          ).paddingAll(3),
                                                        ).paddingAll(4),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Container(
                                                  child: CachedNetworkImage(
                                                      imageUrl: avatarController
                                                          .avatarsData[index]
                                                          .avtarMedia!,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                            height: 75,
                                                            width: 75,
                                                            decoration: const BoxDecoration(
                                                                color: Color(
                                                                    0XFFE7B12D),
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: const Icon(
                                                              Icons.person,
                                                              size: 20,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          )).paddingSymmetric(
                                                      horizontal:
                                                          index == 0 ? 0 : 7),
                                                ),
                            )
                          : Container(
                              height: 75,
                              width: 75,
                              decoration: const BoxDecoration(
                                  color: Color(0XFFE7B12D),
                                  shape: BoxShape.circle),
                              child: const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButtom(
              title: "Save",
              onPressed: () {
                avatarController.avatarIndex.value = selectedIndex;
                Get.back();
                Get.back(result: {"image": null});
              },
            ).paddingSymmetric(horizontal: 58)
          ],
        ),
      ),
    );
  }
}
