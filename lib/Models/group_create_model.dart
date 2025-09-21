// class GroupCreateModel {
//   bool? success;
//   String? message;
//   int? conversationId;
//   ConversationDetails? conversationDetails;

//   GroupCreateModel(
//       {this.success,
//       this.message,
//       this.conversationId,
//       this.conversationDetails});

//   GroupCreateModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     conversationId = json['conversation_id'];
//     conversationDetails = json['conversationDetails'] != null
//         ? ConversationDetails.fromJson(json['conversationDetails'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = success;
//     data['message'] = message;
//     data['conversation_id'] = conversationId;
//     if (conversationDetails != null) {
//       data['conversationDetails'] = conversationDetails!.toJson();
//     }
//     return data;
//   }
// }

// class ConversationDetails {
//   String? groupProfileImage;
//   String? groupName;

//   ConversationDetails({this.groupProfileImage, this.groupName});

//   ConversationDetails.fromJson(Map<String, dynamic> json) {
//     groupProfileImage = json['group_profile_image'];
//     groupName = json['group_name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['group_profile_image'] = groupProfileImage;
//     data['group_name'] = groupName;
//     return data;
//   }
// }

class GroupCreateModel {
  bool? success;
  String? message;
  int? conversationId;
  ConversationDetails? conversationDetails;

  GroupCreateModel(
      {this.success,
      this.message,
      this.conversationId,
      this.conversationDetails});

  GroupCreateModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    // Handle the type conversion for conversationId
    if (json['conversation_id'] != null) {
      if (json['conversation_id'] is int) {
        conversationId = json['conversation_id'];
      } else if (json['conversation_id'] is String) {
        // Try to parse the string as an integer
        conversationId = int.tryParse(json['conversation_id']);
      }
    }

    // Fix the key name to match API response (if needed)
    if (json['conversationDetails'] != null) {
      conversationDetails =
          ConversationDetails.fromJson(json['conversationDetails']);
    } else if (json['conversation_details'] != null) {
      // Check for alternative key name
      conversationDetails =
          ConversationDetails.fromJson(json['conversation_details']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['conversation_id'] = conversationId;
    if (conversationDetails != null) {
      data['conversationDetails'] = conversationDetails!.toJson();
    }
    return data;
  }
}

class ConversationDetails {
  String? groupProfileImage;
  String? groupName;
  String? groupDescription; // Added this field

  ConversationDetails(
      {this.groupProfileImage, this.groupName, this.groupDescription});

  ConversationDetails.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json['group_profile_image'];
    groupName = json['group_name'];
    groupDescription = json['group_description']; // Parse the description
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_profile_image'] = groupProfileImage;
    data['group_name'] = groupName;
    data['group_description'] = groupDescription; // Include in JSON output
    return data;
  }
}
