class StickerModel {
  final int interactiveMediaId;
  final String fileLocation;
  final String type;
  final String title;
  final bool isPremium;
  final bool status;
  final String createdAt;
  final String updatedAt;

  StickerModel({
    required this.interactiveMediaId,
    required this.fileLocation,
    required this.type,
    required this.title,
    required this.isPremium,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      interactiveMediaId: json['interactive_media_id'] ?? 0,
      fileLocation: json['file_location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      isPremium: json['is_premium'] ?? false,
      status: json['status'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interactive_media_id': interactiveMediaId,
      'file_location': fileLocation,
      'type': type,
      'title': title,
      'is_premium': isPremium,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Convenience getters for backward compatibility
  String get id => interactiveMediaId.toString();
  String get name => title;
  String get url => fileLocation;
  String get thumbnailUrl => fileLocation;
}

// sticker_model.dart
class StickerResponse {
  bool? success;
  String? message;
  List<StickerItem>? stickers;
  Pagination? pagination;

  StickerResponse({this.success, this.message, this.stickers, this.pagination});

  StickerResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['wallpapers'] != null) {
      stickers = <StickerItem>[];
      json['wallpapers'].forEach((v) {
        stickers!.add(StickerItem.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (stickers != null) {
      data['wallpapers'] = stickers!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class StickerItem {
  String? fileLocation;
  int? interactiveMediaId;
  String? type;
  String? title;
  bool? isPremium;
  bool? status;
  String? createdAt;
  String? updatedAt;

  StickerItem({
    this.fileLocation,
    this.interactiveMediaId,
    this.type,
    this.title,
    this.isPremium,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  StickerItem.fromJson(Map<String, dynamic> json) {
    fileLocation = json['file_location'];
    interactiveMediaId = json['interactive_media_id'];
    type = json['type'];
    title = json['title'];
    isPremium = json['is_premium'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_location'] = fileLocation;
    data['interactive_media_id'] = interactiveMediaId;
    data['type'] = type;
    data['title'] = title;
    data['is_premium'] = isPremium;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Pagination {
  int? count;
  int? currentPage;
  int? totalPages;

  Pagination({this.count, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    return data;
  }
}
