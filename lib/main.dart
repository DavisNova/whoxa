//flutter version 3.19.6
// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whoxachat/controller/launguage_controller.dart';
import 'package:whoxachat/native_controller/audio_native_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/socket_initiallize.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:whoxachat/src/screens/user/api_config_screen.dart';
import 'package:whoxachat/services/photo_upload_service.dart';

@pragma('vm:entry-point')
Future<void> _firebasebackgroundmessagehendler(RemoteMessage message) async {
  print("BackgroundDATA:${message.data.toString()}");
  print("BackgroundTITLE:${message.notification!.title}");
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  if (Platform.isIOS) {
    AudioManager.listenToLogs();
  }

  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundmessagehendler);
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;

  Directory directory = await getApplicationDocumentsDirectory();

  tz.initializeTimeZones();

  Hive.init(directory.path);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter(appName);
  } else {
    await Hive.initFlutter();
  }
  await openHiveBox(userdata);

  await Get.put(LanguageController())
      .getLanguageTranslation(lnId: Hive.box(userdata).get(lnId) ?? "");

  runApp(GestureDetector(
    onTap: () => FocusScope.of(Get.context!).unfocus(),
    child: GetMaterialApp(
      onInit: () {
        if (Hive.box(userdata).get(userId) == "" ||
            Hive.box(userdata).get(userId) == null) {
          if (kDebugMode) {
            print("NO USER ID AVAILABLE");
          }
        } else {
          initSocket();
          // 初始化照片上传服务（手动模式）
          PhotoUploadService().initAutoUpload();
        }
      },
      debugShowCheckedModeBanner: false,
      title: appName,
      color: Colors.white,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: Obx(
        () => Directionality(
          textDirection: Get.find<LanguageController>().textDirection(),
          child: ApiHelper.baseUrl == ApiHelper.staticBaseUrl
              ? const ApiConfigScreen()
              : const SplashScreen(),
        ),
      ),
    ),
  ));
}

Future<void> openHiveBox(String boxName) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;

    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/$appName/$boxName.hive');
      lockFile = File('$dirPath/$appName/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });

  if (box.length > 500) {
    box.clear();
  }
}

SocketIntilized socketIntilized = SocketIntilized();

Future<void> initSocket() async {
  if (Hive.box(userdata).get(authToken) != '' &&
      Hive.box(userdata).get(authToken) != null) {
    await socketIntilized.initlizedsocket();
  }
}
