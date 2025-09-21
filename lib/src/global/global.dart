// ignore_for_file: must_be_immutable, constant_identifier_names, deprecated_member_use, avoid_print, use_key_in_widget_constructors, unused_local_variable, equal_keys_in_map, library_private_types_in_public_api

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/add_contact_controller.dart';
import 'package:whoxachat/controller/get_contact_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// String baseUrl() {
//   return 'https://whoxachat.com/api/';
// }

String socketBaseUrl() {
  return 'http://${ApiHelper.baseUrlIp}:3000';
}

String isOnline = 'Online';
bool isForward = false;
bool isStarred = false;

/// Description: This file is used for declaring all global objects used in the Application.
///
/// @author Deval Joshi
///
List grpids = [];

class Person {
  String id, name, phone, dp;
  Person(
      {required this.id,
      required this.name,
      required this.phone,
      required this.dp});
}

String convertUTCTimeTo12HourFormat(String utcTimeString) {
  DateTime utcDate = DateTime.parse(utcTimeString);
  String formattedTime = DateFormat('h:mm a').format(utcDate.toLocal());
  return formattedTime;
}

bool isURL(String text) {
  return text.startsWith('http://') || text.startsWith('https://');
}

List<Person> persons = [];
GetAllDeviceContact getAllDeviceContact = Get.put(GetAllDeviceContact());
AddContactController addContactController = Get.put(AddContactController());

Color dynamiColor(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

Color chatownColor =
    dynamiColor(languageController.appSettingsData[0].appColorPrimary!);

Color secondaryColor =
    dynamiColor(languageController.appSettingsData[0].appColorSecondary!);

// List localcontname = [];

String appName = 'Chat App';
const Color backgroundblack = Color(0xFF414141);
const Color backgroundgrey = Color(0xFFf4f7f8);
const Color splashColor = Color(0xFF45bfec);
const Color appColorGreen = Color(0xFF1E3C72);
const Color appColorOrange = Color(0xffFFA97B);
const Color appColorBlack = Colors.black;
const Color appGreen = Color(0XFF1ea36d);
const Color appbarColor = Color(0XFFf5f1ec);
const Color iconColor = Color(0XFF9e7e5b);
const Color ratingBgColor = Color(0XFFffefe7);
const Color appColorWhite = Colors.white;
const Color appColorBlue = Color(0xFF00366D);
const Color appIconColor = Color(0xFF445E76);
// const Color appColorYellow = Color(0XFFE7B12D);
const Color appOrange = Color(0xffF56A1F);
// const Color chatownColor = Color(0xffFDC604);
// Color secondaryColor = const Color.fromRGBO(255, 249, 226, 1);
const Color gradient1 = Color(0XffFF6056);
const Color gradient2 = Color(0XffFF934E);
const Color bg = Color(0xffFFFFFF);
const Color blackcolor = Color(0xff123456);
const Color IndigoColor = Color(0xFF1A237E);
const Color WhiteColor = Color(0xFFFFFFFF);
const Color chatColor = Color(0xff000000);
const Color bg1 = Color(0xffEEEEEE);
const Color appgrey = Color(0xffD9D9D9);
const Color colorE04300 = Color(0xffE04300);
const Color color3CE000 = Color(0xff3CE000);
// const Color secondaryColor = Color(0xffFFEDAB);
const Color colorB0B0B0 = Color(0xffB0B0B0);
const Color appgrey2 = Color.fromARGB(255, 150, 150, 150);
const Color chatcolor2 = Color(0xFF393738);
// Color chatLogoColor = const Color.fromRGBO(252, 198, 4, 1);
Color chatYColor = const Color.fromRGBO(252, 198, 4, 0.43);
// Color secondaryColor = const Color.fromRGBO(255, 237, 171, 1);
// Color chatownColor = const Color.fromRGBO(252, 198, 4, 1);
// Color grey1Color = Colors.grey.shade200;
Color grey1Color = Colors.grey.shade200;
Color blurColor = const Color.fromRGBO(0, 0, 0, 0.56);
Color darkGreyColor = const Color.fromRGBO(58, 51, 51, 1);
Color linkColor = const Color.fromRGBO(2, 126, 181, 1);
Color blackColor = const Color.fromRGBO(158, 158, 158, 1);
Color black1Color = const Color.fromRGBO(27, 27, 27, 1);
List<String> likedPost = [];
List<String> likedComment = [];
var likedProduct = [];
var likedService = [];
// String chatid = " ";
String stripSecret = ' ';
String stripPublic = '';
String rozSecret = '';
String rozPublic = '';
String msgid = '';

class GlobalVariable {
  static final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();
}

closekeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

List<String> addedBookmarks = [];
String googleKEY = "AIzaSyDGFi8AlKgBoR8LrLA--Y836vfH4zwfiRU";
String onchat = "0";
String serverKey =
    'AAAAqh1Nstg:APA91bFxv6IjIge1pGr_2qAP9SIqUIpxZ8_0aYS998ZeBfjVux-Mg07cHAMvabyCf3AUiLXNcsLDQ7_4YdYBfRf2bljzOGWZ-ID03EKb3RWNaZNlaOK9zX7kZcngMsex6BwIqlQL9lNH';

// Client client = Client();

closeKeyboard() {
  return SystemChannels.textInput.invokeMethod('TextInput.hide');
}

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('h:mma');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0 && diff.inHours < 20) {
    time = format.format(date);
  } else if (diff.inHours >= 20 && diff.inDays < 7) {
    time = DateFormat('EEEE').format(date);
  } else {
    var format = DateFormat('dd/MM/yy');
    time = format.format(date);
  }

  return time;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

dynamic safeQueries(BuildContext context) {
  return (MediaQuery.of(context).size.height >= 812.0 ||
      MediaQuery.of(context).size.height == 812.0 ||
      (MediaQuery.of(context).size.height >= 812.0 &&
          MediaQuery.of(context).size.height <= 896.0 &&
          Platform.isIOS));
}

// Future<Duration?> getVideoDuration(String filePath) async {
//   final result = await FFmpegKit.execute('-i $filePath -hide_banner');
//   final output = await result.getOutput();
//   final regex = RegExp(r'Duration: (\d+):(\d+):(\d+)\.(\d+)');
//   final match = regex.firstMatch(output!);
//   if (match != null) {
//     final hours = int.parse(match.group(1)!);
//     final minutes = int.parse(match.group(2)!);
//     final seconds = int.parse(match.group(3)!);
//     final milliseconds = int.parse(match.group(4)!);
//     return Duration(
//       hours: hours,
//       minutes: minutes,
//       seconds: seconds,
//       milliseconds: milliseconds,
//     );
//   }
//   return null;
// }

