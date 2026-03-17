// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────
class PatientProfile {
  final String id; // patients.id
  final String userId; // patients.user_id = user_profiles.id
  String fullName; // user_profiles.full_name
  String email; // user_profiles.email  (read-only)
  String phone; // user_profiles.phone
  DateTime? dateOfBirth; // patients.age  — DB column type is DATE
  String gender; // patients.gender
  String address; // patients.address
  String bloodGroup; // patients.blood_group  (enum)
  List<String> conditions; // patients.conditions
  String avatar;

  PatientProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email = '',
    required this.phone,
    this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.bloodGroup,
    required this.conditions,
    required this.avatar
  });

  /// Calculated age in years from dateOfBirth.
  int? get ageInYears {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  /// ISO date string for display e.g. "2003-01-15"
  String get dobDisplay => dateOfBirth != null
      ? '${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}'
      : '—';

  /// Merge data from both table rows.
  factory PatientProfile.fromBoth({
    required Map<String, dynamic> userProfile,
    required Map<String, dynamic> patient,
  }) {
    // patients.age is a DATE column — parse it as DateTime
    DateTime? dob;
    final rawAge = patient['age'];
    if (rawAge != null && rawAge.toString().isNotEmpty) {
      dob = DateTime.tryParse(rawAge.toString());
    }

    return PatientProfile(
      id: patient['id']?.toString() ?? '',
      userId: userProfile['id']?.toString() ?? '',
      // ── from user_profiles ──
      fullName: userProfile['full_name']?.toString() ?? '',
      email: userProfile['email']?.toString() ?? '',
      phone: userProfile['phone']?.toString() ?? '',
      // ── from patients ──
      dateOfBirth: dob,
      gender: patient['gender']?.toString() ?? 'male',
      address: patient['address']?.toString() ?? '',
      bloodGroup: patient['blood_group']?.toString() ?? '',
      conditions: List<String>.from(patient['conditions'] ?? []),
      avatar: patient['avatar'].toString()

    );
  }

  /// Fields saved to `patients` table.
  /// 'age' column is DATE type — send "YYYY-MM-DD" string or null.
  Map<String, dynamic> toPatientUpsert() => {
    'user_id': userId,
    'age': dateOfBirth != null ? dobDisplay : null,
    'gender': gender,
    'address': address,
    'blood_group': bloodGroup.isEmpty ? null : bloodGroup,
    'conditions': conditions,
    'updated_at': DateTime.now().toIso8601String(),
  };

  /// Fields saved to `user_profiles` table.
  Map<String, dynamic> toUserProfileUpdate() => {
    'full_name': fullName,
    'phone': phone,
  };
}
