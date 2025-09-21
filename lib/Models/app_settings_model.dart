class AppSettingsModel {
  bool? success;
  String? message;
  List<Settings>? settings;
  List<SettingsOnesignal>? settingsOnesignal;

  AppSettingsModel(
      {this.success, this.message, this.settings, this.settingsOnesignal});

  AppSettingsModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    settings = json["settings"] == null
        ? null
        : (json["settings"] as List).map((e) => Settings.fromJson(e)).toList();
    settingsOnesignal = json["settings_OneSignal"] == null
        ? null
        : (json["settings_OneSignal"] as List)
            .map((e) => SettingsOnesignal.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["success"] = success;
    data["message"] = message;
    if (settings != null) {
      data["settings"] = settings?.map((e) => e.toJson()).toList();
    }
    if (settingsOnesignal != null) {
      data["settings_OneSignal"] =
          settingsOnesignal?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Settings {
  String? appLogo;
  int? settingId;
  String? appName;
  String? appEmail;
  String? appText;
  String? appColorPrimary;
  String? appColorSecondary;
  String? appLink;
  String? iosLink;
  String? androidLink;
  String? tellAFriendLink;
  bool? demoCredentials;
  bool? xenditPayMethod;
  bool? applePayMethod;
  String? createdAt;
  String? updatedAt;

  Settings(
      {this.appLogo,
      this.settingId,
      this.appName,
      this.appEmail,
      this.appText,
      this.appColorPrimary,
      this.appColorSecondary,
      this.appLink,
      this.iosLink,
      this.androidLink,
      this.tellAFriendLink,
      this.demoCredentials,
      this.xenditPayMethod,
      this.applePayMethod,
      this.createdAt,
      this.updatedAt});

  Settings.fromJson(Map<String, dynamic> json) {
    appLogo = json["app_logo"];
    settingId = json["setting_id"];
    appName = json["app_name"];
    appEmail = json["app_email"];
    appText = json["app_text"];
    appColorPrimary =
        json["app_color_secondary"]; // color is swap due to backend
    appColorSecondary =
        json["app_color_primary"]; // color is swap due to backend
    appLink = json["app_link"];
    iosLink = json["ios_link"];
    androidLink = json["android_link"];
    tellAFriendLink = json["tell_a_friend_link"];
    demoCredentials = json["demo_credentials"];
    xenditPayMethod = json["xendit_pay_method"];
    applePayMethod = json["apple_pay_method"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["app_logo"] = appLogo;
    data["setting_id"] = settingId;
    data["app_name"] = appName;
    data["app_email"] = appEmail;
    data["app_text"] = appText;
    data["app_color_secondary"] = appColorPrimary;
    data["app_color_primary"] = appColorSecondary;
    data["app_link"] = appLink;
    data["ios_link"] = iosLink;
    data["android_link"] = androidLink;
    data["tell_a_friend_link"] = tellAFriendLink;
    data["demo_credentials"] = demoCredentials;
    data["xendit_pay_method"] = xenditPayMethod;
    data["apple_pay_method"] = applePayMethod;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    return data;
  }
}

class SettingsOnesignal {
  int? settingId;
  String? oneSignalAppId;
  String? oneSignalApiKey;
  String? createdAt;
  String? updatedAt;

  SettingsOnesignal(
      {this.settingId,
      this.oneSignalAppId,
      this.oneSignalApiKey,
      this.createdAt,
      this.updatedAt});

  SettingsOnesignal.fromJson(Map<String, dynamic> json) {
    settingId = json["setting_id"];
    oneSignalAppId = json["ONESIGNAL_APPID"];
    oneSignalApiKey = json["ONESIGNAL_API_KEY"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["setting_id"] = settingId;
    data["ONESIGNAL_APPID"] = oneSignalAppId;
    data["ONESIGNAL_API_KEY"] = oneSignalApiKey;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    return data;
  }
}
