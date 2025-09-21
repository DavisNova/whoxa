class LanguageTranslationModel {
  String? languageAlignment;
  bool? success;
  String? message;
  String? language;
  List<Results>? results;

  LanguageTranslationModel(
      {this.languageAlignment,
      this.success,
      this.message,
      this.language,
      this.results});

  LanguageTranslationModel.fromJson(Map<String, dynamic> json) {
    languageAlignment = json['language_alignment'];
    success = json['success'];
    message = json['message'];
    language = json['language'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['language_alignment'] = languageAlignment;
    data['success'] = success;
    data['message'] = message;
    data['language'] = language;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? key;
  String? translation;

  Results({this.key, this.translation});

  Results.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    translation = json['Translation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['Translation'] = translation;
    return data;
  }
}
