// To parse this JSON data, do
//
//     final addStatusResponseModel = addStatusResponseModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

AddStatusResponseModel addStatusResponseModelFromJson(String str) =>
    AddStatusResponseModel.fromJson(json.decode(str));

String addStatusResponseModelToJson(AddStatusResponseModel data) =>
    json.encode(data.toJson());

class AddStatusResponseModel {
  AddStatusResponseModel({
    this.responseCode,
    this.message,
    this.status,
  });

  String? responseCode;
  String? message;
  String? status;

  factory AddStatusResponseModel.fromJson(Map<String, dynamic> json) =>
      AddStatusResponseModel(
        responseCode: json["response_code"],
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "message": message,
        "status": status,
      };
}
