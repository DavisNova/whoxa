// // ignore_for_file: avoid_types_as_parameter_names, avoid_print, deprecated_member_use

// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:whoxachat/app.dart';
// import 'package:whoxachat/controller/group_create_controller.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/global/strings.dart';

// // ignore: must_be_immutable
// class MyWidget extends StatefulWidget {
//   List<SelectedContact> contactData;
//   List contactID;
//   MyWidget({super.key, required this.contactData, required this.contactID});

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   TextEditingController controller = TextEditingController();
//   GroupCreateController gpCreateController = Get.put(GroupCreateController());
//   File? image;
//   final picker = ImagePicker();

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: secondaryColor.withOpacity(0.05),
//       ),
//       child: Scaffold(
//         body: Column(
//           children: [
//             Container(
//               height: 110,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     secondaryColor.withOpacity(0.04),
//                     chatownColor.withOpacity(0.04),
//                   ],
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Get.back(result: widget.contactData.length);
//                     },
//                     child: const Icon(
//                       Icons.arrow_back_ios,
//                       size: 20,
//                       color: chatColor,
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 7,
//                   ),
//                   Text(
//                     languageController.textTranslate('New Group'),
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: "Poppins",
//                     ),
//                   ),
//                   const Spacer(),
//                   Obx(
//                     () => gpCreateController.isCreate.value == true
//                         ? Center(
//                             child: SizedBox(
//                               width: 30,
//                               height: 30,
//                               child: CircularProgressIndicator(
//                                 color: chatownColor,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                           )
//                         : containerWidget(
//                             onTap: () {
//                               if (controller.text.isEmpty) {
//                                 showCustomToast(languageController
//                                     .textTranslate('Enter group name'));
//                               } else if (widget.contactData.isEmpty) {
//                                 showCustomToast(languageController
//                                     .textTranslate('Please add member'));
//                               } else {
//                                 gpCreateController.groupCreateApi(
//                                     controller.text.toString(),
//                                     image?.path.toString(),
//                                     "",
//                                     widget.contactData);
//                               }
//                             },
//                             title: languageController.textTranslate('Create'),
//                           ),
//                   )
//                 ],
//               ).paddingOnly(top: 30).paddingSymmetric(
//                     horizontal: 28,
//                   ),
//             ),
//             const Divider(
//               color: Color(0xffE9E9E9),
//               height: 1,
//             ),
//             const SizedBox(height: 20),
//             Center(child: gpCreate()),
//             const SizedBox(height: 32),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Members: ${widget.contactData.length.toString()} Out Of 230",
//                 style:
//                     const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//               ),
//             ).paddingOnly(left: 20),
//             const SizedBox(height: 15),
//             widget.contactData.isEmpty
//                 ? const SizedBox.shrink()
//                 : selectedUsersList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget gpCreate() {
//     return Container(
//       width: Get.width * 0.90,
//       decoration: BoxDecoration(boxShadow: const [
//         BoxShadow(blurRadius: 0.5, color: Colors.grey, offset: Offset(0, 0.4))
//       ], borderRadius: BorderRadius.circular(10), color: Colors.white),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             onTap: () {
//               selectImageSource();
//             },
//             child: Container(
//               height: 50,
//               width: 50,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50),
//                   color: secondaryColor),
//               child: image == null
//                   ? Center(
//                       child: Image.asset("assets/images/camera2.png")
//                           .paddingAll(15),
//                     )
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(50),
//                       child: Image.file(image!, fit: BoxFit.cover)),
//             ).paddingOnly(bottom: 5),
//           ),
//           Expanded(
//             child: TextFormField(
//               controller: controller,
//               maxLines: 1,
//               textCapitalization: TextCapitalization.sentences,
//               readOnly: false,
//               cursorColor: Colors.black,
//               maxLength: 60,
//               scrollPhysics: const BouncingScrollPhysics(),
//               textAlignVertical: TextAlignVertical.center,
//               decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.only(top: 0),
//                   fillColor: Colors.transparent,
//                   isDense: true,
//                   hintText: languageController.textTranslate('Group Name'),
//                   hintStyle: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey),
//                   border:
//                       const OutlineInputBorder(borderSide: BorderSide.none)),
//             ).paddingOnly(top: 25, left: 10),
//           )
//         ],
//       ).paddingSymmetric(horizontal: 7),
//     );
//   }

