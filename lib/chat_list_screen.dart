
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/chat_screen.dart';
import 'package:patient_app/provider/chat_provider.dart';
import 'package:patient_app/widgets/chat_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  // ignore: unused_field
  final _secureStorage = const FlutterSecureStorage();

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

  // Real‑time: invalidate provider when a new message arrives
  void _subscribeToNewMessages() {
    _channel = _supabase
        .channel('chat_list_patient_$_currentUserId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (_) {
        ref.invalidate(chatListProvider);
      },
    )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(15)),
        ),
        elevation: 0,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load chats',
                  style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(chatListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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
            itemBuilder: (_, i) => ChatTile(
              preview: chats[i],
              currentUserId: _currentUserId,
              onTap: () async {
                await Get.to(() => ChatScreen(appt: chats[i].appt));
                //  Refresh after returning from chat screen
                ref.invalidate(chatListProvider);
              },
            ),
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
        Text('No chats yet',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
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