// class UserChatListModel {
//   List<ChatList>? chatList;

//   UserChatListModel({this.chatList});

//   UserChatListModel.fromJson(Map<String, dynamic> json) {
//     if (json['chatList'] != null) {
//       chatList = <ChatList>[];
//       json['chatList'].forEach((v) {
//         chatList!.add(ChatList.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (chatList != null) {
//       data['chatList'] = chatList!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class ChatList {
//   int? conversationId;
//   bool? isGroup;
//   String? groupName;
//   String? groupProfileImage;
//   String? lastMessage;
//   String? lastMessageType;
//   int? userId;
//   String? userName;
//   String? phoneNumber;
//   String? profileImage;
//   bool? isBlock;
//   String? createdAt;
//   String? updatedAt;
//   int? unreadCount;

//   ChatList({
//     this.conversationId,
//     this.isGroup,
//     this.groupName,
//     this.groupProfileImage,
//     this.lastMessage,
//     this.lastMessageType,
//     this.userId,
//     this.userName,
//     this.phoneNumber,
//     this.profileImage,
//     this.isBlock,
//     this.createdAt,
//     this.updatedAt,
//     this.unreadCount,
//   });

//   ChatList.fromJson(Map<String, dynamic> json) {
//     conversationId = json['conversation_id'];
//     isGroup = json['is_group'];
//     groupName = json['group_name'];
//     groupProfileImage = json['group_profile_image'];
//     lastMessage = json['last_message'];
//     lastMessageType = json['last_message_type'];
//     userId = json['user_id'];
//     userName = json['user_name'];
//     phoneNumber = json['phone_number'];
//     profileImage = json['profile_image'];
//     isBlock = json['is_block'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     unreadCount = json['unread_count'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['conversation_id'] = conversationId;
//     data['is_group'] = isGroup;
//     data['group_name'] = groupName;
//     data['group_profile_image'] = groupProfileImage;
//     data['last_message'] = lastMessage;
//     data['last_message_type'] = lastMessageType;
//     data['user_id'] = userId;
//     data['user_name'] = userName;
//     data['phone_number'] = phoneNumber;
//     data['profile_image'] = profileImage;
//     data['is_block'] = isBlock;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     data['unread_count'] = unreadCount;
//     return data;
//   }
// }

class UserChatListModel {
  List<ChatList>? chatList;

  UserChatListModel({this.chatList});

  UserChatListModel.fromJson(Map<String, dynamic> json) {
    if (json['chatList'] != null) {
      chatList = <ChatList>[];
      json['chatList'].forEach((v) {
        chatList!.add(ChatList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chatList != null) {
      data['chatList'] = chatList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChatList {
  int? conversationId;
  bool? isGroup;
  String? groupName;
  String? groupDesc;
  String? groupProfileImage;
  String? lastMessage;
  String? lastMessageType;
  int? userId;
  String? userName;
  String? phoneNumber;
  String? profileImage;
  bool? isBlock;
  String? createdAt;
  String? updatedAt;
  int? unreadCount;
  VarificationType? varificationType; // Added new field

  ChatList({
    this.conversationId,
    this.isGroup,
    this.groupName,
    this.groupDesc,
    this.groupProfileImage,
    this.lastMessage,
    this.lastMessageType,
    this.userId,
    this.userName,
    this.phoneNumber,
    this.profileImage,
    this.isBlock,
    this.createdAt,
    this.updatedAt,
    this.unreadCount,
    this.varificationType, // Added new field
  });

  ChatList.fromJson(Map<String, dynamic> json) {
    conversationId = json['conversation_id'];
    isGroup = json['is_group'];
    groupName = json['group_name'];
    groupDesc = json['group_description'];
    groupProfileImage = json['group_profile_image'];
    lastMessage = json['last_message'];
    lastMessageType = json['last_message_type'];
    userId = json['user_id'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    profileImage = json['profile_image'];
    isBlock = json['is_block'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    unreadCount = json['unread_count'];
    varificationType = json['Varification_type'] != null
        ? VarificationType.fromJson(json['Varification_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversation_id'] = conversationId;
    data['is_group'] = isGroup;
    data['group_name'] = groupName;
    data['group_description'] = groupDesc;
    data['group_profile_image'] = groupProfileImage;
    data['last_message'] = lastMessage;
    data['last_message_type'] = lastMessageType;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['phone_number'] = phoneNumber;
    data['profile_image'] = profileImage;
    data['is_block'] = isBlock;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['unread_count'] = unreadCount;
    if (varificationType != null) {
      data['Varification_type'] = varificationType!.toJson();
    }
    return data;
  }
}

class VarificationType {
  String? logo;
  int? verificationTypeId;
  String? titile; // Keeping the original typo from API
  bool? isPaymentRequired;
  bool? isGroup;
  int? cycle;
  String? createdAt;
  String? updatedAt;

  VarificationType({
    this.logo,
    this.verificationTypeId,
    this.titile,
    this.isPaymentRequired,
    this.isGroup,
    this.cycle,
    this.createdAt,
    this.updatedAt,
  });

  VarificationType.fromJson(Map<String, dynamic> json) {
    logo = json['logo'];
    verificationTypeId = json['verification_type_id'];
    titile = json['titile']; // Note: API has a typo 'titile'
    isPaymentRequired = json['is_payment_required'];
    isGroup = json['is_group'];
    cycle = json['cycle'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo'] = logo;
    data['verification_type_id'] = verificationTypeId;
    data['titile'] = titile; // Using the same field name as in API
    data['is_payment_required'] = isPaymentRequired;
    data['is_group'] = isGroup;
    data['cycle'] = cycle;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
