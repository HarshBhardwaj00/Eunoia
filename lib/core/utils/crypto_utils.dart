import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Internal salt for pseudonym generation
/// This ensures that even if the algorithm is known, the salt adds an extra layer of security
const String _internalSalt = 'clinical-app-pseudonym-salt-2024';

/// List of adjectives for pseudonym generation
const List<String> _adjectives = [
  'Resilient',
  'Calm',
  'Brave',
  'Wise',
  'Strong',
  'Peaceful',
  'Hopeful',
  'Steadfast',
  'Courageous',
  'Serene',
  'Mindful',
  'Gentle',
  'Confident',
  'Balanced',
  'Harmonious',
];

/// List of animals for pseudonym generation
const List<String> _animals = [
  'Panda',
  'Eagle',
  'Dolphin',
  'Wolf',
  'Bear',
  'Lion',
  'Owl',
  'Fox',
  'Hawk',
  'Deer',
  'Tiger',
  'Whale',
  'Swan',
  'Horse',
  'Elephant',
];

/// Generates a deterministic pseudonym from a Firebase Auth UID
/// 
/// This function:
/// 1. Takes the user's Firebase UID
/// 2. Applies an internal salt string
/// 3. Hashes the combination using SHA-256
/// 4. Converts the hash to a human-readable pseudonym
/// 
/// The same UID will always produce the same pseudonym, ensuring consistency
/// while maintaining anonymity by never exposing the actual UID.
/// 
/// Example output: 'Resilient Panda 42'
/// 
/// [uid] - The Firebase Auth UID to anonymize
/// Returns a deterministic pseudonym string
String generatePseudonym(String uid) {
  // Combine UID with internal salt
  final saltedInput = '$_internalSalt$uid';
  
  // Convert to bytes and hash with SHA-256
  final bytes = utf8.encode(saltedInput);
  final hash = sha256.convert(bytes);
  
  // Convert hash to hex string
  final hexHash = hash.toString();
  
  // Use different parts of the hash to select components
  final adjectiveIndex = _hexToInt(hexHash.substring(0, 2)) % _adjectives.length;
  final animalIndex = _hexToInt(hexHash.substring(2, 4)) % _animals.length;
  final number = _hexToInt(hexHash.substring(4, 8)) % 100;
  
  // Construct pseudonym
  final adjective = _adjectives[adjectiveIndex];
  final animal = _animals[animalIndex];
  
  return '$adjective $animal $number';
}

/// Converts a hex string segment to an integer
int _hexToInt(String hex) {
  return int.parse(hex, radix: 16);
}

/// Validates that a pseudonym was generated from a specific UID
/// 
/// This can be used to verify ownership without exposing the actual UID
/// 
/// [uid] - The Firebase Auth UID to verify
/// [pseudonym] - The pseudonym to check against
/// Returns true if the pseudonym matches the UID
bool verifyPseudonym(String uid, String pseudonym) {
  return generatePseudonym(uid) == pseudonym;
}
