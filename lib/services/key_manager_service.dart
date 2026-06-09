import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'encryption_service.dart';

class KeyManagerService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: false,
    ),
  );

  static final _supabase = Supabase.instance.client;
  static String get _currentUserId =>
      _supabase.auth.currentUser!.id;

  static Future<void> ensureKeyPair() async {
    final stored = await _storage.read(
      key: 'private_key_$_currentUserId',
    );

    if (stored == null) {
      print('No private key — regenerating for PATIENT...');
      await _regenerateAndReEncrypt();
    }
  }

  static Future<void> _regenerateAndReEncrypt() async {
    // 1. Generate new key pair
    final keyPair = EncryptionService.generateRSAKeyPair();
    final publicPem = EncryptionService.publicKeyToPem(keyPair.publicKey);
    final privatePem = EncryptionService.privateKeyToPem(keyPair.privateKey);

    // 2. Save locally
    await _storage.write(
      key: 'private_key_$_currentUserId',
      value: privatePem,
    );

    // 3. Upload public key
    await _supabase
        .from('user_profiles')
        .update({'public_key': publicPem})
        .eq('id', _currentUserId);

    // 4. Re-encrypt conversations
    await _reEncryptConversations(keyPair);
  }

  static Future<void> _reEncryptConversations(
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair,
      ) async {
    // PATIENT: fetch by patient_id
    // doctor_id here is UUID (doctor's user_id)
    final conversations = await _supabase
        .from('conversations')
        .select('id, doctor_id')
        .eq('patient_id', _currentUserId);

    for (final conv in conversations) {
      try {
        final newAesKey = EncryptionService.generateAESKey();
        final newAesB64 = newAesKey.base64;

        // doctor_id in conversations = doctor's user_id (UUID)
        final doctorProfile = await _supabase
            .from('user_profiles')
            .select('public_key')
            .eq('id', conv['doctor_id'])
            .maybeSingle();

        final doctorKeyPem = doctorProfile?['public_key'] as String?;

        final encForPatient = EncryptionService.encryptWithRSA(
          newAesB64, keyPair.publicKey,
        );

        if (doctorKeyPem != null) {
          final encForDoctor = EncryptionService.encryptWithRSA(
            newAesB64,
            EncryptionService.parsePublicKeyFromPem(doctorKeyPem),
          );

          await _supabase
              .from('conversations')
              .update({
            'aes_key_encrypted_for_patient': encForPatient,
            'aes_key_encrypted_for_doctor': encForDoctor,
          })
              .eq('id', conv['id']);
        } else {
          // Doctor key not available yet
          // Only update patient's key
          await _supabase
              .from('conversations')
              .update({
            'aes_key_encrypted_for_patient': encForPatient,
          })
              .eq('id', conv['id']);
        }

        print('Re-encrypted conv ${conv['id']}');
      } catch (e) {
        print('Failed conv ${conv['id']}: $e');
      }
    }
  }

  static Future<RSAPrivateKey?> getPrivateKey() async {
    final pem = await _storage.read(
      key: 'private_key_$_currentUserId',
    );
    if (pem == null) return null;
    return EncryptionService.parsePrivateKeyFromPem(pem);
  }
}