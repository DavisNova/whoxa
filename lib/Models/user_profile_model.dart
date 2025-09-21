// class UserProfileModel {
//   UserProfileModel({
//     this.message,
//     this.success,
//     this.resData,
//   });
//
//   UserProfileModel.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     success = json['success'];
//     resData =
//         json['resData'] != null ? ResData.fromJson(json['resData']) : null;
//   }
//
//   String? message;
//   ResData? resData;
//   bool? success;
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['message'] = message;
//     data['success'] = success;
//     if (resData != null) {
//       data['resData'] = resData!.toJson();
//     }
//     return data;
//   }
// }
//
// class ResData {
//   ResData({
//     this.profileImage,
//     this.profileBanner,
//     this.userId,
//     this.phoneNumber,
//     this.country,
//     this.countryFullName,
//     this.firstName,
//     this.lastName,
//     this.deviceToken,
//     this.oneSignalPlayerId,
//     this.userName,
//     this.bio,
//     this.dob,
//     this.countryCode,
//     this.password,
//     this.lastSeen,
//     this.gender,
//     this.blockedByAdmin,
//     this.viewedByAdmin,
//     this.avatarId,
//     this.isAccountDeleted,
//     this.verificationTypeId,
//     this.subscriptionTypeId,
//     this.verificationType,
//     this.email,
//     this.isgreetings,
//     this.varificationRequests,
//     this.subscribedUsers,
//   });
//
//   ResData.fromJson(Map<String, dynamic> json) {
//     profileImage = json['profile_image'];
//     profileBanner = json['proile_banner'];
//     userId = json['user_id'];
//     phoneNumber = json['phone_number'];
//     country = json['country'];
//     countryFullName = json['country_full_name'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     deviceToken = json['device_token'];
//     oneSignalPlayerId = json['one_signal_player_id'];
//     userName = json['user_name'];
//     bio = json['bio'];
//     dob = json['dob'];
//     countryCode = json['country_code'];
//     password = json['password'];
//     lastSeen = json['last_seen'];
//     gender = json['gender'];
//     blockedByAdmin = json['Blocked_by_admin'];
//     viewedByAdmin = json['viewed_by_admin'];
//     avatarId = json['avatar_id'];
//     isAccountDeleted = json['is_account_deleted'];
//     verificationTypeId = json['verification_type_id'];
//     subscriptionTypeId = json['subscription_type_id'];
//     verificationType = json['Varification_type'] != null
//         ? VerificationType.fromJson(json['Varification_type'])
//         : null;
//     email = json['email_id'];
//     isgreetings = json['is_greeted'];
//
//     // Add parsing for Varification_requests array
//     if (json['Varification_requests'] != null) {
//       varificationRequests = <VerificationRequest>[];
//       json['Varification_requests'].forEach((v) {
//         varificationRequests!.add(VerificationRequest.fromJson(v));
//       });
//     }
//
//     // Add parsing for Subscribed_users array
//     if (json['Subscribed_users'] != null) {
//       subscribedUsers = <SubscribedUser>[];
//       json['Subscribed_users'].forEach((v) {
//         subscribedUsers!.add(SubscribedUser.fromJson(v));
//       });
//     }
//   }
//
//   String? bio;
//   String? country;
//   String? countryFullName;
//   String? countryCode;
//   String? deviceToken;
//   String? oneSignalPlayerId;
//   String? dob;
//   String? firstName;
//   String? gender;
//   String? lastName;
//   String? password;
//   String? phoneNumber;
//   String? profileImage;
//   String? profileBanner;
//   int? userId;
//   String? userName;
//   int? lastSeen;
//   bool? blockedByAdmin;
//   bool? viewedByAdmin;
//   int? avatarId;
//   bool? isAccountDeleted;
//   int? verificationTypeId;
//   int? subscriptionTypeId;
//   VerificationType? verificationType;
//   String? email;
//   bool? isgreetings;
//   List<VerificationRequest>? varificationRequests; // New field
//   List<SubscribedUser>? subscribedUsers; // New field
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['profile_image'] = profileImage;
//     data['proile_banner'] = profileBanner;
//     data['user_id'] = userId;
//     data['phone_number'] = phoneNumber;
//     data['country'] = country;
//     data['country_full_name'] = countryFullName;
//     data['first_name'] = firstName;
//     data['last_name'] = lastName;
//     data['device_token'] = deviceToken;
//     data['one_signal_player_id'] = oneSignalPlayerId;
//     data['user_name'] = userName;
//     data['bio'] = bio;
//     data['dob'] = dob;
//     data['country_code'] = countryCode;
//     data['password'] = password;
//     data['last_seen'] = lastSeen;
//     data['gender'] = gender;
//     data['Blocked_by_admin'] = blockedByAdmin;
//     data['viewed_by_admin'] = viewedByAdmin;
//     data['avatar_id'] = avatarId;
//     data['is_account_deleted'] = isAccountDeleted;
//     data['verification_type_id'] = verificationTypeId;
//     data['subscription_type_id'] = subscriptionTypeId;
//     if (verificationType != null) {
//       data['Varification_type'] = verificationType!.toJson();
//     }
//     data['email_id'] = email;
//     data['is_greeted'] = isgreetings;
//
//     // Add serialization for Varification_requests
//     if (varificationRequests != null) {
//       data['Varification_requests'] =
//           varificationRequests!.map((v) => v.toJson()).toList();
//     }
//
//     // Add serialization for Subscribed_users
//     if (subscribedUsers != null) {
//       data['Subscribed_users'] =
//           subscribedUsers!.map((v) => v.toJson()).toList();
//     }
//
//     return data;
//   }
// }
//
// class VerificationType {
//   VerificationType({
//     this.logo,
//     this.verificationTypeId,
//     this.title,
//     this.isPaymentRequired,
//     this.isGroup,
//     this.cycle,
//     this.planPrice,
//     this.planDescription,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   VerificationType.fromJson(Map<String, dynamic> json) {
//     logo = json['logo'];
//     verificationTypeId = json['verification_type_id'];
//     title = json['titile']; // Note: API has a typo 'titile' instead of 'title'
//     isPaymentRequired = json['is_payment_required'];
//     isGroup = json['is_group'];
//     cycle = json['cycle'];
//     planPrice = json['plan_price'];
//     planDescription = json['plan_description'];
//     createdAt =
//         json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt =
//         json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//   }
//
//   String? logo;
//   int? verificationTypeId;
//   String? title;
//   bool? isPaymentRequired;
//   bool? isGroup;
//   dynamic cycle; // Using dynamic since the type isn't clear from the JSON
//   String? planPrice;
//   String? planDescription;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['logo'] = logo;
//     data['verification_type_id'] = verificationTypeId;
//     data['titile'] = title; // Keep the typo as in API response
//     data['is_payment_required'] = isPaymentRequired;
//     data['is_group'] = isGroup;
//     data['cycle'] = cycle;
//     data['plan_price'] = planPrice;
//     data['plan_description'] = planDescription;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     return data;
//   }
// }
//
// // New class for Verification Requests
// class VerificationRequest {
//   VerificationRequest({
//     this.evidence,
//     this.varificationRequestId,
//     this.transactionId,
//     this.requestStatusTeamMember,
//     this.requestStatusSuperAdmin,
//     this.paymentStatus,
//     this.description,
//     this.rejectReason,
//     this.link1,
//     this.link2,
//     this.link3,
//     this.link4,
//     this.link5,
//     this.fullName,
//     this.createdAt,
//     this.updatedAt,
//     this.adminId,
//     this.superAdminId,
//     this.conversationId,
//     this.userId,
//     this.verificationTypeId,
//   });
//
//   VerificationRequest.fromJson(Map<String, dynamic> json) {
//     evidence = json['evidence'];
//     varificationRequestId = json['varification_request_id'];
//     transactionId = json['transaction_id'];
//     requestStatusTeamMember = json['request_status_team_member'];
//     requestStatusSuperAdmin = json['request_status_super_admin'];
//     paymentStatus = json['payment_status'];
//     description = json['description'];
//     rejectReason = json['reject_reason'];
//     link1 = json['link_1'];
//     link2 = json['link_2'];
//     link3 = json['link_3'];
//     link4 = json['link_4'];
//     link5 = json['link_5'];
//     fullName = json['full_name'];
//     createdAt =
//         json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt =
//         json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//     adminId = json['admin_id'];
//     superAdminId = json['super_admin_id'];
//     conversationId = json['conversation_id'];
//     userId = json['user_id'];
//     verificationTypeId = json['Verification_type_id'];
//   }
//
//   String? evidence;
//   int? varificationRequestId;
//   dynamic transactionId;
//   String? requestStatusTeamMember;
//   String? requestStatusSuperAdmin;
//   dynamic paymentStatus;
//   dynamic description;
//   dynamic rejectReason;
//   String? link1;
//   String? link2;
//   String? link3;
//   String? link4;
//   String? link5;
//   String? fullName;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   dynamic adminId;
//   dynamic superAdminId;
//   dynamic conversationId;
//   int? userId;
//   int? verificationTypeId;
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['evidence'] = evidence;
//     data['varification_request_id'] = varificationRequestId;
//     data['transaction_id'] = transactionId;
//     data['request_status_team_member'] = requestStatusTeamMember;
//     data['request_status_super_admin'] = requestStatusSuperAdmin;
//     data['payment_status'] = paymentStatus;
//     data['description'] = description;
//     data['reject_reason'] = rejectReason;
//     data['link_1'] = link1;
//     data['link_2'] = link2;
//     data['link_3'] = link3;
//     data['link_4'] = link4;
//     data['link_5'] = link5;
//     data['full_name'] = fullName;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     data['admin_id'] = adminId;
//     data['super_admin_id'] = superAdminId;
//     data['conversation_id'] = conversationId;
//     data['user_id'] = userId;
//     data['Verification_type_id'] = verificationTypeId;
//     return data;
//   }
// }
//
// // New class for Subscribed Users
// class SubscribedUser {
//   SubscribedUser({
//     this.subscribedUserId,
//     this.xenditCustomerId,
//     this.xenditRecurringId,
//     this.expireDate,
//     this.isExpired,
//     this.isPaymentDone,
//     this.createdAt,
//     this.updatedAt,
//     this.subscriptionTypeId,
//     this.userId,
//   });
//
//   SubscribedUser.fromJson(Map<String, dynamic> json) {
//     subscribedUserId = json['subscribed_user_id'];
//     xenditCustomerId = json['xendit_customer_id'];
//     xenditRecurringId = json['xendit_recurring_id'];
//     expireDate = json['expire_date'];
//     isExpired = json['is_expired'];
//     isPaymentDone = json['is_payment_done'];
//     createdAt =
//         json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt =
//         json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//     subscriptionTypeId = json['subscription_type_id'];
//     userId = json['user_id'];
//   }
//
//   int? subscribedUserId;
//   String? xenditCustomerId;
//   String? xenditRecurringId;
//   String? expireDate;
//   bool? isExpired;
//   bool? isPaymentDone;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? subscriptionTypeId;
//   int? userId;
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['subscribed_user_id'] = subscribedUserId;
//     data['xendit_customer_id'] = xenditCustomerId;
//     data['xendit_recurring_id'] = xenditRecurringId;
//     data['expire_date'] = expireDate;
//     data['is_expired'] = isExpired;
//     data['is_payment_done'] = isPaymentDone;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     data['subscription_type_id'] = subscriptionTypeId;
//     data['user_id'] = userId;
//     return data;
//   }
// }

