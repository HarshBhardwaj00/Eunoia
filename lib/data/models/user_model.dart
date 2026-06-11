class UserModel {
  final String uid;
  final String name;
  final int age;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.createdAt,
  });

  /// Convert UserModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create UserModel from Firestore document Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create UserModel from Firestore document snapshot
  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] as String,
      age: data['age'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}
