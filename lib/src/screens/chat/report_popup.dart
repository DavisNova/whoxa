// ignore_for_file: unnecessary_null_comparison, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/src/global/global.dart';

class ReportPopup extends StatefulWidget {
  String conversationId;
  String userId;
  ReportPopup({super.key, required this.conversationId, required this.userId});

  @override
  State<ReportPopup> createState() => _ReportPopupState();
}

class _ReportPopupState extends State<ReportPopup> {
  AllStaredMsgController allStaredMsgController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("cid :: ${widget.conversationId}");
    debugPrint("uid :: ${widget.userId}");
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.white,
      elevation: 0,
      contentPadding:
          const EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: Container(
        width: Get.width,
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7, // Limit max height to 70% of screen
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Report',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333)),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              color: Color(0xffF1F1F1),
              height: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Why are you reporting this user?',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333)),
            ),
            const SizedBox(
              height: 30,
            ),
            Obx(
              () => allStaredMsgController.reportTypesData != null ||
                      allStaredMsgController.reportTypesData.isNotEmpty
                  ? Flexible(
                      child: RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        radius: const Radius.circular(10),
                        thickness: 4,
                        thumbColor: chatownColor.withValues(alpha: 0.6),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              allStaredMsgController.reportTypesData.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => reportText(
                                text: allStaredMsgController
                                    .reportTypesData[index].reportTitle!,
                                index: index,
                              ).paddingOnly(
                                  bottom: index ==
                                          allStaredMsgController
                                                  .reportTypesData.length -
                                              1
                                      ? 0
                                      : 20),
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => allStaredMsgController.isReportUserLoading.value == true
                  ? Center(
                      child: CircularProgressIndicator(
                        color: chatownColor,
                        strokeWidth: 1.5,
                      ),
                    )
                  : CustomButtom(
                      title: "Report",
                      onPressed: () {
                        if (allStaredMsgController.selectedReportIndex.value !=
                            -1) {
                          allStaredMsgController.reportUser(
                            conversationId: widget.conversationId,
                            reportUserId: widget.userId,
                            reportId: allStaredMsgController
                                .reportTypesData[allStaredMsgController
                                    .selectedReportIndex.value]
                                .reportId
                                .toString(),
                          );
                        }
                      },
                    ).paddingSymmetric(horizontal: 70),
            ),
          ],
        ),
      ),
    );
  }

  Widget reportText({
    required String text,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        allStaredMsgController.selectedReportIndex.value = index;
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: Get.width * 0.73,
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  fontFamily: "Poppins",
                  color: appColorBlack),
            ),
          ),
          allStaredMsgController.selectedReportIndex.value == index
              ? const Icon(
                  Icons.report,
                  color: appgrey2,
                )
              : const SizedBox.shrink(),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }
}
