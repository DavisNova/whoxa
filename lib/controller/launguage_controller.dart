import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/Models/app_settings_model.dart';
import 'package:whoxachat/Models/language_translatioins_model.dart';
import 'package:whoxachat/Models/languages_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';

class LanguageController extends GetxController {
  ApiHelper apiHelper = ApiHelper();

  RxBool isLanguagLoading = false.obs;
  RxBool isGetLanguagsLoading = false.obs;
  RxBool isAppSettingsLoading = false.obs;

  @override
  void onInit() {
    getAppSettings();
    getLanguageTranslation();
    getLanguages();
    super.onInit();
  }

  Rx<LanguageTranslationModel> languageTranslationsData =
      LanguageTranslationModel().obs;

  RxList<Languages> languagesData = <Languages>[].obs;
  RxList<Settings> appSettingsData = <Settings>[].obs;
  RxList<SettingsOnesignal> appSettingsOneSignalData =
      <SettingsOnesignal>[].obs;

  getLanguageTranslation({String lnId = ""}) async {
    try {
      isLanguagLoading.value = true;

      final responseJson = await apiHelper.postMethod(
        url: apiHelper.defaultLanguage,
        requestBody: lnId.isEmpty
            ? {}
            : {
                'status_id': lnId,
              },
      );

      if (responseJson["success"] == true) {
        languageTranslationsData.value =
            LanguageTranslationModel.fromJson(responseJson);
      }

      isLanguagLoading.value = false;
    } catch (e) {
      isLanguagLoading.value = false;

      debugPrint('get language Translations failed : $e');
    }
  }

  getLanguages() async {
    try {
      isGetLanguagsLoading.value = true;

      final responseJson = await apiHelper.postMethod(
        url: apiHelper.listOfLanguages,
        requestBody: {},
      );

      if (responseJson["success"] == true) {
        languagesData.value = LanguagesModel.fromJson(responseJson)
            .languages!
            .where((element) => element.status == true)
            .toList();

        debugPrint("languagesData length ${languagesData.length}");
      }

      isGetLanguagsLoading.value = false;
    } catch (e) {
      isGetLanguagsLoading.value = false;

      debugPrint('get languages failed : $e');
    }
  }

  String textTranslate(String text) {
    return languageTranslationsData.value.results == null ||
            languageTranslationsData.value.results!.isEmpty
        ? text
        : languageTranslationsData.value.results!
                .where((element) => element.key == text)
                .isEmpty
            ? text
            : languageTranslationsData.value.results!
                        .where((element) => element.key == text)
                        .first
                        .translation ==
                    null
                ? text
                : languageTranslationsData.value.results!
                    .where((element) => element.key == text)
                    .first
                    .translation!;
  }

  TextDirection textDirection() {
    return languageTranslationsData.value.languageAlignment == null ||
            languageTranslationsData.value.languageAlignment!.isEmpty
        ? TextDirection.ltr
        : languageTranslationsData.value.languageAlignment == "ltr"
            ? TextDirection.ltr
            : TextDirection.rtl;
  }

  getAppSettings() async {
    try {
      isAppSettingsLoading.value = true;

      final responseJson = await apiHelper.postMethod(
        url: apiHelper.getAppSettings,
        requestBody: {},
      );

      if (responseJson["success"] == true) {
        appSettingsData.value =
            AppSettingsModel.fromJson(responseJson).settings!;
        appSettingsOneSignalData.value =
            AppSettingsModel.fromJson(responseJson).settingsOnesignal!;
      }

      isAppSettingsLoading.value = false;
    } catch (e) {
      isAppSettingsLoading.value = false;

      debugPrint('get App settings failed : $e');
    }
  }
}
