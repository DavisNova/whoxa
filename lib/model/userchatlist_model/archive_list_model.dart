class UserArchiveListModel {
  List<ArchiveList>? archiveList;

  UserArchiveListModel({this.archiveList});

  UserArchiveListModel.fromJson(Map<String, dynamic> json) {
    if (json['archiveList'] != null) {
      archiveList = <ArchiveList>[];
      json['archiveList'].forEach((v) {
        archiveList!.add(ArchiveList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (archiveList != null) {
      data['archiveList'] = archiveList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ArchiveList {
  int? conversationId;
  bool? isGroup;
  String? groupName;
  String? groupProfileImage;
  String? lastMessage;
  String? lastMessageType;
  int? userId;
  String? userName;
  String? phoneNumber;
  String? profileImage;
  bool? isBlock;
  String? createdAt;
  String? updatedAt;
  int? unreadCount;
  VarificationType? verificationType;

  ArchiveList(
      {this.conversationId,
      this.isGroup,
      this.groupName,
      this.groupProfileImage,
      this.lastMessage,
      this.lastMessageType,
      this.userId,
      this.userName,
      this.phoneNumber,
      this.profileImage,
      this.isBlock,
      this.createdAt,
      this.updatedAt,
      this.unreadCount,
      this.verificationType});

  ArchiveList.fromJson(Map<String, dynamic> json) {
    conversationId = json['conversation_id'];
    isGroup = json['is_group'];
    groupName = json['group_name'];
    groupProfileImage = json['group_profile_image'];
    lastMessage = json['last_message'];
    lastMessageType = json['last_message_type'];
    userId = json['user_id'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    profileImage = json['profile_image'];
    isBlock = json['is_block'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    unreadCount = json['unread_count'];
    verificationType = json['Varification_type'] != null
        ? VarificationType.fromJson(json['Varification_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversation_id'] = conversationId;
    data['is_group'] = isGroup;
    data['group_name'] = groupName;
    data['group_profile_image'] = groupProfileImage;
    data['last_message'] = lastMessage;
    data['last_message_type'] = lastMessageType;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['phone_number'] = phoneNumber;
    data['profile_image'] = profileImage;
    data['is_block'] = isBlock;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['unread_count'] = unreadCount;
    if (verificationType != null) {
      data['Varification_type'] = verificationType!.toJson();
    }
    return data;
  }
}

class VarificationType {
  String? logo;
  int? verificationTypeId;
  String? titile;
  bool? isPaymentRequired;
  bool? isGroup;
  int? cycle;
  String? createdAt;
  String? updatedAt;

  VarificationType({
    this.logo,
    this.verificationTypeId,
    this.titile,
    this.isPaymentRequired,
    this.isGroup,
    this.cycle,
    this.createdAt,
    this.updatedAt,
  });

  VarificationType.fromJson(Map<String, dynamic> json) {
    try {
      logo = json['logo'];

      // Handle cases where verification_type_id might not be an int
      if (json['verification_type_id'] != null) {
        try {
          if (json['verification_type_id'] is int) {
            verificationTypeId = json['verification_type_id'];
          } else if (json['verification_type_id'] is String) {
            verificationTypeId = int.tryParse(json['verification_type_id']);
          }
        } catch (e) {
          print("Error parsing verification_type_id: $e");
        }
      }

      titile = json['titile'];

      // Safely parse boolean values
      if (json['is_payment_required'] != null) {
        if (json['is_payment_required'] is bool) {
          isPaymentRequired = json['is_payment_required'];
        } else if (json['is_payment_required'] is String) {
          isPaymentRequired =
              json['is_payment_required'].toLowerCase() == 'true';
        }
      }

      if (json['is_group'] != null) {
        if (json['is_group'] is bool) {
          isGroup = json['is_group'];
        } else if (json['is_group'] is String) {
          isGroup = json['is_group'].toLowerCase() == 'true';
        }
      }

      // Handle cycle which might not be an int
      if (json['cycle'] != null) {
        try {
          if (json['cycle'] is int) {
            cycle = json['cycle'];
          } else if (json['cycle'] is String) {
            cycle = int.tryParse(json['cycle']);
          }
        } catch (e) {
          print("Error parsing cycle: $e");
        }
      }

      createdAt = json['createdAt'];
      updatedAt = json['updatedAt'];
    } catch (e) {
      print("Error in VarificationType.fromJson: $e");
      // Set default values if parsing fails
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo'] = logo;
    data['verification_type_id'] = verificationTypeId;
    data['titile'] = titile;
    data['is_payment_required'] = isPaymentRequired;
    data['is_group'] = isGroup;
    data['cycle'] = cycle;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
