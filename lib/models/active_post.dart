class ActivePost {
  final String id;
  final String postId;
  final String? postThumbnailUrl;
  final bool isActive;

  ActivePost({
    required this.id,
    required this.postId,
    this.postThumbnailUrl,
    required this.isActive,
  });

  factory ActivePost.fromMap(Map<String, dynamic> map) {
    return ActivePost(
      id: map['id'],
      postId: map['post_id'],
      postThumbnailUrl: map['post_thumbnail_url'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'post_thumbnail_url': postThumbnailUrl,
      'is_active': isActive,
    };
  }

  ActivePost copyWith({
    String? id,
    String? postId,
    String? postThumbnailUrl,
    bool? isActive,
  }) {
    return ActivePost(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      postThumbnailUrl: postThumbnailUrl ?? this.postThumbnailUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
