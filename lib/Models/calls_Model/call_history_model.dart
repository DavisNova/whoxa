class CallHistoryModel {
  List<CallList>? callList;
  bool? success;

  CallHistoryModel({this.callList, this.success});

  CallHistoryModel.fromJson(Map<String, dynamic> json) {
    callList = json["callList"] == null
        ? null
        : (json["callList"] as List).map((e) => CallList.fromJson(e)).toList();
    success = json["success"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (callList != null) {
      data["callList"] = callList?.map((e) => e.toJson()).toList();
    }
    data["success"] = success;
    return data;
  }
}

class CallList {
  int? callId;
  int? messageId;
  String? missedCall;
  String? callAccept;
  String? callType;
  String? callDecline;
  String? roomId;
  String? callTime;
  String? createdAt;
  String? updatedAt;
  int? conversationId;
  int? userId;
  Conversation? conversation;
  User? user;

  CallList(
      {this.callId,
      this.messageId,
      this.missedCall,
      this.callAccept,
      this.callType,
      this.callDecline,
      this.roomId,
      this.callTime,
      this.createdAt,
      this.updatedAt,
      this.conversationId,
      this.userId,
      this.conversation,
      this.user});

  CallList.fromJson(Map<String, dynamic> json) {
    callId = json["call_id"];
    messageId = json["message_id"];
    missedCall = json["missed_call"];
    callAccept = json["call_accept"];
    callType = json["call_type"];
    callDecline = json["call_decline"];
    roomId = json["room_id"];
    callTime = json["call_time"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    conversationId = json["conversation_id"];
    userId = json["user_id"];
    conversation = json["Conversation"] == null
        ? null
        : Conversation.fromJson(json["Conversation"]);
    user = json["User"] == null ? null : User.fromJson(json["User"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["call_id"] = callId;
    data["message_id"] = messageId;
    data["missed_call"] = missedCall;
    data["call_accept"] = callAccept;
    data["call_type"] = callType;
    data["call_decline"] = callDecline;
    data["room_id"] = roomId;
    data["call_time"] = callTime;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    data["conversation_id"] = conversationId;
    data["user_id"] = userId;
    if (conversation != null) {
      data["Conversation"] = conversation?.toJson();
    }
    if (user != null) {
      data["User"] = user?.toJson();
    }
    return data;
  }
}

class User {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? userName;
  String? firstName;
  String? lastName;
  VerificationType? verificationType;

  User({
    this.profileImage,
    this.userId,
    this.phoneNumber,
    this.userName,
    this.firstName,
    this.lastName,
    this.verificationType,
  });

  User.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    phoneNumber = json["phone_number"];
    userName = json["user_name"];
    firstName = json["first_name"];
    lastName = json["last_name"];

    // Check for both spellings of verification_type - note the capitalization in Varification_type
    if (json["verification_type"] != null) {
      verificationType = VerificationType.fromJson(json["verification_type"]);
    } else if (json["Varification_type"] != null) {
      verificationType = VerificationType.fromJson(json["Varification_type"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    data["phone_number"] = phoneNumber;
    data["user_name"] = userName;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    if (verificationType != null) {
      data["verification_type"] = verificationType!.toJson();
    }
    return data;
  }
}

class VerificationType {
  final String logo;
  final int verificationTypeId;
  final String title;
  final bool isPaymentRequired;
  final bool isGroup;
  final int cycle;
  final String createdAt;
  final String updatedAt;

  VerificationType({
    required this.logo,
    required this.verificationTypeId,
    required this.title,
    required this.isPaymentRequired,
    required this.isGroup,
    required this.cycle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationType.fromJson(Map<String, dynamic> json) {
    try {
      // Get cycle value and handle string case
      int cycleValue = 0;
      if (json["cycle"] != null) {
        if (json["cycle"] is String) {
          cycleValue = int.tryParse(json["cycle"]) ?? 0;
        } else if (json["cycle"] is int) {
          cycleValue = json["cycle"];
        }
      }

      return VerificationType(
        logo: json["logo"] ?? "",
        verificationTypeId: json["verification_type_id"] is String
            ? int.tryParse(json["verification_type_id"]) ?? 0
            : json["verification_type_id"] ?? 0,
        title: json["titile"] ??
            "", // Note: maintaining the typo from the response
        isPaymentRequired: json["is_payment_required"] ?? false,
        isGroup: json["is_group"] ?? false,
        cycle: cycleValue, // Use the safely parsed cycle value
        createdAt: json["createdAt"] ?? "",
        updatedAt: json["updatedAt"] ?? "",
      );
    } catch (e) {
      print("Error parsing VerificationType: $e");
      return VerificationType(
        logo: "",
        verificationTypeId: 0,
        title: "Error",
        isPaymentRequired: false,
        isGroup: false,
        cycle: 0,
        createdAt: "",
        updatedAt: "",
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "logo": logo,
      "verification_type_id": verificationTypeId,
      "titile": title, // Note: maintaining the typo from the response
      "is_payment_required": isPaymentRequired,
      "is_group": isGroup,
      "cycle": cycle,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class Conversation {
  String? groupProfileImage;
  int? conversationId;
  bool? isGroup;
  String? groupName;

  Conversation(
      {this.groupProfileImage,
      this.conversationId,
      this.isGroup,
      this.groupName});

  Conversation.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json["group_profile_image"];
    conversationId = json["conversation_id"];
    isGroup = json["is_group"];
    groupName = json["group_name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["group_profile_image"] = groupProfileImage;
    data["conversation_id"] = conversationId;
    data["is_group"] = isGroup;
    data["group_name"] = groupName;
    return data;
  }
}
