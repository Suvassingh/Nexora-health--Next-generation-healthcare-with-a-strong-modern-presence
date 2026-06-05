class ChatPreview {
  final String? conversationId;
  final String? doctorId;
    final String doctorUserId; 

  final String doctorName;
  final String? doctorAvatarUrl;
  final String? lastMessage;           
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOnline;                 
  final DateTime? lastSeen;            
    final bool hasTodayAppointment; 
    final bool canMessageNow;


  const ChatPreview({
    this.conversationId,
    this.doctorId,
    required this.doctorUserId,
    required this.doctorName,
    this.doctorAvatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeen,
    this.hasTodayAppointment = false,
    this.canMessageNow = false,
  });
}