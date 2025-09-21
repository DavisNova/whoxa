// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/add_member_group_model.dart';
import 'package:whoxachat/Models/group_create_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';

final ApiHelper apiHelper = ApiHelper();

class GroupCreateController extends GetxController {
  RxBool isCreate = false.obs;

  Rx<GroupCreateModel?> createModel = GroupCreateModel().obs;

  RxBool isMember = false.obs;
  Rx<AddMemberGroupModel?> model = AddMemberGroupModel().obs;

  groupCreateApi(String gpname, file, String conversationId,
      List<SelectedContact> contactData, String description) async {
    isCreate(true);
    if (gpname != '' || gpname.isNotEmpty) {
      try {
        var uri = Uri.parse(apiHelper.createGroup);
        var request = http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          "Accept": "application/json",
        };

        request.headers.addAll(headers);
        request.fields['group_name'] = gpname;
        request.fields['group_description'] = description;

        if (file != null) {
          request.files.add(await http.MultipartFile.fromPath('files', file));
        }

        print("create-group ${request.fields}");
        var response = await request.send();
        String responseData =
            await response.stream.transform(utf8.decoder).join();

        var userData = json.decode(responseData);

        createModel.value = GroupCreateModel.fromJson(userData);

        print("create-group $responseData");

        if (createModel.value!.success == true) {
          addToGroupMember(createModel.value!.conversationId.toString(),
              contactData.map((e) => e.userId.toString()).toList());
          showCustomToast(createModel.value!.message!);
          isCreate(false);
        } else {
          isCreate(false);
          showCustomToast(createModel.value!.message!);
        }
      } catch (e) {
        isCreate(false);
        showCustomToast(e.toString());
      } finally {
        isCreate(false);
      }
    } else {
      showCustomToast("Please Enter Group Name");
    }
  }

  Future<void> addToGroupMember(String conversationID, contactList) async {
    isMember(true);
    try {
      var uri = Uri.parse(apiHelper.addMemberToGroup);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID;
      request.fields['multiple_user_id'] = contactList
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(" ", "");

      print("add members ${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();

      var userData = json.decode(responseData);

      model.value = AddMemberGroupModel.fromJson(userData);

      if (model.value!.success == true) {
        isMember(false);
        Get.offAll(() => TabbarScreen(currentTab: 0));
      } else {
        isMember(false);
      }
    } catch (e) {
      isMember(false);
      showCustomToast(e.toString());
    } finally {
      isMember(false);
    }
  }

  // groupCreateUpate(
  //     String gpname, file, String conversationId, String gDesc) async {
  //   isCreate(true);
  //   try {
  //     var uri = Uri.parse(apiHelper.createGroup);
  //     var request = http.MultipartRequest("POST", uri);
  //     Map<String, String> headers = {
  //       'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
  //       "Accept": "application/json",
  //     };

  //     request.headers.addAll(headers);
  //     request.fields['group_name'] = gpname;
  //     request.fields['conversation_id'] = conversationId;
  //     request.fields['group_description'] = gDesc;
  //     if (file != null) {
  //       request.files.add(await http.MultipartFile.fromPath('files', file));
  //     }
  //     print(request.fields);
  //     var response = await request.send();
  //     String responseData =
  //         await response.stream.transform(utf8.decoder).join();

  //     var userData = json.decode(responseData);

  //     createModel.value = GroupCreateModel.fromJson(userData);

  //     if (createModel.value!.success == true) {
  //       isCreate(false);
  //       showCustomToast(createModel.value!.message!);
  //     } else {
  //       isCreate(false);
  //       showCustomToast(createModel.value!.message!);
  //     }
  //   } catch (e) {
  //     isCreate(false);
  //     showCustomToast(e.toString());
  //   } finally {
  //     isCreate(false);
  //   }
  // }
  groupCreateUpate(
      String gpname, file, String conversationId, String gDesc) async {
    isCreate(true);
    try {
      var uri = Uri.parse(apiHelper.createGroup);
      var request = http.MultipartRequest("POST", uri);

      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['group_name'] = gpname;
      request.fields['conversation_id'] = conversationId;
      request.fields['group_description'] = gDesc;

      // Debug: Print request fields
      print("REQUEST FIELDS:");
      print("group_name: ${request.fields['group_name']}");
      print("conversation_id: ${request.fields['conversation_id']}");
      print("group_description: ${request.fields['group_description']}");

      if (file != null) {
        print("File included in request: $file");
        request.files.add(await http.MultipartFile.fromPath('files', file));
      } else {
        print("No file included in request");
      }

      print("Full request fields: ${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();

      // Debug: Print raw response
      print("RESPONSE STATUS CODE: ${response.statusCode}");
      print("RESPONSE HEADERS: ${response.headers}");
      print("RESPONSE RAW DATA: $responseData");

      var userData = json.decode(responseData);
      createModel.value = GroupCreateModel.fromJson(userData);

      // Debug: Print parsed response
      print("PARSED RESPONSE SUCCESS: ${createModel.value!.success}");
      print("PARSED RESPONSE MESSAGE: ${createModel.value!.message}");

      if (createModel.value!.success == true) {
        isCreate(false);
        showCustomToast(createModel.value!.message!);
      } else {
        isCreate(false);
        showCustomToast(createModel.value!.message!);
      }
    } catch (e) {
      // Debug: Print any exceptions
      print("EXCEPTION DURING GROUP UPDATE: $e");
      isCreate(false);
      showCustomToast(e.toString());
    } finally {
      isCreate(false);
    }
  }
}
