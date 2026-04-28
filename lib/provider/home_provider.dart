import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_app/models/patients_model.dart';
import 'package:patient_app/services/api_service.dart';
import 'package:patient_app/widgets/appointment_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class HomeData {
  final PatientProfile profile;
  final AppointmentData? nextAppointment;
  final List<AppointmentData> recentAppointments;
  final Stats stats;
  final List<Map<String, dynamic>> upcomingRaw;
  final List<Map<String, dynamic>> quickDoctors;

  const HomeData({
    required this.profile,
    required this.nextAppointment,
    required this.recentAppointments,
    required this.stats,
    required this.upcomingRaw,
    required this.quickDoctors,
  });
}

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final supa = Supabase.instance.client;
  final uid = supa.auth.currentUser?.id;
  if (uid == null) throw Exception('Not authenticated');

  // Run all independent fetches in parallel
  final results = await Future.wait([
    supa
        .from('user_profiles')
        .select('full_name, avatar_url')
        .eq('id', uid)
        .maybeSingle(),
    supa
        .from('appointments')
        .select('id, scheduled_at, status, consultation_type, doctor_id')
        .eq('patient_id', uid)
        .order('scheduled_at', ascending: false)
        .limit(50),
  ]);

  List<Map<String, dynamic>> upcomingRaw = [];
  try {
    upcomingRaw = await ApiService.getUpcomingAppointmentsEnriched();
  } catch (_) {}

  List<Map<String, dynamic>> quickDoctors = [];
  try {
    final doctors = await ApiService.fetchDoctors(specialty: '');
    quickDoctors = doctors.take(4).toList();
  } catch (_) {}

  final profileMap = results[0] as Map<String, dynamic>?;
  final profile = PatientProfile(
    id: '',
    userId: uid,
    fullName: profileMap?['full_name']?.toString() ?? 'सदस्य',
    email: '',
    phone: '',
    dateOfBirth: null,
    gender: 'male',
    address: '',
    bloodGroup: '',
    conditions: [],
    avatar: profileMap?['avatar_url']?.toString() ?? '',
  );

  final apptRaw = results[1] as List<dynamic>;
  final doctorIds = apptRaw
      .map((e) => (e as Map<String, dynamic>)['doctor_id']?.toString())
      .where((id) => id != null && id.isNotEmpty)
      .toSet()
      .toList();

  final Map<String, Map<String, dynamic>> doctorMap = {};
  if (doctorIds.isNotEmpty) {
    try {
      final doctorRows = await supa
          .from('doctors')
          .select('id, user_id, specialty, healthpost_name')
          .inFilter('id', doctorIds);

      final userIds = (doctorRows as List)
          .map((row) => row['user_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      final profileRows = userIds.isEmpty
          ? <dynamic>[]
          : await supa
          .from('user_profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', userIds);

      final profileLookup = <String, Map<String, dynamic>>{
        for (final row in List<Map<String, dynamic>>.from(profileRows))
          row['id'].toString(): row,
      };

      for (final doctor in List<Map<String, dynamic>>.from(doctorRows)) {
        final doctorUserId = doctor['user_id']?.toString() ?? '';
        final doctorProfile = profileLookup[doctorUserId] ?? {};
        final doctorId = doctor['id']?.toString() ?? '';
        if (doctorId.isEmpty) continue;
        doctorMap[doctorId] = {
          'specialty': doctor['specialty']?.toString() ?? '',
          'healthpost_name': doctor['healthpost_name']?.toString() ?? '',
          'full_name': doctorProfile['full_name']?.toString() ?? 'डाक्टर',
          'avatar_url': doctorProfile['avatar_url']?.toString(),
        };
      }
    } catch (_) {}
  }

  AppointmentData? parseAppt(Map<String, dynamic> m, Map<String, dynamic> d) {
    try {
      return AppointmentData(
        id: m['id']?.toString() ?? '',
        doctorName: d['full_name']?.toString() ?? 'डाक्टर',
        specialty: d['specialty']?.toString() ?? '',
        healthpostName: d['healthpost_name']?.toString() ?? '',
        doctorAvatarUrl: d['avatar_url']?.toString(),
        scheduledAt: DateTime.parse(m['scheduled_at']).toLocal(),
        status: m['status']?.toString() ?? 'pending',
        consultationType: m['consultation_type']?.toString() ?? 'audio',
      );
    } catch (_) {
      return null;
    }
  }

  final apptList = apptRaw
      .map((e) {
    final m = e as Map<String, dynamic>;
    return parseAppt(m, doctorMap[m['doctor_id']?.toString() ?? ''] ?? {});
  })
      .whereType<AppointmentData>()
      .toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  final now = DateTime.now();
  final nextAppointment = apptList.firstWhereOrNull(
        (a) =>
    a.scheduledAt.isAfter(now) &&
        (a.status == 'confirmed' || a.status == 'pending'),
  );

  final monthStart = DateTime(now.year, now.month, 1);
  final stats = Stats(
    total: apptList.length,
    thisMonth: apptList.where((a) => a.scheduledAt.isAfter(monthStart)).length,
    pending: upcomingRaw.isNotEmpty
        ? upcomingRaw.length
        : apptList
        .where((a) => a.status == 'pending' || a.status == 'confirmed')
        .length,
  );

  return HomeData(
    profile: profile,
    nextAppointment: nextAppointment,
    recentAppointments: apptList.take(5).toList(),
    stats: stats,
    upcomingRaw: upcomingRaw,
    quickDoctors: quickDoctors,
  );
});

