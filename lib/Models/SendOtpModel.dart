// ignore_for_file: file_names

class SendOtp {
  String? responseCode;
  String? message;

  SendOtp({this.responseCode, this.message});

  SendOtp.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    return data;
  }
}
