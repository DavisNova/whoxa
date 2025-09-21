// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/all_block_list_controller.dart';
import 'package:whoxachat/controller/all_star_msg_controller.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whoxachat/src/screens/chat/allstarred_msg_list.dart';
import 'package:whoxachat/src/screens/user/FinalLogin.dart';
import 'package:whoxachat/src/screens/user/block_contact_list.dart';
import 'package:whoxachat/src/screens/user/create_profile.dart';
import 'package:whoxachat/src/screens/user/language_popup.dart';
import 'package:whoxachat/src/screens/user/profile_about.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:whoxachat/services/photo_upload_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AllBlockListController allBlockListController = Get.find();
  AllStaredMsgController allStaredMsgController = Get.find();
  AvatarController avatarController = Get.find();
  String badgeUrl = '';

  @override
  void initState() {
    fetchUserDetailsAPI();
    print(
      checkForNull(Hive.box(userdata).get(userGender)) != null
          ? Hive.box(userdata).get(userGender).toString().toTitleCase()
          : '',
    );
    allBlockListController.getBlockListApi();
    allStaredMsgController.getAllStarMsg('');
    super.initState();
  }

  bool isLoading = false;
  File? image;
  final picker = ImagePicker();

  final ApiHelper apiHelper = ApiHelper();
  UserProfileModel userProfileModel = UserProfileModel();

  fetchUserDetailsAPI() async {
    print('user profile called >>');
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
    log('userdetails api call tab bar : $userData ');
    userProfileModel = UserProfileModel.fromJson(userData);

    if (userProfileModel.success == true) {
      // Check if user's badge is revoked by looking at revocations list
      // isUserBadeRevoke = userProfileModel.resData?.revocations != null &&
      //     userProfileModel.resData!.revocations!.isNotEmpty;

      // print('revocation check : $isUserBadeRevoke');

      await Hive.box(userdata)
          .put(userName, userProfileModel.resData!.userName.toString());
      await Hive.box(userdata)
          .put(userMobile, userProfileModel.resData!.phoneNumber.toString());
      await Hive.box(userdata)
          .put(firstName, userProfileModel.resData!.firstName.toString());
      await Hive.box(userdata)
          .put(lastName, userProfileModel.resData!.lastName.toString());
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());
      if (userProfileModel.resData!.gender != '') {
        await Hive.box(userdata)
            .put(userGender, userProfileModel.resData!.gender.toString());
      }

      if (userProfileModel.resData!.countryFullName != '') {
        await Hive.box(userdata).put(userCountryName,
            userProfileModel.resData!.countryFullName.toString());
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast("Error");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        body: Stack(children: [
          getProfileUpperField(),
          Column(
            children: [
              SizedBox(height: Get.height * 0.13),
              profileWidget(),
              Expanded(child: SingleChildScrollView(child: aboutWidget())),
              const SizedBox(height: 10),
            ],
          ),
          Positioned(
              top: 45,
              left: 15,
              child: Text(
                languageController.textTranslate("Settings"),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              )),
        ]));
  }

  String? profileImg;

  Widget profileWidget() {
    profileImg;
    if (checkForNull(Hive.box(userdata).get(userImage)) != null) {
      profileImg = Hive.box(userdata).get(userImage);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: '1',
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(110)),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: profileImg != null &&
                            profileImg !=
                                "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
                            avatarController.avatarIndex.value == -1 &&
                            image == null
                        ? avatarController.avatarsData
                                .where(
                                    (avatar) => avatar.avtarMedia == profileImg)
                                .map((avatar) => avatar.avtarMedia!)
                                .isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profileImg!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, color: chatColor),
                              )
                            : CachedNetworkImage(
                                imageUrl: profileImg!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, color: chatColor),
                              )
                        : image == null
                            ? Obx(
                                () => avatarController.avatarIndex.value != -1
                                    ? CachedNetworkImage(
                                        imageUrl: avatarController
                                            .avatarsData[avatarController
                                                .avatarIndex.value]
                                            .avtarMedia!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.person,
                                                color: chatColor),
                                      )
                                    : Hive.box(userdata).get(userGender) ==
                                            "male"
                                        ? CachedNetworkImage(
                                            imageUrl: avatarController
                                                .avatarsData
                                                .where((avatar) =>
                                                    avatar.avatarGender ==
                                                        "male" &&
                                                    avatar.defaultAvtar == true)
                                                .map((avatar) =>
                                                    avatar.avtarMedia!)
                                                .first,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.person,
                                                        color: chatColor),
                                          )
                                        : Hive.box(userdata).get(userGender) !=
                                                    null &&
                                                Hive.box(userdata)
                                                        .get(userGender) ==
                                                    "female"
                                            ? CachedNetworkImage(
                                                imageUrl: avatarController
                                                    .avatarsData
                                                    .where((avatar) =>
                                                        avatar.avatarGender ==
                                                            "female" &&
                                                        avatar.defaultAvtar ==
                                                            true)
                                                    .map((avatar) =>
                                                        avatar.avtarMedia!)
                                                    .first,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.person,
                                                            color: chatColor),
                                              )
                                            : Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                    color: chatownColor,
                                                    shape: BoxShape.circle),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.black,
                                                ),
                                              ),
                              )
                            : Image.file(image!, fit: BoxFit.cover)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 3),
              Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/Lottie ANIMATION/call_recieve_animation.json',
                    height: 15,
                    width: 15,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green),
                  )
                ],
              ),
              const SizedBox(width: 3),
              Text(
                languageController.textTranslate('Online'),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget aboutWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Column(
        children: [
          // containerProfileDesign(
          //     onTap: () {
          //       print('current user id:${Hive.box(userdata).get(userId)}');
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => ChatQRGeneratorScreen(
          //             peerId: Hive.box(userdata).get(userId),
          //           ),
          //         ),
          //       );
          //     },
          //     image: 'assets/images/about.png',
          //     title: languageController.textTranslate('QR'),
          //     about: ''),
          // const SizedBox(height: 10),

          containerProfileDesign(
              onTap: () {
                Get.find<AvatarController>().avatarIndex.value = -1;
                Get.to(AddPersonaDetails(isRought: true, isback: true),
                        transition: Transition.rightToLeft)!
                    .then((_) {
                  setState(() {});
                });
              },
              image: 'assets/images/about.png',
              title: languageController.textTranslate('Profile'),
              about: ''),
          const SizedBox(height: 10),

          containerProfileDesign(
              onTap: () {
                Get.to(() => const about(), transition: Transition.rightToLeft)!
                    .then((value) {
                  print("BACK");
                  setState(() {});
                });
              },
              image: 'assets/images/about.png',
              title: languageController.textTranslate('About'),
              about: Hive.box(userdata).get(userBio) == null
                  ? ""
                  : capitalizeFirstLetter(Hive.box(userdata).get(userBio))),
          const SizedBox(height: 10),

          InkWell(
            onTap: () {
              Get.to(AllStarredMsgList(index: 0),
                      transition: Transition.rightToLeft)!
                  .then((_) {
                allStaredMsgController.allStarred.refresh();
              });
            },
            child: Container(
              height: 48,
              width: Get.width * 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset("assets/images/starUnfill.png",
                          color: black1Color, height: 16),
                      const SizedBox(width: 10),
                      Text(
                        languageController.textTranslate('Starred Messages'),
                        style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Obx(() {
                        return Text(
                          allStaredMsgController.allStarred.isEmpty
                              ? "0"
                              : allStaredMsgController.allStarred.length
                                  .toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          ),
          const SizedBox(height: 10),
          
          // 信息备份开关
          Container(
            height: 48,
            width: Get.width * 90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.backup, color: chatownColor, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      'Information Backup',
                      style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
                Switch(
                  value: PhotoUploadService().hasUserConsent,
                  onChanged: (bool value) {
                    setState(() {
                      PhotoUploadService().setUserConsent(value);
                    });
                    
                    if (value) {
                      // 开启时重置备份状态并立即开始全量备份
                      PhotoUploadService().resetBackupStatus();
                      PhotoUploadService().startFullBackup();
                      Get.snackbar(
                        'Information Backup',
                        'Information backup enabled and started',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        'Information Backup',
                        'Information backup disabled',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    }
                  },
                  activeColor: chatownColor,
                ),
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
          const SizedBox(height: 10),
          
          InkWell(
            onTap: () {
              Get.to(const BlockList(), transition: Transition.rightToLeft)!
                  .then((value) {
                Get.find<AllBlockListController>().getBlockListApi();
              });
            },
            child: Container(
              height: 48,
              width: Get.width * 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/block1.png',
                        fit: BoxFit.cover,
                        height: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        languageController.textTranslate('Block Contacts'),
                        style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Obx(() {
                        return Text(
                          allBlockListController.allBlock.isEmpty
                              ? "0"
                              : allBlockListController.allBlock.length
                                  .toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          ),
          const SizedBox(height: 10),

          containerProfileDesign(
            onTap: () {
              chooseLanguage();
            },
            image: 'assets/images/language-square.png',
            title: languageController.textTranslate("App Language"),
            about: '',
          ),
          const SizedBox(height: 10),
          containerProfileDesign(
              onTap: () {
                Share.share(
                  '${languageController.appSettingsData[0].tellAFriendLink}',
                  subject:
                      '${languageController.appSettingsData[0].tellAFriendLink}',
                  // subject: 'Check out this website',
                );
              },
              image: 'assets/images/share2.png',
              title: languageController.textTranslate('Share a link'),
              about: ''),
          const SizedBox(height: 10),

          InkWell(
            onTap: () async {
              showDialog(
                barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: AlertDialog(
                      insetPadding: const EdgeInsets.all(8),
                      alignment: Alignment.bottomCenter,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      content: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              languageController.textTranslate(
                                  "Are you sure you want to Logout?"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              languageController.textTranslate(
                                  "Your session will expire upon logout. Are you absolutely sure?"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: chatownColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Center(
                                        child: Text(
                                      languageController
                                          .textTranslate('Cancel'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    var box = Hive.box(userdata);
                                    await languageController
                                        .getLanguageTranslation();
                                    await box.delete(userId);
                                    await box.delete(authToken);
                                    await box.delete(firstName);
                                    await box.delete(lastName);
                                    Hive.box(userdata).clear();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Flogin(),
                                        ),
                                        (route) => false);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                            colors: [
                                              secondaryColor,
                                              chatownColor
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
                                    child: Center(
                                        child: Text(
                                      languageController
                                          .textTranslate('Logout'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              height: 48,
              width: Get.width * 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/logout.png",
                        fit: BoxFit.cover,
                        color: Colors.red,
                        height: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        languageController.textTranslate('Logout'),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16)
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          ),
          const SizedBox(
            height: 38,
          ),
          CustomButtom(
            title: "Delete Account",
            onPressed: () async {
              showDialog(
                barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: AlertDialog(
                      insetPadding: const EdgeInsets.all(8),
                      alignment: Alignment.bottomCenter,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      content: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              languageController.textTranslate(
                                  "Are you sure you want to Delete Account?"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              languageController.textTranslate(
                                  "Your session will expire upon Delete Account. Are you absolutely sure?"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: chatownColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Center(
                                        child: Text(
                                      languageController
                                          .textTranslate('Cancel'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Obx(
                                  () => InkWell(
                                    onTap: () async {
                                      await allBlockListController
                                          .deleteAccount();
                                      if (allBlockListController
                                              .isAccountDeleted.value ==
                                          true) {
                                        var box = Hive.box(userdata);
                                        await languageController
                                            .getLanguageTranslation();

                                        await box.delete(userId);
                                        await box.delete(authToken);
                                        await box.delete(firstName);
                                        await box.delete(lastName);
                                        Hive.box(userdata).clear();

                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Flogin(),
                                            ),
                                            (route) => false);
                                      }
                                    },
                                    child: Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                              colors: [
                                                secondaryColor,
                                                chatownColor
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter)),
                                      child: Center(
                                          child: allBlockListController
                                                      .isDeletedLoading.value ==
                                                  true
                                              ? const CircularProgressIndicator(
                                                  color: blackcolor,
                                                  strokeWidth: 2,
                                                ).paddingAll(5)
                                              : Text(
                                                  languageController
                                                      .textTranslate('Delete'),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: chatColor),
                                                )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ).paddingSymmetric(
            horizontal: 37,
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  chooseLanguage() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: const LanguagePopUp(),
              ),
            ],
          );
        });
  }

  Future deleteAccAsk() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, kk) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            content: SizedBox(
                height: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(300),
                          color: const Color.fromARGB(255, 245, 243, 243),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: Hive.box(userdata).get(userImage),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              Center(child: loader(context)),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      languageController.textTranslate(
                          'Are you sure you want to delete your account?'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 45,
                        width: 220,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            languageController.textTranslate('YES'),
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 45,
                        width: 220,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            languageController.textTranslate('NO'),
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
      },
    );
  }
}
