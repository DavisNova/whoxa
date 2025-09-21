// class StoryListData {
//   bool? success;
//   String? message;
//   List<StatusList>? statusList;
//   UserData? myStatus;

//   StoryListData({this.success, this.message, this.statusList, this.myStatus});

//   StoryListData.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     if (json['statusList'] != null) {
//       statusList = <StatusList>[];
//       json['statusList'].forEach((v) {
//         statusList!.add(StatusList.fromJson(v));
//       });
//     }
//     myStatus =
//         json['myStatus'] != null ? UserData.fromJson(json['myStatus']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = success;
//     data['message'] = message;
//     if (statusList != null) {
//       data['statusList'] = statusList!.map((v) => v.toJson()).toList();
//     }
//     if (myStatus != null) {
//       data['myStatus'] = myStatus!.toJson();
//     }
//     return data;
//   }
// }

// class StatusList {
//   String? fullName;
//   String? phoneNumber;
//   UserData? userData;

//   StatusList({this.fullName, this.phoneNumber, this.userData});

//   StatusList.fromJson(Map<String, dynamic> json) {
//     fullName = json['full_name'];
//     phoneNumber = json['phone_number'];
//     userData =
//         json['userData'] != null ? UserData.fromJson(json['userData']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['full_name'] = fullName;
//     data['phone_number'] = phoneNumber;
//     if (userData != null) {
//       data['userData'] = userData!.toJson();
//     }
//     return data;
//   }
// }

// class UserData {
//   String? profileImage;
//   int? userId;
//   List<Statuses>? statuses;

//   UserData({this.profileImage, this.userId, this.statuses});

//   UserData.fromJson(Map<String, dynamic> json) {
//     profileImage = json['profile_image'];
//     userId = json['user_id'];
//     if (json['Statuses'] != null) {
//       statuses = <Statuses>[];
//       json['Statuses'].forEach((v) {
//         statuses!.add(Statuses.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['profile_image'] = profileImage;
//     data['user_id'] = userId;
//     if (statuses != null) {
//       data['Statuses'] = statuses!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Statuses {
//   int? statusId;
//   String? statusText;
//   String? createdAt;
//   List<StatusMedia>? statusMedia;
//   List<StatusViews>? statusViews;

//   Statuses(
//       {this.statusId,
//       this.statusText,
//       this.createdAt,
//       this.statusMedia,
//       this.statusViews});

//   Statuses.fromJson(Map<String, dynamic> json) {
//     statusId = json['status_id'];
//     statusText = json['status_text'];
//     createdAt = json['createdAt'];
//     if (json['StatusMedia'] != null) {
//       statusMedia = <StatusMedia>[];
//       json['StatusMedia'].forEach((v) {
//         statusMedia!.add(StatusMedia.fromJson(v));
//       });
//     }
//     if (json['StatusViews'] != null) {
//       statusViews = <StatusViews>[];
//       json['StatusViews'].forEach((v) {
//         statusViews!.add(StatusViews.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status_id'] = statusId;
//     data['status_text'] = statusText;
//     data['createdAt'] = createdAt;
//     if (statusMedia != null) {
//       data['StatusMedia'] = statusMedia!.map((v) => v.toJson()).toList();
//     }
//     if (statusViews != null) {
//       data['StatusViews'] = statusViews!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class StatusMedia {
//   String? statusText;
//   String? url;
//   int? statusMediaId;

//   StatusMedia({this.statusText, this.url, this.statusMediaId});

//   StatusMedia.fromJson(Map<String, dynamic> json) {
//     statusText = json['status_text'];
//     url = json['url'];
//     statusMediaId = json['status_media_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status_text'] = statusText;
//     data['url'] = url;
//     data['status_media_id'] = statusMediaId;
//     return data;
//   }
// }

// class StatusViews {
//   int? statusCount;

//   StatusViews({this.statusCount});

//   StatusViews.fromJson(Map<String, dynamic> json) {
//     statusCount = json['status_count'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status_count'] = statusCount;
//     return data;
//   }
// }

class StoryListData {
  bool? success;
  String? message;
  List<ViewedStatusList>? viewedStatusList;
  List<NotViewedStatusList>? notViewedStatusList;
  MyStatus? myStatus;

  StoryListData(
      {this.success,
      this.message,
      this.viewedStatusList,
      this.notViewedStatusList,
      this.myStatus});

  StoryListData.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    viewedStatusList = json["viewedStatusList"] == null
        ? null
        : (json["viewedStatusList"] as List)
            .map((e) => ViewedStatusList.fromJson(e))
            .toList();
    notViewedStatusList = json["notViewedStatusList"] == null
        ? null
        : (json["notViewedStatusList"] as List)
            .map((e) => NotViewedStatusList.fromJson(e))
            .toList();
    myStatus =
        json["myStatus"] == null ? null : MyStatus.fromJson(json["myStatus"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["success"] = success;
    data["message"] = message;
    if (viewedStatusList != null) {
      data["viewedStatusList"] =
          viewedStatusList?.map((e) => e.toJson()).toList();
    }
    if (notViewedStatusList != null) {
      data["notViewedStatusList"] =
          notViewedStatusList?.map((e) => e.toJson()).toList();
    }
    if (myStatus != null) {
      data["myStatus"] = myStatus?.toJson();
    }
    return data;
  }
}

class MyStatus {
  String? profileImage;
  int? userId;
  List<Statuses2>? statuses;
  VerificationType? varificationType; // Add this field

