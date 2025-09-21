class AddContactModel {
  String? message;
  bool? success;
  int? userId;

  AddContactModel({this.message, this.success, this.userId});

  AddContactModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    data['user_id'] = userId;
    return data;
  }
}
