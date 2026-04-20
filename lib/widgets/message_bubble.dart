



import 'package:flutter/material.dart';
import 'package:patient_app/services/encryption_service.dart';
import 'package:patient_app/widgets/video_preview.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.parse(msg['created_at'] as String).toLocal();
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    Widget content;

    if (msg['is_key_exchange'] == true) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg['decrypted_content'] as String,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    } else if (msg['media_type'] == 'image') {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          msg['media_url'] as String,
          width: 200,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const SizedBox(
                  width: 200,
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
        ),
      );
    } else if (msg['media_type'] == 'video') {
      content = VideoPreview(url: msg['media_url'] as String);
    } else {
      content = Text(
        msg['decrypted_content'] as String? ?? '',
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1565C0) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            content,
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