  MyStatus({
    this.profileImage,
    this.userId,
    this.statuses,
    this.varificationType, // Add this field
  });

  MyStatus.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    statuses = json["Statuses"] == null
        ? null
        : (json["Statuses"] as List).map((e) => Statuses2.fromJson(e)).toList();
    varificationType = json["Varification_type"] == null
        ? null
        : VerificationType.fromJson(json["Varification_type"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    if (statuses != null) {
      data["Statuses"] = statuses?.map((e) => e.toJson()).toList();
    }
    if (varificationType != null) {
      data["Varification_type"] = varificationType?.toJson();
    }
    return data;
  }
}

class Statuses2 {
  int? statusId;
  String? updatedAt;
  List<StatusMedia2>? statusMedia;

  Statuses2({this.statusId, this.updatedAt, this.statusMedia});

  Statuses2.fromJson(Map<String, dynamic> json) {
    statusId = json["status_id"];
    updatedAt = json["updatedAt"];
    statusMedia = json["StatusMedia"] == null
        ? null
        : (json["StatusMedia"] as List)
            .map((e) => StatusMedia2.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_id"] = statusId;
    data["updatedAt"] = updatedAt;
    if (statusMedia != null) {
      data["StatusMedia"] = statusMedia?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class StatusMedia2 {
  String? statusText;
  String? url;
  int? statusMediaId;
  String? updatedAt;
  int? statusMediaViewCount;

  StatusMedia2({
    this.statusText,
    this.url,
    this.statusMediaId,
    this.updatedAt,
    this.statusMediaViewCount,
  });

  StatusMedia2.fromJson(Map<String, dynamic> json) {
    statusText = json["status_text"];
    url = json["url"]?.toString().isEmpty == true ? null : json["url"];
    statusMediaId = json["status_media_id"];
    updatedAt = json["updatedAt"];
    statusMediaViewCount = json["status_media_view_count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_text"] = statusText;
    data["url"] = url;
    data["status_media_id"] = statusMediaId;
    data["updatedAt"] = updatedAt;
    data["status_media_view_count"] = statusMediaViewCount;
    return data;
  }
}

class NotViewedStatusList {
  String? fullName;
  String? phoneNumber;
  UserData1? userData;

  NotViewedStatusList({this.fullName, this.phoneNumber, this.userData});

  NotViewedStatusList.fromJson(Map<String, dynamic> json) {
    fullName = json["full_name"];
    phoneNumber = json["phone_number"];
    userData =
        json["userData"] == null ? null : UserData1.fromJson(json["userData"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["full_name"] = fullName;
    data["phone_number"] = phoneNumber;
    if (userData != null) {
      data["userData"] = userData?.toJson();
    }
    return data;
  }
}

class UserData1 {
  String? profileImage;
  int? userId;
  List<Statuses1>? statuses;
  VerificationType? varificationType; // Add this field

  UserData1({
    this.profileImage,
    this.userId,
    this.statuses,
    this.varificationType, // Add this field
  });

  UserData1.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    statuses = json["Statuses"] == null
        ? null
        : (json["Statuses"] as List).map((e) => Statuses1.fromJson(e)).toList();
    varificationType = json["Varification_type"] == null
        ? null
        : VerificationType.fromJson(json["Varification_type"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    if (statuses != null) {
      data["Statuses"] = statuses?.map((e) => e.toJson()).toList();
    }
    if (varificationType != null) {
      data["Varification_type"] = varificationType?.toJson();
    }
    return data;
  }
}

class Statuses1 {
  int? statusId;
  String? updatedAt;
  List<StatusMedia1>? statusMedia;
  List<StatusViews1>? statusViews;

  Statuses1(
      {this.statusId, this.updatedAt, this.statusMedia, this.statusViews});

  Statuses1.fromJson(Map<String, dynamic> json) {
    statusId = json["status_id"];
    updatedAt = json["updatedAt"];
    statusMedia = json["StatusMedia"] == null
        ? null
        : (json["StatusMedia"] as List)
            .map((e) => StatusMedia1.fromJson(e))
            .toList();
    statusViews = json["StatusViews"] == null
        ? null
        : (json["StatusViews"] as List)
            .map((e) => StatusViews1.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_id"] = statusId;
    data["updatedAt"] = updatedAt;
    if (statusMedia != null) {
      data["StatusMedia"] = statusMedia?.map((e) => e.toJson()).toList();
    }
    if (statusViews != null) {
      data["StatusViews"] = statusViews?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class StatusViews1 {
  int? statusCount;

  StatusViews1({this.statusCount});

  StatusViews1.fromJson(Map<String, dynamic> json) {
    statusCount = json["status_count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_count"] = statusCount;
    return data;
  }
}

class StatusMedia1 {
  String? statusText;
  String? url;
  int? statusMediaId;
  String? updatedAt;

  StatusMedia1({this.statusText, this.url, this.statusMediaId, this.updatedAt});

  StatusMedia1.fromJson(Map<String, dynamic> json) {
    statusText = json["status_text"];
    url = json["url"]?.toString().isEmpty == true ? null : json["url"];
    statusMediaId = json["status_media_id"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_text"] = statusText;
    data["url"] = url;
    data["status_media_id"] = statusMediaId;
    data["updatedAt"] = updatedAt;
    return data;
  }
}

class ViewedStatusList {
  String? fullName;
  String? phoneNumber;
  UserData? userData;

  ViewedStatusList({this.fullName, this.phoneNumber, this.userData});

  ViewedStatusList.fromJson(Map<String, dynamic> json) {
    fullName = json["full_name"];
    phoneNumber = json["phone_number"];
    userData =
        json["userData"] == null ? null : UserData.fromJson(json["userData"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["full_name"] = fullName;
    data["phone_number"] = phoneNumber;
    if (userData != null) {
      data["userData"] = userData?.toJson();
    }
    return data;
  }
}

class UserData {
  String? profileImage;
  int? userId;
  List<Statuses>? statuses;
  VerificationType? varificationType; // Add this field

  UserData({
    this.profileImage,
    this.userId,
    this.statuses,
    this.varificationType, // Add this field
  });

  UserData.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    statuses = json["Statuses"] == null
        ? null
        : (json["Statuses"] as List).map((e) => Statuses.fromJson(e)).toList();
    varificationType = json["Varification_type"] == null
        ? null
        : VerificationType.fromJson(json["Varification_type"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    if (statuses != null) {
      data["Statuses"] = statuses?.map((e) => e.toJson()).toList();
    }
    if (varificationType != null) {
      data["Varification_type"] = varificationType?.toJson();
    }
    return data;
  }
}

class Statuses {
  int? statusId;
  String? updatedAt;
  List<StatusMedia>? statusMedia;
  List<StatusViews>? statusViews;

  Statuses({this.statusId, this.updatedAt, this.statusMedia, this.statusViews});

  Statuses.fromJson(Map<String, dynamic> json) {
    statusId = json["status_id"];
    updatedAt = json["updatedAt"];
    statusMedia = json["StatusMedia"] == null
        ? null
        : (json["StatusMedia"] as List)
            .map((e) => StatusMedia.fromJson(e))
            .toList();
    statusViews = json["StatusViews"] == null
        ? null
        : (json["StatusViews"] as List)
            .map((e) => StatusViews.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_id"] = statusId;
    data["updatedAt"] = updatedAt;
    if (statusMedia != null) {
      data["StatusMedia"] = statusMedia?.map((e) => e.toJson()).toList();
    }
    if (statusViews != null) {
      data["StatusViews"] = statusViews?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class StatusViews {
  int? statusCount;

  StatusViews({this.statusCount});

  StatusViews.fromJson(Map<String, dynamic> json) {
    statusCount = json["status_count"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_count"] = statusCount;
    return data;
  }
}

class StatusMedia {
  String? statusText;
  String? url;
  int? statusMediaId;
  String? updatedAt;

  StatusMedia({this.statusText, this.url, this.statusMediaId, this.updatedAt});

  StatusMedia.fromJson(Map<String, dynamic> json) {
    statusText = json["status_text"];
    url = json["url"]?.toString().isEmpty == true ? null : json["url"];
    statusMediaId = json["status_media_id"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status_text"] = statusText;
    data["url"] = url;
    data["status_media_id"] = statusMediaId;
    data["updatedAt"] = updatedAt;
    return data;
  }
}

class VerificationType {
  String? logo;
  int? verificationTypeId;
  String? titile;
  bool? isPaymentRequired;
  bool? isGroup;
  dynamic cycle;
  String? planPrice;
  String? planDescription;
  String? createdAt;
  String? updatedAt;

  VerificationType({
    this.logo,
    this.verificationTypeId,
    this.titile,
    this.isPaymentRequired,
    this.isGroup,
    this.cycle,
    this.planPrice,
    this.planDescription,
    this.createdAt,
    this.updatedAt,
  });

  VerificationType.fromJson(Map<String, dynamic> json) {
    logo = json["logo"];
    verificationTypeId = json["verification_type_id"];
    titile = json["titile"];
    isPaymentRequired = json["is_payment_required"];
    isGroup = json["is_group"];
    cycle = json["cycle"];
    planPrice = json["plan_price"];
    planDescription = json["plan_description"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["logo"] = logo;
    data["verification_type_id"] = verificationTypeId;
    data["titile"] = titile;
    data["is_payment_required"] = isPaymentRequired;
    data["is_group"] = isGroup;
    data["cycle"] = cycle;
    data["plan_price"] = planPrice;
    data["plan_description"] = planDescription;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    return data;
  }
}
