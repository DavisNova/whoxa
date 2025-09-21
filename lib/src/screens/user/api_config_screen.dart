import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/src/global/global.dart';

class ApiConfigScreen extends StatelessWidget {
  const ApiConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            sizeBoxHeight(85),
            Image.asset(
              "assets/images/app_logo.png",
              width: getProportionateScreenWidth(242),
              height: getProportionateScreenHeight(67),
            ),
            sizeBoxHeight(82),
            Image.asset(
              "assets/images/error404.png",
              width: Get.width,
              height: getProportionateScreenHeight(366),
            ).paddingSymmetric(horizontal: 8),
            const Text(
              "Configuration Api is not Connected",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                color: appColorBlack,
              ),
            ).paddingSymmetric(horizontal: 60),
          ],
        ),
      ),
    );
  }
}
