


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/change_password.dart';

import 'package:patient_app/controller/profile_controller.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/login_screen.dart';
import 'package:patient_app/models/patients_model.dart';
import 'package:patient_app/patient_medical_history.dart';
import 'package:patient_app/provider/home_provider.dart';
import 'package:patient_app/provider/profile_provider.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/simmer.dart';
import 'package:patient_app/widgets/voice_fab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/local_controller.dart';

const _genderOptions = ['male', 'female', 'other'];
const _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _service = PatientService();
  final LocaleController _localeCtrl = Get.put(
    LocaleController(),
    permanent: true,
  );
  bool _saving = false;
  bool _editing = false;

  // Local copy for edit mode
  PatientProfile? _cachedProfile;

  // Form controllers & edit-mode state
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  String _selectedGender = 'male';
  String _selectedBloodGroup = '';
  DateTime? _selectedDob;
  List<String> _conditions = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _conditionCtrl.dispose();
    super.dispose();
  }

  // Apply profile data to local edit state
  void _applyProfile(PatientProfile? p) {
    _cachedProfile = p;
    _nameCtrl.text = p?.fullName ?? '';
    _phoneCtrl.text = p?.phone ?? '';
    _addressCtrl.text = p?.address ?? '';
    _selectedGender = (_genderOptions.contains(p?.gender) ? p!.gender : 'male');
    _selectedBloodGroup = p?.bloodGroup ?? '';
    _selectedDob = p?.dateOfBirth;
    _conditions = List<String>.from(p?.conditions ?? []);
    final lang = p?.preferredLanguage ?? 'english';
    _localeCtrl.setLocale(lang == 'nepali' ? 'np' : 'en');
  }

  Future<void> _saveProfile() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      _showSnack(AppLocalizations.of(context)!.notLoggedIn, isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final lang = _localeCtrl.locale == 'np' ? 'nepali' : 'english';
      final updated = PatientProfile(
        id: _cachedProfile?.id ?? '',
        userId: uid,
        fullName: _nameCtrl.text.trim(),
        email: _cachedProfile?.email ?? '',
        phone: _phoneCtrl.text.trim(),
        dateOfBirth: _selectedDob,
        gender: _selectedGender,
        address: _addressCtrl.text.trim(),
        bloodGroup: _selectedBloodGroup,
        conditions: List<String>.from(_conditions),
        avatar: '',
      );
      // Save profile and language preference in parallel
      await Future.wait([
        _service.saveProfile(updated),
        Supabase.instance.client
            .from('user_profiles')
            .update({'preferred_language': lang})
            .eq('id', uid),
      ]);
      setState(() {
        _cachedProfile = updated;
        _editing = false;
      });
      ref.invalidate(profileProvider);
      ref.invalidate(homeDataProvider);
      _showSnack(AppLocalizations.of(context)!.profileSaved);
    } catch (e) {
      _showSnack(AppLocalizations.of(context)!.profileSaved, isError: true);
    } finally {
      setState(() => _saving = false);
    }
  }
  void _cancelEdit() {
    _applyProfile(_cachedProfile);
    setState(() => _editing = false);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: AppLocalizations.of(context)!.selectDateOfBirth,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB71C1C),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