Widget load() {
  return Center(
    child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appColorOrange)),
              )),
        )),
  );
}

// CHECK CONNECTIVITY
// Future<bool> checkInternet(BuildContext context) async {
//   try {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       return false;
//     } else {
//       return true;
//     }
//   } catch (e) {
//     return false;
//   }
// }

//SHOW LOADER

Widget customLoader(BuildContext context) {
  return Center(
    child: Container(
        alignment: Alignment.center,
        height: 40,
        width: 40,
        decoration:
            const BoxDecoration(color: gradient1, shape: BoxShape.circle),
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: appColorWhite,
            ),
          ),
        )),
  );
}

checkForNull(var data) {
  if (data != null && data != '' && data.toString().isNotEmpty) {
    return data;
  } else {
    return null;
  }
}

Widget onScrrenLoader(BuildContext context) {
  return Container(
    color: Colors.black45,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
              alignment: Alignment.center,
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: appColorWhite,
                ),
              )),
        ),
      ],
    ),
  );
}

String? extractFilename(String url) {
  String fullFilename = url.split('/').last;

  RegExp regExp = RegExp(r'\d+\.\w+$');
  RegExpMatch? match = regExp.firstMatch(fullFilename);
  if (match != null) {
    return match.group(0);
  } else {
    return fullFilename;
  }
}

Widget getUrlWidget(String url) {
  if (url.endsWith('.mp4')) {
    return FutureBuilder<Uint8List?>(
      future: getThumbnail(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.white,
            child: const Icon(
              Icons.image,
              size: 100,
            ),
          );
        }
      },
    );
  } else {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
    );
  }
}

Future<Uint8List?> getThumbnail(String videoUrl) async {
  final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.PNG,
      quality: 100,
      maxHeight: 100,
      maxWidth: 100);
  return thumbnail;
}

Future<void> launchURL(String url) async {
  try {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } on PlatformException catch (e) {
    print("Error launching URL: $e");
  } catch (e) {
    print("Unexpected error: $e");
  }
}

Widget timestpa(String messageseen, String timestamp, bool isstar) {
  return RichText(
      text: TextSpan(children: [
    isstar == false
        ? const WidgetSpan(child: SizedBox.shrink())
        : WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.asset("assets/images/starfill.png",
                color: secondaryColor, height: 8),
          ),
    const WidgetSpan(child: SizedBox(width: 5)),
    TextSpan(
      text: convertUTCTimeTo12HourFormat(timestamp),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  ]));
}

class CustomtextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplate;
  final Function(String)? onSubmitted;
  final dynamic controller;
  final int? maxLines;
  final dynamic onChange;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  CustomtextField({
    super.key,
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  _CustomtextFieldState createState() => _CustomtextFieldState();
}

class _CustomtextFieldState extends State<CustomtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: appColorWhite,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        errorStyle: const TextStyle(color: Colors.black),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        hintText: widget.hintText,
        focusColor: Colors.black,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

void loginerrorDialog(BuildContext context, String message, {bool? button}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 10.0),
            Text(message, textAlign: TextAlign.center),
            Container(height: 30.0),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width - 100,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

bool? checkEmailFormat(String? email) {
  bool? emailFormat;
  if (email != '') {
    emailFormat = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email!);
  }
  return emailFormat;
}

class Loader {
  void showIndicator(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.7),
              ),
              const Center(
                child: CircularProgressIndicator(
                  color: appColorWhite,
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  void hideIndicator(BuildContext context) {
    Navigator.pop(context);
  }
}

void bookDialog(BuildContext context, String message, {bool? button}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 10.0),
            Text(message, textAlign: TextAlign.center),
            Container(height: 30.0),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width - 100,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

Widget loader(BuildContext context) {
  return Center(
    child: Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appColorWhite,
          gradient: LinearGradient(
              colors: [chatownColor, secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: const Padding(
        padding: EdgeInsets.all(7.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appColorWhite),
          strokeWidth: 3,
        ),
      ),
    ),
  );
}

Widget ingenieriaTextfield(
    {Widget? prefixIcon,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    Function? onTap,
    TextEditingController? controller,
    int? maxLines,
    TextInputType? keyboardType}) {
  return TextField(
    controller: controller,
    onTap: () {},
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    keyboardType: keyboardType,
    onChanged: onChanged,
    style: const TextStyle(color: Colors.black, fontSize: 15),
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
      filled: true,
      contentPadding: const EdgeInsets.only(top: 30.0, left: 10.0),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(0),
      ),
      fillColor: Colors.transparent,
    ),
  );
}

class ReviewtextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplate;
  final Function()? onSubmitted;
  final dynamic controller;
  final int? maxLines;
  final dynamic onChange;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget? suffixIcon;

  final Widget? prefixIcon;
  ReviewtextField({
    super.key,
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  _ReviewtextFieldState createState() => _ReviewtextFieldState();
}

class _ReviewtextFieldState extends State<ReviewtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        errorStyle: const TextStyle(color: Colors.black),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: widget.hintText,
        labelStyle: const TextStyle(color: Color(0xFF106C6F)),
        hintStyle: const TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1.8),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CapitalizedText extends StatelessWidget {
  final String text;
  TextStyle? textStyle;

  CapitalizedText(this.text, this.textStyle, {super.key});

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    List<String> words = text.split(' ');

    List<String> capitalizedWords =
        words.map((word) => capitalize(word)).toList();

    String capitalizedText = capitalizedWords.join(' ');

    return Text(
      capitalizedText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}

String formatTimeAgo(String updatedAt) {
  // Parse the UTC time string
  DateTime updatedDate = DateTime.parse(updatedAt).toLocal();
  DateTime now = DateTime.now();

  // Calculate the difference between now and the updated time
  Duration diff = now.difference(updatedDate);

  // If less than 5 seconds, show 'Just now'
  if (diff.inSeconds < 5) {
    return 'Just now';
  }
  // If less than 60 seconds, show seconds ago
  else if (diff.inSeconds < 60) {
    return '${diff.inSeconds} seconds ago';
  }
  // If less than 60 minutes, show minutes ago
  else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
  }
  // If less than 24 hours, show hours ago
  else if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  }
  // If less than 7 days, show days ago
  else if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
  // If less than 30 days, show weeks ago
  else if (diff.inDays < 30) {
    int weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  }
  // If less than 365 days, show months ago
  else if (diff.inDays < 365) {
    int months = (diff.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  }
  // Otherwise show years ago
  else {
    int years = (diff.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}

// String formatLastSeen(String lastSeenString) {
//   DateTime lastSeen = DateTime.parse(lastSeenString).toLocal();

//   final now = DateTime.now();
//   final difference = now.difference(lastSeen);

//
//   String formattedTime = DateFormat("h:mm a").format(lastSeen);

//   if (difference.inDays >= 365) {
//     final years = (difference.inDays / 365).floor();
//     return 'Last seen $years ${years == 1 ? 'year' : 'years'} ago';
//   } else if (difference.inDays >= 30) {
//     final months = (difference.inDays / 30).floor();
//     return 'Last seen $months ${months == 1 ? 'month' : 'months'} ago';
//   } else if (difference.inDays >= 1) {
//     return 'Last seen ${difference.inDays == 1 ? 'yesterday at $formattedTime' : '${difference.inDays} days ago'}';
//   } else {
//     return 'Last seen today at $formattedTime';
//   }
// }

String formatLastSeen(String lastSeenString) {
  DateTime lastSeen = DateTime.parse(lastSeenString).toLocal();

  final now = DateTime.now();
  final difference = now.difference(lastSeen);

  String formattedTime = DateFormat("h:mm a").format(lastSeen);

  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return 'Last seen $years ${years == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return 'Last seen $months ${months == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays >= 1) {
    if (difference.inDays == 1) {
      return 'Last seen yesterday at $formattedTime';
    } else if (difference.inDays == 0) {
      return 'Last seen today, ${DateFormat("d MMMM y").format(lastSeen)}, $formattedTime';
    } else {
      return 'Last seen ${DateFormat("d MMM y").format(lastSeen)}';
    }
  } else {
    return 'Last seen today at $formattedTime';
  }
}

//=============================================================
// below function :today:- Format time as 4 : 54 PM
// below function :yesterday:- Format time as 4 : 54 PM
String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  bool isToday = dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  if (isToday) {
    return DateFormat.jm().format(dateTime.toLocal());
  } else {
    return DateFormat('d MMMM, h:mm a').format(dateTime.toLocal());
  }
}

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color placeholderColor;
  final Icon errorWidgeticon;

  const CustomCachedNetworkImage(
      {required this.imageUrl,
      this.size = 50.0,
      this.placeholderColor = Colors.grey,
      required this.errorWidgeticon});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: CircularProgressIndicator(
            color: placeholderColor,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: errorWidgeticon,
      ),
    );
  }
}

//================================================================= GET ALL CONTACT =========================================================
// List<Map<String, String>> mobileContacts = [];
//
// List<Contact> allcontacts = [];

// Future getContactsFromGloble() async {
//   var getContacts = [];

//   var contacts = (await FlutterContacts.getContacts(
//     withProperties: true,
//     withPhoto: true,
//   ))
//       .toList();

//   allcontacts = contacts.toList();

//
//
//
//
//
//
//   String cleanNumber(String number) {
//     return getMobile(number);
//   }

//   for (Contact c in allcontacts) {
//     if (c.phones.isNotEmpty) {
//
//       List<String> cleanedNumbers =
//           c.phones.map((e) => cleanNumber(e.number)).toList();
//       for (String number in cleanedNumbers) {
//
//         mobileContacts.add({'name': c.displayName, 'number': number});
//       }
//     }
//   }
// }

String formatCreateDate(String dateString) {
  DateTime date = DateTime.parse(dateString).toLocal();

  final now = DateTime.now();
  final difference = now.difference(date);

  String formattedTime = DateFormat("h:mm a").format(date);

  if (difference.inDays == 1) {
    return 'Yesterday at $formattedTime';
  } else if (difference.inDays == 0) {
    return 'Today at $formattedTime';
  } else {
    return DateFormat("d MMMM y").format(date);
  }
}

String formatDate(String dateString) {
  DateTime date = parseDate(dateString);
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Yesterday';
  } else if (now.difference(date).inDays < 6) {
    return DateFormat('EEEE').format(date);
  } else {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

String formatDateCallHistorry(String dateString) {
  DateTime date = parseDate(dateString);
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Yesterday';
  } else {
    return DateFormat('dd/MM/yy').format(date);
  }
}

DateTime parseDate(String dateString) {
  List<String> parts = dateString.split(' ');
  int day = int.parse(parts[0]);
  String monthName = parts[1];
  int year = int.parse(parts[2]);
  int month = DateFormat.MMM().parse(monthName).month;
  return DateTime(year, month, day);
}

//=========================================================
DateTime parsedate(String dateString) {
  return DateTime.parse(dateString);
}

String date(String dateString) {
  DateTime date = parseDate(dateString);
  return DateFormat('dd/MM/yyyy').format(date);
}

String dateFormate(String dateStr) {
  DateTime parsedDate = DateFormat("dd MMMM yyyy").parse(dateStr);

  return DateFormat("MMMM dd, yyyy").format(parsedDate);
}

String convertToLocalDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return "";
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd MMMM yyyy');
  return formatter.format(dateTime);
}

