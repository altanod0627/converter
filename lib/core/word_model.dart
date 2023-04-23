class WordModel {
  final String krill;
  final String traditional;
  final String spell;
  final String spellEnglish;
  final String description;

  WordModel({
    required this.krill,
    required this.traditional,
    required this.spell,
    required this.spellEnglish,
    required this.description,
  });

  WordModel.fromJson(Map<String, dynamic> json)
      : krill = json['krill'] ?? '',
        traditional = json['traditional'] ?? '',
        spell = json['spell'] ?? '',
        spellEnglish = json['spellEnglish'] ?? '',
        description = json['description'] ?? '';
}
