import 'dart:async';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:patient_app/chat_screen.dart';
import 'package:patient_app/models/appointment_model.dart';
import 'package:patient_app/models/chat_preview.dart';
import 'package:patient_app/services/api_service.dart';
import 'package:patient_app/services/encryption_service.dart';
import 'package:patient_app/widgets/chat_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  final _secureStorage = const FlutterSecureStorage();

  List<ChatPreview> _chats = [];
  bool _loading = true;
  RealtimeChannel? _channel;

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _subscribeToNewMessages();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  //  LOAD 

  Future<void> _loadChats() async {
    setState(() => _loading = true);
    try {
      // 1. Fetch all appointments (enriched with doctor info)
      final rows = await ApiService.getMyAppointmentsEnriched();
      final appts = rows
          .map((r) => Appt.fromApi(r))
          .where((a) => a.consultType == 'chat' && a.doctorId != null)
          .toList();

      // Deduplicate by doctorId — one conversation per doctor
      final seen = <String>{};
      final uniqueAppts = appts.where((a) {
        if (seen.contains(a.doctorId)) return false;
        seen.add(a.doctorId!);
        return true;
      }).toList();

      // 2. For each appointment, try to fetch the conversation + last message
      final previews = <ChatPreview>[];
      for (final appt in uniqueAppts) {
        final preview = await _buildPreview(appt);
        previews.add(preview);
      }

      // Sort: conversations with messages first, then by last message time
      previews.sort((a, b) {
        if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });

      setState(() => _chats = previews);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chats: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<ChatPreview> _buildPreview(Appt appt) async {
    try {
      // Check if conversation exists
      final conv = await _supabase
          .from('conversations')
          .select('id, aes_key_encrypted_for_patient')
          .eq('patient_id', _currentUserId)
          .eq('doctor_id', appt.doctorId!)
          .maybeSingle();

      if (conv == null) {
        return ChatPreview(appt: appt, lastMessage: null, lastMessageAt: null);
      }

      final convId = conv['id'] as String;

      // Decrypt AES key to preview last message
      String? lastMessage;
      DateTime? lastMessageAt;

      try {
        final privPem = await _secureStorage.read(
          key: 'rsa_private_key_$_currentUserId',
        );
        if (privPem != null) {
          final privKey = EncryptionService.parsePrivateKeyFromPem(privPem);
          final aesB64 = EncryptionService.decryptWithRSA(
            conv['aes_key_encrypted_for_patient'] as String,
            privKey,
          );
          final aesKey = encrypt.Key.fromBase64(aesB64);

          final lastMsg = await _supabase
              .from('messages')
              .select()
              .eq('conversation_id', convId)
              .eq('is_key_exchange', false)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (lastMsg != null) {
            lastMessageAt = DateTime.parse(
              lastMsg['created_at'] as String,
            ).toLocal();

            if (lastMsg['media_type'] == 'image') {
              lastMessage = ' Photo';
            } else if (lastMsg['media_type'] == 'video') {
              lastMessage = ' Video';
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
        // Key not ready yet — show placeholder
        lastMessage = ' Encrypted message';
      }

      return ChatPreview(
        appt: appt,
        conversationId: convId,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
      );
    } catch (_) {
      return ChatPreview(appt: appt, lastMessage: null, lastMessageAt: null);
    }
  }

  //  REALTIME 

  void _subscribeToNewMessages() {
    _channel = _supabase
        .channel('chat_list_patient_$_currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (_) => _loadChats(), // refresh list on any new message
        )
        .subscribe();
  }

  //  BUILD 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _loadChats,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _chats.length,
                itemBuilder: (_, i) => ChatTile(
                  preview: _chats[i],
                  currentUserId: _currentUserId,
                  onTap: () async {
                    await Get.to(() => ChatScreen(appt: _chats[i].appt));
                    _loadChats(); // refresh after returning
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book a chat appointment to start messaging\nyour doctor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}





