class PostModel {
  final String id;
  final String authorId;
  final String content;
  final int timestamp;
  final String? moodTag;
  final int supportCount;

  PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.moodTag,
    this.supportCount = 0,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      authorId: map['authorId'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as int,
      moodTag: map['moodTag'] as String?,
      supportCount: (map['supportCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'content': content,
      'timestamp': timestamp,
      'moodTag': moodTag,
      'supportCount': supportCount,
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? content,
    int? timestamp,
    String? moodTag,
    int? supportCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      moodTag: moodTag ?? this.moodTag,
      supportCount: supportCount ?? this.supportCount,
    );
  }
}
