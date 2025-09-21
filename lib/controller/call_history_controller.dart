// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:whoxachat/Models/calllistmodel.dart';
import 'package:whoxachat/Models/get_all_audiocall_list_model.dart';
import 'package:whoxachat/Models/get_all_videocall_list_model.dart';

class CallHistoryController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<CalllistModel?> callListModel = CalllistModel().obs;
  Rx<GetAllVideoCallListModel?> videoCallListModel =
      GetAllVideoCallListModel().obs;
  Rx<GetAllAudioCallListModel?> audioCallListModel =
      GetAllAudioCallListModel().obs;

  Future<void> callHistoryApi() async {}

  Future<void> callHistoryApiVideo() async {}

  Future<void> callHistoryApiAudio() async {}
}