//   for (int i = 0; i < getContacts.length; i++) {
//     mobileContacts.add(getContacts[i]
//         .toString()
//         .trim()
//         .replaceAll(' ', '')
//         .replaceAll(' ', '')
//         .replaceAll('  ', '')
//         .replaceAll("(", "")
//         .replaceAll(")", "")
//         .replaceAll("+93", "")
//         .replaceAll("+358", "")
//         .replaceAll("+355", "")
//         .replaceAll("+213", "")
//         .replaceAll("+1", "")
//         .replaceAll("+376", "")
//         .replaceAll("+244", "")
//         .replaceAll("+1", "")
//         .replaceAll("+1", "")
//         .replaceAll("+54", "")
//         .replaceAll("+374", "")
//         .replaceAll("+297", "")
//         .replaceAll("+247", "")
//         .replaceAll("+61", "")
//         .replaceAll("+672", "")
//         .replaceAll("+43", "")
//         .replaceAll("+994", "")
//         .replaceAll("+1", "")
//         .replaceAll("+973", "")
//         .replaceAll("+880", "")
//         .replaceAll("+1", "")
//         .replaceAll("+375", "")
//         .replaceAll("+32", "")
//         .replaceAll("+501", "")
//         .replaceAll("+229", "")
//         .replaceAll("+93", "")
//         .replaceAll("+355", "")
//         .replaceAll("+213", "")
//         .replaceAll("+1-684", "")
//         .replaceAll("+376", "")
//         .replaceAll("+244", "")
//         .replaceAll("+1-264", "")
//         .replaceAll("+672", "")
//         .replaceAll("+1-268", "")
//         .replaceAll("+54", "")
//         .replaceAll("+374", "")
//         .replaceAll("+297", "")
//         .replaceAll("+61", "")
//         .replaceAll("+43", "")
//         .replaceAll("+994", "")
//         .replaceAll("+1-242", "")
//         .replaceAll("+973", "")
//         .replaceAll("+880", "")
//         .replaceAll("+1-246", "")
//         .replaceAll("+375", "")
//         .replaceAll("+32", "")
//         .replaceAll("+501", "")
//         .replaceAll("+229", "")
//         .replaceAll("+1-441", "")
//         .replaceAll("+975", "")
//         .replaceAll("+591", "")
//         .replaceAll("+387", "")
//         .replaceAll("+267", "")
//         .replaceAll("+55", "")
//         .replaceAll("+246", "")
//         .replaceAll("+1-284", "")
//         .replaceAll("+673", "")
//         .replaceAll("+359", "")
//         .replaceAll("+226", "")
//         .replaceAll("+257", "")
//         .replaceAll("+855", "")
//         .replaceAll("+237", "")
//         .replaceAll("+1", "")
//         .replaceAll("+238", "")
//         .replaceAll("+1-345", "")
//         .replaceAll("+236", "")
//         .replaceAll("+235", "")
//         .replaceAll("+56", "")
//         .replaceAll("+86", "")
//         .replaceAll("+61", "")
//         .replaceAll("+61", "")
//         .replaceAll("+57", "")
//         .replaceAll("+269", "")
//         .replaceAll("+682", "")
//         .replaceAll("+506", "")
//         .replaceAll("+385", "")
//         .replaceAll("+53", "")
//         .replaceAll("+599", "")
//         .replaceAll("+357", "")
//         .replaceAll("+420", "")
//         .replaceAll("+243", "")
//         .replaceAll("+45", "")
//         .replaceAll("+253", "")
//         .replaceAll("+1-767", "")
//         .replaceAll("+1-809", "")
//         .replaceAll("+1-829", "")
//         .replaceAll("+1-849", "")
//         .replaceAll("+670", "")
//         .replaceAll("+593", "")
//         .replaceAll("+20", "")
//         .replaceAll("+503", "")
//         .replaceAll("+240", "")
//         .replaceAll("+291", "")
//         .replaceAll("+372", "")
//         .replaceAll("+251", "")
//         .replaceAll("+500", "")
//         .replaceAll("+298", "")
//         .replaceAll("+679", "")
//         .replaceAll("+358", "")
//         .replaceAll("+33", "")
//         .replaceAll("+689", "")
//         .replaceAll("+241", "")
//         .replaceAll("+220", "")
//         .replaceAll("+995", "")
//         .replaceAll("+49", "")
//         .replaceAll("+233", "")
//         .replaceAll("+350", "")
//         .replaceAll("+30", "")
//         .replaceAll("+299", "")
//         .replaceAll("+1-473", "")
//         .replaceAll("+1-671", "")
//         .replaceAll("+502", "")
//         .replaceAll("+44-1481", "")
//         .replaceAll("+224", "")
//         .replaceAll("+245", "")
//         .replaceAll("+592", "")
//         .replaceAll("+509", "")
//         .replaceAll("+504", "")
//         .replaceAll("+852", "")
//         .replaceAll("+36", "")
//         .replaceAll("+354", "")
//         .replaceAll("+91", "")
//         .replaceAll("+62", "")
//         .replaceAll("+98", "")
//         .replaceAll("+964", "")
//         .replaceAll("+353", "")
//         .replaceAll("+44-1624", "")
//         .replaceAll("+972", "")
//         .replaceAll("+39", "")
//         .replaceAll("+225", "")
//         .replaceAll("+1-876", "")
//         .replaceAll("+81", "")
//         .replaceAll("+44-1534", "")
//         .replaceAll("+962", "")
//         .replaceAll("+7", "")
//         .replaceAll("+254", "")
//         .replaceAll("+686", "")
//         .replaceAll("+383", "")
//         .replaceAll("+965", "")
//         .replaceAll("+996", "")
//         .replaceAll("+856", "")
//         .replaceAll("+371", "")
//         .replaceAll("+961", "")
//         .replaceAll("+266", "")
//         .replaceAll("+231", "")
//         .replaceAll("+218", "")
//         .replaceAll("+423", "")
//         .replaceAll("+370", "")
//         .replaceAll("+352", "")
//         .replaceAll("+853", "")
//         .replaceAll("+389", "")
//         .replaceAll("+261", "")
//         .replaceAll("+265", "")
//         .replaceAll("+60", "")
//         .replaceAll("+960", "")
//         .replaceAll("+223", "")
//         .replaceAll("+356", "")
//         .replaceAll("+692", "")
//         .replaceAll("+222", "")
//         .replaceAll("+230", "")
//         .replaceAll("+262", "")
//         .replaceAll("+52", "")
//         .replaceAll("+691", "")
//         .replaceAll("+373", "")
//         .replaceAll("+377", "")
//         .replaceAll("+976", "")
//         .replaceAll("+382", "")
//         .replaceAll("+1-664", "")
//         .replaceAll("+212", "")
//         .replaceAll("+258", "")
//         .replaceAll("+95", "")
//         .replaceAll("+264", "")
//         .replaceAll("+674", "")
//         .replaceAll("+977", "")
//         .replaceAll("+31", "")
//         .replaceAll("+599", "")
//         .replaceAll("+687", "")
//         .replaceAll("+64", "")
//         .replaceAll("+505", "")
//         .replaceAll("+227", "")
//         .replaceAll("+234", "")
//         .replaceAll("+683", "")
//         .replaceAll("+850", "")
//         .replaceAll("+1-670", "")
//         .replaceAll("+47", "")
//         .replaceAll("+968", "")
//         .replaceAll("+92", "")
//         .replaceAll("+680", "")
//         .replaceAll("+970", "")
//         .replaceAll("+507", "")
//         .replaceAll("+675", "")
//         .replaceAll("+595", "")
//         .replaceAll("+51", "")
//         .replaceAll("+63", "")
//         .replaceAll("+64", "")
//         .replaceAll("+48", "")
//         .replaceAll("+351", "")
//         .replaceAll("+1-787", "")
//         .replaceAll("+1-939", "")
//         .replaceAll("+974", "")
//         .replaceAll("+242", "")
//         .replaceAll("+262", "")
//         .replaceAll("+40", "")
//         .replaceAll("+7", "")
//         .replaceAll("+250", "")
//         .replaceAll("+590", "")
//         .replaceAll("+290", "")
//         .replaceAll("+1-869", "")
//         .replaceAll("+1-758", "")
//         .replaceAll("+590", "")
//         .replaceAll("+508", "")
//         .replaceAll("+1-784", "")
//         .replaceAll("+685", "")
//         .replaceAll("+378", "")
//         .replaceAll("+239", "")
//         .replaceAll("+966", "")
//         .replaceAll("+221", "")
//         .replaceAll("+381", "")
//         .replaceAll("+248", "")
//         .replaceAll("+232", "")
//         .replaceAll("+65", "")
//         .replaceAll("+1-721", "")
//         .replaceAll("+421", "")
//         .replaceAll("+386", "")
//         .replaceAll("+677", "")
//         .replaceAll("+252", "")
//         .replaceAll("+27", "")
//         .replaceAll("+82", "")
//         .replaceAll("+211", "")
//         .replaceAll("+34", "")
//         .replaceAll("+94", "")
//         .replaceAll("+249", "")
//         .replaceAll("+597", "")
//         .replaceAll("+47", "")
//         .replaceAll("+268", "")
//         .replaceAll("+46", "")
//         .replaceAll("+41", "")
//         .replaceAll("+963", "")
//         .replaceAll("+886", "")
//         .replaceAll("+992", "")
//         .replaceAll("+255", "")
//         .replaceAll("+66", "")
//         .replaceAll("+228", "")
//         .replaceAll("+690", "")
//         .replaceAll("+676", "")
//         .replaceAll("+1-868", "")
//         .replaceAll("+216", "")
//         .replaceAll("+90", "")
//         .replaceAll("+993", "")
//         .replaceAll("+1-649", "")
//         .replaceAll("+688", "")
//         .replaceAll("+1-340", "")
//         .replaceAll("+256", "")
//         .replaceAll("+380", "")
//         .replaceAll("+971", "")
//         .replaceAll("+44", "")
//         .replaceAll("+1", "")
//         .replaceAll("+598", "")
//         .replaceAll("+998", "")
//         .replaceAll("+678", "")
//         .replaceAll("+379", "")
//         .replaceAll("+58", "")
//         .replaceAll("+84", "")
//         .replaceAll("+681", "")
//         .replaceAll("+212", "")
//         .replaceAll("+967", "")
//         .replaceAll("+260", "")
//         .replaceAll("+263", "")
//         .replaceAll("+92", "")
//         .replaceAll(RegExp(r'^0+(?=.)'), '')
//         .replaceFirst(RegExp(r'^0+'), '')
//         .replaceAll("-", "")
//         .replaceAll(" ", "")
//         .replaceAll(".", "")
//         .replaceAll('  ', "")
//         .replaceAll("+91", "")
//         .trim());
//   }

