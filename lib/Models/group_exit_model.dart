class ExitGroupModel {
  bool? success;
  String? message;

  ExitGroupModel({this.success, this.message});

  ExitGroupModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}
