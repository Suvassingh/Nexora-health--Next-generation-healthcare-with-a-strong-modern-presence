class AppointmentModel {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String consultationType; // 'video' or 'chat'
  final String status; // 'upcoming', 'completed', 'cancelled'

  const AppointmentModel({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.consultationType,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      consultationType: json['consultationType'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date,
      'time': time,
      'consultationType': consultationType,
      'status': status,
    };
  }
}
