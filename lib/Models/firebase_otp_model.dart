class FirebaseOtpModel {
  String? responseCode;
  String? status;
  String? message;
  String? phone;
  String? country;
  String? userId;

  FirebaseOtpModel(
      {this.responseCode,
      this.status,
      this.message,
      this.phone,
      this.country,
      this.userId});

  FirebaseOtpModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    phone = json['phone'];
    country = json['country'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['status'] = status;
    data['message'] = message;
    data['phone'] = phone;
    data['country'] = country;
    data['user_id'] = userId;
    return data;
  }
}
