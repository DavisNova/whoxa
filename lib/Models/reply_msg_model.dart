class ReplyMsgModel {
  bool? success;
  String? message;
  int? senderId;
  ResData? resData;

  ReplyMsgModel({this.success, this.message, this.senderId, this.resData});

  ReplyMsgModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    senderId = json['senderId'];
    resData =
        json['resData'] != null ? ResData.fromJson(json['resData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['senderId'] = senderId;
    if (resData != null) {
      data['resData'] = resData!.toJson();
    }
    return data;
  }
}

class ResData {
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
  bool? myMessage;
  SenderData? senderData;

  ResData(
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
      this.myMessage,
      this.senderData});

  ResData.fromJson(Map<String, dynamic> json) {
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
    myMessage = json['myMessage'];
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
    data['myMessage'] = myMessage;
    if (senderData != null) {
      data['senderData'] = senderData!.toJson();
    }
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
