// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:whoxachat/src/global/global.dart';

class JoinedUsers extends StatefulWidget {
  const JoinedUsers({super.key});

  @override
  State<JoinedUsers> createState() => _JoinedUsersState();
}

class _JoinedUsersState extends State<JoinedUsers> {
  final RoomIdController roomIdController = Get.find();

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
      content: Obx(
        () => SizedBox(
          width: double.maxFinite,
          height: roomIdController.connnectdUsersData.length > 5
              ? Get.height * 0.48
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              roomIdController.connnectdUsersData.length < 6
                  ? roomIdController.callHistoryData.isEmpty &&
                          roomIdController.isCallHistoryLoading.value == true
                      ? loader(context)
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: roomIdController.connnectdUsersData.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    CustomCachedNetworkImage(
                                      size: 50,
                                      imageUrl: roomIdController
                                          .connnectdUsersData[index]
                                          .profileImage!,
                                      errorWidgeticon: const Icon(
                                        Icons.groups,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: Get.width * 0.37,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  roomIdController
                                                      .connnectdUsersData[index]
                                                      .userName!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Color(0xff0B0B0B),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              // Verification badge based on verification type
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        SizedBox(
                                          width: Get.width * 0.37,
                                          child: Text(
                                            "${roomIdController.connnectdUsersData[index].firstName!} ${roomIdController.connnectdUsersData[index].lastName!}",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11,
                                              color: Color(0xffA4A4A4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: chatownColor.withOpacity(0.43),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        "Joined",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                          color: Color(0xff000000),
                                        ),
                                      ).paddingSymmetric(
                                          horizontal: 16, vertical: 10),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      const Color(0xff404040).withOpacity(0.04),
                                ),
                              ],
                            );
                          },
                        )
                  : Expanded(
                      child: roomIdController.callHistoryData.isEmpty &&
                              roomIdController.isCallHistoryLoading.value ==
                                  true
                          ? loader(context)
                          : ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  roomIdController.connnectdUsersData.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        CustomCachedNetworkImage(
                                          size: 50,
                                          imageUrl: roomIdController
                                              .connnectdUsersData[index]
                                              .profileImage!,
                                          errorWidgeticon: const Icon(
                                            Icons.groups,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.37,
                                              child: Text(
                                                roomIdController
                                                    .connnectdUsersData[index]
                                                    .userName!,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff0B0B0B),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            SizedBox(
                                              width: Get.width * 0.37,
                                              child: Text(
                                                "${roomIdController.connnectdUsersData[index].firstName!} ${roomIdController.connnectdUsersData[index].lastName!}",
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 11,
                                                  color: Color(0xffA4A4A4),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ).paddingSymmetric(
                                        horizontal: 8, vertical: 7),
                                    Divider(
                                      color: const Color(0xff404040)
                                          .withOpacity(0.04),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
