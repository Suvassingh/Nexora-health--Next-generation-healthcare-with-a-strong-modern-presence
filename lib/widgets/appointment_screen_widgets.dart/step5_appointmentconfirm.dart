import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/models/doctor_model.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/confirm_dialog.dart';


class Step5Summary extends StatelessWidget {
  final TextEditingController sympCtrl;
  final String? report;
  final VoidCallback onUpload;
  final ConsultationType type;
  final DoctorInfo doctor;
  final DateTime? date;
  final Slot? slot;
  final String Function(DateTime) fmtDate;
  final String Function(ConsultationType) consultLabel;
  const Step5Summary({
    required this.sympCtrl,
    required this.report,
    required this.onUpload,
    required this.type,
    required this.doctor,
    required this.date,
    required this.slot,
    required this.fmtDate,
    required this.consultLabel,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'लक्षण र सारांश',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),

        // Symptoms input
        const Text(
          'लक्षणहरू / Symptoms',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: sympCtrl,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'आफ्नो लक्षण यहाँ लेख्नुहोस्...',
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'अपॉइन्टमेन्ट सारांश',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SR(
                type == ConsultationType.chat
                    ? Icons.chat_bubble_outline_rounded
                    : type == ConsultationType.audio
                    ? Icons.phone_outlined
                    : Icons.videocam_outlined,
                'परामर्श प्रकार',
                consultLabel(type),
              ),
              SR(Icons.person_outline_rounded, 'डाक्टर', 'डा. ${doctor.name}'),
              SR(
                Icons.medical_services_outlined,
                'विशेषज्ञता',
                doctor.specialty,
              ),
              SR(Icons.home_outlined, 'स्वास्थ्य संस्था', doctor.hospital),
              if (doctor.district.isNotEmpty)
                SR(
                  Icons.location_on_outlined,
                  'स्थान',
                  [
                    doctor.municipality,
                    doctor.district,
                  ].where((s) => s.isNotEmpty).join(', '),
                ),
              if (date != null)
                SR(Icons.calendar_today_outlined, 'मिति', fmtDate(date!)),
              if (slot != null)
                SR(Icons.access_time_rounded, 'समय', slot!.display),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Optional report upload
        GestureDetector(
          onTap: onUpload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: report != null
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  size: 20,
                  color: report != null
                      ? const Color(0xFF27AE60)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    report ?? 'रिपोर्ट अपलोड गर्नुहोस् (वैकल्पिक)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: report != null
                          ? const Color(0xFF1A7A4A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (report != null)
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF27AE60),
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 13,
              color: Color(0xFF27AE60),
            ),
            SizedBox(width: 5),
            Text(
              'सुरक्षित एन्क्रिप्टेड',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF27AE60),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
