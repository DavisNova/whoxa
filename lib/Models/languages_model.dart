class LanguagesModel {
  bool? success;
  String? message;
  List<Languages>? languages;

  LanguagesModel({this.success, this.message, this.languages});

  LanguagesModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    languages = json["languages"] == null
        ? null
        : (json["languages"] as List)
            .map((e) => Languages.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["success"] = success;
    data["message"] = message;
    if (languages != null) {
      data["languages"] = languages?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Languages {
  String? language;
  bool? status;
  bool? defaultStatus;
  int? statusId;
  String? country;

  Languages(
      {this.language,
      this.status,
      this.defaultStatus,
      this.statusId,
      this.country});

  Languages.fromJson(Map<String, dynamic> json) {
    language = json["language"];
    status = json["status"];
    defaultStatus = json["default_status"];
    statusId = json["status_id"];
    country = json["country"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["language"] = language;
    data["status"] = status;
    data["default_status"] = defaultStatus;
    data["status_id"] = statusId;
    data["country"] = country;
    return data;
  }
}