// class UserProfileModel {
//   String? message;
//   bool? success;
//   ResData? resData;

//   UserProfileModel({this.message, this.success, this.resData});

//   UserProfileModel.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     success = json['success'];
//     resData = json['resData'] != null ? ResData.fromJson(json['resData']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['message'] = message;
//     data['success'] = success;
//     if (resData != null) {
//       data['resData'] = resData!.toJson();
//     }
//     return data;
//   }
// }

// class ResData {
//   String? profileImage;
//   String? profileBanner;
//   int? userId;
//   String? phoneNumber;
//   String? country;
//   String? countryFullName;
//   String? countryCode;
//   String? firstName;
//   String? lastName;
//   String? userName;
//   String? email;
//   String? dob;
//   String? gender;
//   String? password;
//   String? bio;
//   String? deviceToken;
//   String? oneSignalPlayerId;
//   int? lastSeen;
//   bool? blockedByAdmin;
//   bool? viewedByAdmin;
//   int? avatarId;
//   bool? isAccountDeleted;
//   bool? isgreetings;
//   int? verificationTypeId;
//   int? subscriptionTypeId;
//   VerificationType? verificationType;
//   List<Revocation>? revocations;
//   List<VerificationRequest>? varificationRequests;
//   List<SubscribedUser>? subscribedUsers;

