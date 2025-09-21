class GetAllAudioCallListModel {
  String? responseCode;
  String? message;
  List<MissedCallList>? missedCallList;
  String? status;

  GetAllAudioCallListModel(
      {this.responseCode, this.message, this.missedCallList, this.status});

  GetAllAudioCallListModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    if (json['missed_call_list'] != null) {
      missedCallList = <MissedCallList>[];
      json['missed_call_list'].forEach((v) {
        missedCallList!.add(MissedCallList.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (missedCallList != null) {
      data['missed_call_list'] =
          missedCallList!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class MissedCallList {
  String? id;
  String? fromUser;
  String? toUser;
  String? callType;
  String? myId;
  String? secondUserId;
  String? message;
  String? isComeing;
  String? timestamp;
  String? mobileNumber;
  String? profilePic;
  String? username;
  String? groupname;

  MissedCallList(
      {this.id,
      this.fromUser,
      this.toUser,
      this.callType,
      this.myId,
      this.secondUserId,
      this.message,
      this.isComeing,
      this.timestamp,
      this.mobileNumber,
      this.profilePic,
      this.username,
      this.groupname});

  MissedCallList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromUser = json['from_user'];
    toUser = json['to_user'];
    callType = json['call_type'];
    myId = json['my_id'];
    secondUserId = json['second_user_id'];
    message = json['message'];
    isComeing = json['is_comeing'];
    timestamp = json['timestamp'];
    mobileNumber = json['mobile_number'];
    profilePic = json['profile_pic'];
    username = json['username'];
    groupname = json['groupname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_user'] = fromUser;
    data['to_user'] = toUser;
    data['call_type'] = callType;
    data['my_id'] = myId;
    data['second_user_id'] = secondUserId;
    data['message'] = message;
    data['is_comeing'] = isComeing;
    data['timestamp'] = timestamp;
    data['mobile_number'] = mobileNumber;
    data['profile_pic'] = profilePic;
    data['username'] = username;
    data['groupname'] = groupname;
    return data;
  }
}
