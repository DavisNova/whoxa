class MyStorySeenListData {
  bool? success;
  String? message;
  List<StatusViewsList>? statusViewsList;

  MyStorySeenListData({this.success, this.message, this.statusViewsList});

  MyStorySeenListData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['statusViewsList'] != null) {
      statusViewsList = <StatusViewsList>[];
      json['statusViewsList'].forEach((v) {
        statusViewsList!.add(StatusViewsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (statusViewsList != null) {
      data['statusViewsList'] =
          statusViewsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StatusViewsList {
  String? createdAt;
  int? statusCount;
  User? user;

  StatusViewsList({this.createdAt, this.statusCount, this.user});

  StatusViewsList.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    statusCount = json['status_count'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['status_count'] = statusCount;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? profileImage;
  int? userId;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? userName;
  VerificationType? verificationType;

  User({
    this.profileImage,
    this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.userName,
    this.verificationType,
  });

  User.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phoneNumber = json['phone_number'];
    userName = json['user_name'];
    verificationType = json['Varification_type'] != null
        ? VerificationType.fromJson(json['Varification_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone_number'] = phoneNumber;
    data['user_name'] = userName;
    if (verificationType != null) {
      data['Varification_type'] = verificationType!.toJson();
    }
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
    logo = json['logo'];
    verificationTypeId = json['verification_type_id'];
    titile = json['titile'];
    isPaymentRequired = json['is_payment_required'];
    isGroup = json['is_group'];
    cycle = json['cycle'];
    planPrice = json['plan_price'];
    planDescription = json['plan_description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo'] = logo;
    data['verification_type_id'] = verificationTypeId;
    data['titile'] = titile;
    data['is_payment_required'] = isPaymentRequired;
    data['is_group'] = isGroup;
    data['cycle'] = cycle;
    data['plan_price'] = planPrice;
    data['plan_description'] = planDescription;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
