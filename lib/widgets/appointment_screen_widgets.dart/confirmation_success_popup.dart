import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';

class SR2 extends StatelessWidget {
  final IconData icon;
  final String text;
  const SR2(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 15, color: AppConstants.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    ),
  );
}