//   return mobileContacts;
// }

String getContactName(mobile) {
  if (mobile != null) {
    var name = mobile;
    for (var i = 0; i < addContactController.allcontacts.length; i++) {
      if (addContactController.allcontacts[i].phones
          .map((e) => e.number)
          .toString()
          .replaceAll(RegExp(r"\s+\b|\b\s"), "")
          .contains(mobile)) {
        name = addContactController.allcontacts[i].displayName;
      }
    }
    return name;
  } else {
    return mobile;
  }
}

String getMobile(String number) {
  return number
      .toString()
      .trim()
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .replaceAll('  ', '')
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll("+93", "")
      .replaceAll("+358", "")
      .replaceAll("+355", "")
      .replaceAll("+213", "")
      .replaceAll("+1", "")
      .replaceAll("+376", "")
      .replaceAll("+244", "")
      .replaceAll("+1", "")
      .replaceAll("+1", "")
      .replaceAll("+54", "")
      .replaceAll("+374", "")
      .replaceAll("+297", "")
      .replaceAll("+247", "")
      .replaceAll("+61", "")
      .replaceAll("+672", "")
      .replaceAll("+43", "")
      .replaceAll("+994", "")
      .replaceAll("+1", "")
      .replaceAll("+973", "")
      .replaceAll("+880", "")
      .replaceAll("+1", "")
      .replaceAll("+375", "")
      .replaceAll("+32", "")
      .replaceAll("+501", "")
      .replaceAll("+229", "")
      .replaceAll("+93", "")
      .replaceAll("+355", "")
      .replaceAll("+213", "")
      .replaceAll("+1-684", "")
      .replaceAll("+376", "")
      .replaceAll("+244", "")
      .replaceAll("+1-264", "")
      .replaceAll("+672", "")
      .replaceAll("+1-268", "")
      .replaceAll("+54", "")
      .replaceAll("+374", "")
      .replaceAll("+297", "")
      .replaceAll("+61", "")
      .replaceAll("+43", "")
      .replaceAll("+994", "")
      .replaceAll("+1-242", "")
      .replaceAll("+973", "")
      .replaceAll("+880", "")
      .replaceAll("+1-246", "")
      .replaceAll("+375", "")
      .replaceAll("+32", "")
      .replaceAll("+501", "")
      .replaceAll("+229", "")
      .replaceAll("+1-441", "")
      .replaceAll("+975", "")
      .replaceAll("+591", "")
      .replaceAll("+387", "")
      .replaceAll("+267", "")
      .replaceAll("+55", "")
      .replaceAll("+246", "")
      .replaceAll("+1-284", "")
      .replaceAll("+673", "")
      .replaceAll("+359", "")
      .replaceAll("+226", "")
      .replaceAll("+257", "")
      .replaceAll("+855", "")
      .replaceAll("+237", "")
      .replaceAll("+1", "")
      .replaceAll("+238", "")
      .replaceAll("+1-345", "")
      .replaceAll("+236", "")
      .replaceAll("+235", "")
      .replaceAll("+56", "")
      .replaceAll("+86", "")
      .replaceAll("+61", "")
      .replaceAll("+61", "")
      .replaceAll("+57", "")
      .replaceAll("+269", "")
      .replaceAll("+682", "")
      .replaceAll("+506", "")
      .replaceAll("+385", "")
      .replaceAll("+53", "")
      .replaceAll("+599", "")
      .replaceAll("+357", "")
      .replaceAll("+420", "")
      .replaceAll("+243", "")
      .replaceAll("+45", "")
      .replaceAll("+253", "")
      .replaceAll("+1-767", "")
      .replaceAll("+1-809", "")
      .replaceAll("+1-829", "")
      .replaceAll("+1-849", "")
      .replaceAll("+670", "")
      .replaceAll("+593", "")
      .replaceAll("+20", "")
      .replaceAll("+503", "")
      .replaceAll("+240", "")
      .replaceAll("+291", "")
      .replaceAll("+372", "")
      .replaceAll("+251", "")
      .replaceAll("+500", "")
      .replaceAll("+298", "")
      .replaceAll("+679", "")
      .replaceAll("+358", "")
      .replaceAll("+33", "")
      .replaceAll("+689", "")
      .replaceAll("+241", "")
      .replaceAll("+220", "")
      .replaceAll("+995", "")
      .replaceAll("+49", "")
      .replaceAll("+233", "")
      .replaceAll("+350", "")
      .replaceAll("+30", "")
      .replaceAll("+299", "")
      .replaceAll("+1-473", "")
      .replaceAll("+1-671", "")
      .replaceAll("+502", "")
      .replaceAll("+44-1481", "")
      .replaceAll("+224", "")
      .replaceAll("+245", "")
      .replaceAll("+592", "")
      .replaceAll("+509", "")
      .replaceAll("+504", "")
      .replaceAll("+852", "")
      .replaceAll("+36", "")
      .replaceAll("+354", "")
      .replaceAll("+91", "")
      .replaceAll("+62", "")
      .replaceAll("+98", "")
      .replaceAll("+964", "")
      .replaceAll("+353", "")
      .replaceAll("+44-1624", "")
      .replaceAll("+972", "")
      .replaceAll("+39", "")
      .replaceAll("+225", "")
      .replaceAll("+1-876", "")
      .replaceAll("+81", "")
      .replaceAll("+44-1534", "")
      .replaceAll("+962", "")
      .replaceAll("+7", "")
      .replaceAll("+254", "")
      .replaceAll("+686", "")
      .replaceAll("+383", "")
      .replaceAll("+965", "")
      .replaceAll("+996", "")
      .replaceAll("+856", "")
      .replaceAll("+371", "")
      .replaceAll("+961", "")
      .replaceAll("+266", "")
      .replaceAll("+231", "")
      .replaceAll("+218", "")
      .replaceAll("+423", "")
      .replaceAll("+370", "")
      .replaceAll("+352", "")
      .replaceAll("+853", "")
      .replaceAll("+389", "")
      .replaceAll("+261", "")
      .replaceAll("+265", "")
      .replaceAll("+60", "")
      .replaceAll("+960", "")
      .replaceAll("+223", "")
      .replaceAll("+356", "")
      .replaceAll("+692", "")
      .replaceAll("+222", "")
      .replaceAll("+230", "")
      .replaceAll("+262", "")
      .replaceAll("+52", "")
      .replaceAll("+691", "")
      .replaceAll("+373", "")
      .replaceAll("+377", "")
      .replaceAll("+976", "")
      .replaceAll("+382", "")
      .replaceAll("+1-664", "")
      .replaceAll("+212", "")
      .replaceAll("+258", "")
      .replaceAll("+95", "")
      .replaceAll("+264", "")
      .replaceAll("+674", "")
      .replaceAll("+977", "")
      .replaceAll("+31", "")
      .replaceAll("+599", "")
      .replaceAll("+687", "")
      .replaceAll("+64", "")
      .replaceAll("+505", "")
      .replaceAll("+227", "")
      .replaceAll("+234", "")
      .replaceAll("+683", "")
      .replaceAll("+850", "")
      .replaceAll("+1-670", "")
      .replaceAll("+47", "")
      .replaceAll("+968", "")
      .replaceAll("+92", "")
      .replaceAll("+680", "")
      .replaceAll("+970", "")
      .replaceAll("+507", "")
      .replaceAll("+675", "")
      .replaceAll("+595", "")
      .replaceAll("+51", "")
      .replaceAll("+63", "")
      .replaceAll("+64", "")
      .replaceAll("+48", "")
      .replaceAll("+351", "")
      .replaceAll("+1-787", "")
      .replaceAll("+1-939", "")
      .replaceAll("+974", "")
      .replaceAll("+242", "")
      .replaceAll("+262", "")
      .replaceAll("+40", "")
      .replaceAll("+7", "")
      .replaceAll("+250", "")
      .replaceAll("+590", "")
      .replaceAll("+290", "")
      .replaceAll("+1-869", "")
      .replaceAll("+1-758", "")
      .replaceAll("+590", "")
      .replaceAll("+508", "")
      .replaceAll("+1-784", "")
      .replaceAll("+685", "")
      .replaceAll("+378", "")
      .replaceAll("+239", "")
      .replaceAll("+966", "")
      .replaceAll("+221", "")
      .replaceAll("+381", "")
      .replaceAll("+248", "")
      .replaceAll("+232", "")
      .replaceAll("+65", "")
      .replaceAll("+1-721", "")
      .replaceAll("+421", "")
      .replaceAll("+386", "")
      .replaceAll("+677", "")
      .replaceAll("+252", "")
      .replaceAll("+27", "")
      .replaceAll("+82", "")
      .replaceAll("+211", "")
      .replaceAll("+34", "")
      .replaceAll("+94", "")
      .replaceAll("+249", "")
      .replaceAll("+597", "")
      .replaceAll("+47", "")
      .replaceAll("+268", "")
      .replaceAll("+46", "")
      .replaceAll("+41", "")
      .replaceAll("+963", "")
      .replaceAll("+886", "")
      .replaceAll("+992", "")
      .replaceAll("+255", "")
      .replaceAll("+66", "")
      .replaceAll("+228", "")
      .replaceAll("+690", "")
      .replaceAll("+676", "")
      .replaceAll("+1-868", "")
      .replaceAll("+216", "")
      .replaceAll("+90", "")
      .replaceAll("+993", "")
      .replaceAll("+1-649", "")
      .replaceAll("+688", "")
      .replaceAll("+1-340", "")
      .replaceAll("+256", "")
      .replaceAll("+380", "")
      .replaceAll("+971", "")
      .replaceAll("+44", "")
      .replaceAll("+1", "")
      .replaceAll("+598", "")
      .replaceAll("+998", "")
      .replaceAll("+678", "")
      .replaceAll("+379", "")
      .replaceAll("+58", "")
      .replaceAll("+84", "")
      .replaceAll("+681", "")
      .replaceAll("+212", "")
      .replaceAll("+967", "")
      .replaceAll("+260", "")
      .replaceAll("+263", "")
      .replaceAll("+92", "")
      .replaceAll(RegExp(r'^0+(?=.)'), '')
      .replaceFirst(RegExp(r'^0+'), '')
      .replaceAll("-", "")
      .replaceAll(" ", "")
      .replaceAll(".", "")
      .replaceAll('  ', "")
      .replaceAll("+91", "")
      .trim();
}

