import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/add_contact_model.dart';
import 'package:whoxachat/controller/user_chatlist_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';

final ApiHelper apiHelper = ApiHelper();
ChatListController chatListController = Get.find();

class AddContactController extends GetxController {
  @override
  void onInit() {
    getContactsFromGloble();
    super.onInit();
  }

  RxBool isLoading = false.obs;
  Rx<AddContactModel?> model = AddContactModel().obs;
  RxBool isGetContectsFromDeviceLoading = false.obs;

  Future<void> addContactApi(fullName, mobileNum, profile) async {
    isLoading(true);

    var uri = Uri.parse(apiHelper.addContact);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['full_name'] = fullName;
    request.fields['phone_number'] = mobileNum;

    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    model.value = AddContactModel.fromJson(userData);

    if (model.value!.success == true) {
      isLoading(false);
      Get.to(() => SingleChatMsg(
            conversationID: '',
            username: fullName,
            userPic: profile,
            mobileNum: mobileNum,
            index: 0,
            userID: model.value!.userId.toString(),
          ));
    } else {
      isLoading(false);
      showCustomToast(model.value!.message!);
    }
  }

  List<Map<String, String>> mobileContacts = [];

  List<Contact> allcontacts = [];
  final RxBool _permissionDenied = false.obs;
  // Method to fetch contacts from the device and send to the API
  Future<void> getContactsFromGloble() async {
    // Step 1: Check if permission is granted
    bool permissionGranted =
        await FlutterContacts.requestPermission(readonly: true);
    debugPrint("_permissionDenied 1 $permissionGranted");

    if (!permissionGranted) {
      // If permission is denied, update state and exit the method
      _permissionDenied.value = true;
      debugPrint("_permissionDenied $_permissionDenied");
      return;
    }

    try {
      // Step 2: Fetch contacts from the device
      var contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      debugPrint("Fetched ${contacts.length} contacts.");

      // Optional: Log contact names to verify the fetched data
      for (var contact in contacts) {
        debugPrint("Contact name: ${contact.displayName}");
      }
      allcontacts = contacts.toList();

      // Step 3: Process contacts (clean phone numbers and format them)
      List<Map<String, String>> processedContacts = [];
      String cleanNumber(String number) {
        return getMobile(number); // Your custom function to clean the number
      }

      for (var c in contacts) {
        if (c.phones.isNotEmpty) {
          List<String> cleanedNumbers =
              c.phones.map((e) => cleanNumber(e.number)).toList();
          for (String number in cleanedNumbers) {
            processedContacts.add({
              'name': c.displayName, // Contact name
              'number': number, // Cleaned phone number
            });
          }
        }
      }

      // Step 4: Update mobileContacts state
      mobileContacts = processedContacts;

      // Step 5: Pass the processed contacts to the API
      var contactJson = json.encode(processedContacts);
      await getAllDeviceContact.getAllContactApi(contact: contactJson);
    } catch (e) {
      // Handle error if something goes wrong during the contact fetch
      debugPrint("Error fetching contacts: $e");
      _permissionDenied.value = true;
    } finally {
      // Step 6: Set loading state to false after operation
      isGetContectsFromDeviceLoading.value = false;
    }
  }

  // Future getContactsFromGloble() async {
  //   isGetContectsFromDeviceLoading.value = true;

  //   // bool permissionGranted = await FlutterContacts.requestPermission(
  //   //   readonly: true,
  //   // );
  //   // debugPrint("_permissionDenied 2 $permissionGranted");
  //   // if (!permissionGranted) {
  //   var contacts = (await FlutterContacts.getContacts(
  //     withProperties: true,
  //     withPhoto: true,
  //   ));

  //   // Log the number of contacts fetched
  //   debugPrint("Fetched ${contacts.length} contacts.");

  //   // Optional: Log contact names or other properties to verify the fetched data
  //   for (var contact in contacts) {
  //     debugPrint("Contact name: ${contact.displayName}");
  //   }

  //   allcontacts = contacts.toList();

  //   String cleanNumber(String number) {
  //     return getMobile(number);
  //   }

  //   for (Contact c in allcontacts) {
  //     if (c.phones.isNotEmpty) {
  //       List<String> cleanedNumbers =
  //           c.phones.map((e) => cleanNumber(e.number)).toList();
  //       for (String number in cleanedNumbers) {
  //         mobileContacts.add({'name': c.displayName, 'number': number});
  //       }
  //     }
  //   }
  //   var contactJson = json.encode(addContactController.mobileContacts);
  //   await getAllDeviceContact.getAllContactApi(contact: contactJson);
  //   isGetContectsFromDeviceLoading.value = false;
  //   // } else {
  //   //   debugPrint("Fetch contact else part execte");
  //   //   isGetContectsFromDeviceLoading.value = false;
  //   // }
  // }
}
