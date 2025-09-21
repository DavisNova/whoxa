// ignore_for_file: file_names

class GetRoomIdModel {
  String? roomId;
  bool? success;
  int? messageId;
  int? callId;

  GetRoomIdModel({this.roomId, this.success});

  GetRoomIdModel.fromJson(Map<String, dynamic> json) {
    roomId = json['room_id'];
    success = json['success'];
    messageId = json['message_id'];
    callId = json['call_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['room_id'] = roomId;
    data['success'] = success;
    data['message_id'] = messageId;
    data['call_id'] = callId;
    return data;
  }
}
