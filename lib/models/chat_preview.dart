
import 'package:patient_app/models/appointment_model.dart';

class ChatPreview {
  final Appt appt;
  final String? conversationId;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatPreview({
    required this.appt,
    this.conversationId,
    required this.lastMessage,
    required this.lastMessageAt,
  });
}