//   ResData({
//     this.profileImage,
//     this.profileBanner,
//     this.userId,
//     this.phoneNumber,
//     this.country,
//     this.countryFullName,
//     this.countryCode,
//     this.firstName,
//     this.lastName,
//     this.userName,
//     this.email,
//     this.dob,
//     this.gender,
//     this.password,
//     this.bio,
//     this.deviceToken,
//     this.oneSignalPlayerId,
//     this.lastSeen,
//     this.blockedByAdmin,
//     this.viewedByAdmin,
//     this.avatarId,
//     this.isAccountDeleted,
//     this.isgreetings,
//     this.verificationTypeId,
//     this.subscriptionTypeId,
//     this.verificationType,
//     this.revocations,
//     this.varificationRequests,
//     this.subscribedUsers,
//   });

//   ResData.fromJson(Map<String, dynamic> json) {
//     profileImage = json['profile_image'];
//     profileBanner = json['proile_banner']; // Note: The API response has a typo here
//     userId = json['user_id'];
//     phoneNumber = json['phone_number'];
//     country = json['country'];
//     countryFullName = json['country_full_name'];
//     countryCode = json['country_code'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     userName = json['user_name'];
//     email = json['email_id'];
//     dob = json['dob'];
//     gender = json['gender'];
//     password = json['password'];
//     bio = json['bio'];
//     deviceToken = json['device_token'];
//     oneSignalPlayerId = json['one_signal_player_id'];
//     lastSeen = json['last_seen'];
//     blockedByAdmin = json['Blocked_by_admin'];
//     viewedByAdmin = json['viewed_by_admin'];
//     avatarId = json['avatar_id'];
//     isAccountDeleted = json['is_account_deleted'];
//     isgreetings = json['is_greeted'];
//     verificationTypeId = json['verification_type_id'];
//     subscriptionTypeId = json['subscription_type_id'];
//     verificationType = json['Varification_type'] != null
//         ? VerificationType.fromJson(json['Varification_type'])
//         : null;

