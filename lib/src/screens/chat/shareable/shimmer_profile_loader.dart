// ignore_for_file: deprecated_member_use

import 'package:whoxachat/src/screens/user/widget/banner_img_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/src/global/global.dart';

class ChatProfilePlaceholder extends StatelessWidget {
  const ChatProfilePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // SizedBox(
            //   height: Get.height * 0.27,
            //   width: double.infinity,
            //   child: Image.asset(
            //     cacheHeight: 140,
            //     "assets/images/back_img1.png",
            //     fit: BoxFit.cover,
            //   ),
            // ),
            _coverImg(''),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Get.height * 0.13),

                // Profile image and basic info
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10),
                  child: Column(
                    children: [
                      Container(
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
                      const SizedBox(height: 10),
                      Container(
                        height: 18,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buttonContainer(
                        onTap: () async {},
                        img: "assets/images/call_1.png",
                        title: "Audio"),
                    const SizedBox(width: 30),
                    buttonContainer(
                        onTap: () async {},
                        img: "assets/images/video_1.png",
                        title: "Video"),
                    const SizedBox(width: 30),
                    buttonContainer(
                        onTap: () {},
                        img: "assets/icons/search-normal.png",
                        title: "Search")
                  ],
                ),

                const SizedBox(height: 20),

                // Bio section
                Container(
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      blurRadius: 0.5,
                      spreadRadius: 0,
                      offset: Offset(0, 0.4),
                      color: Color.fromRGBO(239, 239, 239, 1),
                    )
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, top: 10, right: 25, bottom: 10),
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
                                  color: const Color(0xff000000)
                                      .withOpacity(0.26)),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "April 02, 2025",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 9,
                                  fontFamily: "Poppins",
                                  color: const Color(0xff000000)
                                      .withOpacity(0.26)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Media container
                Container(
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
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
                ),

                const SizedBox(height: 20),

                // Starred messages
                Container(
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      blurRadius: 0.5,
                      spreadRadius: 0,
                      offset: Offset(0, 0.4),
                      color: Color.fromRGBO(239, 239, 239, 1),
                    )
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25, top: 10, right: 25, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("assets/icons/star2.png",
                                color: chatColor),
                            const SizedBox(width: 10),
                            const Text(
                              "Starred Messages",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
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
                ),

                const SizedBox(height: 36),

                // Action options
                Column(
                  children: [
                    // Block option
                    Container(
                      decoration:
                          const BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          blurRadius: 0.5,
                          spreadRadius: 0,
                          offset: Offset(0, 0.4),
                          color: Color.fromRGBO(239, 239, 239, 1),
                        )
                      ]),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25, top: 15, right: 25, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/block.png",
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Block User",
                                  style: TextStyle(
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
                    ),
                    const SizedBox(height: 1),

                    // Report option
                    Container(
                      decoration:
                          const BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          blurRadius: 0.5,
                          spreadRadius: 0,
                          offset: Offset(0, 0.4),
                          color: Color.fromRGBO(239, 239, 239, 1),
                        )
                      ]),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25, top: 15, right: 25, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/report.png",
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Report User",
                                  style: TextStyle(
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
                    ),
                    const SizedBox(height: 1),

                    // Delete option
                    Container(
                      decoration:
                          const BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          blurRadius: 0.5,
                          spreadRadius: 0,
                          offset: Offset(0, 0.4),
                          color: Color.fromRGBO(239, 239, 239, 1),
                        )
                      ]),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25, top: 15, right: 25, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/delete.png",
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Delete User",
                                  style: TextStyle(
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
                    ),
                  ],
                ),

                SizedBox(height: 40),
              ],
            ),

            // Back button
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
      {required Function() onTap, required String img, required String title}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 53,
        width: 68,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: secondaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(
                img,
              ),
              color: chatColor,
              height: 15,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }
}

Widget _coverImg(String peerBanner) {
  return CoverImageWidget(
    imageUrl: peerBanner != '' && peerBanner.isNotEmpty ? peerBanner : null,
  );
}

// Usage in your existing code:
// return chatProfileController.isLoading.value
//     ? const ChatProfilePlaceholder()
//     : SingleChildScrollView(...
