class TypingUserModel {
  List<TypingUserList>? typingUserList;

  TypingUserModel({this.typingUserList});

  TypingUserModel.fromJson(Map<String, dynamic> json) {
    if (json['typingUserList'] != null) {
      typingUserList = <TypingUserList>[];
      json['typingUserList'].forEach((v) {
        typingUserList!.add(TypingUserList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (typingUserList != null) {
      data['typingUserList'] = typingUserList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TypingUserList {
  String? userId;
  String? conversationId;

  TypingUserList({this.userId, this.conversationId});

  TypingUserList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    conversationId = json['conversation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['conversation_id'] = conversationId;
    return data;
  }
}
