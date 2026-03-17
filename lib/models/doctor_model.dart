class DoctorInfo {
  final String id, name, specialty, hospital;
  final String province, district, municipality;
  final String qualification, licenseNumber;
  final int? experienceYears;
  final double rating;
  final bool isVerified, isAvailable;
  final String? avatarUrl;
  final String phone, email;

  const DoctorInfo({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.province,
    required this.district,
    required this.municipality,
    required this.qualification,
    required this.licenseNumber,
    this.experienceYears,
    required this.rating,
    required this.isVerified,
    required this.isAvailable,
    this.avatarUrl,
    required this.phone,
    required this.email,
  });

  factory DoctorInfo.fromMap(Map<String, dynamic> m) {
    final p =
        m['user_profiles!doctors_user_id_fkey'] as Map<String, dynamic>? ??
        m['user_profiles'] as Map<String, dynamic>? ??
        {};
    return DoctorInfo(
      id: m['user_id']?.toString() ?? '',
      name: p['full_name']?.toString() ?? 'Unknown Doctor',
      specialty: m['specialty']?.toString() ?? '',
      hospital: m['healthpost_name']?.toString() ?? '',
      province: m['province']?.toString() ?? '',
      district: m['district']?.toString() ?? '',
      municipality: m['municipality']?.toString() ?? '',
      qualification: m['qualification']?.toString() ?? '',
      licenseNumber: m['license_number']?.toString() ?? '',
      experienceYears: m['experience_years'] as int?,
      rating: (m['rating'] as num?)?.toDouble() ?? 4.5,
      isVerified: m['is_verified'] as bool? ?? false,
      isAvailable: m['is_active'] as bool? ?? true,
      avatarUrl: p['avatar_url']?.toString(),
      phone: p['phone']?.toString() ?? '',
      email: p['email']?.toString() ?? '',
    );
  }

  String get initials {
    final pts = name.trim().split(' ');
    if (pts.length >= 2) return '${pts[0][0]}${pts[1][0]}'.toUpperCase();
    return pts.isNotEmpty && pts[0].isNotEmpty ? pts[0][0].toUpperCase() : 'D';
  }
}
