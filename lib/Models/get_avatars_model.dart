class AvatarsModel {
  bool? success;
  String? message;
  List<Avtars>? avtars;
  Pagination? pagination;

  AvatarsModel({this.success, this.message, this.avtars, this.pagination});

  AvatarsModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    avtars = json["avatars"] == null
        ? null
        : (json["avatars"] as List).map((e) => Avtars.fromJson(e)).toList();
    pagination = json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["success"] = success;
    data["message"] = message;
    if (avtars != null) {
      data["avatars"] = avtars?.map((e) => e.toJson()).toList();
    }
    if (pagination != null) {
      data["pagination"] = pagination?.toJson();
    }
    return data;
  }
}

class Pagination {
  int? count;
  int? currentPage;
  int? totalPages;

  Pagination({this.count, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    count = json["count"];
    currentPage = json["currentPage"];
    totalPages = json["totalPages"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["count"] = count;
    data["currentPage"] = currentPage;
    data["totalPages"] = totalPages;
    return data;
  }
}

class Avtars {
  String? avtarMedia;
  int? avatarId;
  String? avatarName;
  String? avatarGender;
  bool? status;
  bool? defaultAvtar;
  String? createdAt;
  String? updatedAt;

  Avtars(
      {this.avtarMedia,
      this.avatarId,
      this.avatarName,
      this.avatarGender,
      this.status,
      this.defaultAvtar,
      this.createdAt,
      this.updatedAt});

  Avtars.fromJson(Map<String, dynamic> json) {
    avtarMedia = json["avtar_Media"];
    avatarId = json["avatar_id"];
    avatarName = json["avatar_name"];
    avatarGender = json["avatar_gender"];
    status = json["status"];
    defaultAvtar = json["default_avtar"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["avtar_Media"] = avtarMedia;
    data["avatar_id"] = avatarId;
    data["avatar_name"] = avatarName;
    data["avatar_gender"] = avatarGender;
    data["status"] = status;
    data["default_avtar"] = defaultAvtar;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    return data;
  }
}
