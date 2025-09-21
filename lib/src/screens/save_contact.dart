// ignore_for_file: must_be_immutable, deprecated_member_use, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/add_contact_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SaveContact extends StatefulWidget {
  String name;
  String number;
  SaveContact({super.key, required this.name, required this.number});

  @override
  State<SaveContact> createState() => _SaveContactState();
}

class _SaveContactState extends State<SaveContact> {
  AddContactController addContactController = Get.find();

  Future<void> saveContactInBackground(Map<String, String> contactData) async {
    final String name = contactData['name']!;
    final String number = contactData['number']!;

    final Contact newContact = Contact()
      ..name.first = name
      ..phones = [Phone(number)];

    await newContact.insert();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: secondaryColor.withOpacity(0.05),
      ),
      child: Scaffold(
        backgroundColor: appColorWhite,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
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
                      Get.back();
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
                  const Text(
                    "View Contact",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ).paddingOnly(top: 20).paddingSymmetric(
                    horizontal: 28,
                  ),
            ),
            const Divider(
              color: Color(0xffE9E9E9),
              height: 1,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey.shade200),
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 20),
                    SelectableText(
                      widget.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                addContactController.mobileContacts
                            .where(
                                (element) => element["number"] == widget.number)
                            .isEmpty ==
                        true
                    ? containerWidget(
                        onTap: () async {
                          print("@@@@@@@@@@@@@@@@@@@@@");
                          inviteMe(widget.number);
                        },
                        title: "Add")
                    : const SizedBox.shrink(),
              ],
            ).paddingSymmetric(horizontal: 20),
            Row(
              children: [
                Image.asset("assets/images/call_1.png",
                    height: 18, width: 18, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                SelectableText(
                  widget.number,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ).paddingOnly(left: 90)
          ],
        ),
      ),
    );
  }

  inviteMe(phone) async {
    String url = "tel:$phone";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
