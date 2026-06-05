import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

abstract class NotifType {
  static const appointmentConfirmed = 'appointment_confirmed';
  static const appointmentCancelled = 'appointment_cancelled';
  static const appointmentReminder = 'appointment_reminder';
  static const callIncoming = 'call_incoming';
  static const chatMessage = 'chat_message';
  static const completed = 'completed';
  static const newAppointment = 'new_appointment';
  static const noShow = 'no_show';
}

class ApiService {
  static String baseUrl = 'http://45.115.217.244/api';
  static Dio? _dio;
  static Dio? _supabaseFunctionsDio; 

  static Dio get dio {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          } else {
            debugPrint(
              '[ApiService] No Supabase session — request unauthenticated',
            );
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra['retried'] != true) {
            try {
              // await Supabase.instance.client.auth.refreshSession();
              final newSession = Supabase.instance.client.auth.currentSession;
              if (newSession != null) {
                e.requestOptions.headers['Authorization'] =
                    'Bearer ${newSession.accessToken}';
                e.requestOptions.extra['retried'] = true;
                final retry = await _dio!.fetch(e.requestOptions);
                return handler.resolve(retry);
              }
            } catch (_) {}
          }
          return handler.next(e);
        },
      ),
    );

    return _dio!;
  }


static Dio get supabaseFunctionsDio {
    if (_supabaseFunctionsDio != null) return _supabaseFunctionsDio!;

    // Read from .env at runtime 
    final supabaseAnonKey = dotenv.env['supabase_anonKey'];
    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('Missing supabase_anonKey in .env file');
    }

    _supabaseFunctionsDio = Dio(
      BaseOptions(
        baseUrl: 'https://clmlpgtxonfdnhjgdtxm.supabase.co/functions/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      ),
    );
    return _supabaseFunctionsDio!;
  }

  static void resetDio() => _dio = null;
  // PUSH NOTIFICATION
  static Future<void> _sendPushNotification({
    required String recipientUserId,
    required String userType,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'recipientUserId': recipientUserId,
          'userType': userType,
          'title': title,
          'body': body,
          'type': type,
          'data': data ?? {},
        },
      );
      debugPrint('Notification sent to $userType ($recipientUserId)');
    } catch (e) {
      debugPrint('Failed to send push notification: $e');
    }
  }
  // APPOINTMENTS
  static Future<Map<String, dynamic>> bookAppointment({
    required int doctorTableId,
    required String consultationType,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? patientNotes,
  }) async {
    try {
      final res = await dio.post(
        '/appointments/',
        data: {
          'doctor_id': doctorTableId,
          'consultation_type': consultationType,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'duration_minutes': durationMinutes,
          'patient_notes': patientNotes,
        },
      );
      final appointmentData = Map<String, dynamic>.from(res.data);
      final appointmentId = appointmentData['id'].toString();

      final supabase = Supabase.instance.client;
      final doctorRecord = await supabase
          .from('doctors')
          .select('user_id')
          .eq('id', doctorTableId)
          .maybeSingle();
      final doctorUserId = doctorRecord?['user_id']?.toString();

      if (doctorUserId == null || doctorUserId.isEmpty) {
        debugPrint(
          'Doctor user_id not found for doctorTableId=$doctorTableId',
        );
      } else {
        await _sendPushNotification(
          recipientUserId: doctorUserId,
          userType: 'doctor',
          title: 'New Appointment Request',
          body: 'A patient has booked an appointment with you.',
          type: NotifType.newAppointment,
          data: {'appointment_id': appointmentId},
        );
      }
      return appointmentData;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<String>> checkSlotAvailability({
    required int doctorTableId,
    required DateTime date,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final res = await dio.post(
        '/appointments/check-slots',
        data: {'doctor_id': doctorTableId, 'date': dateStr},
      );
      final data = Map<String, dynamic>.from(res.data);
      return List<String>.from(data['booked_slots'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getMyAppointments() async {
    try {
      final res = await dio.get('/appointments/');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getMyAppointmentsEnriched() async {
    final rows = await getMyAppointments();
    return _enrichAppointmentsWithDoctorProfiles(
      rows,
      debugLabel: 'getMyAppointmentsEnriched',
    );
  }

  static Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final res = await dio.get('/appointments/upcoming/list');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>>
  getUpcomingAppointmentsEnriched() async {
    final rows = await getUpcomingAppointments();
    return _enrichAppointmentsWithDoctorProfiles(
      rows,
      debugLabel: 'getUpcomingAppointmentsEnriched',
    );
  }

  static Future<List<Map<String, dynamic>>> getAppointmentsByStatus(
    String status,
  ) async {
    try {
      final res = await dio.get('/appointments/filter/$status');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getAppointment(
    String appointmentId,
  ) async {
    try {
      final res = await dio.get('/appointments/$appointmentId');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment(
    String appointmentId,
  ) async {
    try {
      final res = await dio.patch('/appointments/$appointmentId/cancel');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  // ENRICH APPOINTMENTS
  static Future<List<Map<String, dynamic>>>
  _enrichAppointmentsWithDoctorProfiles(
    List<Map<String, dynamic>> rows, {
    required String debugLabel,
  }) async {
    if (rows.isEmpty) return rows;
    final supabase = Supabase.instance.client;
    final doctorIds = rows
        .map((e) => e['doctor_id']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (doctorIds.isEmpty) return rows;
    try {
      final doctorTableIds = doctorIds
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList();
      final doctorRows = List<Map<String, dynamic>>.from(
        await supabase
            .from('doctors')
            .select('id, user_id, specialty, healthpost_name')
            .inFilter('id', doctorTableIds),
      );
      final userIds = doctorRows
          .map((e) => e['user_id']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      final profileRows = userIds.isEmpty
          ? <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
              await supabase
                  .from('user_profiles')
                  .select('id, full_name, avatar_url')
                  .inFilter('id', userIds),
            );
      final profileLookup = <String, Map<String, dynamic>>{
        for (final row in profileRows) row['id'].toString(): row,
      };
      final doctorLookup = <String, Map<String, dynamic>>{};
      for (final doctor in doctorRows) {
        final doctorId = doctor['id']?.toString() ?? '';
        final doctorUserId = doctor['user_id']?.toString() ?? '';
        final profile = profileLookup[doctorUserId] ?? {};
        doctorLookup[doctorId] = {
          'doctor_name': profile['full_name']?.toString() ?? 'Doctor',
          'full_name': profile['full_name']?.toString() ?? 'Doctor',
          'specialty': doctor['specialty']?.toString() ?? '',
          'healthpost_name': doctor['healthpost_name']?.toString() ?? '',
          'avatar_url': profile['avatar_url']?.toString(),
          'doctor_user_id': doctorUserId,
        };
      }
      return rows.map((row) {
        final doctorId = row['doctor_id']?.toString() ?? '';
        return {...row, ...(doctorLookup[doctorId] ?? {})};
      }).toList();
    } catch (e) {
      debugPrint('[$debugLabel] enrichment failed: $e');
      return rows;
    }
  }
  // DOCTORS
  static Future<List<Map<String, dynamic>>> fetchDoctors({
    required String specialty,
    String? province,
    String? district,
    String? municipality,
  }) async {
    final params = <String, dynamic>{'specialty': specialty};
    if (province != null && province.isNotEmpty) params['province'] = province;
    if (district != null) params['district'] = district;
    if (municipality != null && municipality.isNotEmpty)
      params['municipality'] = municipality;
    final res = await dio.get('/doctors/', queryParameters: params);
    final rows = List<Map<String, dynamic>>.from(res.data);
    if (rows.isEmpty) return rows;
    final supabase = Supabase.instance.client;
    final userIds = rows
        .map((row) => row['user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (userIds.isEmpty) return rows;
    try {
      final profileRows = await supabase
          .from('user_profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', userIds);
      final profileLookup = <String, Map<String, dynamic>>{
        for (final row in List<Map<String, dynamic>>.from(profileRows))
          row['id'].toString(): row,
      };
      return rows.map((row) {
        final userId = row['user_id']?.toString() ?? '';
        final profile = profileLookup[userId] ?? {};
        return {
          ...row,
          'full_name': profile['full_name']?.toString() ?? row['full_name'],
          'avatar_url': profile['avatar_url']?.toString() ?? row['avatar_url'],
        };
      }).toList();
    } catch (e) {
      debugPrint('[fetchDoctors] profile enrichment failed: $e');
      return rows;
    }
  }

  // CALLS 
  static Future<Map<String, dynamic>> initiateCall({
    required String calleeId,
    required String appointmentId,
    required String callType,
  }) async {
    try {
      final res = await dio.post(
        '/calls/initiate',
        data: {
          'callee_id': calleeId,
          'appointment_id': appointmentId,
          'call_type': callType,
        },
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateCallStatus({
    required String callId,
    required String status,
  }) async {
    try {
      await dio.patch('/calls/$callId/status', data: {'status': status});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> fetchTurnCredentials() async {
    try {
      final res = await dio.get('/turn-credentials');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

   // LIVEKIT CALL INITIATION (NEW)
 
  static Future<Map<String, String>> initiateLiveKitCall({
    required String callerId,
    required String calleeId,
    required String appointmentId,
    required String callType,  
    required String callerName,
  }) async {
    try {
      final response = await supabaseFunctionsDio.post(
        '/initiate-call',
        data: {
          'callerId': callerId,
          'calleeId': calleeId,
          'appointmentId': appointmentId,
          'callType': callType,
          'callerName': callerName,
         },
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'callerToken': data['callerToken'] as String,
        'roomName': data['roomName'] as String,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> completeAppointment(String appointmentId) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('appointments')
        .update({
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId);
  }
   // ERROR HANDLING
   static String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'सर्भरसँग जडान गर्न समय लाग्यो। पुनः प्रयास गर्नुहोस्।';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'इन्टरनेट जडान छैन वा सर्भर बन्द छ।';
    }
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data is Map
        ? e.response?.data['detail'] ?? 'अज्ञात त्रुटि'
        : 'अज्ञात त्रुटि';
    switch (statusCode) {
      case 400:
        return 'अनुरोध गलत छ: $detail';
      case 401:
        return 'लग इन आवश्यक छ।';
      case 403:
        return 'यो काम गर्न अनुमति छैन।';
      case 404:
        return 'डाटा भेटिएन।';
      case 409:
        return 'यो समय अहिले बुक भयो। अर्को छान्नुहोस्।';
      case 500:
        return 'सर्भर त्रुटि। पछि पुनः प्रयास गर्नुहोस्।';
      default:
        return detail.toString();
    }
  }
}
