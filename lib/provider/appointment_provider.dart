
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_model.dart';
import '../services/api_service.dart';


final appointmentsProvider = FutureProvider<List<Appt>>((ref) async {
  final rows = await ApiService.getMyAppointmentsEnriched();
  return rows.map(Appt.fromApi).toList();
});