import 'package:encrypt/encrypt.dart' as crypto;

class EncryptionService {
  // 32-character (256-bit) encryption key
  static const String _encryptionKey = 'abcdefghijklmnopqrstuvwxyz123456';
  
  // 16-character (128-bit) IV for AES-CBC
  static const String _iv = '1234567890123456';

  static final crypto.Key _key = crypto.Key.fromUtf8(_encryptionKey);
  static final crypto.IV _ivObj = crypto.IV.fromUtf8(_iv);
  static final crypto.Encrypter _encrypter = crypto.Encrypter(
    crypto.AES(_key, mode: crypto.AESMode.cbc),
  );

  /// Encrypt plaintext using AES-CBC
  static String encryptData(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _ivObj);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  /// Decrypt ciphertext using AES-CBC
  static String decryptData(String cipherText) {
    try {
      final encrypted = crypto.Encrypted.fromBase64(cipherText);
      final decrypted = _encrypter.decrypt(encrypted, iv: _ivObj);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }
}
