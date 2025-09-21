import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/story_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/screens/layout/story/final_story.dart';
import 'package:whoxachat/src/screens/layout/story/story_screen.dart';

class MyStoriesListScreen extends StatefulWidget {
  const MyStoriesListScreen({super.key});

  @override
  State<MyStoriesListScreen> createState() => _MyStoriesListScreenState();
}

class _MyStoriesListScreenState extends State<MyStoriesListScreen> {
  final StroyGetxController storyController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 56,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    "assets/images/arrow-left.png",
                    height: 25,
                    color: appColorBlack,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  languageController.textTranslate('Status'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins"),
                ),
              ],
            ).paddingSymmetric(horizontal: 20),
            const SizedBox(
              height: 25,
            ),
            Obx(
              () => storyController
                          .storyListData.value.myStatus!.statuses!.isEmpty ||
                      storyController.storyListData.value.myStatus!.statuses![0]
                          .statusMedia!.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: storyController.storyListData.value.myStatus!
                          .statuses![0].statusMedia!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      reverse: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Obx(
                          () => GestureDetector(
                            onTap: () {
                              Get.to(() => StoryScreen6PM(
                                    isForMyStory: true,
                                    storyIndex: index,
                                    badgeUrl: '',
                                  ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2),
                                          shape: BoxShape.circle),
                                      child: CircleAvatar(
                                        radius: 27,
                                        backgroundColor:
                                            const Color(0xffE9E9E9),
                                        backgroundImage: NetworkImage(
                                            storyController
                                                .storyListData
                                                .value
                                                .myStatus!
                                                .statuses![0]
                                                .statusMedia![index]
                                                .url!),
                                      ).marginAll(3),
                                    ),
                                    const SizedBox(
                                      width: 11,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            storyController
                                                        .storyListData
                                                        .value
                                                        .myStatus!
                                                        .statuses![0]
                                                        .statusMedia![index]
                                                        .statusMediaViewCount ==
                                                    0
                                                ? languageController
                                                    .textTranslate(
                                                        'No Views yet')
                                                : "${storyController.storyListData.value.myStatus!.statuses![0].statusMedia![index].statusMediaViewCount.toString()} Views",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Poppins"),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            formatTimeAgo(storyController
                                                .storyListData
                                                .value
                                                .myStatus!
                                                .statuses![0]
                                                .statusMedia![index]
                                                .updatedAt!),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xffA4A4A4),
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Poppins"),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        deleteDialog(
                                          storyController
                                              .storyListData
                                              .value
                                              .myStatus!
                                              .statuses![0]
                                              .statusMedia![index]
                                              .statusMediaId!
                                              .toString(),
                                        );
                                      },
                                      child: Image.asset(
                                        "assets/icons/more.png",
                                        height: 24,
                                        width: 24,
                                      ),
                                    )
                                  ],
                                ).paddingSymmetric(horizontal: 18),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  color: Color(0xffE9E9E9),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                filePickForStory().then(
                  (value) {
                    debugPrint("filePickForStory value $value");
                    storyController.getAllUsersStory();
                    storyController.storyListData.refresh();
                  },
                );
              },
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffEAEAEA),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: appColorBlack,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    languageController.textTranslate('Add Status'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins"),
                  ),
                ],
              ).paddingSymmetric(horizontal: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Color(0xffE9E9E9),
            ),
          ],
        ),
      ),
    );
  }

  Future deleteDialog(String statusMediaID) {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(15),
            alignment: Alignment.bottomCenter,
            backgroundColor: Colors.white,
            elevation: 0,
            contentPadding: const EdgeInsets.only(left: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: SizedBox(
              height: 70,
              width: double.maxFinite,
              child: InkWell(
                onTap: () {
                  debugPrint("PRESSED");
                  // indicatorAnimationController.value =
                  //     IndicatorAnimationCommand.pause;
                  Navigator.pop(context);
                  deleteDialog1(statusMediaID);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset("assets/images/trash1.png", height: 20),
                    const SizedBox(width: 10),
                    Text(languageController.textTranslate('Delete'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400))
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future deleteDialog1(String statusMediaID) {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
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
              height: Get.height * 0.18,
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageController
                        .textTranslate('Are you sure you want to Delete?'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    languageController.textTranslate(
                        'Are you sure you want to delete your status?'),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 39,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: chatownColor)),
                          child: Center(
                            child: Text(
                              languageController.textTranslate('Cancel'),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 27),
                      InkWell(
                        onTap: () {
                          storyController.myStoryDelete(statusMediaID);
                        },
                        child: Container(
                          height: 39,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                  colors: [secondaryColor, chatownColor],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)),
                          child: Center(
                            child: Text(
                              languageController.textTranslate('Delete'),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future filePickForStory() async {
    try {
      // 检查权限
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      
      if (await Permission.photos.isDenied) {
        await Permission.photos.request();
      }

      var result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowCompression: true,
        type: FileType.image,
      );

      if (result != null) {
        storyController.result = result;

        if (kDebugMode) {
          print("File selected");
        }
        log("IDENTIFIER ${storyController.result.files[0].identifier!}");
        log("FILE ${storyController.result.files[0]}");

        // String? filePath = storyController.result.files.single.path;
        // String? extension = filePath!.split('.').last.toLowerCase();

        Get.to(
          () => const FinalStoryConfirmationScreen(),
        )!
        .then(
          (value) {
            debugPrint("filePickForStory value 1 $value");
            if (value == null) {
              storyController.getAllUsersStory();
              storyController.storyListData.refresh();
              setState(() {});
            }
          },
        );
      } else {
        // 用户取消了文件选择
        if (kDebugMode) {
          print("File selection cancelled");
        }
      }
    } catch (e) {
      // 处理权限被拒绝或其他错误
      if (kDebugMode) {
        print("Error picking file: $e");
      }
      
      // 显示错误消息给用户
      Get.snackbar(
        "错误",
        "无法访问文件，请检查权限设置",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
