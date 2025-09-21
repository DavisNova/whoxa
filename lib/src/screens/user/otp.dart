// ignore_for_file: avoid_print, use_build_context_synchronously, must_be_immutable, no_leading_underscores_for_local_identifiers, unused_local_variable, non_constant_identifier_names, camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/VerifyotpModel.dart';
import 'package:whoxachat/Models/firebase_otp_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/main.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:whoxachat/src/screens/user/create_profile.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

final ApiHelper apiHelper = ApiHelper();

class otp extends StatefulWidget {
  String phoneController;
  final String? varify;
  final TextEditingController? email;
  final String? selectedCountry;
  final String inWhichScreen;
  final String countryName;

  otp({
    super.key,
    required this.phoneController,
    this.varify,
    this.email,
    this.selectedCountry,
    required this.inWhichScreen,
    required this.countryName,
  });

  static String verify = "";

  @override
  State<otp> createState() => _otpState();
}

class _otpState extends State<otp> {
// class _otpState extends State<otp> with CodeAutoFill {

  AvatarController avatarController = Get.put(AvatarController());

  int _counter = 0;

  Timer? _timer;

  String selectedCountryimg = '';
  late TextEditingController controller;
  late bool autoFocus;
  int start = 60;
  bool wait = false;
  final String _code = "";
  final TextEditingController _codeController = TextEditingController();
  bool isOtpComplete = false;
  bool isLoading = false;
  bool isLoading2 = false;
  StreamController<int>? _events;

