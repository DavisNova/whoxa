import 'package:whoxachat/Models/reply_msg_model.dart';

class AllStaredMsgModel {
  bool? success;
  String? message;
  List<StarMessageList>? starMessageList;

  AllStaredMsgModel({this.success, this.message, this.starMessageList});

  AllStaredMsgModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['StarMessageList'] != null) {
      starMessageList = <StarMessageList>[];
      json['StarMessageList'].forEach((v) {
        starMessageList!.add(StarMessageList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (starMessageList != null) {
      data['StarMessageList'] =
          starMessageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StarMessageList {
  int? starMessageId;
  String? createdAt;
  String? updatedAt;
  int? messageId;
  int? userId;
  Chat? chat;
  ResData? resData;
  int? otherUserId;
  List<OtherUserDetails>? otherUserDetails;

  StarMessageList(
      {this.starMessageId,
      this.createdAt,
      this.updatedAt,
      this.messageId,
      this.userId,
      this.chat,
      this.resData,
      this.otherUserId,
      this.otherUserDetails});

  StarMessageList.fromJson(Map<String, dynamic> json) {
    starMessageId = json['star_message_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    messageId = json['message_id'];
    userId = json['user_id'];
    chat = json['Chat'] != null ? Chat.fromJson(json['Chat']) : null;
    resData =
        json['resData'] != null ? ResData.fromJson(json['resData']) : null;

    otherUserId = json['other_user_id'];
    if (json['otherUserDetails'] != null) {
      otherUserDetails = <OtherUserDetails>[];
      json['otherUserDetails'].forEach((v) {
        otherUserDetails!.add(OtherUserDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['star_message_id'] = starMessageId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['message_id'] = messageId;
    data['user_id'] = userId;
    if (chat != null) {
      data['Chat'] = chat!.toJson();
    }
    if (resData != null) {
      data['resData'] = resData!.toJson();
    }

    data['other_user_id'] = otherUserId;
    if (otherUserDetails != null) {
      data['otherUserDetails'] =
          otherUserDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chat {
  String? url;
  String? thumbnail;
  int? messageId;
  String? message;
  String? messageType;
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
  bool? deleteFromEveryone;
  String? deleteForMe;
  User? user;
  Conversation? conversation;

  Chat(
      {this.url,
      this.thumbnail,
      this.messageId,
      this.message,
      this.messageType,
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
      this.deleteFromEveryone,
      this.deleteForMe,
      this.user,
      this.conversation});

  Chat.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    thumbnail = json['thumbnail'];
    messageId = json['message_id'];
    message = json['message'];
    messageType = json['message_type'];
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
    deleteFromEveryone = json['delete_from_everyone'];
    deleteForMe = json['delete_for_me'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    conversation = json['Conversation'] != null
        ? Conversation.fromJson(json['Conversation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['thumbnail'] = thumbnail;
    data['message_id'] = messageId;
    data['message'] = message;
    data['message_type'] = messageType;
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
    data['delete_from_everyone'] = deleteFromEveryone;
    data['delete_for_me'] = deleteForMe;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    if (conversation != null) {
      data['Conversation'] = conversation!.toJson();
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

  User(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.userName});

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

class OtherUserDetails {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? userName;

  OtherUserDetails(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.userName});

  OtherUserDetails.fromJson(Map<String, dynamic> json) {
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