//     if (json['Revocations'] != null) {
//       revocations = <Revocation>[];
//       json['Revocations'].forEach((v) {
//         revocations!.add(Revocation.fromJson(v));
//       });
//     }

//     if (json['Varification_requests'] != null) {
//       varificationRequests = <VerificationRequest>[];
//       json['Varification_requests'].forEach((v) {
//         varificationRequests!.add(VerificationRequest.fromJson(v));
//       });
//     }

//     if (json['Subscribed_users'] != null) {
//       subscribedUsers = <SubscribedUser>[];
//       json['Subscribed_users'].forEach((v) {
//         subscribedUsers!.add(SubscribedUser.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['profile_image'] = profileImage;
//     data['proile_banner'] = profileBanner; // Keep the same spelling as API (with typo)
//     data['user_id'] = userId;
//     data['phone_number'] = phoneNumber;
//     data['country'] = country;
//     data['country_full_name'] = countryFullName;
//     data['country_code'] = countryCode;
//     data['first_name'] = firstName;
//     data['last_name'] = lastName;
//     data['user_name'] = userName;
//     data['email_id'] = email;
//     data['dob'] = dob;
//     data['gender'] = gender;
//     data['password'] = password;
//     data['bio'] = bio;
//     data['device_token'] = deviceToken;
//     data['one_signal_player_id'] = oneSignalPlayerId;
//     data['last_seen'] = lastSeen;
//     data['Blocked_by_admin'] = blockedByAdmin;
//     data['viewed_by_admin'] = viewedByAdmin;
//     data['avatar_id'] = avatarId;
//     data['is_account_deleted'] = isAccountDeleted;
//     data['is_greeted'] = isgreetings;
//     data['verification_type_id'] = verificationTypeId;
//     data['subscription_type_id'] = subscriptionTypeId;
//     if (verificationType != null) {
//       data['Varification_type'] = verificationType!.toJson();
//     }
//     if (revocations != null) {
//       data['Revocations'] = revocations!.map((v) => v.toJson()).toList();
//     }
//     if (varificationRequests != null) {
//       data['Varification_requests'] =
//           varificationRequests!.map((v) => v.toJson()).toList();
//     }
//     if (subscribedUsers != null) {
//       data['Subscribed_users'] =
//           subscribedUsers!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// // New Revocation class based on the JSON response
// class Revocation {
//   int? revocationId;
//   String? revocationStatus;
//   String? revocationReason;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   dynamic adminId;
//   dynamic superAdminId;
//   dynamic conversationId;
//   int? verificationTypeId;
//   int? userId;

//   Revocation({
//     this.revocationId,
//     this.revocationStatus,
//     this.revocationReason,
//     this.createdAt,
//     this.updatedAt,
//     this.adminId,
//     this.superAdminId,
//     this.conversationId,
//     this.verificationTypeId,
//     this.userId,
//   });

//   Revocation.fromJson(Map<String, dynamic> json) {
//     revocationId = json['revocation_id'];
//     revocationStatus = json['revocation_status'];
//     revocationReason = json['revocation_reason'];
//     createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//     adminId = json['admin_id'];
//     superAdminId = json['super_admin_id'];
//     conversationId = json['conversation_id'];
//     verificationTypeId = json['verification_type_id'];
//     userId = json['user_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['revocation_id'] = revocationId;
//     data['revocation_status'] = revocationStatus;
//     data['revocation_reason'] = revocationReason;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     data['admin_id'] = adminId;
//     data['super_admin_id'] = superAdminId;
//     data['conversation_id'] = conversationId;
//     data['verification_type_id'] = verificationTypeId;
//     data['user_id'] = userId;
//     return data;
//   }
// }

