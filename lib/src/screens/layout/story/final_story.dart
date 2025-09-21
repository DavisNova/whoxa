// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/story_controller.dart';
import 'package:whoxachat/src/global/global.dart';

class FinalStoryConfirmationScreen extends StatefulWidget {
  const FinalStoryConfirmationScreen({super.key});

  @override
  State<FinalStoryConfirmationScreen> createState() =>
      _FinalStoryConfirmationScreenState();
}

class _FinalStoryConfirmationScreenState
    extends State<FinalStoryConfirmationScreen> {
  StroyGetxController storyController = Get.put(StroyGetxController());
  TextEditingController messagecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (storyController.result.files[0].path!.endsWith('mp4')) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
          preferredSize: const Size(0, 60),
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          )),
      body: Obx(() {
        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Image.file(File(storyController.result.files[0].path!))),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromRGBO(108, 108, 108, 1))),
                  child: TextFormField(
                    maxLength: 150,
                    maxLines: 4,
                    minLines: 1,
                    cursorColor: const Color.fromRGBO(108, 108, 108, 1),
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: Colors.white),
                    controller: messagecontroller,
                    decoration: const InputDecoration(
                        fillColor: Color.fromRGBO(26, 25, 25, 1),
                        alignLabelWithHint: true,
                        counterText: "",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: InputBorder.none,
                        hintText: "Add a caption",
                        hintStyle: TextStyle(
                            color: Color.fromRGBO(108, 108, 108, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                        isDense: true),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                width: 42,
                child: InkWell(
                  onTap: () {
                    if (storyController.result.files[0].path!.endsWith('jpg') ||
                        storyController.result.files[0].path!
                            .endsWith('jpeg') ||
                        storyController.result.files[0].path!
                            .endsWith('JPEG') ||
                        storyController.result.files[0].path!.endsWith('png')) {
                      storyController.addImageStory(
                          storyController.result.files[0].path!,
                          messagecontroller.text);
                    } else if (storyController.result.files[0].path!
                        .endsWith('mp4')) {
                      log("Add Story Path ${storyController.result.files[0].path!}");
                      storyController.addVideoStory(
                          storyController.result.files[0].path!,
                          messagecontroller.text);
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              colors: [secondaryColor, chatownColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: storyController.isUploadStoryLoad.value
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 3, color: Colors.black),
                              ),
                            )
                          : Image.asset("assets/images/send1.png",
                                  color: chatColor)
                              .paddingAll(13)),
                ),
              ),
            ],
          )
              .paddingSymmetric(horizontal: 10, vertical: 15)
              .paddingOnly(top: 15, bottom: 15)
        ]);
      }),
    );
  }
}
