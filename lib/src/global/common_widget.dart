// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/src/global/global.dart';

Widget callOptionsContainer({
  required String image,
  void Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            appColorBlack.withOpacity(0.14),
            const Color(0xFF666666).withOpacity(0),
          ],
          begin: Alignment.topRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appbarColor.withOpacity(0.17),
        ),
        child: Image.asset(
          image,
          scale: 3.5,
        ),
      ).paddingAll(3),
    ),
  );
}

Widget commonImageTexts({
  required String image,
  String? text1 = "",
  String? text2 = "",
  bool isImageShow = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      isImageShow == false ? const SizedBox.shrink() : Image.asset(image),
      text1!.isEmpty
          ? const SizedBox()
          : Text(
              text1,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: appColorBlack,
                  fontFamily: "Poppins"),
            ),
      SizedBox(
        height: text2!.isEmpty ? 0 : 4,
      ),
      text2.isEmpty
          ? const SizedBox()
          : Text(
              text2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF959595),
                  fontFamily: "Poppins"),
            ).paddingSymmetric(horizontal: 85),
    ],
  );
}

Widget commonSearchField({
  required BuildContext context,
  required TextEditingController controller,
  void Function(String)? onChanged,
  String? hintText = "",
  bool isSuffixIconShow = false,
}) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width * 0.94,
    child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: controller,
        onChanged: onChanged,
        readOnly: false,
        autofocus: false,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade100)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(15)),
          contentPadding: EdgeInsets.zero,
          hintText: hintText,
          hintStyle: const TextStyle(
              fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w400),
          prefixIcon: isSuffixIconShow == true
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Image.asset("assets/images/search-normal.png",
                      color: Colors.grey),
                ),
          suffixIcon: isSuffixIconShow == false
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Image.asset("assets/images/search-normal.png",
                      color: Colors.grey),
                ),
          filled: true,
          fillColor: Colors.grey.shade100,
        )),
  );
}
