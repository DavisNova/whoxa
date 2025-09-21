// ignore_for_file: camel_case_types, unused_local_variable, avoid_print, use_build_context_synchronously, avoid_returning_null_for_void, prefer_if_null_operators, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/global.dart';

class about2 extends StatefulWidget {
  final String initialText;
  const about2({super.key, required this.initialText});

  @override
  State<about2> createState() => _about2State();
}

class _about2State extends State<about2> {
  TextEditingController aboutController = TextEditingController();
  String selectedabouttext = "";
  @override
  void initState() {
    aboutController = TextEditingController(text: widget.initialText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: secondaryColor.withOpacity(0.05),
      ),
      child: Scaffold(
        backgroundColor: appColorWhite,
        body: SingleChildScrollView(
          child: Column(
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
                    Text(
                      languageController.textTranslate('About'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.back(result: aboutController.text);
                      },
                      child: aboutController.text.isEmpty
                          ? const SizedBox.shrink()
                          : const Icon(Icons.check, color: Colors.black),
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
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        languageController.textTranslate('Currently set to'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextField(
                            controller: aboutController,
                            readOnly: false,
                            autofocus: false,
                            maxLength: 120,
                            maxLines: 4,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              counterStyle: const TextStyle(fontSize: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: appgrey)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: appgrey),
                                  borderRadius: BorderRadius.circular(10)),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: appgrey),
                                  borderRadius: BorderRadius.circular(10)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: appgrey),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  top: 15, left: 15, bottom: 20, right: 5),
                              hintText: languageController
                                  .textTranslate('Write Something...'),
                              hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              filled: true,
                              fillColor: Colors.white,
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
