import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/provider/patient_own_health.dart';

class PatientMedicalHistoryScreen extends ConsumerWidget {
  const PatientMedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(patientOwnHealthSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.medicalHistory,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(patientOwnHealthSummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(patientOwnHealthSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(patientOwnHealthSummaryProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAlerts(context, summary),
              _buildVitalsCard(context, summary),
              const SizedBox(height: 12),
              _buildAllergiesCard(context, summary),
              const SizedBox(height: 12),
              _buildConditionsCard(context, summary),
              const SizedBox(height: 12),
              _buildHistoryCard(context, summary),
              const SizedBox(height: 12),
              _buildImmunisationsCard(context, summary),
              const SizedBox(height: 12),
              _buildFamilyHistoryCard(context, summary),
              const SizedBox(height: 24),
              _buildPrescriptionsCard(context, summary, ref),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  //  ALERT CHIPS 

  Widget _buildAlerts(BuildContext context, Map<String, dynamic> summary) {
    final allergies = List<Map<String, dynamic>>.from(summary['allergies'] ?? []);
    final severe = allergies.where((a) => a['severity'] == 'severe').toList();
    final conditions = List<Map<String, dynamic>>.from(summary['conditions'] ?? []);
    final active = conditions.where((c) => c['status'] == 'active').toList();

    if (severe.isEmpty && active.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.activeAlerts,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.red.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final a in severe) _chip('⚠ ${a['allergen']}', Colors.red.shade700, Colors.red.shade100),
              for (final c in active) _chip(c['condition_name'] as String? ?? '', Colors.orange.shade800, Colors.orange.shade100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
  );

  //  VITALS CARD 

  Widget _buildVitalsCard(BuildContext context, Map<String, dynamic> summary) {
    final vitals = (summary['vitals']?['latest'] as Map<String, dynamic>?) ?? {};
    if (vitals.isEmpty) return const SizedBox.shrink();

    final tiles = <_VitalItem>[
      if (vitals['bp_systolic'] != null && vitals['bp_diastolic'] != null)
        _VitalItem(Icons.favorite_outline, AppLocalizations.of(context)!.bloodPressure,
            '${vitals['bp_systolic']}/${vitals['bp_diastolic']} mmHg'),
      if (vitals['heart_rate'] != null)
        _VitalItem(Icons.monitor_heart_outlined, AppLocalizations.of(context)!.heartRate, '${vitals['heart_rate']} bpm'),
      if (vitals['spo2'] != null) _VitalItem(Icons.air, 'SpO₂', '${vitals['spo2']}%'),
      if (vitals['temperature_c'] != null)
        _VitalItem(Icons.thermostat_outlined, AppLocalizations.of(context)!.temperature, '${vitals['temperature_c']}°C'),
      if (vitals['weight_kg'] != null)
        _VitalItem(Icons.monitor_weight_outlined, AppLocalizations.of(context)!.weight, '${vitals['weight_kg']} kg'),
      if (vitals['bmi'] != null)
        _VitalItem(Icons.speed_outlined, 'BMI', (vitals['bmi'] as num).toStringAsFixed(1)),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    final recordedAt = vitals['recorded_at'] as String?;
    return _SectionCard(
      icon: Icons.monitor_heart_outlined,
      title: AppLocalizations.of(context)!.latestVitals,
      subtitle: recordedAt != null ? _fmt(recordedAt) : null,
      child: Wrap(spacing: 8, runSpacing: 8, children: tiles.map((t) => _vitalBox(t)).toList()),
    );
  }

  Widget _vitalBox(_VitalItem t) => Container(
    width: 140,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        Icon(t.icon, size: 16, color: Colors.black38),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
              Text(t.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );

  //  ALLERGIES CARD 

  Widget _buildAllergiesCard(BuildContext context, Map<String, dynamic> summary) {
    final list = List<Map<String, dynamic>>.from(summary['allergies'] ?? []);
    if (list.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.warning_amber_outlined,
      title: AppLocalizations.of(context)!.allergies,
      count: list.length,
      child: Column(
        children: list.map((a) {
          final severity = a['severity'] as String? ?? 'moderate';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 3, right: 8),
                  decoration: BoxDecoration(color: _severityColor(severity), shape: BoxShape.circle),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['allergen'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (a['reaction'] != null) Text(a['reaction'] as String, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _severityColor(severity).withOpacity(.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    severity,
                    style: TextStyle(fontSize: 11, color: _severityColor(severity), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  //  CONDITIONS CARD 

  Widget _buildConditionsCard(BuildContext context, Map<String, dynamic> summary) {
    final list = List<Map<String, dynamic>>.from(summary['conditions'] ?? []);
    if (list.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.local_hospital_outlined,
      title: AppLocalizations.of(context)!.conditions,
      count: list.length,
      child: Column(
        children: list.map((c) {
          final status = c['status'] as String? ?? 'active';
          final statusColor = status == 'active'
              ? Colors.red.shade600
              : status == 'managed'
              ? Colors.orange.shade700
              : Colors.green.shade700;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['condition_name'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (c['diagnosed_date'] != null)
                        Text('${AppLocalizations.of(context)!.diagnosed}: ${_fmt(c['diagnosed_date'] as String)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  //  MEDICAL HISTORY CARD 

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> summary) {
    final list = List<Map<String, dynamic>>.from(summary['medical_history'] ?? []);
    if (list.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.history_edu_outlined,
      title: AppLocalizations.of(context)!.consultationHistory,
      count: list.length,
      child: Column(
        children: list.map((h) {
          final doctorData = h['doctors'] as Map<String, dynamic>? ?? {};
          final profiles = doctorData['user_profiles'] as Map<String, dynamic>? ?? {};
          final doctorName = profiles['full_name'] as String? ?? '—';
          final specialty = doctorData['specialty'] as String? ?? '';
          final type = h['consultation_type'] as String?;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(h['diagnosis'] as String? ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                    if (type != null) _TypeBadge(type),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$doctorName${specialty.isNotEmpty ? ' · $specialty' : ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(_fmt(h['created_at'] as String?), style: const TextStyle(fontSize: 11, color: Colors.black38)),
                if (h['chief_complaint'] != null) ...[
                  const SizedBox(height: 6),
                  Text(h['chief_complaint'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF444444))),
                ],
                if (h['treatment_plan'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.medication_liquid_outlined, size: 14, color: Colors.black38),
                      const SizedBox(width: 4),
                      Expanded(child: Text(h['treatment_plan'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54))),
                    ],
                  ),
                ],
                if (h['follow_up_days'] != null) ...[
                  const SizedBox(height: 4),
                  Text('${AppLocalizations.of(context)!.followUp}: ${h['follow_up_days']} days',
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade600)),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  //  IMMUNISATIONS CARD 

  Widget _buildImmunisationsCard(BuildContext context, Map<String, dynamic> summary) {
    final list = List<Map<String, dynamic>>.from(summary['immunisations'] ?? []);
    if (list.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.vaccines_outlined,
      title: AppLocalizations.of(context)!.immunisations,
      count: list.length,
      child: Column(
        children: list.map((imm) {
          final overdue = imm['overdue'] == true;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(overdue ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                    size: 16, color: overdue ? Colors.orange.shade700 : Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(imm['vaccine_name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Text('Dose ${imm['dose_number'] ?? 1}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                          if (imm['administered_at'] != null) ...[
                            const Text(' · ', style: TextStyle(fontSize: 11, color: Colors.black45)),
                            Text(_fmt(imm['administered_at'] as String), style: const TextStyle(fontSize: 11, color: Colors.black45)),
                          ],
                          if (overdue && imm['next_due_date'] != null) ...[
                            const SizedBox(width: 4),
                            Text('Due: ${_fmt(imm['next_due_date'] as String)}',
                                style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  //  FAMILY HISTORY CARD 

  Widget _buildFamilyHistoryCard(BuildContext context, Map<String, dynamic> summary) {
    final list = List<Map<String, dynamic>>.from(summary['family_history'] ?? []);
    if (list.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.people_outline,
      title: AppLocalizations.of(context)!.familyHistory,
      count: list.length,
      child: Column(
        children: list
            .map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Text(f['relation'] as String? ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black45, fontStyle: FontStyle.italic)),
              ),
              Expanded(child: Text(f['condition'] as String? ?? '', style: const TextStyle(fontSize: 13))),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  //  PRESCRIPTIONS CARD (fully localized) 

  Widget _buildPrescriptionsCard(BuildContext context, Map<String, dynamic> summary, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(patientOwnPrescriptionsProvider);

    return _SectionCard(
      icon: Icons.medication_outlined,
      title: AppLocalizations.of(context)!.prescriptions,
      count: null,
      child: prescriptionsAsync.when(
        loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (err, _) => Text(
          AppLocalizations.of(context)!.couldNotLoadPrescriptions(err.toString()),
          style: const TextStyle(color: Colors.black45),
        ),
        data: (list) => list.isEmpty
            ? Text(AppLocalizations.of(context)!.noPrescriptions, style: const TextStyle(color: Colors.black45))
            : Column(children: list.map((p) => _buildPrescriptionTile(p, context)).toList()),
      ),
    );
  }

  Widget _buildPrescriptionTile(Map<String, dynamic> p, BuildContext context) {
    final items = (p['items'] as List? ?? []).cast<Map<String, dynamic>>();
    final doctorName = p['doctors']?['user_profiles']?['full_name'] as String? ?? AppLocalizations.of(context)!.unknownDoctor;
    final specialty = p['doctors']?['specialty'] as String? ?? '';
    final notes = p['notes'] as String?;
    final followUpDate = p['follow_up_date'] as String?;
    final issuedAt = p['issued_at'] as String?;
    final diagnosis = p['diagnosis'] as String? ?? AppLocalizations.of(context)!.prescription;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(diagnosis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(_fmt(issuedAt), style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.medication, size: 14, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(_medicinesCountText(context, items.length), style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
          ],
        ),
        trailing: followUpDate != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event, size: 12, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text('${AppLocalizations.of(context)!.followUpLabel} ${_fmt(followUpDate)}',
                  style: TextStyle(fontSize: 10, color: Colors.orange.shade700)),
            ],
          ),
        )
            : null,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              children: [
                const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE8F0FE), child: Icon(Icons.person_outline, size: 16, color: Colors.blue)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppLocalizations.of(context)!.doctorTitle} $doctorName',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      if (specialty.isNotEmpty) Text(specialty, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (notes != null && notes.isNotEmpty) ...[
            Text(AppLocalizations.of(context)!.notes, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(notes, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 12),
          ],
          Text(AppLocalizations.of(context)!.medicines, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, idx) => _buildMedicineDetailTile(items[idx], context),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineDetailTile(Map<String, dynamic> item, BuildContext context) {
    final name = item['medicine_name'] as String? ?? '';
    final dosage = item['dosage'] as String?;
    final frequency = item['frequency'] as String?;
    final durationDays = item['duration_days'] as int?;
    final instructions = item['instructions'] as String?;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (dosage != null) _infoChip(Icons.medication_liquid_outlined, dosage),
              if (frequency != null) _infoChip(Icons.schedule_outlined, frequency),
              if (durationDays != null) _infoChip(Icons.calendar_today_outlined, '${durationDays.toString()} ${AppLocalizations.of(context)!.days}'),
            ],
          ),
          if (instructions != null && instructions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(instructions, style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  //  HELPERS 

  String _medicinesCountText(BuildContext context, int count) {
    if (count == 1) return AppLocalizations.of(context)!.oneMedicine;
    return AppLocalizations.of(context)!.medicinesCount(count);
  }

  String _fmt(String? iso) {
    if (iso == null) return '—';
    try {
      return DateFormat.yMMMd().format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  Color _severityColor(String? s) {
    switch (s) {
      case 'severe':
        return Colors.red.shade700;
      case 'moderate':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }
}

//  REUSABLE WIDGETS 

class _VitalItem {
  final IconData icon;
  final String label;
  final String value;
  const _VitalItem(this.icon, this.label, this.value);
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final int? count;
  final Widget child;
  const _SectionCard({required this.icon, required this.title, required this.child, this.subtitle, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.black45),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              if (count != null && count! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text('$count', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    const colors = {'video': Colors.blue, 'chat': Colors.purple, 'in_person': Colors.teal, 'audio': Colors.green};
    const icons = {
      'video': Icons.videocam_outlined,
      'chat': Icons.chat_bubble_outline,
      'in_person': Icons.local_hospital_outlined,
      'audio': Icons.headset_outlined,
    };
    final c = colors[type] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[type] ?? Icons.circle, size: 10, color: c),
          const SizedBox(width: 3),
          Text(type.replaceAll('_', ' '), style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.couldNotLoadRecord, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black38)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}

Widget _infoChip(IconData icon, String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: Colors.grey.shade600),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ],
  ),
);