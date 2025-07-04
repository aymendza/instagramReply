class Comment {
  final String id;
  final String commenterName;
  final String commentText;
  final String status;
  final DateTime createdAt;
  final String commentType;
  final Map<String, dynamic>? aiAnalysis;
  String replyText;

  Comment({
    required this.id,
    required this.commenterName,
    required this.commentText,
    required this.status,
    required this.createdAt,
    required this.commentType,
    this.aiAnalysis,
    this.replyText = '',
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      commenterName: map['commenter_name'],
      commentText: map['comment_text'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      commentType: map['comment_type'],
      aiAnalysis: map['analysis'],
      replyText: map['reply_text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commenter_name': commenterName,
      'comment_text': commentText,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'comment_type': commentType,
      'analysis': aiAnalysis,
      'reply_text': replyText,
    };
  }
}
