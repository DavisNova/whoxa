class GetBlockListModel {
  bool? success;
  String? message;
  List<BlockUserList>? blockUserList;

  GetBlockListModel({this.success, this.message, this.blockUserList});

  GetBlockListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['blockUserList'] != null) {
      blockUserList = <BlockUserList>[];
      json['blockUserList'].forEach((v) {
        blockUserList!.add(BlockUserList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (blockUserList != null) {
      data['blockUserList'] = blockUserList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BlockUserList {
  int? blockId;
  String? createdAt;
  String? updatedAt;
  int? userId;
  int? conversationId;
  Conversation? conversation;

  BlockUserList(
      {this.blockId,
      this.createdAt,
      this.updatedAt,
      this.userId,
      this.conversationId,
      this.conversation});

  BlockUserList.fromJson(Map<String, dynamic> json) {
    blockId = json['block_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['user_id'];
    conversationId = json['conversation_id'];
    conversation = json['Conversation'] != null
        ? Conversation.fromJson(json['Conversation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['block_id'] = blockId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['user_id'] = userId;
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
  String? lastMessage;
  String? lastMessageType;
  String? createdAt;
  String? updatedAt;
  List<BlockedUserDetails>? blockedUserDetails;

  Conversation(
      {this.groupProfileImage,
      this.conversationId,
      this.isGroup,
      this.groupName,
      this.lastMessage,
      this.lastMessageType,
      this.createdAt,
      this.updatedAt,
      this.blockedUserDetails});

  Conversation.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json['group_profile_image'];
    conversationId = json['conversation_id'];
    isGroup = json['is_group'];
    groupName = json['group_name'];
    lastMessage = json['last_message'];
    lastMessageType = json['last_message_type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['BlockedUserDetails'] != null) {
      blockedUserDetails = <BlockedUserDetails>[];
      json['BlockedUserDetails'].forEach((v) {
        blockedUserDetails!.add(BlockedUserDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_profile_image'] = groupProfileImage;
    data['conversation_id'] = conversationId;
    data['is_group'] = isGroup;
    data['group_name'] = groupName;
    data['last_message'] = lastMessage;
    data['last_message_type'] = lastMessageType;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (blockedUserDetails != null) {
      data['BlockedUserDetails'] =
          blockedUserDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BlockedUserDetails {
  String? profileImage;
  int? userId;
  String? firstName;
  String? lastName;
  String? userName;
  String? phoneNumber;

  BlockedUserDetails(
      {this.profileImage,
      this.userId,
      this.firstName,
      this.lastName,
      this.userName,
      this.phoneNumber});

  BlockedUserDetails.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['user_name'] = userName;
    data['phone_number'] = phoneNumber;
    return data;
  }
}