//   Widget selectedUsersList() {
//     return SizedBox(
//         height: 75,
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: ListView.builder(
//             itemCount: widget.contactData.length,
//             shrinkWrap: true,
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.only(left: 20),
//             itemBuilder: (context, index) {
//               return InkWell(
//                 highlightColor: Colors.transparent,
//                 hoverColor: Colors.transparent,
//                 splashFactory: NoSplash.splashFactory,
//                 onTap: () {
//                   if (widget.contactData[index].userId.toString() !=
//                       Hive.box(userdata).get(userId).toString()) {
//                     setState(() {
//                       widget.contactData.removeAt(index);
//                     });
//                   }
//                 },
//                 child: Column(
//                   children: [
//                     Stack(
//                       children: [
//                         Container(
//                           height: 40,
//                           width: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             shape: BoxShape.circle,
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(100),
//                             child: Image.network(
//                               widget.contactData[index].profileImage,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(Icons.person),
//                             ),
//                           ),
//                         ),
//                         Hive.box(userdata).get(userId) ==
//                                 widget.contactData[index].userId
//                             ? const SizedBox.shrink()
//                             : Positioned(
//                                 top: 1,
//                                 right: 1,
//                                 child: InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       widget.contactData.removeAt(index);
//                                     });
//                                   },
//                                   child: Container(
//                                     height: 12,
//                                     width: 12,
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         border: Border.all(color: Colors.black),
//                                         color: chatownColor),
//                                     child: const Center(
//                                       child: Icon(Icons.close,
//                                           color: Colors.black, size: 7),
//                                     ),
//                                   ),
//                                 ))
//                       ],
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       widget.contactData[index].userName,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                           fontSize: 9.5, fontWeight: FontWeight.w400),
//                     )
//                   ],
//                 ).paddingOnly(right: 20),
//               );
//             },
//           ),
//         ));
//   }

