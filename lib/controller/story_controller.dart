// ignore_for_file: prefer_null_aware_operators, unnecessary_null_comparison, unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dd;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/Models/Story%20Models/add_story_data.dart';
import 'package:whoxachat/Models/Story%20Models/my_story_seen_list_data.dart';
import 'package:whoxachat/Models/Story%20Models/status_delete_model.dart';
import 'package:whoxachat/Models/Story%20Models/story_list_data.dart';
import 'package:whoxachat/Models/Story%20Models/view_story_data.dart';
import 'package:whoxachat/hive_service/hive_service.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/story/final_story.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final apiHelper = ApiHelper();

class StroyGetxController extends GetxController {
  Dio dio = Dio();

  var isUploadStoryLoad = false.obs;
  var isAllUserStoryLoad = false.obs;
  var isProfileLoading = false.obs;
  var isMyStorySeenLoading = false.obs;
  var isMyStoryDeleteLoading = false.obs;
  var isViewStoryLoading = false.obs;

  var isSeenUserOpen = false;

  final _picker = ImagePicker();

  var deleteStatusModel = StatusDeleteModel().obs;

  var addStoryData = AddStoryDataModel().obs;
  Rx<StoryListData> storyListData = StoryListData().obs;
  RxList<ViewedStatusList> viewedStatusList = <ViewedStatusList>[].obs;
  RxList<NotViewedStatusList> notViewedStatusList = <NotViewedStatusList>[].obs;

  var allStoryListData = StoryListData().obs;
  var viewStoryData = ViewStoryData().obs;
  var myStorySeenData = MyStorySeenListData().obs;

  var totalSeenNumberList = [].obs;

  var indexOfStory = 0.obs;

  var pageIndexValue = 0.obs;
  var storyIndexValue = 0.obs;

  RxString imagePath = ''.obs;
  RxString videoPath = ''.obs;

  late FilePickerResult result;

  late Options options;

  StroyGetxController() {
    _updateOptions();
  }

  void _updateOptions() {
    final token = Hive.box(userdata).get(authToken);
    print("Story Controller Token: $token");
    
    options = Options(
      headers: {
        'Authorization': 'Bearer $token',
        "Accept": "application/json",
      },
      validateStatus: (status) {
        return status! >= 200 && status <= 500;
      },
    );
  }

  Future filePickForStory() async {
    var pickResult = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: true,
      type: FileType.image,
    );
    
