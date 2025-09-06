class Article {
  String aid;
  String name;
  String title;
  List<String> content;
  bool isActive;

  Article({
    required this.aid,
    required this.name,
    required this.title,
    required this.content,
    required this.isActive,
  });

  factory Article.empty() => Article(
      aid: '', name: '', title: '', content: <String>[], isActive: true);

  factory Article.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final raw = json['content'];
    final List<String> normalizedContent;
    if (raw is List) {
      normalizedContent = raw.map((e) => e.toString()).toList();
    } else if (raw is String) {
      normalizedContent = raw
          .split(RegExp(r'\r?\n'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      normalizedContent = <String>[];
    }

    return Article(
      aid: id,
      name: (json['name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: normalizedContent,
      isActive: json['isActive'] == true ||
          json['isActive'] == 1 ||
          (json['isActive']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'content': content,
        'isActive': isActive,
      };

  Article copyWith({
    String? aid,
    String? name,
    String? title,
    List<String>? content,
    bool? isActive,
  }) {
    return Article(
      aid: aid ?? this.aid,
      name: name ?? this.name,
      title: title ?? this.title,
      content: content ?? List<String>.from(this.content),
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'Article(aid: $aid, name: $name, title: $title, content: ${content.length} lines, isActive: $isActive)';
}
