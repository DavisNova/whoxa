// class ConnectedUsersModel {
//   List<ConnectedUsers>? connectedUsers;

//   ConnectedUsersModel({this.connectedUsers});

//   ConnectedUsersModel.fromJson(Map<String, dynamic> json) {
//     connectedUsers = json["connectedUsers"] == null
//         ? null
//         : (json["connectedUsers"] as List)
//             .map((e) => ConnectedUsers.fromJson(e))
//             .toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (connectedUsers != null) {
//       data["connectedUsers"] = connectedUsers?.map((e) => e.toJson()).toList();
//     }
//     return data;
//   }
// }

// class ConnectedUsers {
//   String? profileImage;
//   int? userId;
//   String? userName;
//   String? firstName;
//   String? lastName;

//   ConnectedUsers(
//       {this.profileImage,
//       this.userId,
//       this.userName,
//       this.firstName,
//       this.lastName});

//   ConnectedUsers.fromJson(Map<String, dynamic> json) {
//     profileImage = json["profile_image"];
//     userId = json["user_id"];
//     userName = json["user_name"];
//     firstName = json["first_name"];
//     lastName = json["last_name"];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data["profile_image"] = profileImage;
//     data["user_id"] = userId;
//     data["user_name"] = userName;
//     data["first_name"] = firstName;
//     data["last_name"] = lastName;
//     return data;
//   }
// }

class ConnectedUsersModel {
  List<ConnectedUsers>? connectedUsers;

  ConnectedUsersModel({this.connectedUsers});

