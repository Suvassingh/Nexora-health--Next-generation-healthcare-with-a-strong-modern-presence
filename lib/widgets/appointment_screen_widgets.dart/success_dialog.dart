import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/models/doctor_model.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/confirmation_success_popup.dart';

class SuccessDialog extends StatelessWidget {
  final DoctorInfo doctor;
  final String date;
  final Slot slot;
  final ConsultationType type;
  final String Function(ConsultationType) consultLabel;
  const SuccessDialog({
    required this.doctor,
    required this.date,
    required this.slot,
    required this.type,
    required this.consultLabel,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 38,
              color: Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'अपॉइन्टमेन्ट बुक भयो!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Appointment Confirmed',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                SR2(Icons.person_outline_rounded, 'डा. ${doctor.name}'),
                SR2(Icons.medical_services_outlined, doctor.specialty),
                SR2(Icons.home_outlined, doctor.hospital),
                SR2(Icons.calendar_today_outlined, date),
                SR2(Icons.access_time_rounded, slot.display),
                SR2(
                  type == ConsultationType.chat
                      ? Icons.chat_bubble_outline_rounded
                      : type == ConsultationType.audio
                      ? Icons.phone_outlined
                      : Icons.videocam_outlined,
                  consultLabel(type),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'ठीक छ / Done',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
