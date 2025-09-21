class ArchiveListModel {
  String? responseCode;
  String? message;
  int? unreadCount;
  List<MessagesList>? messagesList;
  String? status;

  ArchiveListModel(
      {this.responseCode,
      this.message,
      this.unreadCount,
      this.messagesList,
      this.status});

  ArchiveListModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    unreadCount = json['unread_count'];
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
    data['unread_count'] = unreadCount;
    if (messagesList != null) {
      data['messages list'] = messagesList!.map((v) => v.toJson()).toList();
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
  String? myId;
  String? secondUserId;
  String? isgroup;
  String? lastMessage;
  String? lastMessageCreated;
  String? type;
  String? replyType;
  String? url;
  String? isComeing;
  String? callType;
  String? msg;
  String? personalCount;
  String? profileBlock;
  String? isStartedMsg;
  String? isArchivedMsg;
  String? profilePic;
  String? username;
  String? firstname;
  String? mobile;
  String? groupId;
  String? groupName;
  String? isOnline;
  String? lastSeen;

  MessagesList(
      {this.id,
      this.fromUser,
      this.toUser,
      this.chatId,
      this.myId,
      this.secondUserId,
      this.isgroup,
      this.lastMessage,
      this.lastMessageCreated,
      this.type,
      this.replyType,
      this.url,
      this.isComeing,
      this.callType,
      this.msg,
      this.personalCount,
      this.profileBlock,
      this.isStartedMsg,
      this.isArchivedMsg,
      this.profilePic,
      this.username,
      this.firstname,
      this.mobile,
      this.groupId,
      this.groupName,
      this.isOnline,
      this.lastSeen});

  MessagesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromUser = json['from_user'];
    toUser = json['to_user'];
    chatId = json['chat_id'];
    myId = json['my_id'];
    secondUserId = json['second_user_id'];
    isgroup = json['isgroup'];
    lastMessage = json['last_message'];
    lastMessageCreated = json['last_message_created'];
    type = json['type'];
    replyType = json['reply_type'];
    url = json['url'];
    isComeing = json['is_comeing'];
    callType = json['call_type'];
    msg = json['msg'];
    personalCount = json['personal_count'];
    profileBlock = json['profile_block'];
    isStartedMsg = json['is_started_msg'];
    isArchivedMsg = json['is_archived_msg'];
    profilePic = json['profile_pic'];
    username = json['username'];
    firstname = json['firstname'];
    mobile = json['mobile'];
    groupId = json['group_id'];
    groupName = json['group_name'];
    isOnline = json['is_online'];
    lastSeen = json['last_seen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_user'] = fromUser;
    data['to_user'] = toUser;
    data['chat_id'] = chatId;
    data['my_id'] = myId;
    data['second_user_id'] = secondUserId;
    data['isgroup'] = isgroup;
    data['last_message'] = lastMessage;
    data['last_message_created'] = lastMessageCreated;
    data['type'] = type;
    data['reply_type'] = replyType;
    data['url'] = url;
    data['is_comeing'] = isComeing;
    data['call_type'] = callType;
    data['msg'] = msg;
    data['personal_count'] = personalCount;
    data['profile_block'] = profileBlock;
    data['is_started_msg'] = isStartedMsg;
    data['is_archived_msg'] = isArchivedMsg;
    data['profile_pic'] = profilePic;
    data['username'] = username;
    data['firstname'] = firstname;
    data['mobile'] = mobile;
    data['group_id'] = groupId;
    data['group_name'] = groupName;
    data['is_online'] = isOnline;
    data['last_seen'] = lastSeen;
    return data;
  }
}