// class VerificationType {
//   String? logo;
//   int? verificationTypeId;
//   String? title;
//   bool? isPaymentRequired;
//   bool? isGroup;
//   dynamic cycle;
//   String? planPrice;
//   String? planDescription;
//   DateTime? createdAt;
//   DateTime? updatedAt;

//   VerificationType({
//     this.logo,
//     this.verificationTypeId,
//     this.title,
//     this.isPaymentRequired,
//     this.isGroup,
//     this.cycle,
//     this.planPrice,
//     this.planDescription,
//     this.createdAt,
//     this.updatedAt,
//   });

//   VerificationType.fromJson(Map<String, dynamic> json) {
//     logo = json['logo'];
//     verificationTypeId = json['verification_type_id'];
//     title = json['titile']; // Note: API has a typo here too
//     isPaymentRequired = json['is_payment_required'];
//     isGroup = json['is_group'];
//     cycle = json['cycle'];
//     planPrice = json['plan_price'];
//     planDescription = json['plan_description'];
//     createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['logo'] = logo;
//     data['verification_type_id'] = verificationTypeId;
//     data['titile'] = title; // Maintain the same spelling as API
//     data['is_payment_required'] = isPaymentRequired;
//     data['is_group'] = isGroup;
//     data['cycle'] = cycle;
//     data['plan_price'] = planPrice;
//     data['plan_description'] = planDescription;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     return data;
//   }
// }

// class VerificationRequest {
//   String? evidence;
//   int? varificationRequestId;
//   dynamic transactionId;
//   String? requestStatusTeamMember;
//   String? requestStatusSuperAdmin;
//   dynamic paymentStatus;
//   dynamic description;
//   dynamic rejectReason;
//   String? link1;
//   String? link2;
//   String? link3;
//   String? link4;
//   String? link5;
//   String? fullName;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   dynamic adminId;
//   dynamic superAdminId;
//   dynamic conversationId;
//   int? userId;
//   int? verificationTypeId;

//   VerificationRequest({
//     this.evidence,
//     this.varificationRequestId,
//     this.transactionId,
//     this.requestStatusTeamMember,
//     this.requestStatusSuperAdmin,
//     this.paymentStatus,
//     this.description,
//     this.rejectReason,
//     this.link1,
//     this.link2,
//     this.link3,
//     this.link4,
//     this.link5,
//     this.fullName,
//     this.createdAt,
//     this.updatedAt,
//     this.adminId,
//     this.superAdminId,
//     this.conversationId,
//     this.userId,
//     this.verificationTypeId,
//   });

//   VerificationRequest.fromJson(Map<String, dynamic> json) {
//     evidence = json['evidence'];
//     varificationRequestId = json['varification_request_id'];
//     transactionId = json['transaction_id'];
//     requestStatusTeamMember = json['request_status_team_member'];
//     requestStatusSuperAdmin = json['request_status_super_admin'];
//     paymentStatus = json['payment_status'];
//     description = json['description'];
//     rejectReason = json['reject_reason'];
//     link1 = json['link_1'];
//     link2 = json['link_2'];
//     link3 = json['link_3'];
//     link4 = json['link_4'];
//     link5 = json['link_5'];
//     fullName = json['full_name'];
//     createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//     adminId = json['admin_id'];
//     superAdminId = json['super_admin_id'];
//     conversationId = json['conversation_id'];
//     userId = json['user_id'];
//     verificationTypeId = json['Verification_type_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['evidence'] = evidence;
//     data['varification_request_id'] = varificationRequestId;
//     data['transaction_id'] = transactionId;
//     data['request_status_team_member'] = requestStatusTeamMember;
//     data['request_status_super_admin'] = requestStatusSuperAdmin;
//     data['payment_status'] = paymentStatus;
//     data['description'] = description;
//     data['reject_reason'] = rejectReason;
//     data['link_1'] = link1;
//     data['link_2'] = link2;
//     data['link_3'] = link3;
//     data['link_4'] = link4;
//     data['link_5'] = link5;
//     data['full_name'] = fullName;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     data['admin_id'] = adminId;
//     data['super_admin_id'] = superAdminId;
//     data['conversation_id'] = conversationId;
//     data['user_id'] = userId;
//     data['Verification_type_id'] = verificationTypeId;
//     return data;
//   }
// }