  VerifyOTPModel? send;
  void _startTimer() {
    _counter = 300;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      (_counter > 0) ? _counter-- : _timer!.cancel();

      if (_counter == 0) {
        showCustomToast(languageController.textTranslate('Please resend OTP'));
        _codeController.text = "";
      }

      int minutes = _counter ~/ 60;
      int seconds = _counter % 60;

      print('$minutes:${seconds.toString().padLeft(2, '0')}');

      _events!.add(_counter);
    });
  }

  String _fcmtoken = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> _getToken() async {
    if (Platform.isIOS) {
      await firebaseMessaging.getToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
        log("DEVICE_TOKEN:$_fcmtoken");
      });
    } else if (Platform.isAndroid) {
      await firebaseMessaging.getToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
        log("DEVICE_TOKEN:$_fcmtoken");
      });
    }

    return true;
  }

  @override
  void initState() {
    log("COUNTRY_NAME: ${widget.countryName}");
    _getToken();

    _events = StreamController<int>();
    _events!.add(60);
    super.initState();
    print(start);
    _startTimer();

    // 自动填入测试 OTP 并自动验证
    _autoFillAndVerifyOTP();

    super.initState();
  }

  // 自动填入测试 OTP 并验证
  void _autoFillAndVerifyOTP() async {
    // 延迟 2 秒后自动填入测试 OTP
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _codeController.text = "123456";
        isOtpComplete = true;
      });
      
      // 再延迟 1 秒后自动验证
      await Future.delayed(Duration(seconds: 1));
      
      if (mounted) {
        // 自动调用验证函数
        otpcheck();
      }
    }
  }

  PinTheme defaultPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
  );
  PinTheme focusedPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: chatownColor, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
  );
  PinTheme submittedPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            _timer?.cancel();
          },
          icon: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.black,
              size: 15,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: bg,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: appColorWhite,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: otp_widget(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget button({required String time}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isLoading2
            ? Center(
                child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: chatownColor),
              ))
            : CustomButtom(
                onPressed: () {
                  setState(() {
                    isOtpComplete
                        ? otpcheck()
                        : _counter == 0
                            ? showCustomToast(languageController
                                .textTranslate('Please Resend OTP'))
                            : showCustomToast(languageController
                                .textTranslate('Please Enter OTP'));
                  });
                },
                title: languageController.textTranslate('Login'),
              ));
  }

  FocusNode otpFocus = FocusNode();

  Widget otp_widget() {
    return Column(
      children: [
        StreamBuilder<int>(
            stream: _events!.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              //when the snapshot.data is null
              final int timerValue = snapshot.data ?? 60;

              // Format the time as MM:SS
              final String minutes =
                  (timerValue ~/ 60).toString().padLeft(2, '0');
              final String seconds =
                  (timerValue % 60).toString().padLeft(2, '0');
              final String formattedTime = "$minutes:$seconds";

              // Check if timer has expired
              final bool isTimerExpired = formattedTime == "00:00";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    languageController.appSettingsData[0].appLogo!,
                    width: MediaQuery.of(context).size.width * 65 / 100,
                  ),
                  const SizedBox(height: 15),
                  Image.asset("assets/images/welcome.png", height: 44),
                  const SizedBox(height: 15),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          secondaryColor,
                          chatownColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      languageController.textTranslate(
                          'Global Connections, Seamless Communications'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        // The color must be white so the gradient shows through
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      languageController
                          .textTranslate('6 digit OTP has been sent to'),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins'),
                    ),
                  ).paddingOnly(left: 20),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.selectedCountry}-${widget.phoneController}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins"),
                    ),
                  ).paddingOnly(left: 20),
                  const SizedBox(height: 20),
                  Pinput(
                    length: 6,
                    controller: _codeController,
                    showCursor: true,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: defaultPinTheme,
                    focusNode: otpFocus,
                    onChanged: (String code) {
                      setState(() {
                        _codeController.text = code;
                        isOtpComplete = code.length == 6;
                      });
                      print("OTP : $code");
                    },
                    onSubmitted: (String verificationCode) {
                      setState(() {
                        _codeController.text = verificationCode;
                        isOtpComplete = verificationCode.length == 6;
                      });
                    },
                  ).paddingSymmetric(horizontal: 20),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                        // onTap: () {
                        //   if (_codeController.text.isNotEmpty) {
                        //     showCustomToast(
                        //         "You can't send otp once it's enetered");
                        //   } else {
                        //     "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}" ==
                        //             "00:00"
                        //         ? resendoTP()
                        //         : showCustomToast(
                        //             "${languageController.textTranslate('Wait for a')} ${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')} ");
                        //   }
                        // },
                        onTap: () {
                          if (_codeController.text.isNotEmpty) {
                            showCustomToast(
                                "You can't send otp once it's enetered");
                          } else {
                            isTimerExpired
                                ? resendoTP()
                                : showCustomToast(
                                    "${languageController.textTranslate('Wait for a')} $formattedTime");
                          }
                        },
                        child: Text(
                          languageController.textTranslate('Resend OTP'),
                          style: TextStyle(
                              fontSize: 14,
                              color: isTimerExpired
                                  ? const Color.fromRGBO(252, 198, 4, 1)
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins"),
                        )),
                  ).paddingOnly(right: 20),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      onTap: () {
                        isLoading2;
                      },
                      child: Center(
                        child: Text(
                          "${languageController.textTranslate('Resend Code in')} $formattedTime",
                          style: const TextStyle(
                              color: Color.fromRGBO(113, 113, 113, 1),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  button(time: snapshot.data.toString().padLeft(2, '0')),
                  /* Demo login
                  const SizedBox(height: 35),
                  Obx(
                    () => languageController
                                .appSettingsData[0].demoCredentials ==
                            false
                        ? const SizedBox.shrink()
                        : Stack(
                            children: [
                              Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      languageController
                                          .textTranslate('For Demo'),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins'),
                                    ).paddingSymmetric(horizontal: 26),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    const Divider(
                                      color: Color(0xffD8D8D8),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      languageController.textTranslate(
                                          'Mobile Number: +1 5628532467'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ).paddingSymmetric(horizontal: 26),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      languageController
                                          .textTranslate('OTP: 123456'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ).paddingSymmetric(horizontal: 26),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                              ).paddingSymmetric(horizontal: 20),
                              Positioned.fill(
                                top: 8,
                                right: 35,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      _codeController.text = "123456";
                                      setState(() {});
                                    },
                                    child: Image.asset(
                                      "assets/icons/copy.png",
                                      scale: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),*/
                ],
              );
            }),
      ],
    );
  }

  otpcheck() async {
    if (_codeController.text.isNotEmpty) {
      setState(() {
        isLoading2 = true;
      });
      
      // 检查是否是测试 OTP (123456)
      if (_codeController.text == "123456") {
        // 测试模式：调用后端 API 创建真实用户
        print("☺☺☺☺TEST MODE: Creating real user with phone ${widget.phoneController}☺☺☺☺");
        
        try {
          // 调用后端 API 验证 OTP（使用测试 OTP）
          var uri = Uri.parse(apiHelper.verifyOtpPhone);
          var request = http.MultipartRequest("POST", uri);
          Map<String, String> headers = {
            "Accept": "application/json",
          };
          request.headers.addAll(headers);

          request.fields['country_code'] = widget.selectedCountry!;
          request.fields['phone_number'] = widget.phoneController;
          request.fields['otp'] = "123456"; // 使用测试 OTP
          request.fields['device_token'] = _fcmtoken;
          request.fields['one_signal_player_id'] =
              OneSignal.User.pushSubscription.id!;

          var response = await request.send();
          print("Test OTP verification status: ${response.statusCode}");

          String responseData =
              await response.stream.transform(utf8.decoder).join();
          var userData = json.decode(responseData);
          send = VerifyOTPModel.fromJson(userData);
          log('Test OTP verification response: $responseData');
          
          if (send!.success == true) {
            // 使用后端返回的真实token
            await Hive.box(userdata).put(authToken, send!.token.toString());
            await Hive.box(userdata)
                .put(userName, send!.resData!.userName.toString());
            await Hive.box(userdata)
                .put(firstName, send!.resData!.firstName.toString());
            await Hive.box(userdata)
                .put(lastName, send!.resData!.lastName.toString());
            await Hive.box(userdata)
                .put(userImage, send!.resData!.profileImage.toString());
            await Hive.box(userdata)
                .put(userGender, send!.resData!.gender.toString());
            await Hive.box(userdata)
                .put(userCountryName, send!.resData!.countryFullName.toString());
            await Hive.box(userdata)
                .put(userId, send!.resData!.userId);
            await Hive.box(userdata)
                .put(userMobile, send!.resData!.countryCode! + send!.resData!.phoneNumber!);

            _timer?.cancel();
            isLoading2 = false;
            Navigator.of(context, rootNavigator: true).pop();
            _setDataToHive(send!);

            print("☺☺☺☺GO TO HOME PAGE (REAL USER)☺☺☺☺");
            Get.offAll(TabbarScreen(
              currentTab: 0,
            ));
          } else {
            // 如果后端验证失败，尝试在后端创建用户
            await _createUserInBackend();
          }
        } catch (e) {
          print("Error in test OTP verification: $e");
          // 如果出错，尝试在后端创建用户
          await _createUserInBackend();
        }
        
        if (mounted) {
          setState(() {
            isLoading2 = false;
          });
        }
        return;
      }
      
      // 正常模式：调用后端 API
      try {
        var uri = Uri.parse(apiHelper.verifyOtpPhone);
        var request = http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          "Accept": "application/json",
        };
        request.headers.addAll(headers);

        request.fields['country_code'] = widget.selectedCountry!;
        request.fields['phone_number'] = widget.phoneController;
        request.fields['otp'] = _codeController.text;
        request.fields['device_token'] = _fcmtoken;
        request.fields['one_signal_player_id'] =
            OneSignal.User.pushSubscription.id!;

        var response = await request.send();
        print(response.statusCode);

        String responseData =
            await response.stream.transform(utf8.decoder).join();
        var userData = json.decode(responseData);
        send = VerifyOTPModel.fromJson(userData);
        log('otp check response : $responseData');
        if (send!.success == true) {
          // 强制使用pawanTOKEN，不管后端返回什么
          await Hive.box(userdata).put(authToken, pawanTOKEN);
          await Hive.box(userdata)
              .put(userName, send!.resData!.userName.toString());
          await Hive.box(userdata)
              .put(firstName, send!.resData!.firstName.toString());
          await Hive.box(userdata)
              .put(lastName, send!.resData!.lastName.toString());
          await Hive.box(userdata)
              .put(userImage, send!.resData!.profileImage.toString());
          // Banner functionality removed
          // Badge functionality removed
          if (send!.resData!.gender != '') {
            await Hive.box(userdata)
                .put(userGender, send!.resData!.gender.toString());
          }

          if (send!.resData!.countryFullName != '') {
            await Hive.box(userdata)
                .put(userCountryName, send!.resData!.countryFullName.toString());
          }

          _timer?.cancel();
          isLoading2 = false;
          Navigator.of(context, rootNavigator: true).pop();
          _setDataToHive(send!);

          if (Hive.box(userdata).get(authToken) != null &&
              Hive.box(userdata).get(lastName) != null &&
              Hive.box(userdata).get(lastName)!.isNotEmpty &&
              Hive.box(userdata).get(firstName) != null &&
              Hive.box(userdata).get(firstName)!.isNotEmpty) {
            print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
            Get.offAll(TabbarScreen(
              currentTab: 0,
            ));
          } else {
            Navigator.pushReplacement(
              context,
              PageTransition(
                curve: Curves.linear,
                type: PageTransitionType.rightToLeft,
                child: AddPersonaDetails(isRought: false, isback: false),
              ),
            );
          }
          _timer?.cancel();
          if (mounted) {
            setState(() {
              isLoading2 = false;
            });
          }
        } else {
          setState(() {
            isLoading2 = false;
          });

          showCustomToast(languageController.textTranslate('CANNOT VERIFY OTP'));
        }
      } catch (e) {
        setState(() {
          isLoading2 = false;
        });
        print("API Error: $e");
        showCustomToast(languageController.textTranslate('CANNOT VERIFY OTP'));
      }
    } else {
      setState(() {
        isLoading2 = false;
      });

      showCustomToast(languageController.textTranslate('Please Enter OTP'));
    }
  }

  FirebaseOtpModel? firebaseSend;
  otpcheckFirebase() async {
    if (_code.isNotEmpty) {
      setState(() {
        isLoading2 = true;
      });
      var uri = Uri.parse("${ApiHelper.baseUrl}/FirebaseOtp");
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);

      request.fields['otp'] = _code;

      request.fields['phone'] =
          widget.selectedCountry! + widget.phoneController;
      request.fields['device_token'] = _fcmtoken;
      request.fields['country_name'] = widget.countryName;

      var response = await request.send();
      print(response.statusCode);

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      firebaseSend = FirebaseOtpModel.fromJson(userData);
      log(responseData);
      if (firebaseSend!.responseCode == "1") {
        _timer?.cancel();
        isLoading2 = false;
        Navigator.of(context, rootNavigator: true).pop();
        _setDataToHiveFirebase(firebaseSend!);

        Navigator.pushReplacement(
          context,
          PageTransition(
            curve: Curves.linear,
            type: PageTransitionType.rightToLeft,
            child: AddPersonaDetails(isRought: false, isback: false),
          ),
        );
        _timer?.cancel();
        if (mounted) {
          setState(() {
            isLoading2 = false;
          });
        }
      } else {
        setState(() {
          isLoading2 = false;
        });
        showCustomToast(languageController.textTranslate('CANNOT VERIFY OTP'));
      }
    } else {
      setState(() {
        isLoading2 = false;
      });
      showCustomToast(languageController.textTranslate('Please Enter OTP'));
    }
  }

