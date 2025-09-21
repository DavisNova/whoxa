class OnlineUsersModel {
  List<String>? onlineUserList;

  OnlineUsersModel({this.onlineUserList});

  OnlineUsersModel.fromJson(Map<String, dynamic> json) {
    onlineUserList = json['onlineUserList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['onlineUserList'] = onlineUserList;
    return data;
  }
}
