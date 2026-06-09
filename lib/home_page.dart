import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/call_history_screen.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/models/notification_model.dart';
import 'package:patient_app/models/patients_model.dart';
import 'package:patient_app/notification_screen.dart';
import 'package:patient_app/provider/notification_provider.dart';
import 'package:patient_app/services/appointment_reminder_service.dart';
import 'package:patient_app/services/notification_service.dart';
import 'package:patient_app/widgets/appointment_data.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/simmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_screen.dart';
import 'package:patient_app/emergency_callscreen.dart';
import 'package:patient_app/services/api_service.dart';
import 'package:patient_app/provider/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _supa = Supabase.instance.client;
  String _cancellingId = '';
  bool _remindersScheduled = false; 

  StreamSubscription<AppNotification>? _notifSub;
  @override
  void initState() {
    super.initState();
  
    _notifSub = NotificationService.instance.inAppStream.listen((n) {
      ref.read(notificationProvider.notifier).addNew(n);
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  Future<void> _cancelAppointment(
    String appointmentId,
    String doctorName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.cancelAppointmentTitle,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.cancelAppointmentConfirm(doctorName),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.cancelConfirmBtn),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancellingId = appointmentId);
    try {
      await ApiService.cancelAppointment(appointmentId);
      Get.snackbar(
        AppLocalizations.of(context)!.success,
        AppLocalizations.of(context)!.appointmentCancelled,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
      ref.invalidate(homeDataProvider);
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        e.toString(),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
    } finally {
      setState(() => _cancellingId = '');
    }
  }

  AppointmentData? _parseAppointment(
    Map<String, dynamic> m,
    Map<String, dynamic> doctorData,
  ) {
    try {
      return AppointmentData(
        id: m['id']?.toString() ?? '',
        doctorName: doctorData['full_name']?.toString() ?? 'डाक्टर',
        specialty: doctorData['specialty']?.toString() ?? '',
        healthpostName: doctorData['healthpost_name']?.toString() ?? '',
        doctorAvatarUrl: doctorData['avatar_url']?.toString(),
        scheduledAt: DateTime.parse(m['scheduled_at']).toLocal(),
        status: m['status']?.toString() ?? 'pending',
        consultationType: m['consultation_type']?.toString() ?? 'audio',
      );
    } catch (_) {
      return null;
    }
  }

  String _greeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = DateTime.now().hour;
    if (h < 12) return l10n.goodMorning;
    if (h < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      //   floatingActionButton: homeAsync.whenOrNull(
      //   data: (data) {
      //     final firstName = _getFirstName(data.profile);
      //     final next = data.nextAppointment;
      //     final voiceText = next != null
      //         ? '${_greeting(context)} $firstName. '
      //           'तपाईंको अर्को अपोइन्टमेन्ट डा. ${next.doctorName} सँग '
      //           '${next.formattedDate} मा छ। '
      //           'तपाईंका जम्मा ${data.stats.total} परामर्श छन्, '
      //           '${data.stats.pending} आउँदो छ।'
      //         : '${_greeting(context)} $firstName. '
      //           'आज कुनै आउँदो अपोइन्टमेन्ट छैन। '
      //           'तपाईंका जम्मा ${data.stats.total} परामर्श छन्।';
      //     return VoiceFab(text: voiceText);
      //   },
      // ),
      body: homeAsync.when(
         data: (data) {
          // Schedule reminders only once (runs when data first loads)
          if (!_remindersScheduled) {
            _remindersScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppointmentReminderService.rescheduleAllReminders();
            });
          }
          // Wrap the content with RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(homeDataProvider),
            child: _buildHomeContent(data),
          );
        },
        loading: () => _buildShimmer(),
        error: (e, _) =>
            _buildError(e.toString(), () => ref.invalidate(homeDataProvider)),
      
      ),
    );
  }

  Widget _buildHomeContent(HomeData data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildGreeting(data.profile),
          const SizedBox(height: 20),
          _buildActionCards(),
          const SizedBox(height: 24),
          _buildNextAppointmentSection(data.nextAppointment),
          const SizedBox(height: 20),
          _buildStatsRow(data.stats),
          if (data.upcomingRaw.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildUpcomingApiSection(data.upcomingRaw),
          ],
          const SizedBox(height: 24),
          _buildQuickDoctorsSection(data.quickDoctors),
          const SizedBox(height: 24),
          _buildRecentHeader(),
          const SizedBox(height: 12),
          if (data.recentAppointments.isEmpty)
            _buildEmptyRecent()
          else
            ...data.recentAppointments.map((a) => _buildRecentCard(a)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(15)),
    ),
    backgroundColor: AppConstants.primaryColor,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    title: const Row(
      children: [
        Image(
          image: AssetImage('assets/images/gov_logo.webp'),
          width: 40,
          height: 40,
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.nepalSarkar,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              AppConstants.govtOfNepal,
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Consumer(
          builder: (context, ref, _) {
            final unread = ref.watch(notificationProvider).unreadCount;
            return GestureDetector(
              onTap: () => Get.to(() => const NotificationScreen()),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Inside DoctorHomeScreen's appBar actions or drawer
                  
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(width: 4),

      const LanguageToggleButton(),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.history),
        onPressed: () => Get.to(() => const CallHistoryScreen()),
      )
    ],
  );
  String _getFirstName(PatientProfile profile) {
    final name = profile.fullName ?? '';
    return name.split(' ').first;
  }

  Widget _buildGreeting(PatientProfile profile) {
    final firstName = _getFirstName(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF1A1A1A)),
                  children: [
                    TextSpan(
                      text: '${_greeting(context)}, $firstName ',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: '👋', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ),
            ),
            if (profile.avatar.isNotEmpty)
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(profile.avatar),
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              )
            else
              CircleAvatar(
                radius: 22,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.12),
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.howareyoufeelingtoday,
          style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildActionCards() => Row(
    children: [
      Expanded(
        child: _ActionCard(
          icon: Icons.calendar_today_rounded,
          label: AppLocalizations.of(context)!.bookAppointment,

          color: AppConstants.primaryColor,
          onTap: () => Get.to(() => const SimpleBookScreen()),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _ActionCard(
          icon: Icons.emergency_rounded,
          label: AppLocalizations.of(context)!.emergencyContact,

          color: const Color(0xFFB71C1C),
          onTap: () => Get.to(() => EmergencyCallscreen()),
        ),
      ),
    ],
  );

  Widget _buildNextAppointmentSection(AppointmentData? next) {
    if (next == null) return _buildNoUpcoming();
    final a = next;
    return GestureDetector(
      onTap: () => Get.to(() => AppointmentsScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.upcomingAppointment,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: a.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.statusLabel(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _DoctorAvatar(
                    name: a.doctorName,
                    avatarUrl: a.doctorAvatarUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'डा. ${a.doctorName}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.specialty,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.healthpostName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              a.formattedDate(context),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(a.consultIcon, size: 13, color: Colors.grey),
                            const SizedBox(width: 3),
                            Text(
                              _consultTypeLabel(a.consultationType, context),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => AppointmentsScreen()),
                      icon: Icon(a.consultIcon, size: 18),
                      label: Text(
                        a.consultationType == 'video'
                            ? 'Join Video'
                            : a.consultationType == 'audio'
                            ? 'Join Call'
                            : 'Open Chat',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (a.status == 'pending' || a.status == 'confirmed')
                    _cancellingId == a.id
                        ? const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () =>
                                _cancelAppointment(a.id, a.doctorName),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUpcoming() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            color: AppConstants.primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.noUpcomingAppointments,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.bookNewAppointmentHint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.to(() => const SimpleBookScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context)!.book,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsRow(Stats stats) => Row(
    children: [
      _StatCard(
        value: '${stats.total}',
        label: AppLocalizations.of(context)!.totalConsultations,
        color: AppConstants.primaryColor,
      ),
      const SizedBox(width: 12),
      _StatCard(
        value: '${stats.thisMonth}',
        label: AppLocalizations.of(context)!.thisMonth,
        color: const Color(0xFF1565C0),
      ),
      const SizedBox(width: 12),
      _StatCard(
        value: '${stats.pending}',
        label: AppLocalizations.of(context)!.upcoming,
        color: const Color(0xFFE65100),
      ),
    ],
  );

  Widget _buildUpcomingApiSection(List<Map<String, dynamic>> raw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.thisWeekAppointments,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${raw.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: raw.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildUpcomingApiCard(raw[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingApiCard(Map<String, dynamic> appt) {
    final id = appt['id']?.toString() ?? '';
    final doctor = appt['doctor'];
    final doctorMap = doctor is Map<String, dynamic> ? doctor : null;
    final doctorProfile = doctorMap?['profile'];
    final doctorProfileMap = doctorProfile is Map<String, dynamic>
        ? doctorProfile
        : null;
    final doctorName =
        appt['doctor_name']?.toString() ??
        appt['full_name']?.toString() ??
        doctorMap?['full_name']?.toString() ??
        doctorProfileMap?['full_name']?.toString() ??
        appt['doctor']?.toString() ??
        'डाक्टर';
    final scheduledAt = appt['scheduled_at'] != null
        ? DateTime.tryParse(appt['scheduled_at'].toString())?.toLocal()
        : null;
    final type = appt['consultation_type']?.toString() ?? 'audio';
    final status = appt['status']?.toString() ?? 'pending';

    final statusColor = status == 'confirmed'
        ? Colors.green
        : status == 'cancelled'
        ? Colors.red
        : Colors.orange;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'डा. $doctorName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (scheduledAt != null)
            Text(
              '${scheduledAt.day}/${scheduledAt.month} – ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: AppConstants.primaryColor),
            ),
          const SizedBox(height: 4),
          Text(
            _consultTypeLabel(type, context),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const Spacer(),
          if (status == 'pending' || status == 'confirmed')
            Align(
              alignment: Alignment.centerRight,
              child: _cancellingId == id
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : GestureDetector(
                      onTap: () => _cancelAppointment(id, doctorName),
                      child: Text(
                        AppLocalizations.of(context)!.cancelAction,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickDoctorsSection(List<Map<String, dynamic>> doctors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.findDoctor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.to(() => const SimpleBookScreen()),
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (doctors.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noDoctorsAvailable,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          )
        else
          ...(doctors.map((d) => _buildDoctorListTile(d))),
      ],
    );
  }

  Widget _buildDoctorListTile(Map<String, dynamic> doctor) {
    final name =
        doctor['full_name']?.toString() ??
        doctor['name']?.toString() ??
        'डाक्टर';
    final specialty = doctor['specialty']?.toString() ?? '';
    final healthpost = doctor['healthpost_name']?.toString() ?? '';
    final avatarUrl = doctor['avatar_url']?.toString();
    final doctorId = doctor['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _DoctorAvatar(name: name, avatarUrl: avatarUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'डा. $name',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (specialty.isNotEmpty)
                  Text(
                    specialty,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (healthpost.isNotEmpty)
                  Text(
                    healthpost,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const SimpleBookScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AppLocalizations.of(context)!.book,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader() => Row(
    children: [
      Text(
        AppLocalizations.of(context)!.recentAppointments,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () => Get.to(() => AppointmentsScreen()),
        child: Text(
          AppLocalizations.of(context)!.seeAll,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _buildRecentCard(AppointmentData a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        _DoctorAvatar(
          name: a.doctorName,
          avatarUrl: a.doctorAvatarUrl,
          size: 44,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'डा. ${a.doctorName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                a.specialty.isEmpty ? a.healthpostName : a.specialty,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 11,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    a.formattedDate(context),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Icon(a.consultIcon, size: 11, color: Colors.grey),
                  const SizedBox(width: 3),
                  Text(
                    _consultTypeLabel(a.consultationType, context),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: a.statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a.statusLabel(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (a.status == 'pending' || a.status == 'confirmed') ...[
              const SizedBox(height: 6),
              _cancellingId == a.id
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : GestureDetector(
                      onTap: () => _cancelAppointment(a.id, a.doctorName),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ],
    ),
  );

  Widget _buildEmptyRecent() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade200),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.noAppointmentsYet,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    ),
  );

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 200, height: 26, radius: 8),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 150, height: 14, radius: 6),
                  ],
                ),
              ),
              const ShimmerBox(width: 44, height: 44, radius: 22),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: ShimmerBox(height: 130, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 130, radius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(height: 180, radius: 18),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: ShimmerBox(height: 72, radius: 14)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 72, radius: 14)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 72, radius: 14)),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 160, height: 18, radius: 6),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) =>
                  const ShimmerBox(width: 190, height: 110, radius: 14),
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 140, height: 18, radius: 6),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ShimmerBox(height: 70, radius: 14),
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 160, height: 18, radius: 6),
          const SizedBox(height: 12),
          ...List.generate(
            2,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ShimmerBox(height: 80, radius: 14),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  String _consultTypeLabel(String type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'video':
        return l10n.video;
      case 'audio':
        return l10n.audio;
      default:
        return l10n.chat;
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _DoctorAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  const _DoctorAvatar({required this.name, this.avatarUrl, required this.size});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppConstants.primaryColor.withOpacity(0.12),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
