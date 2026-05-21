
class PatientProfile {
  final String id; 
  final String userId; 
  String fullName; 
  String email; 
  String phone; 
  DateTime? dateOfBirth; 
  String gender;
  String address; 
  String bloodGroup; 
  List<String> conditions; 
  String avatar;
  final String? preferredLanguage; 

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
    required this.avatar,
    this.preferredLanguage,
  });

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

  String get dobDisplay => dateOfBirth != null
      ? '${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}'
      : '—';

  factory PatientProfile.fromBoth({
    required Map<String, dynamic> userProfile,
    required Map<String, dynamic> patient,
  }) {
    DateTime? dob;
    final rawAge = patient['age'];
    if (rawAge != null && rawAge.toString().isNotEmpty) {
      dob = DateTime.tryParse(rawAge.toString());
    }

    return PatientProfile(
      id: patient['id']?.toString() ?? '',
      userId: userProfile['id']?.toString() ?? '',
      fullName: userProfile['full_name']?.toString() ?? '',
      email: userProfile['email']?.toString() ?? '',
      phone: userProfile['phone']?.toString() ?? '',
      dateOfBirth: dob,
      gender: patient['gender']?.toString() ?? 'male',
      address: patient['address']?.toString() ?? '',
      bloodGroup: patient['blood_group']?.toString() ?? '',
      conditions: List<String>.from(patient['conditions'] ?? []),
      avatar: patient['avatar'].toString(),
          preferredLanguage: userProfile['preferred_language']?.toString(), 


    );
  }

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
      'preferred_language': preferredLanguage, 

  };
}
