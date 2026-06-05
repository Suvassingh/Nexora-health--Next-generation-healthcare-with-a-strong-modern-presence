
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_model.dart';
import '../services/api_service.dart';


final appointmentsProvider = FutureProvider<List<Appt>>((ref) async {
  final rows = await ApiService.getMyAppointmentsEnriched();

  print('RAW ROWS: ${rows.length} ');
  for (final r in rows) {
    print('  id=${r['id']} status=${r['status']} scheduled=${r['scheduled_at']} doctor_name=${r['doctor_name']} full_name=${r['full_name']}');
  }

  final mapped = rows.map(Appt.fromApi).toList();
  print('MAPPED: ${mapped.length} ');
  return mapped;
});