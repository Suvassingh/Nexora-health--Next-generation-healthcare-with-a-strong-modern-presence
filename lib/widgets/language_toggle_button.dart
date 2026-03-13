// import 'package:flutter/material.dart';
// import 'package:patient_app/app_constants.dart';
// import 'package:patient_app/main.dart';

// class LanguageToggleButton extends StatelessWidget {
//   const LanguageToggleButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final currentLang = PatientApp.of(context)?.currentLanguageCode;

//     return Container(
//       padding: const EdgeInsets.all(2),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: ToggleButtons(
//         borderRadius: BorderRadius.circular(25),
//         borderWidth: 0,
//         constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
//         selectedColor: AppConstants.primaryColor,
//         fillColor: Colors.white,
//         color: Colors.white,
//         isSelected: [currentLang == 'en', currentLang == 'ne'],
//         onPressed: (index) {
//           if (index == 0) {
//             PatientApp.of(context)?.changeLanguage('en');
//           } else {
//             PatientApp.of(context)?.changeLanguage('ne');
//           }
//         },
//         children: const [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: Text(
//               'En',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               "ने",
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/main.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = PatientApp.of(context)?.currentLanguageCode ?? 'ne';
    final bool isEn = currentLang == 'en';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: 'En',
            selected: isEn,
            onTap: () => PatientApp.of(context)?.changeLanguage('en'),
          ),
          _Pill(
            label: 'ने',
            selected: !isEn,
            onTap: () => PatientApp.of(context)?.changeLanguage('ne'),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF888888),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