// class SubscribedUser {
//   int? subscribedUserId;
//   String? xenditCustomerId;
//   String? xenditRecurringId;
//   String? expireDate;
//   bool? isExpired;
//   bool? isPaymentDone;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? subscriptionTypeId;
//   int? userId;

//   SubscribedUser({
//     this.subscribedUserId,
//     this.xenditCustomerId,
//     this.xenditRecurringId,
//     this.expireDate,
//     this.isExpired,
//     this.isPaymentDone,
//     this.createdAt,
//     this.updatedAt,
//     this.subscriptionTypeId,
//     this.userId,
//   });

//   SubscribedUser.fromJson(Map<String, dynamic> json) {
//     subscribedUserId = json['subscribed_user_id'];
//     xenditCustomerId = json['xendit_customer_id'];
//     xenditRecurringId = json['xendit_recurring_id'];
//     expireDate = json['expire_date'];
//     isExpired = json['is_expired'];
//     isPaymentDone = json['is_payment_done'];
//     createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
//     updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
//     subscriptionTypeId = json['subscription_type_id'];
//     userId = json['user_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['subscribed_user_id'] = subscribedUserId;
//     data['xendit_customer_id'] = xenditCustomerId;
//     data['xendit_recurring_id'] = xenditRecurringId;
//     data['expire_date'] = expireDate;
//     data['is_expired'] = isExpired;
//     data['is_payment_done'] = isPaymentDone;
//     data['createdAt'] = createdAt?.toIso8601String();
//     data['updatedAt'] = updatedAt?.toIso8601String();
//     data['subscription_type_id'] = subscriptionTypeId;
//     data['user_id'] = userId;
//     return data;
//   }
// }

class UserProfileModel {
  String? message;
  bool? success;
  ResData? resData;