//   selectImageSource() {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(8.0),
//             ),
//           ),
//           content: Stack(
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Container(height: 20.0),
//                   Image.asset(
//                     'assets/icons/upload_vec.png',
//                     height: 100,
//                     width: 100,
//                   ),
//                   Container(height: 15.0),
//                   Text(
//                     languageController.textTranslate('Upload Image'),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Container(height: 15.0),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         getImageFromCamera();
//                       },
//                       style: ButtonStyle(
//                         shape: WidgetStateProperty.all(RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0))),
//                       ),
//                       child: Text(
//                         languageController.textTranslate('Take Picture'),
//                         style: const TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         getImageFromGallery();
//                       },
//                       style: ButtonStyle(
//                         shape: WidgetStateProperty.all(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         languageController.textTranslate('From Gallery'),
//                         style: const TextStyle(color: chatColor),
//                       ),
//                     ),
//                   ),
//                   Container(height: 15.0),
//                 ],
//               ),
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.topRight,
//                   child: ClipOval(
//                     child: Material(
//                       elevation: 5,
//                       color: blackcolor,
//                       child: InkWell(
//                         splashColor: Colors.black,
//                         child: const SizedBox(
//                             width: 25,
//                             height: 25,
//                             child: Icon(
//                               Icons.close,
//                               size: 20,
//                               color: Colors.white,
//                             )),
//                         onTap: () {
//                           closeKeyboard();
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void containerForSheet<T>({BuildContext? context, Widget? child}) {
//     showCupertinoModalPopup<T>(
//       context: context!,
//       builder: (BuildContext context) => child!,
//     ).then<void>((T) {});
//   }

//   Future getImageFromCamera() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     setState(() {
//       if (pickedFile != null) {
//         image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   Future getImageFromGallery() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }
// }

// ignore_for_file: avoid_types_as_parameter_names, avoid_print, deprecated_member_use

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/group_create_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

// ignore: must_be_immutable
class MyWidget extends StatefulWidget {
  List<SelectedContact> contactData;
  List contactID;
  MyWidget({super.key, required this.contactData, required this.contactID});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  TextEditingController controller = TextEditingController();
  TextEditingController descriptionController =
      TextEditingController(); // Added description controller
  GroupCreateController gpCreateController = Get.put(GroupCreateController());
  File? image;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: secondaryColor.withOpacity(0.05),
      ),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor.withOpacity(0.04),
                    chatownColor.withOpacity(0.04),
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back(result: widget.contactData.length);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: chatColor,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    languageController.textTranslate('New Group'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => gpCreateController.isCreate.value == true
                        ? Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: chatownColor,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : containerWidget(
                            onTap: () {
                              if (controller.text.isEmpty) {
                                showCustomToast(languageController
                                    .textTranslate('Enter group name'));
                              } else if (widget.contactData.isEmpty) {
                                showCustomToast(languageController
                                    .textTranslate('Please add member'));
                              } else {
                                gpCreateController.groupCreateApi(
                                    controller.text.toString(),
                                    image?.path.toString(),
                                    descriptionController.text
                                        .toString(), // Pass description
                                    widget.contactData,
                                    descriptionController.text.trim());
                              }
                            },
                            title: languageController.textTranslate('Create'),
                          ),
                  )
                ],
              ).paddingOnly(top: 30).paddingSymmetric(
                    horizontal: 28,
                  ),
            ),
            const Divider(
              color: Color(0xffE9E9E9),
              height: 1,
            ),
            const SizedBox(height: 20),
            Center(child: gpCreate()),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Members: ${widget.contactData.length.toString()} Out Of 230",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ).paddingOnly(left: 20),
            const SizedBox(height: 15),
            widget.contactData.isEmpty
                ? const SizedBox.shrink()
                : selectedUsersList(),
          ],
        ),
      ),
    );
  }

  Widget gpCreate() {
    return Container(
      width: Get.width * 0.90,
      decoration: BoxDecoration(boxShadow: const [
        BoxShadow(blurRadius: 0.5, color: Colors.grey, offset: Offset(0, 0.4))
      ], borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: Column(
        // Changed from Row to Column to stack the description field
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  selectImageSource();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: secondaryColor),
                  child: image == null
                      ? Center(
                          child: Image.asset("assets/images/camera2.png")
                              .paddingAll(15),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(image!, fit: BoxFit.cover)),
                ).paddingOnly(bottom: 5),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  readOnly: false,
                  cursorColor: Colors.black,
                  maxLength: 60,
                  scrollPhysics: const BouncingScrollPhysics(),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 0),
                      fillColor: Colors.transparent,
                      isDense: true,
                      hintText: languageController.textTranslate('Group Name'),
                      hintStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none)),
                ).paddingOnly(top: 25, left: 10),
              )
            ],
          ).paddingSymmetric(horizontal: 7),
          SizedBox(
            height: 15,
          ),
          // Added Description Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: TextFormField(
              controller: descriptionController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Colors.black,
              maxLength: 120,
              scrollPhysics: const BouncingScrollPhysics(),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                fillColor: Colors.grey.withOpacity(0.1),
                filled: true,
                hintText: languageController
                    .textTranslate('Group Description (Optional)'),
                hintStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget selectedUsersList() {
    return SizedBox(
        height: 75,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ListView.builder(
            itemCount: widget.contactData.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemBuilder: (context, index) {
              return InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  if (widget.contactData[index].userId.toString() !=
                      Hive.box(userdata).get(userId).toString()) {
                    setState(() {
                      widget.contactData.removeAt(index);
                    });
                  }
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.contactData[index].profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                        Hive.box(userdata).get(userId) ==
                                widget.contactData[index].userId
                            ? const SizedBox.shrink()
                            : Positioned(
                                top: 1,
                                right: 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      widget.contactData.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.black),
                                        color: chatownColor),
                                    child: const Center(
                                      child: Icon(Icons.close,
                                          color: Colors.black, size: 7),
                                    ),
                                  ),
                                ))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.contactData[index].userName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w400),
                    )
                  ],
                ).paddingOnly(right: 20),
              );
            },
          ),
        ));
  }

  selectImageSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                      color: blackcolor,
                      child: InkWell(
                        splashColor: Colors.black,
                        child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
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

  void containerForSheet<T>({BuildContext? context, Widget? child}) {
    showCupertinoModalPopup<T>(
      context: context!,
      builder: (BuildContext context) => child!,
    ).then<void>((T) {});
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
