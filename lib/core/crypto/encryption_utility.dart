import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Encryption utility class for AES-256 encryption/decryption
///
/// This class provides secure encryption operations for all sensitive data
/// before it reaches any cache (Hive) or network operation (Cloud Firestore).
///
/// Usage flow:
/// 1. Raw text journal entry: "I feel anxious about my presentation tomorrow"
/// 2. Encryption process: AES-256 with device-specific key
/// 3. Ciphertext output: "U2FsdGVkX1+7wX8j9K2mN5pQrT8vL3xW7yH4zA6bC9dE2fG5hI8jK1lM3nO6pQ="
/// 4. Only ciphertext is stored in Hive or sent to Firestore
class EncryptionUtility {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyKey = 'device_encryption_key';

  /// Initialize or retrieve the device-specific encryption key
  ///
  /// This key is stored securely in the device's keychain/keystore
  /// and never leaves the device. Each device has its own unique key.
  static Future<Key> getOrGenerateEncryptionKey() async {
    String? existingKey = await _secureStorage.read(key: _encryptionKeyKey);

    if (existingKey != null) {
      try {
        // Return existing key from secure storage
        return Key.fromBase64(existingKey);
      } catch (e) {
        // Key is corrupted, clear it and generate a new one
        await _secureStorage.delete(key: _encryptionKeyKey);
      }
    }

    // Generate a new 32-byte (256-bit) key for AES-256
    final randomKey = Key.fromSecureRandom(32);
    await _secureStorage.write(key: _encryptionKeyKey, value: randomKey.base64);

    return randomKey;
  }

  /// Get or generate an initialization vector (IV)
  ///
  /// IV ensures that identical plaintext encrypts to different ciphertext
  /// each time, preventing pattern analysis attacks.
  static IV _generateIV() {
    return IV.fromSecureRandom(16);
  }

  /// Encrypt raw text to secure ciphertext
  ///
  /// Example transformation:
  /// Input: "I feel anxious about my presentation tomorrow"
  /// Output: "U2FsdGVkX1+7wX8j9K2mN5pQrT8vL3xW7yH4zA6bC9dE2fG5hI8jK1lM3nO6pQ="
  ///
  /// The ciphertext is base64 encoded for safe storage and transmission.
  /// Never store or transmit the raw plaintext.
  static Future<String> encryptText(String plainText) async {
    try {
      final key = await getOrGenerateEncryptionKey();
      final iv = _generateIV();
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Encrypt the plaintext
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV and encrypted data for storage
      // Format: base64(iv) + ':' + base64(encryptedData)
      final combined = '${iv.base64}:${encrypted.base64}';

      return combined;
    } catch (e) {
      throw EncryptionException('Failed to encrypt text: $e');
    }
  }

  /// Decrypt ciphertext back to raw text
  ///
  /// Reverse of encryptText:
  /// Input: "U2FsdGVkX1+7wX8j9K2mN5pQrT8vL3xW7yH4zA6bC9dE2fG5hI8jK1lM3nO6pQ="
  /// Output: "I feel anxious about my presentation tomorrow"
  static Future<String> decryptText(String cipherText) async {
    try {
      final key = await getOrGenerateEncryptionKey();
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Split the combined string to extract IV and encrypted data
      final parts = cipherText.split(':');
      if (parts.length != 2) {
        throw EncryptionException('Invalid ciphertext format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      // Decrypt the data
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;
    } catch (e) {
      throw EncryptionException('Failed to decrypt text: $e');
    }
  }

  /// Generate a SHA-256 hash of a string for pseudonym generation
  ///
  /// Used for creating anonymous community post pseudonyms.
  /// The hash is one-way and cannot be reversed to the original UID.
  static String generateSHA256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a key hash for verification purposes
  ///
  /// This allows verification that the correct key is being used
  /// without exposing the actual key.
  static Future<String> generateKeyHash() async {
    final key = await getOrGenerateEncryptionKey();
    final bytes = key.bytes;
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clear the encryption key from secure storage
  ///
  /// WARNING: This will make all previously encrypted data unrecoverable.
  /// Only use this for testing or complete data reset scenarios.
  static Future<void> clearEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyKey);
  }
}

/// Custom exception for encryption-related errors
class EncryptionException implements Exception {
  final String message;

  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
