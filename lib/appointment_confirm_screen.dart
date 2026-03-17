import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/models/doctor_model.dart';

import 'package:patient_app/widgets/appointment_screen_widgets.dart/step0_appointment.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/step1_appointment.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/step2_appointment.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/step3_appointment.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/step4_confirm_appointment.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/step5_appointmentconfirm.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/success_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

 
enum ConsultationType { chat, audio, video }




class Slot {
  final String display, value;
  final int hour, minute;
  const Slot(this.display, this.value, this.hour, this.minute);
}

const morningSlots = [
  Slot('९:०० बिहान', '9:00 AM', 9, 0),
  Slot('९:३० बिहान', '9:30 AM', 9, 30),
  Slot('१०:०० बिहान', '10:00 AM', 10, 0),
  Slot('१०:३० बिहान', '10:30 AM', 10, 30),
  Slot('११:०० बिहान', '11:00 AM', 11, 0),
  Slot('११:३० बिहान', '11:30 AM', 11, 30),
];
const afternoonSlots = [
Slot('२:०० दिउँसो', '2:00 PM', 14, 0),
  Slot('२:३० दिउँसो', '2:30 PM', 14, 30),
  Slot('३:०० दिउँसो', '3:00 PM', 15, 0),
  Slot('३:३० दिउँसो', '3:30 PM', 15, 30),
  Slot('४:०० दिउँसो', '4:00 PM', 16, 0),
  Slot('४:३० दिउँसो', '4:30 PM', 16, 30),
];
List<Slot> get _allSlots => [...morningSlots, ...afternoonSlots];


