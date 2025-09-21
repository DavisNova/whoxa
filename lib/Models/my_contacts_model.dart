class MyContactModel {
  final bool? success;
  final String? message;
  final List<MyContactList>? myContactList;
  final Pagination? pagination;

  MyContactModel({
    this.success,
    this.message,
    this.myContactList,
    this.pagination,
  });

  factory MyContactModel.fromJson(Map<String, dynamic> json) {
    return MyContactModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      myContactList: json["myContactList"] == null
          ? []
          : List<MyContactList>.from((json["myContactList"] as List)
              .map((e) => MyContactList.fromJson(e))),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "myContactList": myContactList!.map((e) => e.toJson()).toList(),
      "pagination": pagination?.toJson(),
    };
  }
}

class Pagination {
  final int count;
  final int currentPage;
  final int totalPages;

  Pagination({
    required this.count,
    required this.currentPage,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      count: json["count"] ?? 0,
      currentPage: json["currentPage"] ?? 1,
      totalPages: json["totalPages"] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "count": count,
      "currentPage": currentPage,
      "totalPages": totalPages,
    };
  }
}

class MyContactList {
  final int contactId;
  final String phoneNumber;
  final String fullName;
  final int? userId;
  final UserDetails? userDetails;

  MyContactList({
    required this.contactId,
    required this.phoneNumber,
    required this.fullName,
    this.userId,
    this.userDetails,
  });

  factory MyContactList.fromJson(Map<String, dynamic> json) {
    return MyContactList(
      // Parse contactId safely - convert to int if it's a string
      contactId: json["contact_id"] is String
          ? int.tryParse(json["contact_id"]) ?? 0
          : json["contact_id"] ?? 0,

      // Always convert phone_number to string
      phoneNumber: json["phone_number"]?.toString() ?? "",

      // Use empty string as fallback for fullName
      fullName: json["full_name"] ?? "",

      // Parse userId safely - handle if it's a string
      userId: json["user_id"] is String
          ? int.tryParse(json["user_id"])
          : json["user_id"],

      // Parse userDetails if present
      userDetails: json["userDetails"] == null
          ? null
          : UserDetails.fromJson(json["userDetails"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "contact_id": contactId,
      "phone_number": phoneNumber,
      "full_name": fullName,
      "user_id": userId,
      "userDetails": userDetails?.toJson(),
    };
  }
}

class UserDetails {
  final String profileImage;
  final int? userId;
  final String userName;
  final VerificationType? verificationType;

  UserDetails({
    required this.profileImage,
    this.userId,
    required this.userName,
    this.verificationType,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      profileImage: json["profile_image"] ?? "",
      userId: json["user_id"],
      userName: json["user_name"] ?? "",
      verificationType: json["Varification_type"] == null
          ? null
          : VerificationType.fromJson(json["Varification_type"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "profile_image": profileImage,
      "user_id": userId,
      "user_name": userName,
      "Varification_type": verificationType?.toJson(),
    };
  }
}

class VerificationType {
  final String logo;
  final int verificationTypeId;
  final String title;
  final bool isPaymentRequired;
  final bool isGroup;
  final int cycle;
  final String createdAt;
  final String updatedAt;

  VerificationType({
    required this.logo,
    required this.verificationTypeId,
    required this.title,
    required this.isPaymentRequired,
    required this.isGroup,
    required this.cycle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationType.fromJson(Map<String, dynamic> json) {
    try {
      // Get cycle value and handle string case
      int cycleValue = 0;
      if (json["cycle"] != null) {
        if (json["cycle"] is String) {
          cycleValue = int.tryParse(json["cycle"]) ?? 0;
        } else if (json["cycle"] is int) {
          cycleValue = json["cycle"];
        }
      }

      return VerificationType(
        logo: json["logo"] ?? "",
        verificationTypeId: json["verification_type_id"] is String
            ? int.tryParse(json["verification_type_id"]) ?? 0
            : json["verification_type_id"] ?? 0,
        title: json["titile"] ??
            "", // Note: maintaining the typo from the response
        isPaymentRequired: json["is_payment_required"] ?? false,
        isGroup: json["is_group"] ?? false,
        cycle: cycleValue, // Use the safely parsed cycle value
        createdAt: json["createdAt"] ?? "",
        updatedAt: json["updatedAt"] ?? "",
      );
    } catch (e) {
      print("Error parsing VerificationType: $e");
      return VerificationType(
        logo: "",
        verificationTypeId: 0,
        title: "Error",
        isPaymentRequired: false,
        isGroup: false,
        cycle: 0,
        createdAt: "",
        updatedAt: "",
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "logo": logo,
      "verification_type_id": verificationTypeId,
      "titile": title, // Note: maintaining the typo from the response
      "is_payment_required": isPaymentRequired,
      "is_group": isGroup,
      "cycle": cycle,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
