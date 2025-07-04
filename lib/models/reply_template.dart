class ReplyTemplate {
  final String id;
  final String category;
  final String templateText;

  ReplyTemplate({
    required this.id,
    required this.category,
    required this.templateText,
  });

  factory ReplyTemplate.fromMap(Map<String, dynamic> map) {
    return ReplyTemplate(
      id: map['id'],
      category: map['category'],
      templateText: map['template_text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'template_text': templateText,
    };
  }
}
