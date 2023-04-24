class WordModel {
  final String krill;
  final String traditional;

  WordModel({
    required this.krill,
    required this.traditional,
  });

  WordModel.fromJson(Map<String, dynamic> json)
      : krill = json['krill'] ?? '',
        traditional = json['traditional'] ?? '';
}
