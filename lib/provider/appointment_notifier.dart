// appointment_notifier.dart (new file)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:patient_app/models/appointment_model.dart';
import 'package:patient_app/provider/appointment_provider.dart';
import '../services/api_service.dart';
import '../services/appointment_reminder_service.dart';

class AppointmentNotifier extends StateNotifier<void> {
  final Ref ref;

  AppointmentNotifier(this.ref) : super(null);

  Future<void> autoCompletePastAppointments(List<Appt> pastConfirmed) async {
    for (final appt in pastConfirmed) {
      try {
        await ApiService.completeAppointment(appt.id);

        await AppointmentReminderService.rescheduleAllReminders();

        // Trigger refresh of the appointments list
        ref.read(refreshTriggerProvider.notifier).state++;
      } catch (e) {
      }
    }
  }
}

final appointmentNotifierProvider =
    StateNotifierProvider<AppointmentNotifier, void>(
      (ref) => AppointmentNotifier(ref),
    );
