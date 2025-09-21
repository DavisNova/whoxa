// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/reply_msg_model.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class ReplyMsgController extends GetxController {
  RxBool isReply = false.obs;
  Rx<ReplyMsgModel?> model = ReplyMsgModel().obs;

  getReplyDataApi({required String replyMsgId, int? index}) async {
    Get.find<AllStaredMsgController>().isLoading.value = true;
    try {
      print("replyMsgId:$replyMsgId");
      var uri = Uri.parse(apiHelper.getReplyUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['message_id'] = replyMsgId;

      print(request.fields);

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      model.value = ReplyMsgModel.fromJson(userData);

      if (model.value!.success == true) {
        print("AAAAAAAAAAAAAAAAAA");
        Get.find<AllStaredMsgController>().allStarred[index!].resData =
            model.value!.resData;
        Get.find<AllStaredMsgController>().isLoading.value = false;
      } else {
        Get.find<AllStaredMsgController>().isLoading.value = false;
      }
    } catch (e) {
      Get.find<AllStaredMsgController>().isLoading.value = false;
      print(e.toString());
    } finally {
      Get.find<AllStaredMsgController>().isLoading.value = false;
    }
  }
}
