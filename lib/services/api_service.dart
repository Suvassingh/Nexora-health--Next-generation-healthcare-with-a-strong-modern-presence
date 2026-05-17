

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

//  Notification type constants 
abstract class NotifType {
  // Patient receives these:
  static const appointmentConfirmed = 'appointment_confirmed';
  static const appointmentCancelled = 'appointment_cancelled';
  static const appointmentReminder  = 'appointment_reminder';
  static const callIncoming         = 'call_incoming';
  static const chatMessage          = 'chat_message';
  static const completed            = 'completed';

  // Doctor receives these:
  static const newAppointment = 'new_appointment';
  static const noShow         = 'no_show';
}

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001/api';
    } else {
      return 'http://10.0.2.2:8001/api';
    }
  }

  static String get turnServerBase {
    if (kIsWeb) return 'http://127.0.0.1:8002';
    return 'http://10.0.2.2:3478';
  }

  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
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
            debugPrint('=== HTTP REQUEST ===');
            debugPrint('${options.method} ${options.uri}');
            debugPrint('Session exists: ${session != null}');

            String tokenPreview = 'NULL';
            final token = session?.accessToken;
            if (token != null && token.isNotEmpty) {
              tokenPreview = token.length > 30 ? token.substring(0, 30) : token;
              options.headers['Authorization'] = 'Bearer $token';
            }
            debugPrint('Token preview: $tokenPreview');
            debugPrint('Request headers before send: ${options.headers}');
            debugPrint('Request data: ${options.data}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('=== HTTP RESPONSE ===');
            debugPrint(
              '${response.requestOptions.method} ${response.requestOptions.uri} -> ${response.statusCode}',
            );
            debugPrint('Response headers: ${response.headers.map}');
            debugPrint('Response data: ${response.data}');
            return handler.next(response);
          },
          onError: (DioException e, handler) async {
            debugPrint('=== HTTP ERROR ===');
            debugPrint(
              '${e.requestOptions.method} ${e.requestOptions.uri} -> ${e.response?.statusCode}',
            );
            debugPrint('Error response headers: ${e.response?.headers.map}');
            debugPrint('Error response data: ${e.response?.data}');
            if (e.response?.statusCode == 401 &&
                e.requestOptions.extra['retried'] != true) {
              try {
                await Supabase.instance.client.auth.refreshSession();
                final newSession = Supabase.instance.client.auth.currentSession;
                if (newSession != null) {
                  e.requestOptions.headers['Authorization'] =
                  'Bearer ${newSession.accessToken}';
                  e.requestOptions.extra['retried'] = true;
                  final retry = await _dio!.fetch(e.requestOptions);
                  return handler.resolve(retry);
                }
              } catch (err) {
                debugPrint('Refresh session failed: $err');
              }
            }
            return handler.next(e);
          },
        ),
      );
    }
    return _dio!;
  }

  //  Notifications 

  static Future<void> sendNotification({
    required String recipientUserId,
    required String userType, 
    required String title,
    required String body,
    required String type,
    Map<String, String> data = const {},
  }) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'send-notification',
        body: {
          'recipientUserId': recipientUserId,
          'userType': userType,
          'title': title,
          'body': body,
          'type': type,
          'data': data,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[sendNotification] failed: $e');
    }
  }

  //  Appointments 

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
          'doctor_id':          doctorTableId,
          'consultation_type':  consultationType,
          'scheduled_at':       scheduledAt.toUtc().toIso8601String(),
          'duration_minutes':   durationMinutes,
          'patient_notes':      patientNotes,
        },
      );
      return res.data as Map<String, dynamic>;
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
      final data = res.data as Map<String, dynamic>;
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

  static Future<List<Map<String, dynamic>>> getUpcomingAppointmentsEnriched() async {
    final rows = await getUpcomingAppointments();
    return _enrichAppointmentsWithDoctorProfiles(
      rows,
      debugLabel: 'getUpcomingAppointmentsEnriched',
    );
  }

  static Future<List<Map<String, dynamic>>> _enrichAppointmentsWithDoctorProfiles(
      List<Map<String, dynamic>> rows, {
        required String debugLabel,
      }) async {
    if (rows.isEmpty) return rows;

    final supabase = Supabase.instance.client;
    final doctorIds = rows
        .map((row) => row['doctor_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final doctorTableIds = doctorIds
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toList();
    final doctorUserIds = doctorIds
        .where((id) => int.tryParse(id) == null)
        .toList();

    if (doctorIds.isEmpty) return rows;

    try {
      // 1. Fetch doctor rows from Supabase
      final doctorRowsById = doctorTableIds.isEmpty
          ? <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
        await supabase
            .from('doctors')
            .select('id, user_id, specialty, healthpost_name')
            .inFilter('id', doctorTableIds),
      );
      final doctorRowsByUserId = doctorUserIds.isEmpty
          ? <Map<String, dynamic>>[]
          : List<Map<String, dynamic>>.from(
        await supabase
            .from('doctors')
            .select('id, user_id, specialty, healthpost_name')
            .inFilter('user_id', doctorUserIds),
      );
      final doctorRows = <Map<String, dynamic>>[
        ...doctorRowsById,
        ...doctorRowsByUserId,
      ];
      final doctorList = <Map<String, dynamic>>[
        for (final doctor in doctorRows)
          if ((doctor['id']?.toString() ?? '').isNotEmpty) doctor,
      ];

      // 2. Fetch user_profiles — name and avatar only; location comes from
      final userIds = doctorList
          .map((row) => row['user_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
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

      // 3. Identify doctors missing profiles for FastAPI fallback
      final missingProfileDoctorIds = doctorList
          .where((doc) {
        final uid = doc['user_id']?.toString() ?? '';
        final profile = profileLookup[uid];
        return profile == null ||
            (profile['full_name']?.toString() ?? '').isEmpty;
      })
          .map((doc) => doc['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      // 4.  fire all fallback fetches concurrently (parallel not sequential)
      final apiDoctorNames = <String, String>{};
      if (missingProfileDoctorIds.isNotEmpty) {
        await Future.wait(
          missingProfileDoctorIds.map((doctorId) async {
            try {
              final res = await dio.get('/doctors/$doctorId');
              final data = res.data as Map<String, dynamic>;
              String? name;
              if (data['profile'] is Map) {
                name = (data['profile'] as Map)['full_name']?.toString();
              }
              if (name == null && data['user_profiles'] is Map) {
                name = (data['user_profiles'] as Map)['full_name']?.toString();
              }
              name ??= data['full_name']?.toString() ?? data['name']?.toString();
              if (name != null && name.isNotEmpty && name != 'null') {
                apiDoctorNames[doctorId] = name;
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('FastAPI fallback failed for doctor $doctorId: $e');
              }
            }
          }),
        );
      }

      // 5. Build lookup map
      final doctorLookup = <String, Map<String, dynamic>>{};
      for (final doctor in doctorList) {
        final doctorId = doctor['id']?.toString() ?? '';
        if (doctorId.isEmpty) continue;

        final doctorUserId = doctor['user_id']?.toString() ?? '';
        final profile = profileLookup[doctorUserId] ?? const {};
        final apiName = apiDoctorNames[doctorId];

        final resolvedName =
        (profile['full_name']?.toString() ?? '').isNotEmpty
            ? profile['full_name']!.toString()
            : (apiName != null && apiName.isNotEmpty)
            ? apiName
            : 'डाक्टर';

        doctorLookup[doctorId] = {
          'doctor_name':     resolvedName,
          'full_name':       resolvedName,
          'specialty':       doctor['specialty']?.toString() ?? '',
          'healthpost_name': doctor['healthpost_name']?.toString() ?? '',
          'avatar_url':      profile['avatar_url']?.toString(),
          'doctor_user_id':  doctorUserId,
        };
        if (doctorUserId.isNotEmpty) {
          doctorLookup[doctorUserId] = doctorLookup[doctorId]!;
        }
      }

      // 6. Merge into appointments
      final enriched = rows.map((row) {
        final doctorId = row['doctor_id']?.toString() ?? '';
        final doctorData = doctorLookup[doctorId] ?? const <String, dynamic>{};
        return {...row, ...doctorData};
      }).toList();

      if (kDebugMode) {
        final unresolved = enriched
            .where((row) => (row['doctor_name']?.toString() ?? '') == 'डाक्टर')
            .map((row) => row['doctor_id']?.toString() ?? '')
            .toSet()
            .toList();
        debugPrint(
          '[$debugLabel] rows=${rows.length}, doctorIds=${doctorIds.length}, '
              'doctorRows=${doctorList.length}, profileRows=${profileRows.length}, '
              'fastApiFetched=${apiDoctorNames.length}, unresolved=$unresolved',
        );
      }

      return enriched;
    } catch (e) {
      if (kDebugMode) debugPrint('[$debugLabel] enrichment failed: $e');
      return rows;
    }
  }

  static Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final res = await dio.get('/appointments/upcoming/list');
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment(
      String appointmentId,
      ) async {
    try {
      final res = await dio.patch('/appointments/$appointmentId/cancel');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //  Doctors 

  
  static Future<List<Map<String, dynamic>>> fetchDoctors({
    required String specialty,
    String? province,
    String? district,
    String? municipality,
  }) async {
    final params = <String, dynamic>{'specialty': specialty};
    if (province != null && province.isNotEmpty) params['province'] = province;
    if (district != null) params['district'] = district;
    if (municipality != null && municipality.isNotEmpty) {
      params['municipality'] = municipality;
    }

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

      final enriched = rows.map((row) {
        final userId = row['user_id']?.toString() ?? '';
        final profile = profileLookup[userId] ?? const <String, dynamic>{};
        return {
          ...row,
          'full_name':  profile['full_name']?.toString() ?? row['full_name'],
          'avatar_url': profile['avatar_url']?.toString() ?? row['avatar_url'],
        
        };
      }).toList();

      if (kDebugMode) {
        final unresolved = enriched
            .where((row) {
          final name = row['full_name']?.toString() ?? '';
          return name.isEmpty || name == 'Unknown Doctor' || name == 'डाक्टर';
        })
            .map((row) => row['id']?.toString() ?? '')
            .toList();
        debugPrint(
          '[fetchDoctors] rows=${rows.length}, '
              'profileRows=${profileLookup.length}, '
              'unresolvedDoctorRows=$unresolved',
        );
      }

      return enriched;
    } catch (e) {
      if (kDebugMode) debugPrint('[fetchDoctors] profile enrichment failed: $e');
      return rows;
    }
  }

  //  Calls 

  static Future<Map<String, dynamic>> initiateCall({
    required String calleeId,
    required String appointmentId,
    required String callType,
  }) async {
    try {
      final res = await dio.post(
        '/calls/initiate',
        data: {
          'callee_id':      calleeId,
          'appointment_id': appointmentId,
          'call_type':      callType,
        },
      );
      return res.data as Map<String, dynamic>;
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
      return Map<String, dynamic>.from(
        (await dio.get('/turn-credentials')).data,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final resp = await Dio().get('${turnServerBase}/turn-credentials');
        return Map<String, dynamic>.from(resp.data);
      }
      throw _handleError(e);
    }
  }

  //  Error handling 

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
      case 400: return 'अनुरोध गलत छ: $detail';
      case 401: return 'लग इन आवश्यक छ।';
      case 403: return 'यो काम गर्न अनुमति छैन।';
      case 404: return 'डाटा भेटिएन।';
      case 409: return 'यो समय अहिले बुक भयो। अर्को छान्नुहोस्।';
      case 500: return 'सर्भर त्रुटि। पछि पुनः प्रयास गर्नुहोस्।';
      default:  return detail.toString();
    }
  }
}