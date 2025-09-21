// ignore_for_file: use_build_context_synchronously, avoid_print, camel_case_types, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class profile2 extends StatefulWidget {
  const profile2({super.key});

  @override
  State<profile2> createState() => _profile2State();
}

class _profile2State extends State<profile2> {
  File? image;
  final picker = ImagePicker();
  UserProfileModel userProfileModel = UserProfileModel();
  TextEditingController textController = TextEditingController();
  TextEditingController textController1 = TextEditingController();
  bool isLoading = false;
  String? profileImg;

  bool ActiveConnection = false;
  String T = "";
  Future CheckUserConnection() async {
    if (isLoading = true) {
      textController.text = Hive.box(userdata).get(firstName).toString();
      textController1.text = Hive.box(userdata).get(lastName).toString();
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          fetchUserDetailsAPI();
          ActiveConnection = true;

          T = "Turn off the data and repress again";
          log("Connected");
        });
      }
    } on SocketException catch (_) {
      setState(() {
        showCustomToast(
            languageController.textTranslate('No Internet Connection'));

        ActiveConnection = false;
        textController.text = Hive.box(userdata).get(firstName) ?? "";
        textController1.text = Hive.box(userdata).get(lastName) ?? "";
      });
    }
  }

  fetchUserDetailsAPI() async {
    closeKeyboard();

    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);
    textController.text = userProfileModel.resData!.firstName!;
    textController1.text = userProfileModel.resData!.lastName!;

    if (response.statusCode == 200) {
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());
      await Hive.box(userdata)
          .put(firstName, userProfileModel.resData!.firstName.toString());
      await Hive.box(userdata)
          .put(lastName, userProfileModel.resData!.lastName.toString());

      textController.text = Hive.box(userdata).get(firstName).toString();
      textController1.text = Hive.box(userdata).get(lastName).toString();

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  bool isUpdate = false;
  editApiCall() async {
    closeKeyboard();

    setState(() {
      isUpdate = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);

    request.fields['first_name'] = textController.text;
    request.fields['last_name'] = textController1.text;

    if (image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('files', image!.path));
    }

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    if (response.statusCode == 200) {
      await Hive.box(userdata)
          .put(firstName, userProfileModel.resData!.firstName.toString());
      await Hive.box(userdata)
          .put(lastName, userProfileModel.resData!.lastName.toString());
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());

      setState(() {
        isUpdate = false;
      });

      log(responseData);
      Get.back();
      showCustomToast("Update profile");
    } else {
      setState(() {
        isUpdate = false;
      });
      showCustomToast("Error");
    }
  }

  @override
  void initState() {
    CheckUserConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: chatownColor,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 15, top: 15),
            child: Image.asset("assets/images/arrow-left.png",
                height: 22, color: chatColor),
          ),
        ),
        title: Obx(
          () => Text(
            languageController.textTranslate('Profile'),
            style: const TextStyle(color: Colors.black, fontSize: 17),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 20),
                  isLoading
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(180),
                          child: CustomCachedNetworkImage(
                            size: 180,
                            imageUrl: Hive.box(userdata).get(userImage),
                            placeholderColor: chatownColor,
                            errorWidgeticon: const Icon(Icons.person),
                          ),
                        )
                      : userIMG(),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageController.textTranslate('First Name'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                              controller: textController,
                              readOnly: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade100,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.only(
                                    top: 1, left: 15, bottom: 1),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageController.textTranslate('Last Name'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                              controller: textController1,
                              readOnly: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade100,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.only(
                                    top: 1, left: 15, bottom: 1),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              )),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
            _submitButton(context).paddingOnly(bottom: 35)
          ],
        ),
      ),
    );
  }

  Widget userIMG() {
    profileImg;
    if (checkForNull(Hive.box(userdata).get(userImage)) != null) {
      profileImg = Hive.box(userdata).get(userImage);
    }
    return Hero(
      tag: '1',
      child: Stack(
        children: [
          Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(180),
            child: InkWell(
              onTap: () {
                selectImageSource();
              },
              child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(180),
                          child: Image.file(image!, fit: BoxFit.cover))
                      : isLoading
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(180),
                              child: CustomCachedNetworkImage(
                                size: 180,
                                imageUrl: Hive.box(userdata).get(userImage),
                                placeholderColor: chatownColor,
                                errorWidgeticon: const Icon(Icons.person),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(180),
                              child: CustomCachedNetworkImage(
                                size: 180,
                                imageUrl:
                                    userProfileModel.resData!.profileImage!,
                                placeholderColor: chatownColor,
                                errorWidgeticon: const Icon(Icons.person),
                              ),
                            )),
            ),
          ),
          Positioned(
            bottom: 7,
            right: 20,
            child: InkWell(
              onTap: () {
                selectImageSource();
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: chatownColor,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Image.asset("assets/images/edit-2.png", color: chatColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool buttonClick = false;
  Widget _submitButton(BuildContext context) {
    return InkWell(
      onTap: () {
        closekeyboard();

        if (textController.text.isNotEmpty && textController1.text.isNotEmpty) {
          ActiveConnection
              ? editApiCall()
              : showCustomToast(
                  languageController.textTranslate('No Internet Connection'));
        } else {
          if (textController.text.isEmpty) {
            showCustomToast(
                languageController.textTranslate('Please enter first name'));
          } else if (textController1.text.isEmpty) {
            showCustomToast(
                languageController.textTranslate('Please enter last name'));
          }
        }
      },
      child: buttonClick
          ? loader(context)
          : Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.87,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: chatownColor,
              ),
              child: const Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ),
            ),
    );
  }

  selectImageSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(height: 20.0),
                  Image.asset(
                    'assets/icons/upload_vec.png',
                    height: 100,
                    width: 100,
                  ),
                  Container(height: 15.0),
                  Text(
                    languageController.textTranslate('Upload Image'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(height: 15.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromCamera();
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                      ),
                      child: Text(
                        languageController.textTranslate('Take Picture'),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromGallery();
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      child: Text(
                        languageController.textTranslate('From Gallery'),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(height: 15.0),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: ClipOval(
                    child: Material(
                      elevation: 5,
                      color: chatownColor,
                      child: InkWell(
                        splashColor: chatownColor,
                        child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.black,
                            )),
                        onTap: () {
                          closeKeyboard();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}
