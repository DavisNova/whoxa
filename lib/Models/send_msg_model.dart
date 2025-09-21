class SendMsgModel {
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
  String? sharedContactNumber;
  int? forwardId;
  int? replyId;
  int? statusId;
  String? createdAt;
  String? updatedAt;
  int? senderId;
  int? conversationId;
  bool? isStarMessage;
  bool? deleteFromEveryone;
  String? deleteForMe;
  bool? myMessage;
  List<StatusData>? statusData;
  SenderData? senderData;

  SendMsgModel(
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
      this.sharedContactNumber,
      this.forwardId,
      this.replyId,
      this.statusId,
      this.createdAt,
      this.updatedAt,
      this.senderId,
      this.conversationId,
      this.isStarMessage,
      this.deleteFromEveryone,
      this.deleteForMe,
      this.myMessage,
      this.statusData,
      this.senderData});

  SendMsgModel.fromJson(Map<String, dynamic> json) {
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
    sharedContactNumber = json['shared_contact_number'];
    forwardId = json['forward_id'];
    replyId = json['reply_id'];
    statusId = json['status_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    senderId = json['senderId'];
    conversationId = json['conversation_id'];
    isStarMessage = json['is_star_message'];
    deleteFromEveryone = json['delete_from_everyone'];
    deleteForMe = json['delete_for_me'];
    myMessage = json['myMessage'];
    if (json['statusData'] != null) {
      statusData = <StatusData>[];
      json['statusData'].forEach((v) {
        statusData!.add(StatusData.fromJson(v));
      });
    }
    senderData = json['senderData'] != null
        ? SenderData.fromJson(json['senderData'])
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
    data['shared_contact_number'] = sharedContactNumber;
    data['forward_id'] = forwardId;
    data['reply_id'] = replyId;
    data['status_id'] = statusId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['senderId'] = senderId;
    data['conversation_id'] = conversationId;
    data['is_star_message'] = isStarMessage;
    data['delete_from_everyone'] = deleteFromEveryone;
    data['delete_for_me'] = deleteForMe;
    data['myMessage'] = myMessage;
    if (statusData != null) {
      data['statusData'] = statusData!.map((v) => v.toJson()).toList();
    }
    if (senderData != null) {
      data['senderData'] = senderData!.toJson();
    }
    return data;
  }
}

class StatusData {
  int? statusId;
  String? updatedAt;
  String? createdAt;
  List<StatusMedia>? statusMedia;

  StatusData({this.statusId, this.updatedAt, this.createdAt, this.statusMedia});

  StatusData.fromJson(Map<String, dynamic> json) {
    statusId = json['status_id'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
    if (json['StatusMedia'] != null) {
      statusMedia = <StatusMedia>[];
      json['StatusMedia'].forEach((v) {
        statusMedia!.add(StatusMedia.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_id'] = statusId;
    data['updatedAt'] = updatedAt;
    data['createdAt'] = createdAt;
    if (statusMedia != null) {
      data['StatusMedia'] = statusMedia!.map((v) => v.toJson()).toList();
    }
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
    statusText = json['status_text'];
    url = json['url'];
    statusMediaId = json['status_media_id'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_text'] = statusText;
    data['url'] = url;
    data['status_media_id'] = statusMediaId;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class SenderData {
  String? profileImage;
  int? userId;
  String? userName;
  String? firstName;
  String? lastName;
  String? phoneNumber;

  SenderData(
      {this.profileImage,
      this.userId,
      this.userName,
      this.firstName,
      this.lastName,
      this.phoneNumber});

  SenderData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    userName = json['user_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone_number'] = phoneNumber;
    return data;
  }
}
