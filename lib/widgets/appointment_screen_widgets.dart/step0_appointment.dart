
import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_confirm_screen.dart';

class Step0Type extends StatelessWidget {
  final ConsultationType? selected;
  final ValueChanged<ConsultationType> onSelect;
  const Step0Type({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'परामर्श प्रकार छान्नुहोस्',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'कसरी डाक्टरसँग कुरा गर्न चाहनुहुन्छ?',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TypeTile(
              icon: Icons.chat_bubble_outline_rounded,
              ne: 'च्याट',
              en: 'Chat',
              desc: 'लेखेर कुरा गर्नुहोस्',
              type: ConsultationType.chat,
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(width: 12),
            TypeTile(
              icon: Icons.phone_outlined,
              ne: 'अडियो',
              en: 'Audio',
              desc: 'फोनमा कुरा गर्नुहोस्',
              type: ConsultationType.audio,
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(width: 12),
            TypeTile(
              icon: Icons.videocam_outlined,
              ne: 'भिडियो',
              en: 'Video',
              desc: 'भिडियो कलमा गर्नुहोस्',
              type: ConsultationType.video,
              selected: selected,
              onSelect: onSelect,
            ),
          ],
        ),
      ],
    ),
  );
}

class TypeTile extends StatelessWidget {
  final IconData icon;
  final String ne, en, desc;
  final ConsultationType type;
  final ConsultationType? selected;
  final ValueChanged<ConsultationType> onSelect;
  const TypeTile({
    required this.icon,
    required this.ne,
    required this.en,
    required this.desc,
    required this.type,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: sel
                ? AppConstants.primaryColor.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? AppConstants.primaryColor : const Color(0xFFE2E8F0),
              width: sel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sel
                      ? AppConstants.primaryColor.withOpacity(0.1)
                      : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: sel
                      ? AppConstants.primaryColor
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ne,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: sel
                      ? AppConstants.primaryColor
                      : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                en,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(fontSize: 9, color: Color(0xFFCBD5E1)),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
