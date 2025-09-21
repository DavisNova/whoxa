class GetUserChatList {
  String? responseCode;
  String? message;
  List<MessagesList>? messagesList;
  String? status;

  GetUserChatList(
      {this.responseCode, this.message, this.messagesList, this.status});

  GetUserChatList.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    if (json['messages list'] != null) {
      messagesList = <MessagesList>[];
      json['messages list'].forEach((v) {
        messagesList!.add(MessagesList.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (messagesList != null) {
      data['messages list'] =
          messagesList!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class MessagesList {
  String? id;
  String? fromUser;
  String? toUser;
  String? chatId;
  String? lastMessage;
  String? lastMessageCreatedDate;
  String? lastMessageCreatedTime;
  String? lastMessageCreated;
  String? type;
  String? url;
  String? msg;
  String? isStartedMsg;
  String? isArchived;
  String? profileBlock;
  String? profilePic;
  String? username;
  String? firstname;
  String? groupId;
  String? groupName;

  MessagesList(
      {this.id,
      this.fromUser,
      this.toUser,
      this.chatId,
      this.lastMessage,
      this.lastMessageCreatedDate,
      this.lastMessageCreatedTime,
      this.lastMessageCreated,
      this.type,
      this.url,
      this.msg,
      this.isStartedMsg,
      this.isArchived,
      this.profileBlock,
      this.profilePic,
      this.username,
      this.firstname,
      this.groupId,
      this.groupName});

  MessagesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromUser = json['from_user'];
    toUser = json['to_user'];
    chatId = json['chat_id'];
    lastMessage = json['last_message'];
    lastMessageCreatedDate = json['last_message_created_date'];
    lastMessageCreatedTime = json['last_message_created_time'];
    lastMessageCreated = json['last_message_created'];
    type = json['type'];
    url = json['url'];
    msg = json['msg'];
    isStartedMsg = json['is_started_msg'];
    isArchived = json['is_archived'];
    profileBlock = json['profile_block'];
    profilePic = json['profile_pic'];
    username = json['username'];
    firstname = json['firstname'];
    groupId = json['group_id'];
    groupName = json['group_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_user'] = fromUser;
    data['to_user'] = toUser;
    data['chat_id'] = chatId;
    data['last_message'] = lastMessage;
    data['last_message_created_date'] = lastMessageCreatedDate;
    data['last_message_created_time'] = lastMessageCreatedTime;
    data['last_message_created'] = lastMessageCreated;
    data['type'] = type;
    data['url'] = url;
    data['msg'] = msg;
    data['is_started_msg'] = isStartedMsg;
    data['is_archived'] = isArchived;
    data['profile_block'] = profileBlock;
    data['profile_pic'] = profilePic;
    data['username'] = username;
    data['firstname'] = firstname;
    data['group_id'] = groupId;
    data['group_name'] = groupName;
    return data;
  }
}
