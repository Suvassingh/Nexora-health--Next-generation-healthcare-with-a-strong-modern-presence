import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

class EncryptionService {
  //  RSA KEY GENERATION (2048-bit keys, secure random, OAEP padding for encryption)

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair() {
    final secureRandom = FortunaRandom();
    final seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));

    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          secureRandom,
        ),
      );

    final pair = keyGen.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  //  SERIALISATION OF RSA KEYS TO PEM-LIKE STRINGS (for storage in SharedPreferences or secure storage)
  // Store keys as JSON containing hex strings of all BigInt components.
  // Simple, version-agnostic, no ASN1 dependency.

  static String publicKeyToPem(RSAPublicKey key) {
    final map = {
      'n': key.modulus!.toRadixString(16),
      'e': key.exponent!.toRadixString(16),
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  static RSAPublicKey parsePublicKeyFromPem(String pem) {
    final map = jsonDecode(utf8.decode(base64Decode(pem))) as Map;
    return RSAPublicKey(
      BigInt.parse(map['n'] as String, radix: 16),
      BigInt.parse(map['e'] as String, radix: 16),
    );
  }

  static String privateKeyToPem(RSAPrivateKey key) {
    final map = {
      'n': key.modulus!.toRadixString(16),
      'e': key.publicExponent!.toRadixString(16),
      'd': key.privateExponent!.toRadixString(16),
      'p': key.p!.toRadixString(16),
      'q': key.q!.toRadixString(16),
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  static RSAPrivateKey parsePrivateKeyFromPem(String pem) {
    final map = jsonDecode(utf8.decode(base64Decode(pem))) as Map;
    return RSAPrivateKey(
      BigInt.parse(map['n'] as String, radix: 16),
      BigInt.parse(map['d'] as String, radix: 16),
      BigInt.parse(map['p'] as String, radix: 16),
      BigInt.parse(map['q'] as String, radix: 16),
    );
  }

  //  RSA ENCRYPT / DECRYPT WITH OAEP PADDING (for encrypting small data like AES keys or sensitive fields)

  static String encryptWithRSA(String plaintext, RSAPublicKey publicKey) {
    final encrypter = encrypt.Encrypter(
      encrypt.RSA(publicKey: publicKey, encoding: encrypt.RSAEncoding.OAEP),
    );
    return encrypter.encrypt(plaintext).base64;
  }

  static String decryptWithRSA(String ciphertext, RSAPrivateKey privateKey) {
    final encrypter = encrypt.Encrypter(
      encrypt.RSA(privateKey: privateKey, encoding: encrypt.RSAEncoding.OAEP),
    );
    return encrypter.decrypt64(ciphertext);
  }

  //  AES-GCM FOR SYMMETRIC ENCRYPTION (e.g. encrypting data before sending to server)

  static encrypt.Key generateAESKey() => encrypt.Key.fromSecureRandom(32);

  static EncryptedMessage encryptWithAES(String plaintext, encrypt.Key key) {
    final iv = encrypt.IV.fromSecureRandom(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return EncryptedMessage(content: encrypted.base64, iv: iv.base64);
  }

  static String decryptWithAES(
    String ciphertext,
    encrypt.Key key,
    String ivBase64,
  ) {
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    return encrypter.decrypt64(ciphertext, iv: iv);
  }
}

class EncryptedMessage {
  final String content;
  final String iv;
  const EncryptedMessage({required this.content, required this.iv});
}
