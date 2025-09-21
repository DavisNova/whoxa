import 'package:intl/intl.dart';

class LastSeenModel {
  List<LastSeenUserList>? lastSeenUserList;

  LastSeenModel({this.lastSeenUserList});

  LastSeenModel.fromJson(Map<String, dynamic> json) {
    if (json['lastSeenUserList'] != null) {
      lastSeenUserList = <LastSeenUserList>[];
      json['lastSeenUserList'].forEach((v) {
        lastSeenUserList!.add(LastSeenUserList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lastSeenUserList != null) {
      data['lastSeenUserList'] =
          lastSeenUserList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LastSeenUserList {
  int? userId;
  String? updatedAt;

  LastSeenUserList({this.userId, this.updatedAt});

  LastSeenUserList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

String convertToLocalDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return "";
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd MMMM yyyy');
  return formatter.format(dateTime);
}
