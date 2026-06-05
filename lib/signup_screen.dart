

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/controller/internet_status_controller.dart';
import 'package:patient_app/home_screen.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/login_screen.dart';
import 'package:patient_app/utils/logging.dart';
import 'package:patient_app/widgets/connectivity_icon.dart';
import 'package:patient_app/widgets/dropdown_inputfield.dart';
import 'package:patient_app/widgets/image_button.dart';
import 'package:patient_app/widgets/input_field.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/login_signup_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

//  GETX CONTROLLER 
class SignupController extends GetxController {
  final supabase = Supabase.instance.client;

  // TextEditingControllers
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  // Reactive variables
  final selectedGender = Rx<String?>(null);
  final selectedDob = Rx<DateTime?>(null);
  final isLoading = false.obs;

  // Rate limiting
  bool _isSigningUp = false;

  final TabController? tabController;
  SignupController(this.tabController);

  
  //  Validation helpers
  String? validateEmail(String email) {
    if (email.isEmpty) return 'emailRequired';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(email)) return 'invalidEmail';
    return null;
  }

  String? validatePhone(String phone) {
    if (phone.isEmpty) return 'phoneRequired';
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 10) return 'phoneInvalidLength';
    return null;
  }

  String? validatePassword(String pwd) {
    if (pwd.length < 6) return 'passwordMinSix';
    return null;
  }

  bool validatePersonalInfo(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String? error;

    if (nameCtrl.text.trim().isEmpty) {
      error = l.nameRequired;
    } else if ((error = validatePhone(phoneCtrl.text.trim())) != null) {
      error = error == 'phoneRequired' ? l.phoneRequired : l.phoneInvalid;
    } else if (selectedDob.value == null) {
      error = l.ageRequired;
    } else if (selectedGender.value == null) {
      error = l.genderRequired;
    } else if (addressCtrl.text.trim().isEmpty) {
      error = l.addressRequired;
    }

    // Minimum age 18
    if (selectedDob.value != null) {
      final age = DateTime.now().difference(selectedDob.value!).inDays ~/ 365;
      if (age < 18) error = l.ageMinimum18;
    }

    if (error != null) {
      _snackError(context, error);
      return false;
    }
    return true;
  }

  bool validateAccountInfo(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String? error;

    if ((error = validateEmail(emailCtrl.text.trim())) != null) {
      _snackError(
        context,
        error == 'emailRequired' ? l.emailRequired : l.invalidEmail,
      );
      return false;
    }
    if ((error = validatePassword(passwordCtrl.text)) != null) {
      _snackError(
        context,
        error == 'passwordMinSix' ? l.passwordMinSix : l.passwordRequired,
      );
      return false;
    }
    if (passwordCtrl.text != confirmPwdCtrl.text) {
      _snackError(context, l.passwordMismatch);
      return false;
    }
    return true;
  }

  void _snackError(BuildContext context, String message) {
    Get.snackbar(
      AppLocalizations.of(context)!.error,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  
  //  Data formatting
  String? _formatPhone(String phone) {
    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (phone.isEmpty) return null;
    if (phone.startsWith('+977')) return phone;
    if (phone.startsWith('977')) return '+$phone';
    if (phone.startsWith('0')) return '+977${phone.substring(1)}';
    return '+977$phone';
  }

  String _mapGender(String? gender) {
    if (gender == null) return 'other';
    final lower = gender.toLowerCase();
    if (lower.contains('male') || lower == 'पुरुष') return 'male';
    if (lower.contains('female') || lower == 'महिला') return 'female';
    return 'other';
  }

  String? _dobToAgeString(DateTime? dob) {
    if (dob == null) return null;
    final age = DateTime.now().difference(dob).inDays ~/ 365;
    return age.toString();
  }

  
  //  Save profile
  
  Future<void> _saveProfile(String userId, {bool isGoogle = false}) async {
    final formattedPhone = _formatPhone(phoneCtrl.text);

    final profileData = <String, dynamic>{
      'id': userId,
      'full_name': nameCtrl.text.trim(),
      'role': 'patient',
      'preferred_language': 'nepali',
      'updated_at': DateTime.now().toIso8601String(),
      'email': emailCtrl.text.trim(),
    };
    if (formattedPhone != null) profileData['phone'] = formattedPhone;
    if (isGoogle) {
      // if Google sign‑in and name empty, keep empty (will be filled later)
      if (nameCtrl.text.trim().isEmpty) profileData['full_name'] = '';
    }
    await supabase.from('user_profiles').upsert(profileData, onConflict: 'id');

    final patientData = <String, dynamic>{'user_id': userId};
    if (selectedGender.value != null)
      patientData['gender'] = _mapGender(selectedGender.value);
    if (selectedDob.value != null)
      patientData['age'] = selectedDob.value!.toIso8601String();
    if (addressCtrl.text.trim().isNotEmpty)
      patientData['address'] = addressCtrl.text.trim();
    if (patientData.length > 1) {
      await supabase
          .from('patients')
          .upsert(patientData, onConflict: 'user_id');
    }
  }

  
  //  Sign up

  Future<void> signUp(BuildContext context) async {
    if (_isSigningUp) return;
    if (!validatePersonalInfo(context)) return;
    if (!validateAccountInfo(context)) return;

    final l = AppLocalizations.of(context)!;
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Get.snackbar(l.error, l.noInternetConnection);
      return;
    }

    _isSigningUp = true;
    isLoading.value = true;
    try {
      final result = await supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        emailRedirectTo: 'com.example.patient_app://login-callback/',
      );
      if (result.user == null) {
        Get.snackbar(
          l.error,
          l.signUpFailed,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      await _saveProfile(result.user!.id);
      await supabase.auth.signOut();

      Get.snackbar(
        l.verifyEmailTitle,
        l.verifyEmailMessage,
        backgroundColor: Colors.green.shade100,
        duration: const Duration(seconds: 5),
      );
      Get.offAll(() => LoginScreen());
    } on AuthException catch (e) {
      if (e.message.contains('already registered') ||
          e.message.contains('User already registered')) {
        // Try to sign in and update profile (recovery)
        try {
          final loginResult = await supabase.auth.signInWithPassword(
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text,
          );
          if (loginResult.user != null) {
            await _saveProfile(loginResult.user!.id);
            Get.snackbar(
              l.success,
              l.accountSetupComplete,
              backgroundColor: Colors.green.shade100,
            );
            await Future.delayed(const Duration(seconds: 2));
            Get.offAll(() => LoginScreen());
          }
        } catch (_) {
          Get.snackbar(
            l.signUpFailed,
            l.emailAlreadyRegistered,
            backgroundColor: Colors.red.shade100,
          );
        }
      } else {
        Get.snackbar(
          l.signUpFailed,
          _authErrorMessage(e.message, l),
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        l.signUpFailed,
        l.somethingWentWrong,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
      _isSigningUp = false;
    }
  }

  //  Google Sign In
  Future<void> continueWithGoogle(BuildContext context) async {
    if (_isSigningUp) return;
    _isSigningUp = true;
    final l = AppLocalizations.of(context)!;
    isLoading.value = true;
    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId: dotenv.env['web_clientid'],
        clientId: Platform.isAndroid
            ? dotenv.env['android_clientid']
            : dotenv.env['ios_clientid'],
      );
      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken ?? '';
      final result = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (result.user == null) return;
      final userId = result.user!.id;
      final googleName =
          result.user!.userMetadata?['full_name'] ??
          result.user!.userMetadata?['name'] ??
          '';
      final googleAvatar = result.user!.userMetadata?['avatar_url'] ?? '';

      // If user did not fill name manually, use Google name
      if (nameCtrl.text.trim().isEmpty) {
        nameCtrl.text = googleName;
      }

      await _saveProfile(userId, isGoogle: true);

      // Also update avatar if needed
      await supabase
          .from('user_profiles')
          .update({'avatar_url': googleAvatar})
          .eq('id', userId);

      // Check completeness
      final hasCompleteProfile =
          nameCtrl.text.trim().isNotEmpty &&
          selectedGender.value != null &&
          selectedDob.value != null &&
          addressCtrl.text.trim().isNotEmpty;

      if (!hasCompleteProfile) {
        Get.snackbar(
          l.incompleteProfile,
          l.completeProfileHint,
          backgroundColor: Colors.orange.shade100,
        );
      }
      Get.offAll(() => HomeScreen());
    } catch (e) {
      Get.snackbar(l.googleSignInFailed, l.somethingWentWrong);
      logger(
        e.toString(),
        'SignupScreen.continueWithGoogle',
        level: Level.info,
      );
    } finally {
      isLoading.value = false;
      _isSigningUp = false;
    }
  }

  String _authErrorMessage(String message, AppLocalizations l) {
    if (message.contains('already registered') ||
        message.contains('User already registered')) {
      return l.emailAlreadyRegistered;
    }
    if (message.contains('invalid email')) return l.invalidEmail;
    return l.signUpFailed;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPwdCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }
}


//  SIGNUP SCREEN

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SignupController _controller;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPwdFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = SignupController(_tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.onClose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
    _genderFocus.dispose();
    _addressFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPwdFocus.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    bool isValid = true;
    if (index == 1 && !_controller.validatePersonalInfo(context))
      isValid = false;
    if (isValid) _tabController.animateTo(index);
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: now.subtract(
        const Duration(days: 365 * 18),
      ), // minimum 18 years
    );
    if (picked != null) _controller.selectedDob.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Obx(
      () => Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: AppConstants.primaryColor,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: AppConstants.whiteColor,
                tabs: [
                  Tab(text: loc.personalInfo),
                  Tab(text: loc.accountInfo),
                ],
              ),
              title: const Row(
                children: [
                  Image(
                    image: AssetImage('assets/images/gov_logo.webp'),
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 20),
                  Column(
                    children: [
                      Text(
                        AppConstants.nepalSarkar,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        AppConstants.govtOfNepal,
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() {
                    final ct =
                        Get.find<ConnectivityController>().connectionType.value;
                    if (ct == ConnectivityResult.none)
                      return const ConnectivityIndicator(
                        icon: Icons.signal_wifi_off,
                      );
                    if (ct == ConnectivityResult.wifi)
                      return const ConnectivityIndicator(icon: Icons.wifi);
                    if (ct == ConnectivityResult.mobile)
                      return const ConnectivityIndicator(
                        icon: Icons.signal_cellular_4_bar,
                      );
                    return const SizedBox.shrink();
                  }),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const LanguageToggleButton(),
                ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // disable swipe
              children: [_buildPersonalInfoTab(loc), _buildAccountInfoTab(loc)],
            ),
          ),
          if (_controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppConstants.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creating account…',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(loc.name),
                  InputField(
                    hintText: 'Ram Bahadur',
                    controller: _controller.nameCtrl,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_phoneFocus),
                  ),
                  const SizedBox(height: 20),
                  _label(loc.phone),
                  InputField(
                    hintText: '98xxxxxxxx',
                    controller: _controller.phoneCtrl,
                    focusNode: _phoneFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _dobFocus.requestFocus(),
                  ),
                  const SizedBox(height: 20),
                  _label(loc.age),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _controller.selectedDob.value != null
                                  ? '${_controller.selectedDob.value!.toLocal()}'
                                        .split(' ')[0]
                                  : 'Select birth date',
                              style: TextStyle(
                                color: _controller.selectedDob.value != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label(loc.gender),
                  DropdownInputField(
                    hintText: loc.gender,
                    items: [loc.male, loc.female, loc.others],
                    onChanged: (v) => _controller.selectedGender.value = v,
                    value: _controller.selectedGender.value,
                  ),
                  const SizedBox(height: 20),
                  _label(loc.address),
                  InputField(
                    hintText: 'Kathmandu-4, Nepal',
                    controller: _controller.addressCtrl,
                    focusNode: _addressFocus,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => _changeTab(1),
                  ),
                ],
              ),
            ),
            LoginSignupButton(text: loc.next, onPressed: () => _changeTab(1)),
            const SizedBox(height: 20),
            _loginPromptRow(loc),
            const SizedBox(height: 10),
            Text(
              loc.orSignupWith,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(
              () => ImageButton(
                imagePath: 'assets/images/google.png',
                text: loc.google,
                onPressed: _controller.isLoading.value
                    ? null
                    : () => _controller.continueWithGoogle(context),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoTab(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(loc.email),
                  InputField(
                    hintText: 'ram@gmail.com',
                    controller: _controller.emailCtrl,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_passwordFocus),
                  ),
                  const SizedBox(height: 20),
                  _label(loc.password),
                  PasswordField(
                    controller: _controller.passwordCtrl,
                    hintText: 'xxxxxxxx',
                    focusNode: _passwordFocus,
                    onSubmitted: () => _confirmPwdFocus.requestFocus(),
                  ),
                  const SizedBox(height: 20),
                  _label(loc.confirmpassword),
                  PasswordField(
                    controller: _controller.confirmPwdCtrl,
                    hintText: 'xxxxxxxx',
                    focusNode: _confirmPwdFocus,
                    onSubmitted: () => _controller.signUp(context),
                  ),
                ],
              ),
            ),
            LoginSignupButton(
              text: loc.signup,
              onPressed: _controller.isLoading.value
                  ? null
                  : () => _controller.signUp(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _loginPromptRow(AppLocalizations loc) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        loc.alreadyhaveanaccount,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
      TextButton(
        onPressed: () => Get.offAll(() => LoginScreen()),
        child: Text(
          loc.login,
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

//  Reusable password field with toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;
  const PasswordField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      textInputAction: TextInputAction.next,
      onEditingComplete: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 1.5,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
