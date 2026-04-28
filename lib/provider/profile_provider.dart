import 'package:patient_app/controller/profile_controller.dart';
import 'package:patient_app/models/patients_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = FutureProvider<PatientProfile?>((ref) async {
  final service = PatientService();
  return await service.fetchMyProfile();
});