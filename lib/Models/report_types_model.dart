class ReportTypesModel {
  final bool? success;
  final String? message;
  final List<ReportType>? reportType;
  final Pagination? pagination;

  ReportTypesModel({
    this.success,
    this.message,
    this.reportType,
    this.pagination,
  });

  factory ReportTypesModel.fromJson(Map<String, dynamic> json) {
    return ReportTypesModel(
      success: json['success'],
      message: json['message'],
      reportType: json['data'] != null
          ? List<ReportType>.from(
              json['data'].map((x) => ReportType.fromJson(x)))
          : [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': reportType?.map((x) => x.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class ReportType {
  final int? reportId;
  final String? reportTitle;
  final String? reportDetails;
  final String? reportFor;
  final bool? status;
  final String? createdAt;
  final String? updatedAt;

  ReportType({
    this.reportId,
    this.reportTitle,
    this.reportDetails,
    this.reportFor,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportType.fromJson(Map<String, dynamic> json) {
    return ReportType(
      reportId: json['report_id'],
      reportTitle: json['report_title'],
      reportDetails: json['report_details'],
      reportFor: json['report_for'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'report_title': reportTitle,
      'report_details': reportDetails,
      'report_for': reportFor,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Pagination {
  final int? total;
  final int? page;
  final int? pageSize;
  final int? totalPages;

  Pagination({
    this.total,
    this.page,
    this.pageSize,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }
}