Widget _buildProfileShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile card shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const ShimmerBox(
                      width: 72,
                      height: 72,
                      radius: 36,
                    ), // avatar
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 160, height: 18, radius: 6),
                          SizedBox(height: 8),
                          ShimmerBox(width: 110, height: 14, radius: 5),
                          SizedBox(height: 8),
                          ShimmerBox(width: 80, height: 12, radius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 58, radius: 10)),
                    SizedBox(width: 10),
                    Expanded(child: ShimmerBox(height: 58, radius: 10)),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 58, radius: 10)),
                    SizedBox(width: 10),
                    Expanded(child: ShimmerBox(height: 58, radius: 10)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Medical history card shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 140, height: 18, radius: 6),
                const SizedBox(height: 14),
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerBox(height: 14, radius: 5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Settings card shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const ShimmerBox(width: 80, height: 16, radius: 5),
                const SizedBox(height: 14),
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: ShimmerBox(height: 44, radius: 8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout button shimmer
          const ShimmerBox(height: 50, radius: 14),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  String _buildProfileVoiceText() {
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Unknown';
    final age = _cachedProfile?.ageInYears;
    final gender = _selectedGender.isNotEmpty ? _selectedGender : 'unknown';
    final blood = _selectedBloodGroup.isNotEmpty
        ? _selectedBloodGroup
        : 'not set';
    final address = _addressCtrl.text.isNotEmpty
        ? _addressCtrl.text
        : 'not provided';
    final conditionList = _conditions.isEmpty
        ? 'no recorded conditions'
        : _conditions.join(', ');

    return 'Profile summary for $name. '
        '${age != null ? "Age: $age years. " : ""}'
        'Gender: $gender. '
        'Blood group: $blood. '
        'Address: $address. '
        'Medical history: $conditionList.';
  }
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: _buildAppBar(),
        body: _buildProfileShimmer(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.couldNotLoadData,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(profileProvider),
                icon: const Icon(Icons.refresh),
                label:  Text(AppLocalizations.of(context)!.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        // Apply profile to local state when data changes
        if (_cachedProfile?.userId != profile?.userId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _applyProfile(profile));
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF2F4F7),
          appBar: _buildAppBar(),
          floatingActionButton: _editing
              ? null 
              : VoiceFab(text: _buildProfileVoiceText()),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 16),
                      _buildMedicalHistoryCard(),
                      const SizedBox(height: 16),
                      _buildSettingsCard(),
                      const SizedBox(height: 20),
                      _buildLogoutButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppConstants.primaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(15)),
    ),
    title: Row(
      children: [
        Image.asset("assets/images/gov_logo.webp", width: 40, height: 40),
        const SizedBox(width: 20),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.nepalSarkar,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(AppConstants.govtOfNepal,
                style: TextStyle(fontSize: 10, color: Colors.white)),
          ],
        ),
      ],
    ),
    actions: [
      if (!_editing)
        GestureDetector(
          onTap: () => setState(() => _editing = true),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Row(
              children: [
                Icon(Icons.edit, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(AppLocalizations.of(context)!.edit,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )
      else
        Row(
          children: [
            GestureDetector(
              onTap: _saving ? null : _cancelEdit,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text(AppLocalizations.of(context)!.cancel,
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
            GestureDetector(
              onTap: _saving ? null : _saveProfile,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _saving
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFB71C1C)),
                )
                    :  Text(AppLocalizations.of(context)!.save,
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
    ],
  );

  Widget _buildProfileCard() {
    final age = _cachedProfile?.ageInYears;
    final dobStr = _selectedDob != null
        ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFEEEEEE),
                    child: Icon(Icons.person, size: 40, color: Colors.grey.shade500),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, size: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _editing
                        ? _inputField(_nameCtrl, hint: AppLocalizations.of(context)!.fullName,
                          )
                        : Text(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 3),
                    _editing
                        ? _inputField(_phoneCtrl,
                        hint: AppLocalizations.of(context)!.phone, keyboardType: TextInputType.phone)
                        : Text(
                      _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '—',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    if (!_editing && (_cachedProfile?.email.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 3),
                      Text(_cachedProfile!.email,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                    if (!_editing) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.verified,
                              size: 14, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.verified,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _editing
                    ? GestureDetector(
                  onTap: _pickDateOfBirth,
                  child: _styledBox(
                    label:AppLocalizations.of(context)!.dateOfBirth,
                    editing: true,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(dobStr,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A))),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 14, color: Color(0xFFB71C1C)),
                      ],
                    ),
                  ),
                )
                    : _infoBox(
                  label: AppLocalizations.of(context)!.ageAndDob,
                  value: age != null ? '$age वर्ष  ($dobStr)' : dobStr,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _editing
                    ? _styledBox(
                  label: AppLocalizations.of(context)!.gender,
                  editing: true,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _genderOptions.contains(_selectedGender)
                          ? _selectedGender
                          : 'male',
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                      items: _genderOptions
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                  ),
                )
                    : _infoBox(
                  label: AppLocalizations.of(context)!.gender,
                  value: _selectedGender.isNotEmpty ? _selectedGender : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _editing
                    ? _styledBox(
                  label: AppLocalizations.of(context)!.address,
                  editing: true,
                  child: TextField(
                    controller: _addressCtrl,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                )
                    : _infoBox(
                  label: AppLocalizations.of(context)!.address,
                  value: _addressCtrl.text.isNotEmpty ? _addressCtrl.text : '—',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _editing
                    ? _styledBox(
                  label: AppLocalizations.of(context)!.bloodGroup,
                  editing: true,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _bloodGroupOptions.contains(_selectedBloodGroup)
                          ? _selectedBloodGroup
                          : null,
                      hint:  Text(AppLocalizations.of(context)!.select
,
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                      items: _bloodGroupOptions
                          .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBloodGroup = v!),
                    ),
                  ),
                )
                    : _infoBox(
                  label: AppLocalizations.of(context)!.bloodGroup,
                  value: _selectedBloodGroup.isNotEmpty ? _selectedBloodGroup : '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox({required String label, required String value}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFEEEEEE)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
      ],
    ),
  );

  Widget _styledBox({
    required String label,
    required Widget child,
    bool editing = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: editing ? const Color(0xFFFFF8F8) : const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: editing
            ? const Color(0xFFB71C1C).withOpacity(0.4)
            : const Color(0xFFEEEEEE),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        child,
      ],
    ),
  );

 Widget _buildMedicalHistoryCard() => GestureDetector(
     onTap: () => Get.to(() => const PatientMedicalHistoryScreen()),
     child: Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [
           BoxShadow(
               color: Colors.black.withOpacity(0.06),
               blurRadius: 10,
               offset: const Offset(0, 2)),
         ],
       ),
       child: Row(
         children: [
           Container(
             padding: const EdgeInsets.all(6),
             decoration: BoxDecoration(
                 color: const Color(0xFFFCE4EC),
                 borderRadius: BorderRadius.circular(8)),
             child: const Text('🩺', style: TextStyle(fontSize: 16)),
           ),
           const SizedBox(width: 10),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   AppLocalizations.of(context)!.medicalHistory,
                   style: const TextStyle(
                       fontSize: 15,
                       fontWeight: FontWeight.bold,
                       color: Color(0xFF1A1A1A)),
                 ),
                 const SizedBox(height: 2),
                 Text(
                   AppLocalizations.of(context)!.viewYourHealthRecords,
                   style: const TextStyle(fontSize: 12, color: Colors.grey),
                 ),
               ],
             ),
           ),
           const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
         ],
       ),
     ),
   );

  void _showAddConditionDialog() {
    _conditionCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:  Text(AppLocalizations.of(context)!.addCondition,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _conditionCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.conditionHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:  Text(
              AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = _conditionCtrl.text.trim();
              if (val.isNotEmpty) setState(() => _conditions.add(val));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child:  Text(AppLocalizations.of(context)!.add, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('⚙️', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
               Text(
                AppLocalizations.of(context)!.settings,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.language, size: 18, color: Color(0xFF1565C0)),
              ),
              const SizedBox(width: 12),
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.language,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
                    Text(
                      AppLocalizations.of(context)!.nepali,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [LanguageToggleButton()],
                ),
              ),
            ],
          ),
        ),
        const Divider(
            height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        //   child: Row(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(7),
        //         decoration: BoxDecoration(
        //             color: const Color(0xFFE8F5E9),
        //             borderRadius: BorderRadius.circular(8)),
        //         child: const Icon(Icons.data_saver_on, size: 18, color: Color(0xFF2E7D32)),
        //       ),
        //       const SizedBox(width: 12),
        //       // const Expanded(
        //       //   child: Column(
        //       //     crossAxisAlignment: CrossAxisAlignment.start,
        //       //     children: [
        //       //       Text('कम डेटा मोड',
        //       //           style: TextStyle(
        //       //               fontSize: 13.5,
        //       //               fontWeight: FontWeight.w600,
        //       //               color: Color(0xFF1A1A1A))),
        //       //       Text('Low Data Mode',
        //       //           style: TextStyle(fontSize: 12, color: Colors.grey)),
        //       //     ],
        //       //   ),
        //       // ),
        //       // CupertinoSwitch(
        //       //   value: AppSettings.of(context).lowDataMode,
        //       //   onChanged: (val) =>
        //       //       AppSettings.of(context).setLowDataMode(val),
        //       //   activeTrackColor: const Color(0xFFB71C1C),
        //       // ),
        //     ],
        //   ),
        // ),
        const Divider(
            height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
        InkWell(
          onTap: () => Get.to(() => ChangePasswordScreen(), transition: Transition.downToUp),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF7B1FA2)),
                ),
                const SizedBox(width: 12),
                 Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.changePassword,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildLogoutButton() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: _confirmLogout,
      icon: const Icon(Icons.logout, size: 18, color: Color(0xFFB71C1C)),
      label:  Text(
        AppLocalizations.of(context)!.logout,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB71C1C))),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
      ),
    ),
  );

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:  Text(
          AppLocalizations.of(context)!.logout,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content:  Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:  Text(
              AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
              await _service.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child:  Text(
              AppLocalizations.of(context)!.logout, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl,
      {required String hint, TextInputType keyboardType = TextInputType.text}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.normal),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB71C1C))),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB71C1C), width: 2)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      );
}