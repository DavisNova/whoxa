// ignore_for_file: avoid_print, camel_case_types

import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/group_create_controller.dart';
import 'package:whoxachat/src/global/global.dart';

class create_group extends StatefulWidget {
  const create_group({super.key});

  @override
  State<create_group> createState() => _create_groupState();
}

class _create_groupState extends State<create_group> {
  TextEditingController groupnameController = TextEditingController();
  GroupCreateController gpCreateController = Get.put(GroupCreateController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      body: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                selectImageSource();
              });
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(300),
                color: const Color.fromARGB(255, 245, 243, 243),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(300),
                      child: Image.file(image!, fit: BoxFit.cover))
                  : Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: Image.asset(
                        'assets/images/camera.png',
                        color: chatColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 60,
            child: TextFormField(
                controller: groupnameController,
                readOnly: false,
                maxLength: 16,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 245, 243, 243),
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 245, 243, 243),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        const EdgeInsets.only(top: 30, left: 15, bottom: 0),
                    hintText: 'Enter Group Name',
                    hintStyle: const TextStyle(
                        fontSize: 13,
                        color: appgrey2,
                        fontWeight: FontWeight.w400),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 243, 243),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 25),
                      child: Image.asset("assets/images/group_user.png",
                          color: chatColor),
                    ))),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              if (groupnameController.text.isEmpty) {
                showCustomToast(
                    languageController.textTranslate('Enter group name'));
              } else if (image == null) {
                showCustomToast(
                    languageController.textTranslate('Set group profile'));
              } else {
                gpCreateController.groupCreateApi(
                    groupnameController.text.toString(),
                    image!.path.toString(),
                    "",
                    [],
                    '');
              }
            },
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text(
                  'CREATE',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectImageSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
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
                        style: const TextStyle(color: chatColor),
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
                        splashColor: chatColor,
                        child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            )),
                        onTap: () {
                          Navigator.pop(context);
                          closeKeyboard();
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

  File? image;
  final picker = ImagePicker();

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
