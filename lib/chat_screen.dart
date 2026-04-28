import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/models/appointment_model.dart';
import 'package:patient_app/services/encryption_service.dart';
import 'package:patient_app/widgets/message_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final Appt appt;
  const ChatScreen({super.key, required this.appt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  final _secureStorage = const FlutterSecureStorage();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  List<Map<String, dynamic>> _messages = [];
  String? _conversationId;
  encrypt.Key? _aesKey;
  bool _loading = true;
  bool _sending = false;
  RealtimeChannel? _channel;
  String? _currentUserPrivateKeyPem;

  String get _currentUserId => _supabase.auth.currentUser!.id;
  String get _doctorId => widget.appt.doctorId!;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      await _ensureUserKeyPair();
      _conversationId = await _getOrCreateConversation();
      await _fetchAndDecryptAESKey();
      await _loadMessages();
      _subscribeToMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize chat: $e');
    } finally {
      setState(() => _loading = false);
    }
    print('=== appt raw doctorId: ${widget.appt.doctorId}');
    print('=== appt doctorName: ${widget.appt.doctorName}');
  }

  //  KEY PAIR MANAGEMENT
  Future<void> _ensureUserKeyPair() async {
    final profile = await _supabase
        .from('user_profiles')
        .select('public_key')
        .eq('id', _currentUserId)
        .maybeSingle();

    final storedPrivPem = await _secureStorage.read(
      key: 'rsa_private_key_$_currentUserId',
    );

    // Check if stored keys are in old format (not valid JSON)
    final privIsOld = storedPrivPem != null && !_isValidKeyFormat(storedPrivPem);
    final pubIsOld = profile != null &&
        profile['public_key'] != null &&
        !_isValidKeyFormat(profile['public_key'] as String);

    final needsRegen = storedPrivPem == null ||
        profile == null ||
        profile['public_key'] == null ||
        privIsOld ||
        pubIsOld;

    if (needsRegen) {
      debugPrint(' Regenerating keys — wiping old conversation too');

      // Delete old conversation so it gets recreated with new keys
      await _supabase
          .from('conversations')
          .delete()
          .eq('patient_id', _currentUserId)
          .eq('doctor_id', widget.appt.doctorId ?? '');

      await _generateAndSaveKeyPair();
    } else {
      _currentUserPrivateKeyPem = storedPrivPem;
    }
  }

  bool _isValidKeyFormat(String pem) {
    try {
      // Try base64 decode first
      final bytes = base64Decode(pem);
      final decoded = utf8.decode(bytes);
      // New format is JSON starting with '{'
      if (decoded.startsWith('{')) {
        final map = jsonDecode(decoded) as Map;
        return map.containsKey('n') && map.containsKey('e');
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _generateAndSaveKeyPair() async {
    final keyPair = EncryptionService.generateRSAKeyPair();
    final pubPem = EncryptionService.publicKeyToPem(keyPair.publicKey);
    final privPem = EncryptionService.privateKeyToPem(keyPair.privateKey);

    await _secureStorage.write(
      key: 'rsa_private_key_$_currentUserId',
      value: privPem,
    );
    await _supabase
        .from('user_profiles')
        .update({'public_key': pubPem})
        .eq('id', _currentUserId);

    _currentUserPrivateKeyPem = privPem;
    debugPrint(' New key pair saved');
  }

  Future<String> _getOrCreateConversation() async {
    // Look for existing conversation between this patient and doctor
    // Validate doctorId is a UUID before hitting Supabase
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (_doctorId == null || !uuidRegex.hasMatch(_doctorId!)) {
      throw Exception(
        'Invalid doctor ID: "$_doctorId". '
        'Expected a UUID. Check that doctor_user_id is being passed correctly.',
      );
    }
    final existing = await _supabase
        .from('conversations')
        .select('id')
        .eq('patient_id', _currentUserId)
        .eq('doctor_id', _doctorId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // Fetch both public keys
    final rows = await _supabase
        .from('user_profiles')
        .select('id, public_key')
        .inFilter('id', [_currentUserId, _doctorId]);

    final Map<String, String> pubKeys = {
      for (final r in rows) r['id'] as String: r['public_key'] as String,
    };

    if (pubKeys[_doctorId] == null) {
      throw Exception(
        'Doctor has not set up encryption yet. Ask them to open the app once.',
      );
    }
    if (pubKeys[_currentUserId] == null) {
      throw Exception('Your public key is missing. Please restart the app.');
    }

    final aesKey = EncryptionService.generateAESKey();
    final aesB64 = aesKey.base64;

    final encForPatient = EncryptionService.encryptWithRSA(
      aesB64,
      EncryptionService.parsePublicKeyFromPem(pubKeys[_currentUserId]!),
    );
    final encForDoctor = EncryptionService.encryptWithRSA(
      aesB64,
      EncryptionService.parsePublicKeyFromPem(pubKeys[_doctorId]!),
    );

    final response = await _supabase
        .from('conversations')
        .insert({
          'patient_id': _currentUserId,
          'doctor_id': _doctorId,
          'aes_key_encrypted_for_patient': encForPatient,
          'aes_key_encrypted_for_doctor': encForDoctor,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  //  AES KEY FETCH & DECRYPTION

  Future<void> _fetchAndDecryptAESKey() async {
    final conv = await _supabase
        .from('conversations')
        .select('aes_key_encrypted_for_patient')
        .eq('id', _conversationId!)
        .single();

    final encKey = conv['aes_key_encrypted_for_patient'] as String?;
    if (encKey == null) throw Exception('No AES key found in conversation');

    final privKey = EncryptionService.parsePrivateKeyFromPem(
      _currentUserPrivateKeyPem!,
    );
    final aesB64 = EncryptionService.decryptWithRSA(encKey, privKey);
    _aesKey = encrypt.Key.fromBase64(aesB64);
  }

  //  MESSAGES FETCH & REALTIME SUBSCRIPTION

  Future<void> _loadMessages() async {
    final data = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', _conversationId!)
        .order('created_at', ascending: true);

    setState(() => _messages = data.map(_decodeMessage).toList());
    _scrollToBottom();
  }

  void _subscribeToMessages() {
    // Use unique channel name per user+conversation to avoid conflicts
    final channelName = 'messages:${_conversationId!}:$_currentUserId';

    _channel = _supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: _conversationId!,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;

            // Skip if we already have this message (sent by us, added optimistically)
            final alreadyExists = _messages.any(
              (m) => m['id'] != null && m['id'] == newRecord['id'],
            );
            if (alreadyExists) return;

            final decoded = _decodeMessage(newRecord);
            setState(() => _messages.add(decoded));
            _scrollToBottom();
          },
        )
        .subscribe((status, [error]) {
          debugPrint('Realtime status: $status, error: $error');
        });
  }

  Map<String, dynamic> _decodeMessage(Map<String, dynamic> msg) {
    if (msg['is_key_exchange'] == true) {
      return {...msg, 'decrypted_content': ' Secure session established'};
    }
    if (msg['media_url'] != null) {
      // Media message — no decryption needed for the URL itself
      return {...msg, 'decrypted_content': null};
    }
    try {
      final text = EncryptionService.decryptWithAES(
        msg['encrypted_content'] as String,
        _aesKey!,
        msg['iv'] as String,
      );
      return {...msg, 'decrypted_content': text};
    } catch (_) {
      return {...msg, 'decrypted_content': '[Unable to decrypt]'};
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  //  SEND MESSAGE & MEDIA
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _aesKey == null) return;
    _messageController.clear();

    final enc = EncryptionService.encryptWithAES(text, _aesKey!);

    // Optimistically add to UI immediately (don't wait for realtime)
    final tempMsg = {
      'id': null,
      'conversation_id': _conversationId,
      'sender_id': _currentUserId,
      'encrypted_content': enc.content,
      'iv': enc.iv,
      'media_url': null,
      'media_type': null,
      'is_key_exchange': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'decrypted_content': text,
    };
    setState(() => _messages.add(tempMsg));
    _scrollToBottom();

    final inserted = await _supabase
        .from('messages')
        .insert({
          'conversation_id': _conversationId,
          'sender_id': _currentUserId,
          'encrypted_content': enc.content,
          'iv': enc.iv,
        })
        .select()
        .single();

    // Replace temp message with real one (has actual id + created_at)
    setState(() {
      final idx = _messages.indexWhere((m) => m['id'] == null);
      if (idx != -1) {
        _messages[idx] = {...inserted, 'decrypted_content': text};
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await _uploadAndSendMedia(File(file.path), 'image');
  }

  Future<void> _pickAndSendVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _uploadAndSendMedia(File(file.path), 'video');
  }

  Future<void> _uploadAndSendMedia(File file, String mediaType) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final ext = file.path.split('.').last;
      final path =
          'chat/$_conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from('chat-media').upload(path, file);
      final url = _supabase.storage.from('chat-media').getPublicUrl(path);

      // Optimistically add media message
      final tempMsg = {
        'id': null,
        'conversation_id': _conversationId,
        'sender_id': _currentUserId,
        'media_url': url,
        'media_type': mediaType,
        'is_key_exchange': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'decrypted_content': null,
      };
      setState(() => _messages.add(tempMsg));
      _scrollToBottom();

      final inserted = await _supabase
          .from('messages')
          .insert({
            'conversation_id': _conversationId,
            'sender_id': _currentUserId,
            'media_url': url,
            'media_type': mediaType,
          })
          .select()
          .single();

      setState(() {
        final idx = _messages.indexWhere((m) => m['id'] == null);
        if (idx != -1) {
          _messages[idx] = {...inserted, 'decrypted_content': null};
        }
      });
    } catch (e) {
      // Remove failed optimistic message
      setState(() => _messages.removeWhere((m) => m['id'] == null));
      Get.snackbar('Error', 'Failed to send media: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  //  BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${widget.appt.doctorName}'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      return MessageBubble(
                        msg: msg,
                        isMe: msg['sender_id'] == _currentUserId,
                      );
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: _pickAndSendImage,
              color: AppConstants.primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: _pickAndSendVideo,
              color: AppConstants.primaryColor,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            if (_sending)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              CircleAvatar(
                backgroundColor: AppConstants.primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: _sendMessage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
