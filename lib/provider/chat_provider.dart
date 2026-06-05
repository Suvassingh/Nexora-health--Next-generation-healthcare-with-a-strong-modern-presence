
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/models/chat_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatListProvider = FutureProvider<List<ChatPreview>>((ref) async {
  final supabase = Supabase.instance.client;
  final currentUserId = supabase.auth.currentUser!.id;

  print('chatListProvider: start for $currentUserId');

  try {
    // 1. Fetch all confirmed appointments for the patient
    final appointments = await supabase
        .from('appointments')
        .select('doctor_id, scheduled_at')
        .eq('patient_id', currentUserId)
        .inFilter('status', ['confirmed', 'completed', 'no_show']);
    print('appointments count: ${appointments.length}');

    if (appointments.isEmpty) {
      print('No confirmed appointments empty list');
      return [];
    }

    // 2. Get unique doctor_ids (integers) from appointments
    final Set<int> doctorIdsSet = {};
    for (final apt in appointments) {
      doctorIdsSet.add(apt['doctor_id'] as int);
    }
    final doctorIds = doctorIdsSet.toList();
    print('doctor ids: $doctorIds');

    // 3. Fetch doctor details from 'doctors' table to get user_id
    final doctorsList = await supabase
        .from('doctors')
        .select('id, user_id')
        .inFilter('id', doctorIds);
    print('doctors count: ${doctorsList.length}');

    // Map doctor_id (int) -> user_id (UUID)
    final Map<int, String> doctorIdToUserId = {};
    for (final doc in doctorsList) {
      doctorIdToUserId[doc['id'] as int] = doc['user_id'] as String;
    }

    // 4. Collect all doctor user_ids
    final Set<String> doctorUserIdsSet = {};
    for (final apt in appointments) {
      final doctorId = apt['doctor_id'] as int;
      final userId = doctorIdToUserId[doctorId];
      if (userId != null) doctorUserIdsSet.add(userId);
    }
    final doctorUserIds = doctorUserIdsSet.toList();
    print('doctor user_ids: $doctorUserIds');

    // 5. Fetch user_profiles for these doctors (name, avatar, online status)
    final profiles = await supabase
        .from('user_profiles')
        .select('id, full_name, avatar_url, is_online, last_seen')
        .inFilter('id', doctorUserIds);
    final Map<String, Map<String, dynamic>> profileMap = {};
    for (final p in profiles) {
      profileMap[p['id'] as String] = p;
    }
    print('profiles count: ${profiles.length}');

    // 6. Fetch existing conversations for the patient
    final conversations = await supabase
        .from('conversations')
        .select(
          'id, doctor_id, last_message_preview, last_message_at, unread_count_patient',
        )
        .eq('patient_id', currentUserId);
    final Map<String, Map<String, dynamic>> convMap = {};
    for (final conv in conversations) {
      convMap[conv['doctor_id'] as String] = conv;
    }
    print('conversations count: ${conversations.length}');

    // 7. Determine today's UTC range
  final nowLocal = DateTime.now();
    final todayLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);

    // 8. Build result list (one entry per unique doctor user_id)
    final Map<String, ChatPreview> resultMap = {};

    for (final apt in appointments) {
      final doctorIdInt = apt['doctor_id'] as int;
      final doctorUserId = doctorIdToUserId[doctorIdInt];
      if (doctorUserId == null) {
        print('No user_id found for doctor_id $doctorIdInt');
        continue;
      }

      final profile = profileMap[doctorUserId];
      if (profile == null) {
        print('No user_profile found for doctor_user_id $doctorUserId');
        continue;
      }

      final scheduledAt = DateTime.parse(apt['scheduled_at']).toUtc();
   final appointmentLocal = scheduledAt.toLocal();
      final hasToday =
          appointmentLocal.year == todayLocal.year &&
          appointmentLocal.month == todayLocal.month &&
          appointmentLocal.day == todayLocal.day;
      print('Appointment: $scheduledAt UTC, hasToday: $hasToday');

      final conversation = convMap[doctorUserId];

      if (resultMap.containsKey(doctorUserId)) {
        // If already have an entry for this doctor, update hasToday if needed
        if (hasToday) {
          final existing = resultMap[doctorUserId]!;
          resultMap[doctorUserId] = existing.copyWith(
            hasTodayAppointment: true,
          );
        }
        continue;
      }

      resultMap[doctorUserId] = ChatPreview(
        conversationId: conversation?['id'] as String?,
        doctorId: doctorIdInt.toString(),
        doctorUserId: doctorUserId,
        doctorName: profile['full_name'] ?? 'Doctor',
        doctorAvatarUrl: profile['avatar_url'] as String?,
        lastMessage: conversation?['last_message_preview'] as String?,
        lastMessageAt: conversation?['last_message_at'] != null
            ? DateTime.parse(conversation!['last_message_at'])
            : null,
        unreadCount: conversation?['unread_count_patient'] ?? 0,
        isOnline: profile['is_online'] ?? false,
        lastSeen: profile['last_seen'] != null
            ? DateTime.parse(profile['last_seen'])
            : null,
        hasTodayAppointment: hasToday,
      );
    }

    final result = resultMap.values.toList();

    // Sort: today’s appointments first, then by last message time, then name
    result.sort((a, b) {
      if (a.hasTodayAppointment != b.hasTodayAppointment)
        return a.hasTodayAppointment ? -1 : 1;
      if (a.lastMessageAt != null && b.lastMessageAt != null)
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      if (a.lastMessageAt != null) return -1;
      if (b.lastMessageAt != null) return 1;
      return a.doctorName.compareTo(b.doctorName);
    });

    print('final result count: ${result.length}');
    return result;
  } catch (e, stack) {
    print('ChatListProvider error: $e');
    print(stack);
    rethrow;
  }
});

// Add copyWith extension for ChatPreview (place this after the class)
extension ChatPreviewCopyWith on ChatPreview {
  ChatPreview copyWith({
    String? conversationId,
    String? doctorId,
    String? doctorUserId,
    String? doctorName,
    String? doctorAvatarUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
    bool? hasTodayAppointment,
  }) {
    return ChatPreview(
      conversationId: conversationId ?? this.conversationId,
      doctorId: doctorId ?? this.doctorId,
      doctorUserId: doctorUserId ?? this.doctorUserId,
      doctorName: doctorName ?? this.doctorName,
      doctorAvatarUrl: doctorAvatarUrl ?? this.doctorAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      hasTodayAppointment: hasTodayAppointment ?? this.hasTodayAppointment,
    );
  }
}
