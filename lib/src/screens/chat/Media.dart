// ignore_for_file: deprecated_member_use, must_be_immutable, file_names, avoid_print, non_constant_identifier_names

import 'dart:developer';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/single_chat_media_controller.dart';
import 'package:whoxachat/model/chat_profile_model.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/pdf.dart';
import 'package:whoxachat/src/screens/chat/FileView.dart';
import 'package:whoxachat/src/screens/chat/chatvideo.dart';
import 'package:whoxachat/src/screens/chat/imageView.dart';
import 'package:page_transition/page_transition.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Media extends StatefulWidget {
  String? peeid;
  String? peername;
  Media({super.key, this.peeid, this.peername});

  @override
  State<Media> createState() => _MediaState();
}

class _MediaState extends State<Media> {
  ChatProfileController chatProfileController = Get.find();
  @override
  void initState() {
    if (widget.peeid!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        chatProfileController.getProfileDATA(widget.peeid!);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 50,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
        title: Text(
          capitalizeFirstLetter(widget.peername.toString()),
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 18, color: chatColor),
        ),
      ),
      body: Obx(() {
        return SafeArea(
            child: Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.maxFinite,
                  color: Colors.white,
                  child: Center(
                    child: TabBar(
                      dividerColor: const Color.fromRGBO(236, 236, 236, 1),
                      indicatorColor: chatownColor,
                      unselectedLabelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                      labelStyle: TextStyle(
                          color: chatownColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                      tabs: [
                        Tab(
                          text:
                              '      ${languageController.textTranslate('Media')}        ',
                        ),
                        Tab(
                          text:
                              "      ${languageController.textTranslate('Links')}       ",
                        ),
                        Tab(
                          text:
                              "      ${languageController.textTranslate('Docs')}        ",
                        ),
                      ],
                    ),
                  ),
                ),
                chatProfileController.isLoading.value &&
                        chatProfileController
                            .profileModel.value!.mediaData!.isEmpty &&
                        chatProfileController
                            .profileModel.value!.documentData!.isEmpty &&
                        chatProfileController
                            .profileModel.value!.linkData!.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.4),
                            loader(context),
                          ],
                        ),
                      )
                    : chatProfileController.profileModel.value == null
                        ? const SizedBox()
                        : Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                chatProfileController
                                        .profileModel.value!.mediaData!.isEmpty
                                    ? Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.90,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Text(
                                                    "${languageController.textTranslate("You haven't share any media")} with ${widget.peername}",
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: chatColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                            )
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: GridView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              mainAxisExtent: 110,
                                              mainAxisSpacing: 10.0,
                                            ),
                                            itemCount: chatProfileController
                                                .profileModel
                                                .value!
                                                .mediaData!
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Media1(
                                                  chatProfileController
                                                      .profileModel
                                                      .value!
                                                      .mediaData![index],
                                                  index);
                                            },
                                          ),
                                        ),
                                      ),
                                Column(
                                  children: [
                                    Center(
                                      child: chatProfileController.profileModel
                                              .value!.linkData!.isEmpty
                                          ? Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15),
                                                    child: Container(
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.90,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Text(
                                                          "${languageController.textTranslate("You haven't share any link with")} ${widget.peername}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              color: chatColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.transparent,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 20, 0, 0),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    primary: false,
                                                    padding: EdgeInsets.zero,
                                                    itemCount:
                                                        chatProfileController
                                                            .profileModel
                                                            .value!
                                                            .linkData!
                                                            .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return links(
                                                          chatProfileController
                                                              .profileModel
                                                              .value!
                                                              .linkData![index],
                                                          index);
                                                    },
                                                  )),
                                            ),
                                    )
                                  ],
                                ),
                                Container(
                                  child: chatProfileController.profileModel
                                          .value!.documentData!.isEmpty
                                      ? Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.90,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Text(
                                                      "${languageController.textTranslate("You haven't share any doc with")} ${widget.peername}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: chatColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w300),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.transparent,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 20, 0, 0),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                padding: EdgeInsets.zero,
                                                itemCount: chatProfileController
                                                    .profileModel
                                                    .value!
                                                    .documentData!
                                                    .length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return docs(
                                                      chatProfileController
                                                          .profileModel
                                                          .value!
                                                          .documentData![index],
                                                      index);
                                                },
                                              )),
                                        ),
                                ),
                              ],
                            ),
                          ),
              ],
            ),
          ),
        ));
      }),
    );
  }

