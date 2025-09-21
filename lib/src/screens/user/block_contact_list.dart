// ignore_for_file: avoid_print, unused_field, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:whoxachat/Models/block_list_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/all_block_list_controller.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';

class BlockList extends StatefulWidget {
  const BlockList({super.key});

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  AllBlockListController allBlockListController = Get.find();
  ChatListController chatListController = Get.find();

  @override
  void initState() {
    allBlockListController.getBlockListApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: secondaryColor.withOpacity(0.05),
      ),
      child: Scaffold(
          backgroundColor: appColorWhite,
          body: Column(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      secondaryColor.withOpacity(0.04),
                      chatownColor.withOpacity(0.04),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: chatColor,
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      languageController.textTranslate('Block List'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ).paddingOnly(top: 30).paddingSymmetric(
                      horizontal: 28,
                    ),
              ),
              const Divider(
                color: Color(0xffE9E9E9),
                height: 1,
              ),
              Expanded(
                child: Obx(() {
                  return allBlockListController.isLoading.value &&
                          allBlockListController.allBlock.isEmpty
                      ? loader(context)
                      : allBlockListController.allBlock.isNotEmpty
                          ? SingleChildScrollView(
                              child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount:
                                      allBlockListController.allBlock.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (allBlockListController
                                        .allBlock[index]
                                        .conversation!
                                        .blockedUserDetails!
                                        .isNotEmpty) {
                                      return profileWidget(
                                          allBlockListController
                                              .allBlock[index],
                                          index);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ))
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    commonImageTexts(
                                      image:
                                          "assets/images/no_block_contact.png",
                                      text1: languageController
                                          .textTranslate("No Block Contact"),
                                      text2: languageController.textTranslate(
                                          "You don't have any blocked contact to show"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                }),
              ),
            ],
          )),
    );
  }

  Widget profileWidget(BlockUserList data, index) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CustomCachedNetworkImage(
                      imageUrl: data
                          .conversation!.blockedUserDetails![0].profileImage!,
                      placeholderColor: chatownColor,
                      errorWidgeticon: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        capitalizeFirstLetter(data.conversation!
                                .blockedUserDetails![0].firstName! +
                            data.conversation!.blockedUserDetails![0]
                                .lastName!),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    Text(
                      data.conversation!.blockedUserDetails![0].phoneNumber!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
            InkWell(
              onTap: () {
                chatListController.blockUserApi(data.conversationId);
                allBlockListController.allBlock.remove(data);
              },
              child: Container(
                height: 28,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: secondaryColor,
                    border: Border.all(color: chatownColor)),
                child: Center(
                  child: Text(
                    languageController.textTranslate('Unblock'),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        if (index !=
            allBlockListController.blockListModel.value!.blockUserList!.length -
                1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Divider(
              color: Colors.grey.shade200,
            ),
          )
      ],
    );
  }
}
