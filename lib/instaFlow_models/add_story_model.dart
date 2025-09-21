class AddStoryModel {
  String? responseCode;
  String? message;
  String? status;

  AddStoryModel({this.responseCode, this.message, this.status});

  AddStoryModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}
