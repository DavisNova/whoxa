class GetContactModel {
  bool? success;
  String? message;
  List<NewContactList>? newContactList;

  GetContactModel({this.success, this.message, this.newContactList});

  GetContactModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['newContactList'] != null) {
      newContactList = <NewContactList>[];
      json['newContactList'].forEach((v) {
        newContactList!.add(NewContactList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (newContactList != null) {
      data['newContactList'] = newContactList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NewContactList {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? country;
  String? firstName;
  String? lastName;
  String? deviceToken;
  String? userName;
  String? bio;
  String? dob;
  String? countryCode;
  String? password;
  int? passwordAttempts;
  String? gender;
  String? createdAt;
  String? updatedAt;
  String? fullName;

  NewContactList(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.country,
      this.firstName,
      this.lastName,
      this.deviceToken,
      this.userName,
      this.bio,
      this.dob,
      this.countryCode,
      this.password,
      this.passwordAttempts,
      this.gender,
      this.createdAt,
      this.updatedAt,
      this.fullName});

  NewContactList.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    phoneNumber = json['phone_number'];
    country = json['country'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    deviceToken = json['device_token'];
    userName = json['user_name'];
    bio = json['bio'];
    dob = json['dob'];
    countryCode = json['country_code'];
    password = json['password'];
    passwordAttempts = json['password_attempts'];
    gender = json['gender'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['country'] = country;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['device_token'] = deviceToken;
    data['user_name'] = userName;
    data['bio'] = bio;
    data['dob'] = dob;
    data['country_code'] = countryCode;
    data['password'] = password;
    data['password_attempts'] = passwordAttempts;
    data['gender'] = gender;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['full_name'] = fullName;
    return data;
  }
}
