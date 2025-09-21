import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/get_contact_model.dart';
import 'package:whoxachat/Models/my_contacts_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class GetAllDeviceContact extends GetxController {
  RxBool isGetContectLoading = false.obs;
  RxBool isGetMYContectLoading = false.obs;

  RxInt getMyContact = 1.obs;

  Rx<MyContactModel> myContactsData = MyContactModel().obs;

  @override
  void onInit() {
    getAllContactApi();
    super.onInit();
  }

  Rx<GetContactModel?> model = GetContactModel().obs;
  RxList<NewContactList> getList = <NewContactList>[].obs;
  Future<void> getAllContactApi({var contact}) async {
    isGetContectLoading.value = true;
    var uri = Uri.parse(apiHelper.getAllContact);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };
    log("AAAAAA get all contact: $contact");
    request.headers.addAll(headers);
    request.fields['contact_list'] = contact ?? '';
    log("FEILDs:${request.fields}");
    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    model.value = GetContactModel.fromJson(userData);

    if (response.statusCode == 200) {
      getList.clear();
      if (model.value != null) {
        for (int i = 0; i < model.value!.newContactList!.length; i++) {
          getList.add(model.value!.newContactList![i]);
        }
      }
      isGetContectLoading.value = false;
      log("API_CONTACT_RESPONSE: $userData");
    } else if (response.statusCode == 500) {
      isGetContectLoading.value = false;
      log("API_CONTACT_RESPONSE: $userData");
    }
    isGetContectLoading.value = false;
  }

  myContact({
    bool isAddData = false,
  }) async {
    try {
      isGetMYContectLoading.value = isAddData == false ? false : true;
      if (isAddData == true) {
        getMyContact.value = getMyContact.value + 1;
      } else {
        getMyContact.value = 1;
      }
      final responseJson = await apiHelper.postMethod(
        url: apiHelper.myContacts,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Content-Type': 'application/json',
        },
        requestBody: {
          "page": getMyContact.value,
        },
      );

      if (responseJson["success"] == true) {
        log("$responseJson", name: "myContactsData");
        myContactsData.value = MyContactModel.fromJson(responseJson);
        debugPrint(
            "myContactsData length ${myContactsData.value.myContactList!.length}");
        if (getMyContact.value == myContactsData.value.pagination!.totalPages) {
          myContactsData.refresh();
        } else {
          if (getMyContact.value != 1) {
            myContact(isAddData: true);
          }
        }
      }

      isGetMYContectLoading.value = false;
    } catch (e) {
      isGetMYContectLoading.value = false;

      debugPrint('get my contacts failed : $e');
    }
  }
}