class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _supa = Supabase.instance.client;
  int _step = 0; // 0-5

  ConsultationType? _type;
  String? _province, _district, _municipality;
  String? _selectedSpecialtyNe;
  List<DoctorInfo> _doctors = [];
  bool _loadingDoctors = false;
  DoctorInfo? _doctor;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  Slot? _selectedSlot;
  Map<String, bool> _slotAvailability = {};
  bool _loadingSlots = false;
  final _sympCtrl = TextEditingController();
  String? _reportName;
  bool _booking = false;

  static const _stepLabels = [
    'प्रकार',
    'स्थान',
    'विशेषज्ञ',
    'डाक्टर',
    'मिति',
    'लक्षण',
  ];

  static const _specialties = [
    {'ne': 'सामान्य चिकित्सक', 'en': 'General Physician'},
    {'ne': 'हृदय रोग', 'en': 'Cardiologist'},
    {'ne': 'हाड जोर्नी', 'en': 'Orthopedic'},
    {'ne': 'बाल रोग', 'en': 'Pediatrician'},
    {'ne': 'छाला रोग', 'en': 'Dermatologist'},
    {'ne': 'मानसिक स्वास्थ्य', 'en': 'Psychiatrist'},
    {'ne': 'स्त्री रोग', 'en': 'Gynecologist'},
    {'ne': 'शल्य चिकित्सा', 'en': 'Surgeon'},
    {'ne': 'न्यूरोलोजी', 'en': 'Neurologist'},
    {'ne': 'कान नाक घाँटी', 'en': 'ENT Specialist'},
    {'ne': 'नेत्र रोग', 'en': 'Ophthalmologist'},
  ];

  @override
  void dispose() {
    _sympCtrl.dispose();
    super.dispose();
  }

  String? get _specEn => _selectedSpecialtyNe == null
      ? null
      : _specialties.firstWhere(
          (s) => s['ne'] == _selectedSpecialtyNe,
          orElse: () => {'en': ''},
        )['en'];

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _type != null;
      case 1:
        return _province != null && _district != null;
      case 2:
        return _selectedSpecialtyNe != null;
      case 3:
        return _doctor != null;
      case 4:
        return _selectedDate != null && _selectedSlot != null;
      case 5:
        return true;
      default:
        return false;
    }
  }

  void _snack(String msg, {bool err = false}) => Get.snackbar(
    err ? 'त्रुटि' : 'सफल',
    msg,
    backgroundColor: err ? const Color(0xFFFEF2F2) : const Color(0xFFEAF7EF),
    colorText: err ? const Color(0xFFEF4444) : const Color(0xFF1A7A4A),
    borderRadius: 14,
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 3),
  );

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${w[d.weekday - 1]}, ${d.day} ${m[d.month - 1]} ${d.year}';
  }

  String _consultLabel(ConsultationType t) => switch (t) {
    ConsultationType.chat => 'च्याट / Chat',
    ConsultationType.audio => 'अडियो / Audio',
    ConsultationType.video => 'भिडियो / Video',
  };

  // ── Fetch doctors ────────────────────────────────────────────────────────
  Future<void> _fetchDoctors() async {
    setState(() {
      _loadingDoctors = true;
      _doctors = [];
    });
    try {
      final spec = _specEn ?? '';
      if (spec.isEmpty) {
        setState(() => _loadingDoctors = false);
        return;
      }
      var q = _supa
          .from('doctors')
          .select(
            'user_id,specialty,healthpost_name,qualification,license_number,'
            'experience_years,is_active,is_verified,rating,'
            'user_profiles!doctors_user_id_fkey(full_name,phone,email,avatar_url,province,district,municipality)',
          )
          .ilike('specialty', '%$spec%')
          .eq('is_active', true);
      if (_province != null) {
        q = q.eq('user_profiles.province', _province!);
      }
      if (_district != null) {
        q = q.eq('user_profiles.district', _district!);
      }
      if (_municipality != null && _municipality!.isNotEmpty) {
        q = q.eq('user_profiles.municipality', _municipality!);
      }
       final res = await q.limit(30);
      setState(() {
        _doctors = (res as List).map((e) => DoctorInfo.fromMap(e)).toList();
        _loadingDoctors = false;
      });
    } catch (e) {
      setState(() => _loadingDoctors = false);
      _snack('डाक्टर लोड गर्न सकिएन: $e', err: true);
    }
  }

  // ── Check slot availability ──────────────────────────────────────────────
  Future<void> _checkAvailability() async {
    if (_doctor == null || _selectedDate == null) return;
    setState(() {
      _loadingSlots = true;
      _slotAvailability = {};
    });
    try {
      final start = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final end = start.add(const Duration(days: 1));
      final res = await _supa
          .from('appointments')
          .select('scheduled_at')
          .eq('doctor_id', _doctor!.id)
          .gte('scheduled_at', start.toIso8601String())
          .lt('scheduled_at', end.toIso8601String())
          .not('status', 'in', '("cancelled","no_show")');
      final booked = <String>{};
      for (final r in res as List) {
        final dt = DateTime.parse(r['scheduled_at']).toLocal();
        final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final mm = dt.minute.toString().padLeft(2, '0');
        final ap = dt.hour < 12 ? 'AM' : 'PM';
        booked.add('$h12:$mm $ap');
      }
      setState(() {
        _slotAvailability = {
          for (final s in _allSlots) s.value: booked.contains(s.value),
        };
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() => _loadingSlots = false);
      _snack('समय जाँच गर्न सकिएन: $e', err: true);
    }
  }

  // ── Book appointment ─────────────────────────────────────────────────────
  Future<void> _book() async {
    setState(() => _booking = true);
    try {
      final pid = _supa.auth.currentUser?.id;
      if (pid == null) throw Exception('Not authenticated');
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedSlot!.hour,
        _selectedSlot!.minute,
      );
      // Race-condition guard — double-check slot is still free
      final conflict = await _supa
          .from('appointments')
          .select('id')
          .eq('doctor_id', _doctor!.id)
          .eq('scheduled_at', dt.toUtc().toIso8601String())
          .not('status', 'in', '("cancelled","no_show")')
          .maybeSingle();
      if (conflict != null) {
        setState(() => _booking = false);
        _snack('यो समय अहिले बुक भयो, अर्को छान्नुहोस्।', err: true);
        await _checkAvailability();
        return;
      }
      await _supa.from('appointments').insert({
        'doctor_id': _doctor!.id,
        'patient_id': pid,
        'scheduled_at': dt.toUtc().toIso8601String(),
        'duration_mins': 15,
        'reason': _sympCtrl.text.trim().isEmpty ? null : _sympCtrl.text.trim(),
        'status': 'pending',
        'consultation_type': _type!.name,
      });
      setState(() => _booking = false);
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessDialog(
            doctor: _doctor!,
            date: _fmtDate(_selectedDate!),
            slot: _selectedSlot!,
            type: _type!,
            consultLabel: _consultLabel,
          ),
        );
        Get.back();
      }
    } catch (e) {
      setState(() => _booking = false);
      _snack('बुकिङ असफल: $e', err: true);
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void _next() {
    if (!_canProceed) return;
    if (_step == 2) _fetchDoctors();
    if (_step == 5) {
      _book();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0)
      setState(() => _step--);
    else
      Get.back();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _back,
      ),
      title: const Text(
        'अपॉइन्टमेन्ट बुक',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    body: Column(
      children: [
        _StepBar(current: _step, labels: _stepLabels),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
          ),
        ),
        _BottomBar(
          step: _step,
          total: _stepLabels.length,
          canProceed: _canProceed,
          booking: _booking,
          onNext: _next,
        ),
      ],
    ),
  );

  Widget _buildStep() => switch (_step) {
    0 => Step0Type(
      selected: _type,
      onSelect: (t) => setState(() => _type = t),
    ),
    1 => Step1Location(
      province: _province,
      district: _district,
      municipality: _municipality,
      onProvince: (v) => setState(() {
        _province = v;
        _district = null;
        _municipality = null;
      }),
      onDistrict: (v) => setState(() {
        _district = v;
        _municipality = null;
      }),
      onMunicipality: (v) => setState(() => _municipality = v),
    ),
    2 => Step2Specialty(
      selected: _selectedSpecialtyNe,
      specialties: _specialties,
      onSelect: (s) => setState(() => _selectedSpecialtyNe = s),
    ),
    3 => Step3Doctor(
      loading: _loadingDoctors,
      doctors: _doctors,
      selected: _doctor,
      onSelect: (d) => setState(() => _doctor = d),
    ),
    4 => Step4DateTime(
      focusedMonth: _focusedMonth,
      selectedDate: _selectedDate,
      selectedSlot: _selectedSlot,
      availability: _slotAvailability,
      loadingSlots: _loadingSlots,
      onMonthChanged: (m) => setState(() => _focusedMonth = m),
      onDateSelect: (d) {
        setState(() {
          _selectedDate = d;
          _selectedSlot = null;
        });
        _checkAvailability();
      },
      onSlotSelect: (s) => setState(() => _selectedSlot = s),
    ),
    5 => Step5Summary(
      sympCtrl: _sympCtrl,
      report: _reportName,
      onUpload: () => setState(() => _reportName = 'report_2026.pdf'),
      type: _type!,
      doctor: _doctor!,
      date: _selectedDate,
      slot: _selectedSlot,
      fmtDate: _fmtDate,
      consultLabel: _consultLabel,
    ),
    _ => const SizedBox(),
  };
}


