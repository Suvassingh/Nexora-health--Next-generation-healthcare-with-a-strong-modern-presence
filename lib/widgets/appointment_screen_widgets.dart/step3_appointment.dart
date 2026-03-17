


import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/models/doctor_model.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/doctor_info.dart';

class Step3Doctor extends StatelessWidget {
  final bool loading;
  final List<DoctorInfo> doctors;
  final DoctorInfo? selected;
  final ValueChanged<DoctorInfo> onSelect;
  const Step3Doctor({
    required this.loading,
    required this.doctors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => loading
      ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppConstants.primaryColor),
              const SizedBox(height: 12),
              const Text(
                'डाक्टर खोज्दै...',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        )
      : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    const Text(
                      'डाक्टर छान्नुहोस्',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const Spacer(),
                    if (doctors.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${doctors.length} उपलब्ध',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (doctors.isEmpty)
                EmptyDoctors()
              else
                ...doctors.map(
                  (d) => DoctorCard(
                    doctor: d,
                    isSelected: selected?.id == d.id,
                    onSelect: onSelect,
                  ),
                ),
            ],
          ),
        );
}