    if (pickResult != null) {
      result = pickResult;
      if (kDebugMode) {
        print("File selected");
      }
      log("IDENTIFIER ${result.files[0].identifier!}");
      log("FILE ${result.files[0]}");

      String? filePath = result.files.single.path;
      String? extension =
          filePath != null ? filePath.split('.').last.toLowerCase() : null;

      Get.to(
        () => const FinalStoryConfirmationScreen(),
      )!
          .then(
        (value) {
          debugPrint("filePickForStory value 1 $value");
        },
      );
    }
  }

  void setImagePath(String path) {
    imagePath.value = path;
    if (kDebugMode) {
      print("${imagePath.value} PATH☺☺☺");
    }
  }

  Future<void> openImagePicker(bool isForCamera) async {
    final XFile? pickedImage = await _picker.pickImage(
        source: isForCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedImage != null) {
      setImagePath(pickedImage.path);
      Get.back();
    }
  }

  getVideoFromCamera(bool isForCamera) async {
    final XFile? pickedVideo = await _picker.pickVideo(
        source: isForCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedVideo != null) {
      videoPath.value = pickedVideo.path;

      Get.back();
    }
  }

  addImageStory(
    String imagePath,
    String text,
  ) async {
    print(text);
    try {
      isUploadStoryLoad(true);
      
      // 更新token
      _updateOptions();

      dd.FormData formData = dd.FormData.fromMap({
        if (imagePath.isNotEmpty)
          "files": await dd.MultipartFile.fromFile(
            imagePath,
          ),
        "status_text": text,
      });

      final result = await dio.post(apiHelper.addStoryUrl,
          data: formData, options: options);
      final respo = AddStoryDataModel.fromJson(result.data);

      addStoryData = respo.obs;

      log("Requested Data of add_story ${formData.fields}");
      log("Requested Data files of add_story ${formData.files}");
      log("MESSAGE ${addStoryData.value.message}");

      if (kDebugMode) {
        print("Status of add_story : ${result.statusCode}");
      }

      if (result.statusCode == 200) {
        if (addStoryData.value.success == true) {
          Fluttertoast.showToast(msg: "Story Uploaded");
          await getAllUsersStory();
          storyListData.refresh();
          Get.back();
        }
      } else {}
    } catch (e) {
      log(e.toString());
    } finally {
      isUploadStoryLoad(false);
    }
  }

  addVideoStory(
    String imagePath,
    String text,
  ) async {
    try {
      log("Image Path $imagePath");

      isUploadStoryLoad(true);
      
      // 更新token
      _updateOptions();
      
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String thumbnailPath = '${appDirectory.path}/thumbnail_$timestamp.jpg';

      File thumbnailFile = File(thumbnailPath);

      dd.FormData formData = dd.FormData.fromMap({
        "files": await dd.MultipartFile.fromFile(
          imagePath,
        ),
        "status_text": text
      });

      print("Requested Data of add_story $formData");
      print("Requested Data of add_story ${formData.fields}");

      for (int i = 0; i < formData.fields.length; i++) {
        print(
            "Requested Data of add_story form data  ${formData.fields[i].value}");
      }

      final result = await dio.post(apiHelper.addStatusUrl,
          data: formData, options: options);
      final respo = AddStoryDataModel.fromJson(result.data);

      addStoryData = respo.obs;

      if (kDebugMode) {
        print("Status of add_story : ${result.statusCode}");
      }

      if (result.statusCode == 200) {
        if (addStoryData.value.success == true) {
          Fluttertoast.showToast(msg: "Story Uploaded");
          await getAllUsersStory();
          storyListData.refresh();
          Get.back();
        }
      } else {}
    } catch (e) {
      log(e.toString());
    } finally {
      isUploadStoryLoad(false);
    }
  }

  // getAllUsersStory() async {
  //   try {
  //     isAllUserStoryLoad(true);
  //
  //     final result = await dio.post(apiHelper.statusListUrl, options: options);
  //
  //     final respo = StoryListData.fromJson(result.data);
  //
  //     storyListData = respo.obs;
  //     viewedStatusList.value = storyListData.value.viewedStatusList!;
  //     notViewedStatusList.value = storyListData.value.notViewedStatusList!;
  //     notViewedStatusList.removeWhere((element) =>
  //         element.userData!.userId! == Hive.box(userdata).get(userId));
  //     notViewedStatusList.refresh();
  //     storyListData.refresh();
  //     allStoryListData = respo.obs;
  //
  //     var storeJsonData = json.encode(result.data);
  //     log('storeJsonData: $storeJsonData');
  //     log("STORY-LIST:$respo");
  //     log("STORY-LIST:${storyListData.toString()}");
  //     log("STORY-LIST:${allStoryListData.toString()}");
  //     log("STORY-LIST viewedStatusList.length :${viewedStatusList.length}");
  //     log("STORY-LIST notViewedStatusList.length :${notViewedStatusList.length}");
  //
  //     if (kDebugMode) {
  //       print("Status of get_story_by_user : ${result.statusCode}");
  //     }
  //     myStorySeenListAPI(
  //         storyListData.value.myStatus!.statuses![0].statusId!.toString());
  //     isAllUserStoryLoad(false);
  //   } catch (e) {
  //     log(e.toString());
  //     isAllUserStoryLoad(false);
  //   } finally {
  //     isAllUserStoryLoad(false);
  //   }
  // }

  getAllUsersStory() async {
    try {
      isAllUserStoryLoad(true);
      
      log("🔄 Getting all users story from: ${apiHelper.statusListUrl}");
      log("🔑 Using token: ${options.headers?['Authorization'] ?? 'No token'}");

      final result = await dio.post(apiHelper.statusListUrl, options: options);
      
      log("📊 API Response Status: ${result.statusCode}");
      log("📊 API Response Data: ${result.data}");
      
      final respo = StoryListData.fromJson(result.data);

      storyListData = respo.obs;
      viewedStatusList.value = storyListData.value.viewedStatusList!;
      notViewedStatusList.value = storyListData.value.notViewedStatusList!;
      
      // 调试：打印过滤前的数据
      log("🔍 BEFORE FILTER: notViewedStatusList.length = ${notViewedStatusList.length}");
      log("🔍 CURRENT USER ID: ${Hive.box(userdata).get(userId)}");
      
      // 暂时注释掉移除自己故事的逻辑，让所有故事都显示
      // notViewedStatusList.removeWhere((element) =>
      // element.userData!.userId! == Hive.box(userdata).get(userId));
      
      notViewedStatusList.refresh();
      storyListData.refresh();
      allStoryListData = respo.obs;

      var storeJsonData = json.encode(result.data);
      log('storeJsonData: $storeJsonData');
      log("STORY-LIST:$respo");
      log("STORY-LIST:${storyListData.toString()}");
      log("STORY-LIST:${allStoryListData.toString()}");
      log("STORY-LIST viewedStatusList.length :${viewedStatusList.length}");
      log("STORY-LIST notViewedStatusList.length :${notViewedStatusList.length}");
      
      // 调试myStatus数据
      log("🔍 MY STATUS DEBUG:");
      log("myStatus is null: ${storyListData.value.myStatus == null}");
      if (storyListData.value.myStatus != null) {
        log("myStatus.statuses is null: ${storyListData.value.myStatus!.statuses == null}");
        if (storyListData.value.myStatus!.statuses != null) {
          log("myStatus.statuses.length: ${storyListData.value.myStatus!.statuses!.length}");
          if (storyListData.value.myStatus!.statuses!.isNotEmpty) {
            log("myStatus.statuses[0].statusMedia is null: ${storyListData.value.myStatus!.statuses![0].statusMedia == null}");
            if (storyListData.value.myStatus!.statuses![0].statusMedia != null) {
              log("myStatus.statuses[0].statusMedia.length: ${storyListData.value.myStatus!.statuses![0].statusMedia!.length}");
            }
          }
        }
      }

      if (kDebugMode) {
        print("Status of get_story_by_user : ${result.statusCode}");
      }

      // Add this check to prevent the range error
      if (storyListData.value.myStatus != null &&
          storyListData.value.myStatus!.statuses != null &&
          storyListData.value.myStatus!.statuses!.isNotEmpty) {
        myStorySeenListAPI(
            storyListData.value.myStatus!.statuses![0].statusId!.toString());
      }

      isAllUserStoryLoad(false);
    } catch (e) {
      log(e.toString());
      isAllUserStoryLoad(false);
    } finally {
      isAllUserStoryLoad(false);
    }
  }

  viewStoryAPI(String storyID, viewCount, pageIndex) async {
    try {
      isViewStoryLoading.value = true;
      Map<String, dynamic> data = {
        'status_id': storyID,
        'status_count': viewCount
      };

      log("Requested Data of view_story $data");

      final result =
          await dio.post(apiHelper.viewStatusUrl, data: data, options: options);

      dd.FormData formData = dd.FormData.fromMap(
          {"status_id": storyID, "status_count": viewCount});

      print("Requested Data of add_story ${formData.fields}");

      print("Staus of view_story ${result.statusCode}");

      final respo = ViewStoryData.fromJson(result.data);
      storyListData.value.notViewedStatusList![pageIndex].userData!.statuses![0]
          .statusViews![0].statusCount = storyListData
              .value
              .notViewedStatusList![pageIndex]
              .userData!
              .statuses![0]
              .statusViews![0]
              .statusCount! +
          1;
      notViewedStatusList.refresh();
      storyListData.refresh();
      viewedStatusList.refresh();
      notViewedStatusList.refresh();
      print("Requested Data of add_story$respo");

      viewStoryData = respo.obs;
      isViewStoryLoading.value = false;
    } catch (e) {
      log(e.toString());
      isViewStoryLoading.value = false;
    }
  }

  myStorySeenListAPI(String storyID) async {
    try {
      isMyStorySeenLoading(true);

      Map<String, dynamic> data = {'status_id': storyID};

      var box = await Hive.openBox(HiveService.storySeenListBox);

      if (kDebugMode) {
        print("Requested data of story_seen_list $data");
      }

      final result = await dio.post(apiHelper.myStatusSeenListUrl,
          data: data, options: options);

      log("Status of story_seen_list ${result.statusCode}");

      var storeJsonData = json.encode(result.data);
      await box.put(storyID, storeJsonData);
      var getData = box.get(storyID);

      log("Stored Seen List $getData");

      final respo = MyStorySeenListData.fromJson(result.data);
      myStorySeenData = respo.obs;

      if (myStorySeenData.value.statusViewsList!.isNotEmpty) {
        print(myStorySeenData.value.statusViewsList![0].user!.firstName);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  myStoryDelete(statusMediaID) async {
    try {
      isMyStoryDeleteLoading(true);

      var uri = Uri.parse(apiHelper.statusDetele);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['status_media_id'] = statusMediaID;

      print(request.fields);

      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      deleteStatusModel.value = StatusDeleteModel.fromJson(useData);

      if (deleteStatusModel.value.success == true) {
        isMyStoryDeleteLoading(false);
        storyListData.value.myStatus!.statuses![0].statusMedia!.removeWhere(
            (element) => element.statusMediaId.toString() == statusMediaID);
        storyListData.refresh();
        showCustomToast("You Story Removed");
        Get.back();
      }
    } catch (e) {
      log("Error occurred: ${e.toString()}");
    } finally {
      isMyStoryDeleteLoading(false);
    }
  }

  getAllUsersStoryUpdate() async {
    final result = await dio.post(apiHelper.statusListUrl, options: options);

    final respo = StoryListData.fromJson(result.data);

    storyListData = respo.obs;
    viewedStatusList.value = storyListData.value.viewedStatusList!;
    notViewedStatusList.value = storyListData.value.notViewedStatusList!;
    allStoryListData = respo.obs;

    var storeJsonData = json.encode(result.data);

    log("STORY-LIST:$respo");
    log("STORY-LIST:${storyListData.toString()}");
    log("STORY-LIST:${allStoryListData.toString()}");

    if (kDebugMode) {
      print("Status of get_story_by_user : ${result.statusCode}");
    }
  }
}
