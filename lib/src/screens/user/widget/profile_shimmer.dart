// ChatProfile placeholder
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/src/global/global.dart';

class ChatProfilePlaceholder1 extends StatelessWidget {
  const ChatProfilePlaceholder1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              height: Get.height * 0.27,
              width: double.infinity,
              child: Image.asset(
                cacheHeight: 140,
                "assets/images/back_img1.png",
                fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Get.height * 0.13),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: 95,
                              height: 95,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEEEEEE),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 18,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     buttonContainer(
                //         onTap: () async {},
                //         img: "assets/images/call_1.png",
                //         title: "Audio"),
                //     const SizedBox(width: 30),
                //     buttonContainer(
                //         onTap: () async {},
                //         img: "assets/images/video_1.png",
                //         title: "Video"),
                //     const SizedBox(width: 30),
                //     buttonContainer(
                //         onTap: () {},
                //         img: "assets/icons/search-normal.png",
                //         title: "Search")
                //   ],
                // ),
                // const SizedBox(height: 20),
                // bioContainer(),
                // const SizedBox(height: 20),
                // mediaContainer(),
                // const SizedBox(height: 20),
                // starredContainer(),
                // const SizedBox(height: 36),
                // actionOptions(),
              ],
            ),
            Positioned(
                top: 40,
                left: 5,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 19))),
          ],
        ),
      ),
    );
  }

  Widget buttonContainer(
      {required VoidCallback onTap,
      required String img,
      required String title}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [secondaryColor, chatownColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Image.asset(
                img,
                height: 21,
                width: 21,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }

  Widget bioContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, top: 10, right: 25, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width * 0.80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "Logged in",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 9,
                      fontFamily: "Poppins",
                      color: const Color(0xff000000).withOpacity(0.26)),
                ),
                const SizedBox(width: 2),
                Text(
                  "April 02, 2025",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 9,
                      fontFamily: "Poppins",
                      color: const Color(0xff000000).withOpacity(0.26)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget mediaContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Media, links and docs",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
              Row(
                children: const [
                  Text(
                    "0",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: appgrey2,
                  ),
                ],
              )
            ],
          ).paddingSymmetric(horizontal: 20, vertical: 10),
          SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "You haven't share any media",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  Widget starredContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/icons/star2.png", color: chatColor),
                const SizedBox(width: 10),
                const Text(
                  "Starred Messages",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            Row(
              children: const [
                Text(
                  "0",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: appgrey2,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget actionOptions() {
    return Column(
      children: [
        actionButton(icon: "assets/icons/block.png", text: "Block User"),
        const SizedBox(height: 1),
        actionButton(icon: "assets/icons/report.png", text: "Report User"),
        const SizedBox(height: 1),
        actionButton(icon: "assets/icons/delete.png", text: "Delete User"),
      ],
    );
  }

  Widget actionButton({required String icon, required String text}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  height: 18,
                  width: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffFF2525),
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// AddPersonaDetails placeholder
class AddPersonaDetailsPlaceholder extends StatelessWidget {
  final bool isRought;

  const AddPersonaDetailsPlaceholder({Key? key, required this.isRought})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: isRought == false
          ? createProfilePlaceholder()
          : profilePlaceholder(context),
    );
  }

  Widget createProfilePlaceholder() {
    return Container(
      width: Get.width,
      color: const Color.fromRGBO(250, 250, 250, 1),
      child: Column(
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Add Info",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                ),
              ).paddingOnly(top: 30).paddingSymmetric(
                    horizontal: 28,
                  ),
            ),
          ),
          const Divider(
            color: Color(0xffE9E9E9),
            height: 1,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  formField("Username"),
                  const SizedBox(height: 20),
                  formField("First Name"),
                  const SizedBox(height: 20),
                  formField("Last Name"),
                  const SizedBox(height: 20),
                  genderWidget(),
                  const SizedBox(height: 25),
                  Divider(
                    color: const Color(0xFF000000).withOpacity(0.06),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Contact Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            fontFamily: "Poppins",
                            color: Color(0xff3A3333)),
                      ),
                      const Text(
                        '(Non Changeable)',
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 8,
                            fontFamily: "Poppins",
                            color: Color(0xff959595)),
                      ).paddingOnly(top: 2, left: 2),
                    ],
                  ),
                  const SizedBox(height: 20),
                  mobileNumberWidget(),
                  const SizedBox(height: 20),
                  nationalityWidget(),
                  const SizedBox(height: 30),
                  continueButton(),
                  const SizedBox(height: 30),
                ],
              ).paddingSymmetric(horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget profilePlaceholder(BuildContext context) {
    return Container(
      width: Get.width,
      color: const Color.fromRGBO(250, 250, 250, 1),
      child: Stack(
        children: [
          SizedBox(
            height: Get.height * 0.27,
            width: double.infinity,
            child: Image.asset(
              cacheHeight: 140,
              "assets/images/back_img1.png",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 25, right: 25, bottom: 20, top: Get.height * 0.13),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _imgWidget(),
                        const SizedBox(height: 15),
                        formField("Username"),
                        const SizedBox(height: 15),
                        formField("First Name"),
                        const SizedBox(height: 15),
                        formField("Last Name"),
                        const SizedBox(height: 15),
                        genderWidget(),
                        const SizedBox(height: 15),
                        mobileNumberWidget(),
                        const SizedBox(height: 15),
                        nationalityWidget(),
                        const SizedBox(height: 30),
                        continueButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 45,
            left: 15,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    "assets/images/arrow-left.png",
                    color: appColorBlack,
                    scale: 1.5,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            fontFamily: "Poppins",
            color: Color(0xff3A3333),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xffEFEFEF)),
          ),
        ),
      ],
    );
  }

  Widget _imgWidget() {
    return Container(
      height: 110,
      width: 110,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEEEEE),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [secondaryColor, chatownColor],
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/edit-1.png",
                      height: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget genderWidget() {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                'Gender',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              Row(
                children: [
                  Container(
                    height: 16,
                    width: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xff9E9E9E),
                          Color(0xff1B1B1B),
                        ],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: appColorWhite, width: 2),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xff9E9E9E),
                            Color(0xff1B1B1B),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Male',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Row(
                children: [
                  Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xff9E9E9E).withOpacity(0.5),
                          const Color(0xff1B1B1B).withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColorWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Female',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget nationalityWidget() {
    return isRought == true
        ? Container(
            height: 50,
            width: Get.width * 0.90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: const Color(0XffEFEFEF)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Image.asset("assets/images/location1.png", height: 21),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(80, 80, 80, 1),
                      ),
                    ),
                    Text(
                      'United States',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Country',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 50,
                width: Get.width * 0.90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: const Color(0XffEFEFEF)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Image.asset("assets/images/location1.png", height: 21),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'United States',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget mobileNumberWidget() {
    return isRought == true
        ? Container(
            height: 50,
            width: Get.width * 0.90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: const Color(0XffEFEFEF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/call_1.png",
                      color: Colors.black,
                      height: 21,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(80, 80, 80, 1),
                          ),
                        ),
                        Text(
                          '+1 555-123-4567',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Image.asset("assets/images/verify.png", height: 17),
              ],
            ).paddingSymmetric(horizontal: 10),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Phone Number",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 50,
                width: Get.width * 0.90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: const Color(0XffEFEFEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/call_1.png",
                          color: Colors.black,
                          height: 21,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '+1 555-123-4567',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Image.asset("assets/images/verify.png", height: 17),
                  ],
                ).paddingSymmetric(horizontal: 10),
              ),
            ],
          );
  }

  Widget continueButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, chatownColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 50,
          width: Get.width * 0.80,
          alignment: Alignment.center,
          child: const Text(
            "Continue",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