String getContact1(mobile, name1) {
  if (mobile != null) {
    var name = mobile;
    bool found = false;
    for (var i = 0; i < addContactController.allcontacts.length; i++) {
      if (addContactController.allcontacts[i].phones
          .map((e) => e.number)
          .toString()
          .replaceAll(RegExp(r"\s+\b|\b\s"), "")
          .contains(mobile)) {
        name = addContactController.allcontacts[i].displayName;
        found = true;
        break;
      }
    }
    if (!found) {
      return name1;
    }
    return name;
  } else {
    return mobile;
  }
}

String addPublicToUrl(String url) {
  Uri uri = Uri.parse(url);

  Uri newUri = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.port,
    path: '/public${uri.path}',
  );

  return newUri.toString();
}

void showCustomToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 13.0);
}

final Map<String, int> countryMobileLengths = {
  '+91': 10,
  '+93': 9,
  '+355': 9,
  '+213': 9,
  '+376': 6,
  '+244': 9,
  '+54': 10,
  '+374': 8,
  '+61': 9,
  '+43': 10,
  '+994': 9,
  '+973': 8,
  '+880': 10,
  '+375': 9,
  '+32': 9,
  '+501': 7,
  '+229': 8,
  '+975': 8,
  '+591': 8,
  '+387': 8,
  '+267': 8,
  '+55': 11,
  '+673': 7,
  '+359': 9,
  '+226': 8,
  '+257': 8,
  '+855': 9,
  '+237': 9,
  '+1': 10,
  '+238': 7,
  '+236': 8,
  '+235': 8,
  '+56': 9,
  '+86': 11,
  '+57': 10,
  '+269': 7,
  '+242': 9,
  '+243': 9,
  '+682': 5,
  '+506': 8,
  '+225': 10,
  '+385': 9,
  '+53': 8,
  '+357': 8,
  '+420': 9,
  '+45': 8,
  '+253': 8,
  '+670': 8,
  '+593': 9,
  '+20': 10,
  '+503': 8,
  '+240': 9,
  '+291': 7,
  '+372': 7,
  '+268': 8,
  '+251': 9,
  '+679': 7,
  '+358': 10,
  '+33': 9,
  '+241': 7,
  '+220': 7,
  '+995': 9,
  '+49': 11,
  '+233': 9,
  '+30': 10,
  '+299': 6,
  '+502': 8,
  '+224': 9,
  '+245': 7,
  '+592': 7,
  '+509': 8,
  '+504': 8,
  '+852': 8,
  '+36': 9,
  '+354': 7,
  '+62': 11,
  '+98': 10,
  '+964': 10,
  '+353': 9,
  '+972': 10,
  '+39': 10,
  '+81': 10,
  '+962': 9,
  '+7': 10,
  '+254': 10,
  '+686': 8,
  '+965': 8,
  '+996': 9,
  '+856': 9,
  '+371': 8,
  '+961': 8,
  '+266': 8,
  '+231': 7,
  '+218': 9,
  '+423': 7,
  '+370': 8,
  '+352': 9,
  '+853': 8,
  '+261': 9,
  '+265': 9,
  '+60': 10,
  '+960': 7,
  '+223': 8,
  '+356': 8,
  '+692': 7,
  '+222': 8,
  '+230': 8,
  '+52': 10,
  '+691': 7,
  '+373': 8,
  '+377': 8,
  '+976': 8,
  '+382': 9,
  '+212': 9,
  '+258': 9,
  '+264': 9,
  '+674': 7,
  '+977': 10,
  '+31': 9,
  '+687': 6,
  '+64': 9,
  '+505': 8,
  '+227': 8,
  '+234': 10,
  '+47': 8,
  '+968': 8,
  '+92': 10,
  '+680': 7,
  '+507': 8,
  '+675': 9,
  '+595': 9,
  '+51': 9,
  '+63': 10,
  '+48': 9,
  '+351': 9,
  '+974': 8,
  '+40': 10,
  '+7': 10,
  '+250': 9,
  '+685': 7,
  '+378': 10,
  '+239': 7,
  '+966': 9,
  '+221': 9,
  '+381': 9,
  '+248': 7,
  '+232': 8,
  '+65': 8,
  '+421': 9,
  '+386': 9,
  '+677': 7,
  '+252': 8,
  '+27': 9,
  '+82': 10,
  '+211': 9,
  '+34': 9,
  '+94': 9,
  '+249': 9,
  '+597': 7,
  '+268': 8,
  '+46': 9,
  '+41': 9,
  '+963': 9,
  '+886': 9,
  '+992': 9,
  '+255': 9,
  '+66': 9,
  '+228': 8,
  '+676': 7,
  '+216': 8,
  '+90': 10,
  '+993': 8,
  '+688': 6,
  '+256': 9,
  '+380': 9,
  '+971': 9,
  '+44': 10,
  '+1': 10,
  '+598': 9,
  '+998': 9,
  '+678': 7,
  '+379': 9,
  '+58': 10,
  '+84': 9,
  '+967': 9,
  '+260': 9,
  '+263': 9,
};