//==================================================== IMAGE, VIDEO ===================================================================================================
  Widget Media1(MediaData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: data.url.toString().contains(".mp4")
          ? InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoViewFix(
                        username:
                            "${capitalizeFirstLetter("")} ${capitalizeFirstLetter("")}",
                        url: data.url!,
                        play: true,
                        mute: false,
                        date: "",
                      ),
                    ));
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    child: ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl: data.thumbnail!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 42,
                      child: Image.asset("assets/images/play1.png",
                          height: 22, color: chatColor))
                ],
              ),
            )
          : InkWell(
              onTap: () {
                log(data.url!);
                Navigator.push(
                  context,
                  PageTransition(
                      curve: Curves.linear,
                      type: PageTransitionType.rightToLeft,
                      child: ImageView(
                        image: data.url!,
                        userimg: "",
                      )),
                );
              },
              child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey.shade200,
                  child: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: data.url!,
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
    );
  }

//=================================================================== Links ============================================================================
  Widget links(LinkData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: const Color(0xffE8E8E8))),
        width: MediaQuery.of(context).size.width * 0.90,
        child: InkWell(
          onTap: () {
            launchURL(data.message!);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: FlutterLinkPreview(
                  url: data.message!,
                  builder: (info) {
                    if (info is WebInfo) {
                      return info.title == null && info.description == null
                          ? Text(
                              data.message!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (info.image != null)
                                  Container(
                                    height: 58,
                                    width: 57,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(info.image!,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (info.title != null)
                                        Text(
                                          info.title!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ).paddingAll(2),
                                      info.image == null
                                          ? const SizedBox(height: 5)
                                          : const SizedBox.shrink(),
                                      if (info.description != null)
                                        Text(
                                          info.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color:
                                                  Color.fromRGBO(68, 68, 68, 1),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                    }
                    return const CircularProgressIndicator();
                  },
                  titleStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.message!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: linkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ).paddingOnly(left: 10)
            ],
          ),
        ).paddingAll(5),
      ),
    );
  }

//=================================================================== Documenet ========================================================================
  Widget docs(DocumentData data, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
              curve: Curves.linear,
              type: PageTransitionType.rightToLeft,
              child: FileView(file: data.url!),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: secondaryColor),
          child: Container(
            width: Get.width * 0.50,
            height: 58,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Image(
                      height: 28,
                      image: AssetImage('assets/images/pdf.png'),
                    ),
                    FutureBuilder<Map<String, dynamic>>(
                      future: getPdfInfo(data.url!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                extractFilename(data.url!)
                                    .toString()
                                    .split("-")
                                    .last,
                                style: const TextStyle(
                                  color: chatColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                languageController
                                    .textTranslate('0 Page - 0 KB'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ).paddingOnly(left: 12);
                        } else if (snapshot.hasError) {
                          return const Text('');
                        } else if (snapshot.hasData) {
                          final int pageCount = snapshot.data!['pageCount'];
                          final String fileSize = snapshot.data!['fileSize'];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 11),
                                child: Text(
                                  extractFilename(data.url!)
                                      .toString()
                                      .split("-")
                                      .last,
                                  style: const TextStyle(
                                    color: chatColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '$pageCount Page - $fileSize',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ).paddingOnly(left: 12),
                            ],
                          );
                        } else {
                          return Text(languageController
                              .textTranslate('No PDF info available'));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

//=======================================================
  Widget getUrlWidget(String url) {
    if (url.endsWith('.mp4')) {
      return FutureBuilder<Uint8List?>(
        future: getThumbnail(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.fill,
            );
          } else {
            return Container();
          }
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
      );
    }
  }

  Future<Uint8List?> getThumbnail(String videoUrl) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        quality: 100,
        maxHeight: 100,
        maxWidth: 100);
    return thumbnail;
  }
}
