class BlockUserModel {
  bool? isBlock;
  bool? success;
  String? message;

  BlockUserModel({this.isBlock, this.success, this.message});

  BlockUserModel.fromJson(Map<String, dynamic> json) {
    isBlock = json['is_block'];
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_block'] = isBlock;
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}