  UserProfileModel({this.message, this.success, this.resData});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    resData =
        json['resData'] != null ? ResData.fromJson(json['resData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
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
  String? countryCode;
  String? firstName;
  String? lastName;
  String? userName;
  String? email;
  String? dob;
  String? gender;
  String? password;
  String? bio;
  String? deviceToken;
  String? oneSignalPlayerId;
  int? lastSeen;
  bool? blockedByAdmin;
  bool? viewedByAdmin;
  int? avatarId;
  bool? isAccountDeleted;
  bool? isgreetings;
  bool? isRevoke;
  bool? isBlockbyAdmin;
  int? verificationTypeId;
  int? subscriptionTypeId;
  VerificationType? verificationType;
  List<Revocation>? revocations;
  List<VerificationRequest>? varificationRequests;
  List<SubscribedUser>? subscribedUsers;
  bool? activePlan;

  ResData({
    this.profileImage,
    this.profileBanner,
    this.userId,
    this.phoneNumber,
    this.country,
    this.countryFullName,
    this.countryCode,
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.dob,
    this.gender,
    this.password,
    this.bio,
    this.deviceToken,
    this.oneSignalPlayerId,
    this.lastSeen,
    this.blockedByAdmin,
    this.viewedByAdmin,
    this.avatarId,
    this.isAccountDeleted,
    this.isgreetings,
    this.isRevoke,
    this.verificationTypeId,
    this.subscriptionTypeId,
    this.isBlockbyAdmin,
    this.verificationType,
    this.revocations,
    this.varificationRequests,
    this.subscribedUsers,
    this.activePlan,
  });

  ResData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    profileBanner =
        json['proile_banner']; // Note: The API response has a typo here
    userId = json['user_id'];
    phoneNumber = json['phone_number']?.toString();
    country = json['country'];
    countryFullName = json['country_full_name'];
    countryCode = json['country_code'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    userName = json['user_name'];
    email = json['email_id'];
    dob = json['dob'];
    gender = json['gender'];
    password = json['password'];
    bio = json['bio'];
    deviceToken = json['device_token'];
    oneSignalPlayerId = json['one_signal_player_id'];
    lastSeen = json['last_seen'];
    blockedByAdmin = json['Blocked_by_admin'];
    viewedByAdmin = json['viewed_by_admin'];
    avatarId = json['avatar_id'];
    isAccountDeleted = json['is_account_deleted'];
    isgreetings = json['is_greeted'];
    isRevoke = json['is_revoke_popup'];
    verificationTypeId = json['verification_type_id'];
    subscriptionTypeId = json['subscription_type_id'];
    blockedByAdmin = json['Blocked_by_admin'];
    activePlan = json['active_plan'];

    // Check if Verification_type is not null and is a Map
    if (json['Varification_type'] != null &&
        json['Varification_type'] is! bool) {
      try {
        verificationType = VerificationType.fromJson(json['Varification_type']);
      } catch (e) {
        print('Error parsing VerificationType: $e');
        verificationType = null;
      }
    } else {
      verificationType = null;
    }

    // Fix for the 'Revocations' field
    revocations = <Revocation>[];
    if (json['Revocations'] != null && json['Revocations'] is List) {
      try {
        json['Revocations'].forEach((v) {
          revocations!.add(Revocation.fromJson(v));
        });
      } catch (e) {
        print('Error parsing Revocations: $e');
      }
    }

    // Fix for the 'Varification_requests' field
    varificationRequests = <VerificationRequest>[];
    if (json['Varification_requests'] != null &&
        json['Varification_requests'] is List) {
      try {
        json['Varification_requests'].forEach((v) {
          varificationRequests!.add(VerificationRequest.fromJson(v));
        });
      } catch (e) {
        print('Error parsing VerificationRequests: $e');
      }
    }

    // Fix for the 'Subscribed_users' field
    subscribedUsers = <SubscribedUser>[];
    if (json['Subscribed_users'] != null && json['Subscribed_users'] is List) {
      try {
        json['Subscribed_users'].forEach((v) {
          subscribedUsers!.add(SubscribedUser.fromJson(v));
        });
      } catch (e) {
        print('Error parsing SubscribedUsers: $e');
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['proile_banner'] =
        profileBanner; // Keep the same spelling as API (with typo)
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['country'] = country;
    data['country_full_name'] = countryFullName;
    data['country_code'] = countryCode;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['user_name'] = userName;
    data['email_id'] = email;
    data['dob'] = dob;
    data['gender'] = gender;
    data['password'] = password;
    data['bio'] = bio;
    data['device_token'] = deviceToken;
    data['one_signal_player_id'] = oneSignalPlayerId;
    data['last_seen'] = lastSeen;
    data['Blocked_by_admin'] = blockedByAdmin;
    data['viewed_by_admin'] = viewedByAdmin;
    data['avatar_id'] = avatarId;
    data['is_account_deleted'] = isAccountDeleted;
    data['is_greeted'] = isgreetings;
    data['verification_type_id'] = verificationTypeId;
    data['subscription_type_id'] = subscriptionTypeId;
    data['Blocked_by_admin'] = blockedByAdmin;
    data['active_plan'] = activePlan;
    if (verificationType != null) {
      data['Varification_type'] = verificationType!.toJson();
    }
    if (revocations != null && revocations!.isNotEmpty) {
      data['Revocations'] = revocations!.map((v) => v.toJson()).toList();
    }
    if (varificationRequests != null && varificationRequests!.isNotEmpty) {
      data['Varification_requests'] =
          varificationRequests!.map((v) => v.toJson()).toList();
    }
    if (subscribedUsers != null && subscribedUsers!.isNotEmpty) {
      data['Subscribed_users'] =
          subscribedUsers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// New Revocation class based on the JSON response
class Revocation {
  int? revocationId;
  String? revocationStatus;
  String? revocationReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic adminId;
  dynamic superAdminId;
  dynamic conversationId;
  int? verificationTypeId;
  int? userId;

  Revocation({
    this.revocationId,
    this.revocationStatus,
    this.revocationReason,
    this.createdAt,
    this.updatedAt,
    this.adminId,
    this.superAdminId,
    this.conversationId,
    this.verificationTypeId,
    this.userId,
  });

  Revocation.fromJson(Map<String, dynamic> json) {
    revocationId = json['revocation_id'];
    revocationStatus = json['revocation_status'];
    revocationReason = json['revocation_reason'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    adminId = json['admin_id'];
    superAdminId = json['super_admin_id'];
    conversationId = json['conversation_id'];
    verificationTypeId = json['verification_type_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['revocation_id'] = revocationId;
    data['revocation_status'] = revocationStatus;
    data['revocation_reason'] = revocationReason;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['admin_id'] = adminId;
    data['super_admin_id'] = superAdminId;
    data['conversation_id'] = conversationId;
    data['verification_type_id'] = verificationTypeId;
    data['user_id'] = userId;
    return data;
  }
}

class VerificationType {
  String? logo;
  int? verificationTypeId;
  String? title;
  bool? isPaymentRequired;
  bool? isGroup;
  dynamic cycle;
  String? planPrice;
  String? planDescription;
  DateTime? createdAt;
  DateTime? updatedAt;

  VerificationType({
    this.logo,
    this.verificationTypeId,
    this.title,
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
    title = json['titile']; // Note: API has a typo here too
    isPaymentRequired = json['is_payment_required'];
    isGroup = json['is_group'];
    cycle = json['cycle'];
    planPrice = json['plan_price'];
    planDescription = json['plan_description'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo'] = logo;
    data['verification_type_id'] = verificationTypeId;
    data['titile'] = title; // Maintain the same spelling as API
    data['is_payment_required'] = isPaymentRequired;
    data['is_group'] = isGroup;
    data['cycle'] = cycle;
    data['plan_price'] = planPrice;
    data['plan_description'] = planDescription;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }
}

class VerificationRequest {
  String? evidence;
  int? varificationRequestId;
  dynamic transactionId;
  String? requestStatusTeamMember;
  String? requestStatusSuperAdmin;
  dynamic paymentStatus;
  dynamic description;
  dynamic rejectReason;
  String? link1;
  String? link2;
  String? link3;
  String? link4;
  String? link5;
  String? fullName;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic adminId;
  dynamic superAdminId;
  dynamic conversationId;
  int? userId;
  int? verificationTypeId;

  VerificationRequest({
    this.evidence,
    this.varificationRequestId,
    this.transactionId,
    this.requestStatusTeamMember,
    this.requestStatusSuperAdmin,
    this.paymentStatus,
    this.description,
    this.rejectReason,
    this.link1,
    this.link2,
    this.link3,
    this.link4,
    this.link5,
    this.fullName,
    this.createdAt,
    this.updatedAt,
    this.adminId,
    this.superAdminId,
    this.conversationId,
    this.userId,
    this.verificationTypeId,
  });

  VerificationRequest.fromJson(Map<String, dynamic> json) {
    evidence = json['evidence'];
    varificationRequestId = json['varification_request_id'];
    transactionId = json['transaction_id'];
    requestStatusTeamMember = json['request_status_team_member'];
    requestStatusSuperAdmin = json['request_status_super_admin'];
    paymentStatus = json['payment_status'];
    description = json['description'];
    rejectReason = json['reject_reason'];
    link1 = json['link_1'];
    link2 = json['link_2'];
    link3 = json['link_3'];
    link4 = json['link_4'];
    link5 = json['link_5'];
    fullName = json['full_name'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    adminId = json['admin_id'];
    superAdminId = json['super_admin_id'];
    conversationId = json['conversation_id'];
    userId = json['user_id'];
    verificationTypeId = json['Verification_type_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['evidence'] = evidence;
    data['varification_request_id'] = varificationRequestId;
    data['transaction_id'] = transactionId;
    data['request_status_team_member'] = requestStatusTeamMember;
    data['request_status_super_admin'] = requestStatusSuperAdmin;
    data['payment_status'] = paymentStatus;
    data['description'] = description;
    data['reject_reason'] = rejectReason;
    data['link_1'] = link1;
    data['link_2'] = link2;
    data['link_3'] = link3;
    data['link_4'] = link4;
    data['link_5'] = link5;
    data['full_name'] = fullName;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['admin_id'] = adminId;
    data['super_admin_id'] = superAdminId;
    data['conversation_id'] = conversationId;
    data['user_id'] = userId;
    data['Verification_type_id'] = verificationTypeId;
    return data;
  }
}

class SubscribedUser {
  int? subscribedUserId;
  String? xenditCustomerId;
  String? xenditRecurringId;
  String? expireDate;
  bool? isExpired;
  bool? isPaymentDone;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? subscriptionTypeId;
  int? userId;

  SubscribedUser({
    this.subscribedUserId,
    this.xenditCustomerId,
    this.xenditRecurringId,
    this.expireDate,
    this.isExpired,
    this.isPaymentDone,
    this.createdAt,
    this.updatedAt,
    this.subscriptionTypeId,
    this.userId,
  });

  SubscribedUser.fromJson(Map<String, dynamic> json) {
    subscribedUserId = json['subscribed_user_id'];
    xenditCustomerId = json['xendit_customer_id'];
    xenditRecurringId = json['xendit_recurring_id'];
    expireDate = json['expire_date'];
    isExpired = json['is_expired'];
    isPaymentDone = json['is_payment_done'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    subscriptionTypeId = json['subscription_type_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscribed_user_id'] = subscribedUserId;
    data['xendit_customer_id'] = xenditCustomerId;
    data['xendit_recurring_id'] = xenditRecurringId;
    data['expire_date'] = expireDate;
    data['is_expired'] = isExpired;
    data['is_payment_done'] = isPaymentDone;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['subscription_type_id'] = subscriptionTypeId;
    data['user_id'] = userId;
    return data;
  }
}
