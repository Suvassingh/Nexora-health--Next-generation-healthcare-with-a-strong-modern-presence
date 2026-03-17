import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patient_app/app_constants.dart';


class _Appt {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String healthpostName;
  final String? avatarUrl;
  final DateTime scheduledAt;
  final String status;
  final String consultType; // chat | audio | video
  final String? reason;

  const _Appt({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.healthpostName,
    this.avatarUrl,
    required this.scheduledAt,
    required this.status,
    required this.consultType,
    this.reason,
  });

  // ── Derived helpers ────────────────────────────────────────────────────────
  String get initials {
    final pts = doctorName.trim().split(' ');
    if (pts.length >= 2) return '${pts[0][0]}${pts[1][0]}'.toUpperCase();
    return pts.isNotEmpty && pts[0].isNotEmpty ? pts[0][0].toUpperCase() : 'D';
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return scheduledAt.isAfter(now) &&
        (status == 'pending' || status == 'confirmed');
  }

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled' || status == 'no_show';

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  bool get isTomorrow {
    final tom = DateTime.now().add(const Duration(days: 1));
    return scheduledAt.year == tom.year &&
        scheduledAt.month == tom.month &&
        scheduledAt.day == tom.day;
  }

  String get dateLabel {
    if (isToday) return 'आज';
    if (isTomorrow) return 'भोलि';
    const months = [
      'जनवरी',
      'फेब्रुअरी',
      'मार्च',
      'अप्रिल',
      'मे',
      'जुन',
      'जुलाई',
      'अगस्ट',
      'सेप्टेम्बर',
      'अक्टोबर',
      'नोभेम्बर',
      'डिसेम्बर',
    ];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}';
  }

  String get timeLabel {
    final h = scheduledAt.hour % 12 == 0 ? 12 : scheduledAt.hour % 12;
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    final ap = scheduledAt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ap';
  }

  String get dateTimeLabel => '$dateLabel, $timeLabel';

  IconData get consultIcon => switch (consultType) {
    'video' => Icons.videocam_rounded,
    'audio' => Icons.phone_rounded,
    _ => Icons.chat_bubble_rounded,
  };

  String get consultLabel => switch (consultType) {
    'video' => 'video',
    'audio' => 'audio',
    _ => 'chat',
  };

  Color get statusColor => switch (status) {
    'confirmed' => const Color(0xFF1565C0),
    'pending' => const Color(0xFFB71C1C),
    'completed' => const Color(0xFF2E7D32),
    'cancelled' => const Color(0xFF757575),
    'no_show' => const Color(0xFF6D4C41),
    _ => const Color(0xFF546E7A),
  };

  String get statusNe => switch (status) {
    'confirmed' => 'आउँदो',
    'pending' => 'आउँदो',
    'completed' => 'सम्पन्न',
    'cancelled' => 'रद्द',
    'no_show' => 'गैरहाजिर',
    _ => status,
  };

  factory _Appt.fromMap(Map<String, dynamic> m, Map<String, dynamic> extras) {
    final prof =
        m['user_profiles!appointments_doctor_id_fkey']
            as Map<String, dynamic>? ??
        m['user_profiles'] as Map<String, dynamic>? ??
        {};
    return _Appt(
      id: m['id']?.toString() ?? '',
      doctorId: m['doctor_id']?.toString() ?? '',
      doctorName: prof['full_name']?.toString() ?? 'डाक्टर',
      specialty: extras['specialty']?.toString() ?? '',
      healthpostName: extras['healthpost_name']?.toString() ?? '',
      avatarUrl: prof['avatar_url']?.toString(),
      scheduledAt: DateTime.parse(m['scheduled_at']).toLocal(),
      status: m['status']?.toString() ?? 'pending',
      consultType: m['consultation_type']?.toString() ?? 'audio',
      reason: m['reason']?.toString(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _supa = Supabase.instance.client;

  late TabController _tabCtrl;

  bool _loading = true;
  bool _cancelling = false;
  String? _error;

  List<_Appt> _upcoming = [];
  List<_Appt> _completed = [];
  List<_Appt> _cancelled = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = _supa.auth.currentUser?.id;
      if (uid == null) throw Exception('Not authenticated');

      // Step 1 — fetch appointments with doctor user_profiles join
      final rows = await _supa
          .from('appointments')
          .select(
            'id, doctor_id, scheduled_at, status, consultation_type, reason, '
            'user_profiles!appointments_doctor_id_fkey(full_name, avatar_url)',
          )
          .eq('patient_id', uid)
          .order('scheduled_at', ascending: false);

      // Step 2 — fetch doctor extras (specialty, healthpost) by user_ids
      final doctorIds = (rows as List)
          .map((e) => (e as Map<String, dynamic>)['doctor_id']?.toString())
          .where((id) => id != null && id!.isNotEmpty)
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> extrasMap = {};
      if (doctorIds.isNotEmpty) {
        try {
          final dRows = await _supa
              .from('doctors')
              .select('user_id, specialty, healthpost_name')
              .inFilter('user_id', doctorIds);
          for (final r in dRows as List) {
            final m = r as Map<String, dynamic>;
            extrasMap[m['user_id']?.toString() ?? ''] = m;
          }
        } catch (_) {}
      }

      // Step 3 — parse and bucket
      final all = rows
          .map((e) {
            final m = e as Map<String, dynamic>;
            final did = m['doctor_id']?.toString() ?? '';
            try {
              return _Appt.fromMap(m, extrasMap[did] ?? {});
            } catch (_) {
              return null;
            }
          })
          .where((a) => a != null)
          .cast<_Appt>()
          .toList();

      final now = DateTime.now();
      setState(() {
        _upcoming =
            all
                .where(
                  (a) =>
                      (a.status == 'pending' || a.status == 'confirmed') &&
                      a.scheduledAt.isAfter(now),
                )
                .toList()
              ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        _completed = all.where((a) => a.status == 'completed').toList()
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

        _cancelled =
            all
                .where((a) => a.status == 'cancelled' || a.status == 'no_show')
                .toList()
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Cancel appointment ────────────────────────────────────────────────────
  Future<void> _cancelAppointment(_Appt appt) async {
    final confirm = await _showCancelDialog(appt);
    if (confirm != true) return;

    setState(() => _cancelling = true);
    try {
      await _supa
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appt.id);

      Get.snackbar(
        'रद्द गरियो',
        'अपोइन्टमेन्ट सफलतापूर्वक रद्द गरियो।',
        backgroundColor: const Color(0xFFF5F5F5),
        colorText: const Color(0xFF424242),
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      await _loadAppointments();
    } catch (e) {
      Get.snackbar(
        'त्रुटि',
        'रद्द गर्न सकिएन: $e',
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFEF4444),
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<bool?> _showCancelDialog(_Appt appt) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'अपोइन्टमेन्ट रद्द गर्नुहुन्छ?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'डा. ${appt.doctorName}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            appt.dateTimeLabel,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            'यो कार्य पूर्ववत गर्न सकिँदैन।',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('फिर्ता', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('रद्द गर्नुहोस्'),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: _loading
          ? _buildShimmer()
          : _error != null
          ? _buildError()
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildTabContent(_upcoming, 'upcoming'),
                _buildTabContent(_completed, 'completed'),
                _buildTabContent(_cancelled, 'cancelled'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(
          () => const BookAppointmentScreen(),
        )?.then((_) => _loadAppointments()),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'नयाँ बुक',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ── AppBar with tabs ──────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppConstants.primaryColor,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    leading: Navigator.canPop(context)
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          )
        : null,
    title: const Text(
      'मेरा अपोइन्टमेन्ट',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        onPressed: _loadAppointments,
      ),
    ],
    bottom: TabBar(
      controller: _tabCtrl,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      tabs: [
        Tab(
          text: 'आउँदो${_upcoming.isNotEmpty ? " (${_upcoming.length})" : ""}',
        ),
        Tab(text: 'सम्पन्न'),
        Tab(text: 'रद्द'),
      ],
    ),
  );

  // ── Tab content ───────────────────────────────────────────────────────────
  Widget _buildTabContent(List<_Appt> list, String type) {
    if (list.isEmpty) return _buildEmpty(type);
    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: list.length,
        itemBuilder: (_, i) => _ApptCard(
          appt: list[i],
          showJoin: type == 'upcoming',
          showCancel: type == 'upcoming',
          cancelling: _cancelling,
          onCancel: () => _cancelAppointment(list[i]),
          onJoin: () => _handleJoin(list[i]),
          onTap: () => _showDetailSheet(list[i]),
        ),
      ),
    );
  }

  // ── Join handler ──────────────────────────────────────────────────────────
  void _handleJoin(_Appt appt) {
    Get.snackbar(
      '${appt.consultLabel.toUpperCase()} जोइन',
      'डा. ${appt.doctorName} सँग ${appt.consultLabel} सुरु हुँदैछ...',
      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      colorText: AppConstants.primaryColor,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  // ── Detail bottom sheet ───────────────────────────────────────────────────
  void _showDetailSheet(_Appt a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        appt: a,
        onCancel: () {
          Navigator.pop(context);
          _cancelAppointment(a);
        },
        onJoin: () {
          Navigator.pop(context);
          _handleJoin(a);
        },
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty(String type) {
    final icon = type == 'upcoming'
        ? Icons.calendar_today_outlined
        : type == 'completed'
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;
    final msg = type == 'upcoming'
        ? 'कुनै आउँदो अपोइन्टमेन्ट छैन'
        : type == 'completed'
        ? 'कुनै सम्पन्न अपोइन्टमेन्ट छैन'
        : 'कुनै रद्द गरिएको अपोइन्टमेन्ट छैन';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          if (type == 'upcoming') ...[
            Text(
              'नयाँ अपोइन्टमेन्ट बुक गर्न तलको बटन थिच्नुहोस्',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    itemBuilder: (_, __) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'डेटा लोड गर्न सकिएन',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? '',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('पुन: प्रयास'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// APPOINTMENT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ApptCard extends StatelessWidget {
  final _Appt appt;
  final bool showJoin;
  final bool showCancel;
  final bool cancelling;
  final VoidCallback onCancel;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  const _ApptCard({
    required this.appt,
    required this.showJoin,
    required this.showCancel,
    required this.cancelling,
    required this.onCancel,
    required this.onJoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Doctor info row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  _Avatar(name: appt.doctorName, url: appt.avatarUrl, size: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'डा. ${appt.doctorName}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          appt.specialty.isNotEmpty
                              ? appt.specialty
                              : appt.healthpostName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 7),
                        // Date + time + consult type
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: Color(0xFFB71C1C),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              appt.dateTimeLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB71C1C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              appt.consultIcon,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appt.consultLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        // Reason (if set)
                        if (appt.reason != null && appt.reason!.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            appt.reason!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: appt.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appt.statusNe,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────
            if (showJoin || showCancel)
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: const Color(0xFFE2E8F0),
              ),

            // ── Action buttons ────────────────────────────────────────────
            if (showJoin || showCancel)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  children: [
                    // Join button (full width)
                    if (showJoin)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onJoin,
                          icon: Icon(appt.consultIcon, size: 17),
                          label: const Text(
                            'Join',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    if (showJoin && showCancel) const SizedBox(height: 8),
                    // Cancel button (full width, always visible for upcoming)
                    if (showCancel)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: cancelling ? null : onCancel,
                          icon: cancelling
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : const Icon(Icons.cancel_outlined, size: 17),
                          label: const Text(
                            'अपोइन्टमेन्ट रद्द गर्नुहोस्',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade300),
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final _Appt appt;
  final VoidCallback? onCancel;
  final VoidCallback? onJoin;

  const _DetailSheet({required this.appt, this.onCancel, this.onJoin});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Scrollable content
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  // Header
                  Row(
                    children: [
                      _Avatar(
                        name: appt.doctorName,
                        url: appt.avatarUrl,
                        size: 56,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'डा. ${appt.doctorName}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appt.specialty.isNotEmpty
                                  ? appt.specialty
                                  : appt.healthpostName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            if (appt.specialty.isNotEmpty &&
                                appt.healthpostName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                appt.healthpostName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: appt.statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appt.statusNe,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info rows
                  _SheetRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'मिति',
                    value: appt.dateLabel,
                  ),
                  _SheetRow(
                    icon: Icons.access_time_rounded,
                    label: 'समय',
                    value: appt.timeLabel,
                  ),
                  _SheetRow(
                    icon: appt.consultIcon,
                    label: 'परामर्श',
                    value: appt.consultLabel,
                  ),
                  if (appt.reason != null && appt.reason!.isNotEmpty)
                    _SheetRow(
                      icon: Icons.notes_rounded,
                      label: 'कारण',
                      value: appt.reason!,
                    ),
                  _SheetRow(
                    icon: Icons.home_outlined,
                    label: 'स्वास्थ्य संस्था',
                    value: appt.healthpostName.isEmpty
                        ? '—'
                        : appt.healthpostName,
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (appt.isUpcoming) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onJoin,
                        icon: Icon(appt.consultIcon, size: 18),
                        label: Text(
                          'Join ${appt.consultLabel}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text(
                          'अपोइन्टमेन्ट रद्द गर्नुहोस्',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          backgroundColor: Colors.red.shade50,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppConstants.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED AVATAR
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  final double size;
  const _Avatar({required this.name, this.url, required this.size});

  String get _initials {
    final pts = name.trim().split(' ');
    if (pts.length >= 2) return '${pts[0][0]}${pts[1][0]}'.toUpperCase();
    return pts.isNotEmpty && pts[0].isNotEmpty ? pts[0][0].toUpperCase() : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final r = size / 2;
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: r,
        backgroundImage: NetworkImage(url!),
        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      );
    }
    return CircleAvatar(
      radius: r,
      backgroundColor: AppConstants.primaryColor.withOpacity(0.12),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: r * 0.65,
        ),
      ),
    );
  }
}
