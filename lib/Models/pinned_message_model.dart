// class PinMessageModel {
//   bool? success;
//   String? message;
//   List<PinnedMessage>? pinnedMessages;

//   PinMessageModel({this.success, this.message, this.pinnedMessages});

//   PinMessageModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];

//     // Handle both PinMessageList and pinned_messages keys
//     var messagesList = json['PinMessageList'] ?? json['pinned_messages'];

//     if (messagesList != null) {
//       pinnedMessages = <PinnedMessage>[];
//       messagesList.forEach((v) {
//         pinnedMessages!.add(PinnedMessage.fromJson(v));
//       });
//     }
//   }
// }

// class PinnedMessage {
//   int? id;
//   int? pinMessageId;
//   int? messageId;
//   String? duration;
//   String? expiresAt;
//   String? createdAt;
//   String? updatedAt;
//   MessageData? messageData;

//   PinnedMessage({
//     this.id,
//     this.pinMessageId,
//     this.messageId,
//     this.duration,
//     this.expiresAt,
//     this.createdAt,
//     this.updatedAt,
//     this.messageData,
//   });

//   PinnedMessage.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     pinMessageId = json['pin_message_id'];
//     messageId = json['message_id'];
//     duration = json['duration'];
//     expiresAt = json['expires_at'];
//     createdAt = json['createdAt'] ?? json['created_at'] ?? json['pinnedAt'];
//     updatedAt = json['updatedAt'] ?? json['updated_at'];

//     // Handle the different nesting formats
//     if (json['Chat'] != null) {
//       messageData = MessageData.fromJson(json['Chat']);

//       // Add sender data if it exists in the JSON
//       if (json['Chat']['User'] != null) {
//         messageData!.senderData = SenderData.fromJson(json['Chat']['User']);
//       }
//     } else if (json['message_data'] != null) {
//       messageData = MessageData.fromJson(json['message_data']);
//     }
//   }
// }

// class MessageData {
//   int? id;
//   int? messageId;
//   String? message;
//   String? messageType;
//   String? url;
//   String? thumbnail;
//   String? audioTime;
//   String? latitude;
//   String? longitude;
//   bool? myMessage;
//   SenderData? senderData;
//   int? messageRead;
//   String? createdAt;
//   String? updatedAt;
//   String? sharedContactName;
//   String? sharedContactNumber;
//   String? sharedContactProfileImage;

//   MessageData({
//     this.id,
//     this.messageId,
//     this.message,
//     this.messageType,
//     this.url,
//     this.thumbnail,
//     this.audioTime,
//     this.latitude,
//     this.longitude,
//     this.myMessage,
//     this.senderData,
//     this.messageRead,
//     this.createdAt,
//     this.updatedAt,
//     this.sharedContactName,
//     this.sharedContactNumber,
//     this.sharedContactProfileImage,
//   });

//   MessageData.fromJson(Map<String, dynamic> json) {
//     id = json['id'] ?? json['message_id'];
//     messageId = json['message_id'];
//     message = json['message'];
//     messageType = json['message_type'];
//     url = json['url'];
//     thumbnail = json['thumbnail'];
//     audioTime = json['audio_time'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     myMessage = json['my_message'];
//     messageRead = json['message_read'];
//     createdAt = json['createdAt'] ?? json['created_at'];
//     updatedAt = json['updatedAt'] ?? json['updated_at'];
//     sharedContactName = json['shared_contact_name'];
//     sharedContactNumber = json['shared_contact_number'];
//     sharedContactProfileImage = json['shared_contact_profile_image'];
//   }
// }

// class SenderData {
//   int? userId;
//   String? phoneNumber;
//   String? firstName;
//   String? lastName;
//   String? userName;
//   String? profileImage;

//   SenderData({
//     this.userId,
//     this.phoneNumber,
//     this.firstName,
//     this.lastName,
//     this.userName,
//     this.profileImage,
//   });

//   SenderData.fromJson(Map<String, dynamic> json) {
//     userId = json['user_id'];
//     phoneNumber = json['phone_number'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     userName = json['user_name'];
//     profileImage = json['profile_image'];
//   }
// }

// pinned_message_model.dart
// pinned_message_model.dart
class PinMessageModel {
  bool? success;
  String? message;
  List<PinnedMessage>? pinnedMessages;

  PinMessageModel({this.success, this.message, this.pinnedMessages});

  PinMessageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    // Handle the new response format with PinMessageList key
    if (json['PinMessageList'] != null) {
      pinnedMessages = <PinnedMessage>[];
      json['PinMessageList'].forEach((v) {
        pinnedMessages!.add(PinnedMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (pinnedMessages != null) {
      data['PinMessageList'] = pinnedMessages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PinnedMessage {
  int? pinMessageId;
  String? duration;
  String? expiresAt;
  String? createdAt;
  String? updatedAt;
  int? messageId;
  int? conversationId;
  int? userId;
  User? user;
  Chat? chat;
  int? otherUserId;
  List<User>? otherUserDetails;

  PinnedMessage({
    this.pinMessageId,
    this.duration,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.messageId,
    this.conversationId,
    this.userId,
    this.user,
    this.chat,
    this.otherUserId,
    this.otherUserDetails,
  });

  PinnedMessage.fromJson(Map<String, dynamic> json) {
    pinMessageId = json['pin_message_id'];
    duration = json['duration'];
    expiresAt = json['expires_at'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    messageId = json['message_id'];
    conversationId = json['conversation_id'];
    userId = json['user_id'];
    otherUserId = json['other_user_id'];

    if (json['User'] != null) {
      user = User.fromJson(json['User']);
    }

    if (json['Chat'] != null) {
      chat = Chat.fromJson(json['Chat']);
    }

    if (json['otherUserDetails'] != null) {
      otherUserDetails = <User>[];
      json['otherUserDetails'].forEach((v) {
        otherUserDetails!.add(User.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pin_message_id'] = pinMessageId;
    data['duration'] = duration;
    data['expires_at'] = expiresAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['message_id'] = messageId;
    data['conversation_id'] = conversationId;
    data['user_id'] = userId;
    data['other_user_id'] = otherUserId;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    if (chat != null) {
      data['Chat'] = chat!.toJson();
    }
    if (otherUserDetails != null) {
      data['otherUserDetails'] =
          otherUserDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? userName;

  User({
    this.profileImage,
    this.userId,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.userName,
  });

  User.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    phoneNumber = json['phone_number'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['user_name'] = userName;
    return data;
  }
}

class Chat {
  String? url;
  String? thumbnail;
  int? messageId;
  String? message;
  String? messageType;
  String? whoSeenTheMessage;
  bool? deleteFromEveryone;
  String? deleteForMe;
  int? messageRead;
  String? videoTime;
  String? audioTime;
  String? latitude;
  String? longitude;
  String? sharedContactName;
  String? sharedContactProfileImage;
  String? sharedContactNumber;
  int? forwardId;
  int? replyId;
  int? statusId;
  String? createdAt;
  String? updatedAt;
  int? senderId;
  int? conversationId;
  Conversation? conversation;

  Chat({
    this.url,
    this.thumbnail,
    this.messageId,
    this.message,
    this.messageType,
    this.whoSeenTheMessage,
    this.deleteFromEveryone,
    this.deleteForMe,
    this.messageRead,
    this.videoTime,
    this.audioTime,
    this.latitude,
    this.longitude,
    this.sharedContactName,
    this.sharedContactProfileImage,
    this.sharedContactNumber,
    this.forwardId,
    this.replyId,
    this.statusId,
    this.createdAt,
    this.updatedAt,
    this.senderId,
    this.conversationId,
    this.conversation,
  });

  Chat.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    thumbnail = json['thumbnail'];
    messageId = json['message_id'];
    message = json['message'];
    messageType = json['message_type'];
    whoSeenTheMessage = json['who_seen_the_message'];
    deleteFromEveryone = json['delete_from_everyone'];
    deleteForMe = json['delete_for_me'];
    messageRead = json['message_read'];
    videoTime = json['video_time'];
    audioTime = json['audio_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    sharedContactName = json['shared_contact_name'];
    sharedContactProfileImage = json['shared_contact_profile_image'];
    sharedContactNumber = json['shared_contact_number'];
    forwardId = json['forward_id'];
    replyId = json['reply_id'];
    statusId = json['status_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    senderId = json['senderId'];
    conversationId = json['conversation_id'];

    if (json['Conversation'] != null) {
      conversation = Conversation.fromJson(json['Conversation']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['thumbnail'] = thumbnail;
    data['message_id'] = messageId;
    data['message'] = message;
    data['message_type'] = messageType;
    data['who_seen_the_message'] = whoSeenTheMessage;
    data['delete_from_everyone'] = deleteFromEveryone;
    data['delete_for_me'] = deleteForMe;
    data['message_read'] = messageRead;
    data['video_time'] = videoTime;
    data['audio_time'] = audioTime;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['shared_contact_name'] = sharedContactName;
    data['shared_contact_profile_image'] = sharedContactProfileImage;
    data['shared_contact_number'] = sharedContactNumber;
    data['forward_id'] = forwardId;
    data['reply_id'] = replyId;
    data['status_id'] = statusId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['senderId'] = senderId;
    data['conversation_id'] = conversationId;
    if (conversation != null) {
      data['Conversation'] = conversation!.toJson();
    }
    return data;
  }
}

class Conversation {
  String? groupProfileImage;
  int? conversationId;
  bool? isGroup;
  String? groupName;

  Conversation({
    this.groupProfileImage,
    this.conversationId,
    this.isGroup,
    this.groupName,
  });

  Conversation.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json['group_profile_image'];
    conversationId = json['conversation_id'];
    isGroup = json['is_group'];
    groupName = json['group_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_profile_image'] = groupProfileImage;
    data['conversation_id'] = conversationId;
    data['is_group'] = isGroup;
    data['group_name'] = groupName;
    return data;
  }
}
