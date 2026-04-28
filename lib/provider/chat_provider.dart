import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:patient_app/models/chat_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/appointment_model.dart';
import '../services/api_service.dart';
import '../services/encryption_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatListProvider = FutureProvider<List<ChatPreview>>((ref) async {
  final supabase = Supabase.instance.client;
  final secureStorage = const FlutterSecureStorage();
  final currentUserId = supabase.auth.currentUser!.id;

  final rows = await ApiService.getMyAppointmentsEnriched();
  final appts = rows
      .map((r) => Appt.fromApi(r))
      .where((a) => a.consultType == 'chat' && a.doctorId != null)
      .toList();

  // Deduplicate by doctorId
  final seen = <String>{};
  final uniqueAppts = appts.where((a) {
    if (seen.contains(a.doctorId)) return false;
    seen.add(a.doctorId!);
    return true;
  }).toList();

  // Build previews in parallel
  final previews = await Future.wait(
    uniqueAppts.map((appt) => _buildChatPreview(
        appt, supabase, secureStorage, currentUserId)),
  );

  previews.sort((a, b) {
    if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
    if (a.lastMessageAt == null) return 1;
    if (b.lastMessageAt == null) return -1;
    return b.lastMessageAt!.compareTo(a.lastMessageAt!);
  });

  return previews;
});

// Helper — extracted so it can be used outside the class
Future<ChatPreview> _buildChatPreview(
    Appt appt,
    SupabaseClient supabase,
    FlutterSecureStorage secureStorage,
    String currentUserId,
    ) async {
  try {
    final conv = await supabase
        .from('conversations')
        .select('id, aes_key_encrypted_for_patient')
        .eq('patient_id', currentUserId)
        .eq('doctor_id', appt.doctorId!)
        .maybeSingle();

    if (conv == null) {
      return ChatPreview(appt: appt, lastMessage: null, lastMessageAt: null);
    }

    final convId = conv['id'] as String;
    String? lastMessage;
    DateTime? lastMessageAt;

    try {
      final privPem = await secureStorage.read(
          key: 'rsa_private_key_$currentUserId');
      if (privPem != null) {
        final privKey = EncryptionService.parsePrivateKeyFromPem(privPem);
        final aesB64 = EncryptionService.decryptWithRSA(
            conv['aes_key_encrypted_for_patient'] as String, privKey);
        final aesKey = encrypt.Key.fromBase64(aesB64);

        final lastMsg = await supabase
            .from('messages')
            .select()
            .eq('conversation_id', convId)
            .eq('is_key_exchange', false)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastMsg != null) {
          lastMessageAt =
              DateTime.parse(lastMsg['created_at'] as String).toLocal();
          if (lastMsg['media_type'] == 'image') {
            lastMessage = '📷 Photo';
          } else if (lastMsg['media_type'] == 'video') {
            lastMessage = '🎥 Video';
          } else if (lastMsg['encrypted_content'] != null) {
            lastMessage = EncryptionService.decryptWithAES(
              lastMsg['encrypted_content'] as String,
              aesKey,
              lastMsg['iv'] as String,
            );
          }
        }
      }
    } catch (_) {
      lastMessage = ' Encrypted message';
    }

    return ChatPreview(
        appt: appt,
        conversationId: convId,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt);
  } catch (_) {
    return ChatPreview(appt: appt, lastMessage: null, lastMessageAt: null);
  }
}