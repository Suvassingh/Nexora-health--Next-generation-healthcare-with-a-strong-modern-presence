

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/incoming_call.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class CallManager {
  CallManager._();
  static final instance = CallManager._();

  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  bool _initialized = false;

  String? get _currentUserId => _supabase.auth.currentUser?.id;


  void init() {
    if (_initialized || _currentUserId == null) return;
    _initialized = true;

    debugPrint('🔔 CallManager init for user: $_currentUserId');

    _channel = _supabase
        .channel('incoming_calls_$_currentUserId')
        .onPostgresChanges(
      event:  PostgresChangeEvent.insert,
      schema: 'public',
      table:  'calls',
   
      callback: (payload) {
        debugPrint('📞 CallManager received: ${payload.newRecord}');
        final record = payload.newRecord;
        if (record['callee_id'] == _currentUserId) {
          _handleIncomingCall(record);
        }
      },
    )
        .subscribe((status, [err]) {
      debugPrint('[CallManager] status=$status err=$err');
    });
  }


  Future<void> _handleIncomingCall(Map<String, dynamic> record) async {
    final callId = record['id'] as String;
    final callerId = record['caller_id'] as String;
    final callType = record['call_type'] as String;

    // Fetch caller name
    String callerName = 'Unknown';
    try {
      final profile = await _supabase
          .from('user_profiles')
          .select('full_name')
          .eq('id', callerId)
          .single();
      callerName = profile['full_name']?.toString() ?? 'Unknown';
    } catch (_) {}

    // Navigate to ringing screen
    Get.to(
      () => IncomingCallScreen(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        isVideo: callType == 'video',
      ),
      fullscreenDialog: true,
    );
  }


  void dispose() {
    _channel?.unsubscribe();
    _initialized = false;
  }
}