  ConnectedUsersModel.fromJson(Map<String, dynamic> json) {
    connectedUsers = json["connectedUsers"] == null
        ? null
        : (json["connectedUsers"] as List)
            .map((e) => ConnectedUsers.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (connectedUsers != null) {
      data["connectedUsers"] = connectedUsers?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ConnectedUsers {
  String? profileImage;
  int? userId;
  String? userName;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? oneSignalPlayerId;
  bool? isGroup;
  VerificationType? verificationType;
  String? token;

  // For call-related data
  String? roomId;
  bool? missedCall;
  int? callId;
  String? callType;

  // For message-related data
  int? messageId;
  int? conversationId;
  String? senderPhoneNumber;
  String? receiverPhoneNumber;
  String? senderProfileImage;
  String? receiverProfileImage;
  int? senderId;
  String? senderName;
  String? senderFirstName;
  int? receiverId;
  String? receiverToken;

  ConnectedUsers({
    this.profileImage,
    this.userId,
    this.userName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.oneSignalPlayerId,
    this.isGroup,
    this.verificationType,
    this.token,
    this.roomId,
    this.missedCall,
    this.callId,
    this.callType,
    this.messageId,
    this.conversationId,
    this.senderPhoneNumber,
    this.receiverPhoneNumber,
    this.senderProfileImage,
    this.receiverProfileImage,
    this.senderId,
    this.senderName,
    this.senderFirstName,
    this.receiverId,
    this.receiverToken,
  });

  ConnectedUsers.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    userName = json["user_name"];
    firstName = json["first_name"];
    lastName = json["last_name"];
    phoneNumber = json["phone_number"];
    oneSignalPlayerId = json["one_signal_player_id"];
    isGroup = json["is_group"] ?? false;
    verificationType = json["Varification_type"] != null
        ? VerificationType.fromJson(json["Varification_type"])
        : null;
    token = json["receiver_token"];

    // Call-related data
    roomId = json["room_id"];
    missedCall = json["missed_call"] ?? false;
    callId = json["call_id"];
    callType = json["call_type"];

    // Message-related data
    messageId = json["message_id"];
    conversationId = json["conversation_id"];
    senderPhoneNumber = json["sender_phone_number"];
    receiverPhoneNumber = json["receiver_phone_number"];
    senderProfileImage = json["sender_profile_image"];
    receiverProfileImage = json["receiver_profile_image"];
    senderId = json["senderId"];
    senderName = json["senderName"];
    senderFirstName = json["sender_first_name"];
    receiverId = json["receiverId"];
    receiverToken = json["receiver_token"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    data["user_name"] = userName;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    data["phone_number"] = phoneNumber;
    data["one_signal_player_id"] = oneSignalPlayerId;
    data["is_group"] = isGroup;
    if (verificationType != null) {
      data["Varification_type"] = verificationType!.toJson();
    }
    data["receiver_token"] = token;

    // Call-related data
    data["room_id"] = roomId;
    data["missed_call"] = missedCall;
    data["call_id"] = callId;
    data["call_type"] = callType;

    // Message-related data
    data["message_id"] = messageId;
    data["conversation_id"] = conversationId;
    data["sender_phone_number"] = senderPhoneNumber;
    data["receiver_phone_number"] = receiverPhoneNumber;
    data["sender_profile_image"] = senderProfileImage;
    data["receiver_profile_image"] = receiverProfileImage;
    data["senderId"] = senderId;
    data["senderName"] = senderName;
    data["sender_first_name"] = senderFirstName;
    data["receiverId"] = receiverId;
    data["receiver_token"] = receiverToken;

    return data;
  }
}

class VerificationType {
  String? createdAt;
  bool? isPaymentRequired;
  int? verificationTypeId;
  String? title;
  String? planPrice;
  String? logo;
  bool? isGroup;
  String? planDescription;
  String? updatedAt;

  VerificationType({
    this.createdAt,
    this.isPaymentRequired,
    this.verificationTypeId,
    this.title,
    this.planPrice,
    this.logo,
    this.isGroup,
    this.planDescription,
    this.updatedAt,
  });

  VerificationType.fromJson(Map<String, dynamic> json) {
    createdAt = json["createdAt"];
    isPaymentRequired = json["is_payment_required"] ?? false;
    verificationTypeId = json["verification_type_id"];
    title = json["titile"]; // Note: keeping the typo as it's in the JSON
    planPrice = json["plan_price"];
    logo = json["logo"];
    isGroup = json["is_group"] ?? false;
    planDescription = json["plan_description"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["createdAt"] = createdAt;
    data["is_payment_required"] = isPaymentRequired;
    data["verification_type_id"] = verificationTypeId;
    data["titile"] = title; // Note: keeping the typo as it's in the JSON
    data["plan_price"] = planPrice;
    data["logo"] = logo;
    data["is_group"] = isGroup;
    data["plan_description"] = planDescription;
    data["updatedAt"] = updatedAt;
    return data;
  }
}

// Adding subscription-related models based on the Xendit payment flow diagram
class SubscriptionModel {
  int? subscriptionId;
  int? userId;
  String? subscriptionStatus;
  String? subscriptionType;
  String? startDate;
  String? endDate;
  String? xenditInvoiceId;
  String? xenditRecurringId;
  PaymentMethod? paymentMethod;

  SubscriptionModel({
    this.subscriptionId,
    this.userId,
    this.subscriptionStatus,
    this.subscriptionType,
    this.startDate,
    this.endDate,
    this.xenditInvoiceId,
    this.xenditRecurringId,
    this.paymentMethod,
  });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    subscriptionId = json["subscription_id"];
    userId = json["user_id"];
    subscriptionStatus = json["subscription_status"];
    subscriptionType = json["subscription_type"];
    startDate = json["start_date"];
    endDate = json["end_date"];
    xenditInvoiceId = json["xendit_invoice_id"];
    xenditRecurringId = json["xendit_recurring_id"];
    paymentMethod = json["payment_method"] != null
        ? PaymentMethod.fromJson(json["payment_method"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["subscription_id"] = subscriptionId;
    data["user_id"] = userId;
    data["subscription_status"] = subscriptionStatus;
    data["subscription_type"] = subscriptionType;
    data["start_date"] = startDate;
    data["end_date"] = endDate;
    data["xendit_invoice_id"] = xenditInvoiceId;
    data["xendit_recurring_id"] = xenditRecurringId;
    if (paymentMethod != null) {
      data["payment_method"] = paymentMethod!.toJson();
    }
    return data;
  }
}

class PaymentMethod {
  String? type; // e.g., "credit_card", "e_wallet", "bank_transfer"
  String? id;
  String? status;
  Map<String, dynamic>? details;

  PaymentMethod({
    this.type,
    this.id,
    this.status,
    this.details,
  });

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    id = json["id"];
    status = json["status"];
    details = json["details"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["type"] = type;
    data["id"] = id;
    data["status"] = status;
    data["details"] = details;
    return data;
  }
}