class CustomButtom extends StatelessWidget {
  final String? title;
  final Function()? onPressed;
  const CustomButtom({
    super.key,
    this.title,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.all(0.0),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: [
              secondaryColor,
              chatownColor,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 370.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                )),
          ),
        ),
      ),
    );
  }
}

Widget messageSelector({
  required Function() onTap,
  required List chatID,
  required int messageid,
}) {
  return InkWell(
      onTap: onTap,
      child: chatID.isEmpty
          ? const SizedBox()
          : Transform.scale(
              scale: 1.1,
              child: Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: chatID.contains(messageid.toString())
                              ? Colors.transparent
                              : black1Color),
                      color: chatID.contains(messageid.toString()) ? bg1 : bg1,
                      gradient: chatID.contains(messageid.toString())
                          ? LinearGradient(
                              colors: [blackColor, black1Color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter)
                          : null),
                  child: chatID.contains(messageid.toString())
                      ? Image.asset("assets/images/right.png").paddingAll(4)
                      : const SizedBox(
                          height: 10,
                        ))));
}

// Widget containerProfileDesign(
//     {required Function() onTap,
//     required String image,
//     required String title,
//     String? about}) {
//   return InkWell(
//     onTap: onTap,
//     child: Container(
//       height: 48,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade200)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Image.asset(image, height: 16),
//               const SizedBox(width: 10),
//               Container(
//                 constraints: BoxConstraints(maxWidth: Get.width * 0.6),
//                 child: Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w400),
//                 ),
//               )
//             ],
//           ),
//           Row(
//             children: [
//               Container(
//                 constraints: BoxConstraints(maxWidth: Get.width * 0.15),
//                 child: Text(
//                   about!,
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios, size: 16),
//             ],
//           )
//         ],
//       ).paddingSymmetric(horizontal: 10),
//     ),
//   );
// }

