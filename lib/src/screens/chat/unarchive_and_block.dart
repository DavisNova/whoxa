// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/model/userchatlist_model/archive_list_model.dart';

class UnarchiveAndBlock extends StatefulWidget {
  String isblock;
  String cID;
  bool isGroup;
  String uname;
  String gpname;
  ArchiveList data;
  UnarchiveAndBlock({
    super.key,
    required this.isblock,
    required this.cID,
    required this.isGroup,
    required this.uname,
    required this.gpname,
    required this.data,
  });

  @override
  State<UnarchiveAndBlock> createState() => _UnarchiveAndBlockState();
}

class _UnarchiveAndBlockState extends State<UnarchiveAndBlock> {
  ChatListController chatListController = Get.find<ChatListController>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.white,
      elevation: 0,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
                widget.isGroup == false
                    ? chatListController.addArchveApi(widget.cID, widget.uname)
                    : chatListController.addArchveApi(
                        widget.cID, widget.gpname);
                chatListController.userArchiveListModel.value!.archiveList!
                    .remove(widget.data);
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/unarchive.png",
                    height: 18,
                    width: 18,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Unarchive Chat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              )
                  .paddingSymmetric(
                    horizontal: 20,
                  )
                  .paddingOnly(bottom: widget.isGroup == false ? 10 : 0),
            ),
            widget.isGroup == false
                ? const Divider(
                    height: 1,
                    color: Color(0xffF1F1F1),
                  )
                : const SizedBox.shrink(),
            widget.isGroup == false
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      await chatListController.blockUserApi(widget.cID);
                      await chatListController.forArchiveChatList();
                      Get.back();
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/block.png",
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.isblock == "false"
                              ? languageController.textTranslate('Block')
                              : languageController.textTranslate('Unblock'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    )
                        .paddingSymmetric(
                          horizontal: 20,
                        )
                        .paddingOnly(top: 10),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
