// ignore_for_file: file_names

class VerifyOTPModel {
  String? message;
  bool? success;
  String? token;
  ResData? resData;

  VerifyOTPModel({this.message, this.success, this.token, this.resData});

  VerifyOTPModel.fromJson(Map<String, dynamic> json) {
    message = json['message']?.toString();
    success = json['success'] is bool
        ? json['success']
        : json['success'].toString() == 'true';
    token = json['token']?.toString();
    resData = json['resData'] != null
        ? ResData.fromJson(json['resData'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    data['token'] = token;
    if (resData != null) {
      data['resData'] = resData!.toJson();
    }
    return data;
  }
}

class ResData {
  String? profileImage;
  String? profileBanner;
  int? userId;
  String? phoneNumber;
  String? country;
  String? countryFullName;
  String? deviceToken;
  String? oneSignalPlayerId;
  String? userName;
  String? firstName;
  String? lastName;
  String? bio;
  String? dob;
  String? countryCode;
  String? password;
  int? otp;
  String? gender;
  String? createdAt;
  String? updatedAt;
  int? status;
  int? lastSeen;
  bool? blockedByAdmin;
  bool? viewedByAdmin;
  int? avatarId;
  bool? isAccountDeleted;
  bool? isGreeted;
  String? verificationTypeId;
  dynamic subscriptionTypeId;
  VarificationType? varificationType;
  List<dynamic>? subscribedUsers;
  List<dynamic>? varificationRequests;

  ResData({
    this.profileImage,
    this.profileBanner,
    this.userId,
    this.phoneNumber,
    this.country,
    this.countryFullName,
    this.deviceToken,
    this.oneSignalPlayerId,
    this.userName,
    this.firstName,
    this.lastName,
    this.bio,
    this.dob,
    this.countryCode,
    this.password,
    this.otp,
    this.gender,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.lastSeen,
    this.blockedByAdmin,
    this.viewedByAdmin,
    this.avatarId,
    this.isAccountDeleted,
    this.isGreeted,
    this.verificationTypeId,
    this.subscriptionTypeId,
    this.varificationType,
    this.subscribedUsers,
    this.varificationRequests,
  });

  ResData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image']?.toString();
    profileBanner = json['profile_banner']?.toString(); // fixed key
    userId = _tryParseInt(json['user_id']);
    phoneNumber = json['phone_number']?.toString();
    country = json['country']?.toString();
    countryFullName = json['country_full_name']?.toString();
    deviceToken = json['device_token']?.toString();
    oneSignalPlayerId = json['one_signal_player_id']?.toString();
    userName = json['user_name']?.toString();
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    bio = json['bio']?.toString();
    dob = json['dob']?.toString();
    countryCode = json['country_code']?.toString();
    password = json['password']?.toString();
    otp = _tryParseInt(json['otp']);
    gender = json['gender']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    status = _tryParseInt(json['status']);
    lastSeen = _tryParseInt(json['last_seen']);
    blockedByAdmin =
        json['Blocked_by_admin'] == true || json['Blocked_by_admin'] == 'true';
    viewedByAdmin =
        json['viewed_by_admin'] == true || json['viewed_by_admin'] == 'true';
    avatarId = _tryParseInt(json['avatar_id']);
    isAccountDeleted = json['is_account_deleted'] == true ||
        json['is_account_deleted'] == 'true';
    isGreeted = json['is_greeted'] == true || json['is_greeted'] == 'true';
    verificationTypeId = json['verification_type_id']?.toString();
    subscriptionTypeId = json['subscription_type_id'];
    varificationType = json['Varification_type'] != null
        ? VarificationType.fromJson(json['Varification_type'])
        : null;
    subscribedUsers = json['Subscribed_users'] ?? [];
    varificationRequests = json['Varification_requests'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['profile_banner'] = profileBanner;
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['country'] = country;
    data['country_full_name'] = countryFullName;
    data['device_token'] = deviceToken;
    data['one_signal_player_id'] = oneSignalPlayerId;
    data['user_name'] = userName;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['bio'] = bio;
    data['dob'] = dob;
    data['country_code'] = countryCode;
    data['password'] = password;
    data['otp'] = otp;
    data['gender'] = gender;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['status'] = status;
    data['last_seen'] = lastSeen;
    data['Blocked_by_admin'] = blockedByAdmin;
    data['viewed_by_admin'] = viewedByAdmin;
    data['avatar_id'] = avatarId;
    data['is_account_deleted'] = isAccountDeleted;
    data['is_greeted'] = isGreeted;
    data['verification_type_id'] = verificationTypeId;
    data['subscription_type_id'] = subscriptionTypeId;
    if (varificationType != null) {
      data['Varification_type'] = varificationType!.toJson();
    }
    data['Subscribed_users'] = subscribedUsers ?? [];
    data['Varification_requests'] = varificationRequests ?? [];
    return data;
  }

  int? _tryParseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class VarificationType {
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

  VarificationType({
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

  VarificationType.fromJson(Map<String, dynamic> json) {
    logo = json['logo']?.toString();
    verificationTypeId = json['verification_type_id'] is int
        ? json['verification_type_id']
        : int.tryParse(json['verification_type_id']?.toString() ?? '');
    titile = json['titile']?.toString();
    isPaymentRequired = json['is_payment_required'] == true ||
        json['is_payment_required'] == 'true';
    isGroup = json['is_group'] == true || json['is_group'] == 'true';
    cycle = json['cycle'];
    planPrice = json['plan_price']?.toString();
    planDescription = json['plan_description']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'logo': logo,
      'verification_type_id': verificationTypeId,
      'titile': titile,
      'is_payment_required': isPaymentRequired,
      'is_group': isGroup,
      'cycle': cycle,
      'plan_price': planPrice,
      'plan_description': planDescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