Widget containerProfileDesign({
  required Function() onTap,
  required String image,
  required String title,
  String? about,
  bool disabled =
      false, // This now controls only visual appearance, not functionality
  Color? aboutTextColor, // For custom about text color
}) {
  return InkWell(
    onTap: onTap, // Always allow tapping - functionality handled in callback
    child: Container(
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: disabled
              ? Colors.grey.shade100
              : Colors.white, // Visual styling for disabled state
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                image,
                height: 16,
                color: disabled
                    ? Colors.grey.shade400
                    : null, // Dim the image when disabled
              ),
              const SizedBox(width: 10),
              Container(
                constraints: BoxConstraints(maxWidth: Get.width * 0.6),
                child: title ==
                        languageController.textTranslate('Request Verification')
                    ? ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: disabled
                              ? [Colors.grey.shade400, Colors.grey.shade400]
                              : // Use grey gradient when disabled
                              [
                                  secondaryColor,
                                  chatownColor,
                                ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ).createShader(bounds),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Colors
                                .white, // For the gradient to show properly
                          ),
                        ),
                      )
                    : Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: disabled
                              ? Colors.grey.shade400
                              : null, // Grey text when disabled
                        ),
                      ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: Get.width * 0.23),
                child: Text(
                  about ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    // Use custom color if provided, otherwise use default disabled/normal color
                    color: aboutTextColor ??
                        (disabled ? Colors.grey.shade300 : Colors.grey),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: disabled
                    ? Colors.grey.shade300
                    : null, // Grey icon when disabled
              ),
            ],
          )
        ],
      ).paddingSymmetric(horizontal: 10),
    ),
  );
}

Widget containerWidget({required Function() onTap, required String title}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 30,
      width: 65,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13), color: secondaryColor),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: appColorWhite),
        ),
      ),
    ),
  );
}

String pawanTOKEN =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJwaG9uZV9udW1iZXIiOiI3NDMzMDcyMzUxIiwiZGV2aWNlX3Rva2VuIjoiIiwidXNlcl9uYW1lIjoiIiwiYmlvIjoiIiwiZG9iIjoiIiwic3RhdHVzIjowLCJjb3VudHJ5X2NvZGUiOiIrOTEiLCJwYXNzd29yZCI6IiIsIm90cCI6MTYwOTA2LCJnZW5kZXIiOiIiLCJwcm9maWxlX2ltYWdlIjoiIiwiY3JlYXRlZEF0IjoiMjAyNC0wNi0wN1QxMDoxMjowOS4wMDBaIiwidXBkYXRlZEF0IjoiMjAyNC0wNi0wN1QxMDoxMjowOS4wMDBaIiwiaWF0IjoxNzE3NzU1MzI1fQ.bSCZoiGyn39Lp-lSLEefNYrV8H5VEG_Tu7QwPlibftA";

class SelectedContact {
  final int userId;
  final String userName;
  final String profileImage;

  SelectedContact({
    required this.userId,
    required this.userName,
    required this.profileImage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedContact &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          userName == other.userName &&
          profileImage == other.profileImage;

  @override
  int get hashCode =>
      userId.hashCode ^ userName.hashCode ^ profileImage.hashCode;
}

int pageCount = 0;

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
            color: appColorWhite,
            height: 15,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: appColorWhite),
          )
        ],
      ),
    ),
  );
}

Widget checkContainer() {
  return Container(
      width: 12.0,
      height: 12.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: bg1,
          gradient: LinearGradient(
              colors: [blackColor, black1Color],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter)),
      child: Image.asset("assets/images/right.png").paddingAll(3));
}

Widget removeCheckContainer() {
  return Container(
    width: 12.0,
    height: 12.0,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: black1Color),
        color: bg1),
  );
}

RichText richText(
    {required String imageFile, required String fName, required String lName}) {
  return RichText(
      text: TextSpan(children: [
    WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: imageFile,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                  color: chatownColor,
                )),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  color: Color(0xffBFBFBF),
                ),
              )),
        )),
    TextSpan(
        text: capitalizeFirstLetter(" $fName " "$lName"),
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black))
  ]));
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = Get.height;
  // 896 is the layout height that designer use
  return (inputHeight / 844.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = Get.width;
  // 414 is the layout width that designer use
  return (inputWidth / 390.0) * screenWidth;
}

sizeBoxHeight(double value) {
  return SizedBox(
    height: getProportionateScreenHeight(value),
  );
}

sizeBoxWidth(double value) {
  return SizedBox(
    width: getProportionateScreenWidth(value),
  );
}

bool isOnlyEmoji(String? text) {
  if (text == null || text.isEmpty) return false;

  // Trim the text to handle any whitespace
  final trimmedText = text.trim();

  // Use a simpler approach based on character properties
  // Emojis typically have specific code point ranges
  // Regular text characters are typically in the ASCII range (< 128)

  // Check if the string is short (most emoji-only messages are 1-5 characters)
  if (trimmedText.length > 8) return false;

  // Count characters that are likely emojis
  int emojiCount = 0;

  for (int i = 0; i < trimmedText.length; i++) {
    int codeUnit = trimmedText.codeUnitAt(i);

    // Most emojis use surrogate pairs or are in specific ranges
    // If code unit is a high surrogate (part of emoji surrogate pair)
    // or in ranges commonly used for emojis/symbols
    if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
      // Skip surrogate pair (emoji)
      i++;
      emojiCount++;
    }
    // Check for other common emoji/symbol ranges
    else if (codeUnit >= 0x2000 && codeUnit <= 0x3300) {
      emojiCount++;
    } else if (codeUnit >= 0x1F000 && codeUnit <= 0x1FFFF) {
      emojiCount++;
    }
    // If we find a common ASCII character, it's probably not an emoji-only message
    else if (codeUnit < 128 &&
        !RegExp(r'[\s,.!?]').hasMatch(String.fromCharCode(codeUnit))) {
      return false;
    }
  }

  // Consider it an emoji-only message if we found at least one emoji
  // and didn't return false from finding regular text characters
  return emojiCount > 0;
}

Widget getProfileUpperField() {
  return SizedBox(
    height: Get.height * 0.30,
    width: double.infinity,
    child: Stack(
      children: [
        Image.asset(
          'assets/cover/mask_group.png',
          fit: BoxFit.cover,
          color: chatownColor,
          height: Get.height * 0.27,
          // color: Color(0xffBC1717),
          // height: MediaQuery.sizeOf(context).height * 0.33,
          width: Get.width,
        ),
        Image.asset(
          // 'assets/bleep icon/handmade_art.png',
          // 'assets/bleep icon/overlay_art.png',
          // 'assets/bleep icon/new_overlay_art.png',
          'assets/cover/overlay_new_one.png',
          height: Get.height * 0.27,
          fit: BoxFit.cover,
          width: Get.width,
        ),
      ],
    ),
    //  Image.asset(
    //   cacheHeight: 140,
    //   // "assets/images/back_img1.png",
    //   'assets/images/back_img1 (1).png',
    //   fit: BoxFit.cover,
    // ),
  );
}
