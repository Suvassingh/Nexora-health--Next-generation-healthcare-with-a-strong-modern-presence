
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:patient_app/models/encrypted_message.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  //   RSA KEY GENERATION  

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

  //   SERIALIZATION  

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
      BigInt.parse(map['n'], radix: 16),
      BigInt.parse(map['e'], radix: 16),
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
      BigInt.parse(map['n'], radix: 16),
      BigInt.parse(map['d'], radix: 16),
      BigInt.parse(map['p'], radix: 16),
      BigInt.parse(map['q'], radix: 16),
    );
  }

  //   RSA ENCRYPTION  

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

  //   AES KEY  

  static encrypt.Key generateAESKey() =>
      encrypt.Key.fromSecureRandom(32);

  //   AES STRING ENCRYPTION    

  static EncryptedMessage encryptWithAES(
      String plaintext,
      encrypt.Key key,
      ) {
    final iv = encrypt.IV.fromSecureRandom(12);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    return EncryptedMessage(
      content: encrypted.base64,
      iv: iv.base64,
    );
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


  //   AES BYTE ENCRYPTION  

  /// Encrypts raw bytes. Returns [12-byte IV | ciphertext].
  static Future<Uint8List> encryptBytes(
      Uint8List plainBytes, encrypt.Key key) async {
    final iv = encrypt.IV.fromSecureRandom(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
     return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  /// Decrypts bytes produced by [encryptBytes]. Expects [12-byte IV | ciphertext].
  static Future<Uint8List> decryptBytes(
      Uint8List combined, encrypt.Key key) async {
    if (combined.length < 12) throw Exception('Invalid encrypted data: too short');
    final ivBytes = combined.sublist(0, 12);
    final ciphertext = combined.sublist(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(ciphertext),
      iv: encrypt.IV(ivBytes),
    );
    return Uint8List.fromList(decrypted);
  }
}