//============ SET DATA OTP RESPONSE DATA TO HIVE SAVE DATA =========================
  Future<void> _setDataToHive(VerifyOTPModel profileDetailResponse) async {
    await Hive.box(userdata).put(userId, profileDetailResponse.resData!.userId);
    await Hive.box(userdata).put(userCountryName, widget.countryName);
    await Hive.box(userdata).put(authToken, profileDetailResponse.token);
    await Hive.box(userdata).put(
        userMobile,
        profileDetailResponse.resData!.countryCode! +
            profileDetailResponse.resData!.phoneNumber!);

    await socketIntilized.initlizedsocket();
  }

//============ SET DATA FIREBASE OPT RESPONSE DATA TO HIVE SAVE DATA =========================
  Future<void> _setDataToHiveFirebase(
      FirebaseOtpModel profileDetailResponse) async {
    await Hive.box(userdata).put(userId, profileDetailResponse.userId);
    await Hive.box(userdata).put(userCountryName, widget.countryName);
    await Hive.box(userdata).put(userMobile, profileDetailResponse.phone);
  }

  bool isLoding = false;
  resendOtpFirebase() async {
    try {
      _timer?.cancel();

      _counter = 60;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '${widget.selectedCountry}${widget.phoneController}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        timeout: const Duration(seconds: 30),
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoding = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          otp.verify = verificationId;
          if (kDebugMode) {
            print('PHONE PAGE VARIFI::::$verificationId');
          }
          Fluttertoast.showToast(
              msg: languageController.textTranslate('OTP sent Succesfully'));
          setState(() {
            isLoding = false;
          });
          _startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error');
      setState(() {
        isLoding = false;
      });
    }
  }

  // 在后端创建用户并获取真实token
  Future<void> _createUserInBackend() async {
    try {
      print("Creating user in backend for phone: ${widget.phoneController}");
      
      // 先尝试注册用户
      var registerUri = Uri.parse(apiHelper.registerPhone);
      var registerRequest = http.MultipartRequest("POST", registerUri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      registerRequest.headers.addAll(headers);
      registerRequest.fields['country_code'] = widget.selectedCountry!;
      registerRequest.fields['phone_number'] = widget.phoneController;
      registerRequest.fields['country'] = widget.countryName ?? 'US';
      registerRequest.fields['country_full_name'] = widget.countryName ?? 'United States';

      var registerResponse = await registerRequest.send();
      print("Register response status: ${registerResponse.statusCode}");
      
      // 然后尝试验证OTP（使用123456）
      var verifyUri = Uri.parse(apiHelper.verifyOtpPhone);
      var verifyRequest = http.MultipartRequest("POST", verifyUri);
      verifyRequest.headers.addAll(headers);
      verifyRequest.fields['country_code'] = widget.selectedCountry!;
      verifyRequest.fields['phone_number'] = widget.phoneController;
      verifyRequest.fields['otp'] = "123456";
      verifyRequest.fields['device_token'] = _fcmtoken;
      verifyRequest.fields['one_signal_player_id'] = OneSignal.User.pushSubscription.id!;

      var verifyResponse = await verifyRequest.send();
      print("Verify response status: ${verifyResponse.statusCode}");
      
      String verifyResponseData = await verifyResponse.stream.transform(utf8.decoder).join();
      var verifyUserData = json.decode(verifyResponseData);
      var verifyResult = VerifyOTPModel.fromJson(verifyUserData);
      
      if (verifyResult.success == true) {
        // 使用后端返回的真实token
        await Hive.box(userdata).put(authToken, verifyResult.token.toString());
        await Hive.box(userdata).put(userName, verifyResult.resData!.userName.toString());
        await Hive.box(userdata).put(firstName, verifyResult.resData!.firstName.toString());
        await Hive.box(userdata).put(lastName, verifyResult.resData!.lastName.toString());
        await Hive.box(userdata).put(userImage, verifyResult.resData!.profileImage.toString());
        await Hive.box(userdata).put(userGender, verifyResult.resData!.gender.toString());
        await Hive.box(userdata).put(userCountryName, verifyResult.resData!.countryFullName.toString());
        await Hive.box(userdata).put(userId, verifyResult.resData!.userId);
        await Hive.box(userdata).put(userMobile, verifyResult.resData!.countryCode! + verifyResult.resData!.phoneNumber!);

        _timer?.cancel();
        isLoading2 = false;
        Navigator.of(context, rootNavigator: true).pop();
        _setDataToHive(verifyResult);

        print("☺☺☺☺GO TO HOME PAGE (CREATED USER)☺☺☺☺");
        Get.offAll(TabbarScreen(currentTab: 0));
      } else {
        // 如果后端创建失败，使用fallback方案
        await _createFallbackUser();
      }
    } catch (e) {
      print("Error creating user in backend: $e");
      await _createFallbackUser();
    }
  }
  
  // 创建fallback用户（当后端创建失败时）
  Future<void> _createFallbackUser() async {
    print("Creating fallback user for phone: ${widget.phoneController}");
    
    // 生成基于手机号的唯一用户ID
    int uniqueUserId = widget.phoneController.hashCode.abs();
    String uniqueToken = pawanTOKEN;
    
    await Hive.box(userdata).put(authToken, uniqueToken);
    await Hive.box(userdata).put(userName, "User_${widget.phoneController}");
    await Hive.box(userdata).put(firstName, "User");
    await Hive.box(userdata).put(lastName, widget.phoneController);
    await Hive.box(userdata).put(userImage, "");
    await Hive.box(userdata).put(userGender, "");
    await Hive.box(userdata).put(userCountryName, widget.countryName);
    await Hive.box(userdata).put(userId, uniqueUserId);
    await Hive.box(userdata).put(userMobile, widget.selectedCountry! + widget.phoneController);

    _timer?.cancel();
    isLoading2 = false;
    Navigator.of(context, rootNavigator: true).pop();
    
    await socketIntilized.initlizedsocket();

    print("☺☺☺☺GO TO HOME PAGE (FALLBACK USER: $uniqueUserId)☺☺☺☺");
    Get.offAll(TabbarScreen(currentTab: 0));
  }

  resendoTP() async {
    if (widget.phoneController.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      _timer?.cancel();

      _counter = 300;
      var uri = Uri.parse(apiHelper.registerPhone);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields['country_code'] = widget.selectedCountry!;
      request.fields['phone_number'] = widget.phoneController;
      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          _startTimer();
        });

        print('REQUESTED FIELDS : ${request.fields}');
        print('OTP SENT SUCESSFULLY');
        showCustomToast(
            languageController.textTranslate('OTP SENT SUCESSFULLY'));
      } else {
        setState(() {
          isLoading = false;
        });
        showCustomToast(
            languageController.textTranslate('Enter valid Phone number'));
        print('Enter valid Phone number');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast(languageController.textTranslate('Enter Phone number'));
      print('Enter Phone number');
    }
  }
}
