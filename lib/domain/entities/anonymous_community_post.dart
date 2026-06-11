/// Abstract entity schema for an Anonymous Community Post
/// Firebase UIDs must be stripped from community collections
/// Uses SHA-256 pseudonyms for posting to maintain anonymity
/// All sensitive content must be encrypted before storage using AES-256
abstract class AnonymousCommunityPost {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String pseudonym; // SHA-256 hash of user identifier
  final String encryptedContent;
  final String encryptionKeyHash;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final List<String> supportingComments; // Encrypted comment IDs
  final bool isModerated;
  
  const AnonymousCommunityPost({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.pseudonym,
    required this.encryptedContent,
    required this.encryptionKeyHash,
    this.tags = const [],
    this.upvotes = 0,
    this.downvotes = 0,
    this.supportingComments = const [],
    this.isModerated = false,
  });
}