class _StepBar extends StatelessWidget {
  final int current;
  final List<String> labels;
  const _StepBar({required this.current, required this.labels});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: Column(
      children: [
        Row(
          children: List.generate(
            labels.length,
            (i) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == current
                          ? AppConstants.primaryColor
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: i == current
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: i == current
                        ? AppConstants.primaryColor
                        : i < current
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(height: 0.5, color: const Color(0xFFE2E8F0)),
      ],
    ),
  );
}


class _BottomBar extends StatelessWidget {
  final int step, total;
  final bool canProceed, booking;
  final VoidCallback onNext;
  const _BottomBar({
    required this.step,
    required this.total,
    required this.canProceed,
    required this.booking,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (canProceed && !booking) ? onNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed
              ? AppConstants.primaryColor
              : const Color(0xFFE2E8F0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF9CA3AF),
        ),
        child: booking
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                step == total - 1
                    ? 'अपॉइन्टमेन्ट बुक गर्नुहोस् / Confirm'
                    : 'अर्को / Next',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ),
  );
}











class DoctorInitials extends StatelessWidget {
  final String initials;
  const DoctorInitials(this.initials);
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    ),
  );
}

class DChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const DChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

class EmptyDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 64,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 14),
          Text(
            'यस क्षेत्रमा डाक्टर भेटिएन',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'जिल्ला परिवर्तन गर्नुहोस् वा नगरपालिका छोड्नुहोस्',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}




class NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const NavBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
    ),
  );
}

