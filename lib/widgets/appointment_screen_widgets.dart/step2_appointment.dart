import 'package:patient_app/app_constants.dart';
import 'package:flutter/material.dart';
class Step2Specialty extends StatelessWidget {
  final String? selected;
  final List<Map<String, String>> specialties;
  final ValueChanged<String> onSelect;
  const Step2Specialty({
    required this.selected,
    required this.specialties,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'विशेषज्ञता छान्नुहोस्',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'कुन किसिमका डाक्टर चाहिन्छ?',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 16),
        ...specialties.map((s) {
          final sel = selected == s['ne'];
          return GestureDetector(
            onTap: () => onSelect(s['ne']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: sel
                    ? AppConstants.primaryColor.withOpacity(0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel
                      ? AppConstants.primaryColor
                      : const Color(0xFFE2E8F0),
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: sel
                          ? AppConstants.primaryColor.withOpacity(0.1)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: 18,
                      color: sel
                          ? AppConstants.primaryColor
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['ne']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel
                                ? AppConstants.primaryColor
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          s['en']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sel)
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );
}
