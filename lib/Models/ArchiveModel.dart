// ignore_for_file: file_names

class ArchiveModel {
  String? responseCode;
  String? message;
  String? status;

  ArchiveModel({this.responseCode, this.message, this.status});

  ArchiveModel.fromJson(Map<String, dynamic> json) {
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
