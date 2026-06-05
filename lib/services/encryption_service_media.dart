import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static const int _ivLength = 16;

  static Future<Uint8List> encryptBytes(
      Uint8List bytes,
      encrypt.Key key,
      ) async {
    try {
      final iv = encrypt.IV.fromSecureRandom(_ivLength);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          key,
          mode: encrypt.AESMode.cbc,
        ),
      );

      final encrypted = encrypter.encryptBytes(
        bytes,
        iv: iv,
      );

      return Uint8List.fromList([
        ...iv.bytes,
        ...encrypted.bytes,
      ]);
    } catch (e) {
      throw Exception('Failed to encrypt bytes: $e');
    }
  }

  static Future<Uint8List> decryptBytes(
      Uint8List combined,
      encrypt.Key key, {
        String? ivBase64,
      }) async {
    try {
      late Uint8List ivBytes;
      late Uint8List ciphertext;

      if (ivBase64 != null) {
        ivBytes = Uint8List.fromList(
          base64Decode(ivBase64),
        );
        ciphertext = combined;
      } else {
        if (combined.length < _ivLength) {
          throw Exception('Invalid encrypted data');
        }

        ivBytes = combined.sublist(0, _ivLength);
        ciphertext = combined.sublist(_ivLength);
      }

      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          key,
          mode: encrypt.AESMode.cbc,
        ),
      );

      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(ciphertext),
        iv: encrypt.IV(ivBytes),
      );

      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw Exception('Failed to decrypt bytes: $e');
    }
  }
}