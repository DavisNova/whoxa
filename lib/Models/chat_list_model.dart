// ignore_for_file: unnecessary_this

class ChatListModel {
  String? responseCode;
  String? message;
  List<MessagesList>? messagesList;
  String? status;

  ChatListModel(
      {this.responseCode, this.message, this.messagesList, this.status});

  ChatListModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    if (json['messages_list'] != null) {
      messagesList = <MessagesList>[];
      json['messages_list'].forEach((v) {
        messagesList!.add(MessagesList.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = this.responseCode;
    data['message'] = this.message;
    if (this.messagesList != null) {
      data['messages_list'] =
          this.messagesList!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class MessagesList {
  String? id;
  String? fromUser;
  String? toUser;
  String? lastMessage;
  String? lastMessageCreatedDate;
  String? lastMessageCreatedTime;
  String? url;
  String? isStartedMsg;
  String? isArchived;
  String? profileBlock;
  String? profilePic;
  String? username;

  MessagesList(
      {this.id,
      this.fromUser,
      this.toUser,
      this.lastMessage,
      this.lastMessageCreatedDate,
      this.lastMessageCreatedTime,
      this.url,
      this.isStartedMsg,
      this.isArchived,
      this.profileBlock,
      this.profilePic,
      this.username});

  MessagesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromUser = json['from_user'];
    toUser = json['to_user'];
    lastMessage = json['last_message'];
    lastMessageCreatedDate = json['last_message_created_date'];
    lastMessageCreatedTime = json['last_message_created_time'];
    url = json['url'];
    isStartedMsg = json['is_started_msg'];
    isArchived = json['is_archived'];
    profileBlock = json['profile_block'];
    profilePic = json['profile_pic'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['from_user'] = this.fromUser;
    data['to_user'] = this.toUser;
    data['last_message'] = this.lastMessage;
    data['last_message_created_date'] = this.lastMessageCreatedDate;
    data['last_message_created_time'] = this.lastMessageCreatedTime;
    data['url'] = this.url;
    data['is_started_msg'] = this.isStartedMsg;
    data['is_archived'] = this.isArchived;
    data['profile_block'] = this.profileBlock;
    data['profile_pic'] = this.profilePic;
    data['username'] = this.username;
    return data;
  }
}
