// patient_app/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/chat_screen.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/provider/chat_provider.dart';
import 'package:patient_app/services/encryption_service.dart';
import 'package:patient_app/widgets/chat_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});
  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _subscribeToNewMessages();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToNewMessages() {
    _channel = _supabase
        .channel('chat_list_patient_$_currentUserId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (_) => ref.invalidate(chatListProvider),
    ).subscribe();
  }
  Future<String> _createConversation(
    String patientId,
    String doctorId,
  ) async {
    final supabase = Supabase.instance.client;

    // Check if conversation already exists
    final existing = await supabase
        .from('conversations')
        .select('id')
        .eq('patient_id', patientId)
        .eq('doctor_id', doctorId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // Fetch public keys 
    final rows = await supabase
        .from('user_profiles')
        .select('id, public_key')
        .inFilter('id', [patientId, doctorId]);

    final Map<String, String?> rawKeys = {
      for (final r in rows) r['id'] as String: r['public_key'] as String?,
    };

    final patientKey = rawKeys[patientId];
    final doctorKey = rawKeys[doctorId];

    if (patientKey == null) {
      throw Exception(
        'Patient has not set up encryption yet. Please ask them to open the app once.',
      );
    }
    if (doctorKey == null) {
      throw Exception(
        'Doctor has not set up encryption yet. Please ask them to open the app once.',
      );
    }

    // Generate AES key and encrypt for both parties
    final aesKey = EncryptionService.generateAESKey();
    final aesB64 = aesKey.base64;

    final encForPatient = EncryptionService.encryptWithRSA(
      aesB64,
      EncryptionService.parsePublicKeyFromPem(patientKey),
    );
    final encForDoctor = EncryptionService.encryptWithRSA(
      aesB64,
      EncryptionService.parsePublicKeyFromPem(doctorKey),
    );

    // Insert conversation
    final response = await supabase
        .from('conversations')
        .insert({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'aes_key_encrypted_for_patient': encForPatient,
          'aes_key_encrypted_for_doctor': encForDoctor,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }
  void _showCantMessageDialog(BuildContext context, String doctorName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Chat not available'),
        content: Text(
          'You can only send messages to Dr. $doctorName on the day of your appointment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadiusGeometry.vertical(bottom: Radius.circular(15)),
        ),
        elevation: 0,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title:
            Text(AppLocalizations.of(context)?.messages ?? 'Messages',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            )
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.failedToLoadChats,
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(chatListProvider),
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        data: (chats) => chats.isEmpty
            ? _buildEmpty()
            : RefreshIndicator(
          onRefresh: () async => ref.invalidate(chatListProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (_, i) {
              final preview = chats[i];
              return ChatTile(
                preview: preview,
                currentUserId: _currentUserId,
onTap: () async {
                        String convId;
                        if (preview.conversationId == null) {
                          convId = await _createConversation(
                            _currentUserId,
                            preview.doctorUserId,
                          );
                        } else {
                          convId = preview.conversationId!;
                        }

                        await Get.to(
                          () => ChatScreen(
                            conversationId: convId,
                            partnerId: preview.doctorUserId,
                            partnerName: preview.doctorName,
                            partnerAvatarUrl: preview.doctorAvatarUrl,
                            canSendMessages:
                                preview.hasTodayAppointment, // ✅ key change
                          ),
                        );
                        ref.invalidate(chatListProvider);
                      }
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_bubble_outline_rounded,
            size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.noChatsYet,
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.bookChatAppointmentHint,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      ],
    ),
  );
}