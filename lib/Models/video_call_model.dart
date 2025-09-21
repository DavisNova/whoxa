class VideoCallModel {
  String? responseCode;
  String? message;
  String? token;
  String? callId;
  String? callerName;
  String? receiverName;
  String? callerProfilePic;
  String? receiverProfilePic;
  String? callerId;
  String? receiverId;
  String? status;

  VideoCallModel(
      {this.responseCode,
      this.message,
      this.token,
      this.callId,
      this.callerName,
      this.receiverName,
      this.callerProfilePic,
      this.receiverProfilePic,
      this.callerId,
      this.receiverId,
      this.status});

  VideoCallModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    token = json['token'];
    callId = json['call_id'];
    callerName = json['caller_name'];
    receiverName = json['receiver_name'];
    callerProfilePic = json['caller_profile_pic'];
    receiverProfilePic = json['receiver_profile_pic'];
    callerId = json['caller_id'];
    receiverId = json['receiver_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    data['token'] = token;
    data['call_id'] = callId;
    data['caller_name'] = callerName;
    data['receiver_name'] = receiverName;
    data['caller_profile_pic'] = callerProfilePic;
    data['receiver_profile_pic'] = receiverProfilePic;
    data['caller_id'] = callerId;
    data['receiver_id'] = receiverId;
    data['status'] = status;
    return data;
  }
}
