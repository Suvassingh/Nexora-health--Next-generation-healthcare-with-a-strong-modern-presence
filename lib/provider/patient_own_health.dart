

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart'; 
String? _currentUserId() => Supabase.instance.client.auth.currentUser?.id;

final patientOwnHealthSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final uid = _currentUserId();
  if (uid == null) throw Exception('Not authenticated');

  final res = await ApiService.dio.get('/health-records/summary/$uid');

  final data = res.data;
  if (data is! Map<String, dynamic>) {
    throw Exception('Unexpected response format');
  }
  return data;
});

final patientOwnHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final uid = _currentUserId();
  if (uid == null) throw Exception('Not authenticated');

  final res = await ApiService.dio.get(
    '/health-records/$uid/history',
    queryParameters: {'limit': 50},
  );

  final data = res.data;
  if (data is List) {
    return List<Map<String, dynamic>>.from(data);
  }
  return [];
});

final patientOwnAllergiesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final uid = _currentUserId();
  if (uid == null) throw Exception('Not authenticated');

  final res = await ApiService.dio.get('/health-records/$uid/allergies');
  final data = res.data;
  if (data is List) return List<Map<String, dynamic>>.from(data);
  return [];
});

final patientOwnConditionsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final uid = _currentUserId();
    if (uid == null) throw Exception('Not authenticated');

    final res = await ApiService.dio.get('/health-records/$uid/conditions');
    final data = res.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  },
);

final patientOwnVitalsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final uid = _currentUserId();
  if (uid == null) throw Exception('Not authenticated');

  final res = await ApiService.dio.get(
    '/health-records/$uid/vitals',
    queryParameters: {'limit': 20},
  );
  final data = res.data;
  if (data is List) return List<Map<String, dynamic>>.from(data);
  return [];
});


final patientOwnImmunisationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final uid = _currentUserId();
      if (uid == null) throw Exception('Not authenticated');

      final res = await ApiService.dio.get(
        '/health-records/$uid/immunisations',
      );
      final data = res.data;
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    });

/// Convenience provider: family history.
final patientOwnFamilyHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final uid = _currentUserId();
      if (uid == null) throw Exception('Not authenticated');

      final res = await ApiService.dio.get(
        '/health-records/$uid/family-history',
      );
      final data = res.data;
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    });
final patientOwnPrescriptionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final uid = _currentUserId();
      if (uid == null) throw Exception('Not authenticated');

      final res = await ApiService.dio.get('/prescriptions/patient/$uid');
      final data = res.data;
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    });
