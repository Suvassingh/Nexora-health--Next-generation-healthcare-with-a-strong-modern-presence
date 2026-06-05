// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:patient_app/app_constants.dart';
//
// class VoiceFab extends StatefulWidget {
//   final String text;
//   const VoiceFab({super.key, required this.text});
//
//   @override
//   State<VoiceFab> createState() => _VoiceFabState();
// }
//
// class _VoiceFabState extends State<VoiceFab>
//     with SingleTickerProviderStateMixin {
//   final FlutterTts _tts = FlutterTts();
//   bool _speaking = false;
//
//   late AnimationController _pulseCtrl;
//   late Animation<double> _pulseAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat(reverse: true);
//     _pulseAnim = Tween(
//       begin: 1.0,
//       end: 1.18,
//     ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
//
//     _tts.setCompletionHandler(() {
//       if (mounted) setState(() => _speaking = false);
//     });
//     _tts.setCancelHandler(() {
//       if (mounted) setState(() => _speaking = false);
//     });
//   }
//
//   @override
//   void dispose() {
//     _tts.stop();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _toggle() async {
//     if (_speaking) {
//       await _tts.stop();
//       setState(() => _speaking = false);
//     } else {
//       await _tts.setLanguage('ne-NP');
//       await _tts.setSpeechRate(0.48);
//       await _tts.setPitch(1.0);
//       setState(() => _speaking = true);
//       await _tts.speak(widget.text);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _speaking ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
//       child: FloatingActionButton(
//         heroTag: 'voice_fab',
//         onPressed: _toggle,
//         backgroundColor: _speaking
//             ? const Color(0xFFB71C1C)
//             : AppConstants.primaryColor,
//         elevation: 4,
//         tooltip: _speaking ? 'Stop' : 'Read summary aloud',
//         child: Icon(
//           _speaking ? Icons.stop_rounded : Icons.volume_up_rounded,
//           color: Colors.white,
//           size: 26,
//         ),
//       ),
//     );
//   }
// }
