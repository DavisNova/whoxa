class GetAllVideoCallListModel {
  String? responseCode;
  String? message;
  List<VideoCallList>? videoCallList;
  String? status;

  GetAllVideoCallListModel(
      {this.responseCode, this.message, this.videoCallList, this.status});

  GetAllVideoCallListModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    if (json['video_call_list'] != null) {
      videoCallList = <VideoCallList>[];
      json['video_call_list'].forEach((v) {
        videoCallList!.add(VideoCallList.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (videoCallList != null) {
      data['video_call_list'] = videoCallList!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class VideoCallList {
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

  VideoCallList(
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

  VideoCallList.fromJson(Map<String, dynamic> json) {
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
