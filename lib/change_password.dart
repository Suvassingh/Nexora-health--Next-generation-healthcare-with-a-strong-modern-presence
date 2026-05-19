import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
AppLocalizations get _l => AppLocalizations.of(context)!;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;

  // Password strength (0–4)
  int _strength = 0;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  //  Password strength checker 
  void _checkStrength(String val) {
    int score = 0;
    if (val.length >= 8) score++;
    if (val.contains(RegExp(r'[A-Z]'))) score++;
    if (val.contains(RegExp(r'[0-9]'))) score++;
    if (val.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    setState(() => _strength = score);
  }

  String get _strengthLabel {
    switch (_strength) {
      case 1:
        return _l.strengthWeak;
      case 2:
        return _l.strengthFair;
      case 3:
        return _l.strengthGood;
      case 4:
        return _l.strengthExcellent;
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1:
        return Colors.red.shade400;
      case 2:
        return Colors.orange.shade400;
      case 3:
        return Colors.blue.shade400;
      case 4:
        return Colors.green.shade500;
      default:
        return Colors.transparent;
    }
  }

  //  Save 
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // Step 1 — Re-authenticate with current password to verify identity
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email == null) {
        _showSnack(_l.emailNotFound, isError: true);
        return;
      }

      // Verify current password by attempting a sign-in
      final checkRes = await Supabase.instance.client.auth.signInWithPassword(
        email: user!.email!,
        password: _currentCtrl.text.trim(),
      );

      if (checkRes.user == null) {
        _showSnack(_l.currentPasswordWrong, isError: true);
        return;
      }

      // Step 2 — Update to new password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newCtrl.text.trim()),
      );

      Get.to(() => ProfilePage());
      Get.snackbar(_l.success, _l.passwordChangedSuccess,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
_showSnack('${_l.somethingWentWrong}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  //  Build 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        title: Row(
          children: [
            Image.asset("assets/images/gov_logo.webp", width: 40, height: 40),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInfoBanner(),
                    const SizedBox(height: 16),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // //  AppBar 

  //  Info banner 
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFE65100), size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_l.passwordSecurityInfo,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFE65100),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  Form card 
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Current password 
_buildFieldLabel(_l.currentPassword, Icons.lock_outline),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _currentCtrl,
            hint: _l.currentPasswordHint,
            show: _showCurrent,
            onToggle: () => setState(() => _showCurrent = !_showCurrent),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return _l.currentPasswordRequired;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 20),

          //  New password 
_buildFieldLabel(_l.newPassword, Icons.lock_reset_outlined),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _newCtrl,
            hint: _l.newPasswordHint,
            show: _showNew,
            onToggle: () => setState(() => _showNew = !_showNew),
            onChanged: _checkStrength,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return _l.newPasswordRequired;
              }
              if (val.length < 8) {
                return _l.minEightChars;
              }
              if (val == _currentCtrl.text) {
                return _l.passwordMustDiffer;
              }
              return null;
            },
          ),

          // Strength indicator
          if (_newCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildStrengthBar(),
          ],

          const SizedBox(height: 20),

          //  Confirm password 
          _buildFieldLabel(
            _l.confirmpassword,
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _confirmCtrl,
            hint: _l.repeatPasswordHint,
            show: _showConfirm,
            onToggle: () => setState(() => _showConfirm = !_showConfirm),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return _l.confirmPasswordRequired;
              }
              if (val != _newCtrl.text) {
                return _l.passwordMismatch;
              }
              return null;
            },
          ),

          // Tips
          const SizedBox(height: 20),
          _buildTips(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFB71C1C)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: const Color(0xFFAAAAAA),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < _strength
                      ? _strengthColor
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (_strengthLabel.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${_l.passwordStrength}: $_strengthLabel',
            style: TextStyle(
              fontSize: 11.5,
              color: _strengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            _l.passwordTipsTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 8),
         _tip(_l.tipMinChars),
          _tip(_l.tipMixCase),
          _tip(_l.tipIncludeNumbers),
          _tip(_l.tipSpecialChars),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 13,
            color: Color(0xFFB71C1C),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  Save button 
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB71C1C).withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            :  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_reset, size: 18),
                  SizedBox(width: 8),
                  Text(
                    _l.changePassword,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
