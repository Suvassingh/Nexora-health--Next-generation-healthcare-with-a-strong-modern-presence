
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/appointment_model.dart';
import '../services/api_service.dart';
final refreshTriggerProvider = StateProvider<int>((ref) => 0);


final appointmentsProvider = FutureProvider<List<Appt>>((ref) async {
    ref.watch(refreshTriggerProvider);

  final rows = await ApiService.getMyAppointmentsEnriched();

  for (final r in rows) {
    print('  id=${r['id']} status=${r['status']} scheduled=${r['scheduled_at']} doctor_name=${r['doctor_name']} full_name=${r['full_name']}');
  }

  final mapped = rows.map(Appt.fromApi).toList();
  print('MAPPED: ${mapped.length} ');
  return mapped;
});