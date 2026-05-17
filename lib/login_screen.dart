
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/controller/internet_status_controller.dart';
import 'package:patient_app/home_screen.dart';
import 'package:patient_app/l10n/app_localizations.dart';
import 'package:patient_app/signup_screen.dart';
import 'package:patient_app/widgets/connectivity_icon.dart';
import 'package:patient_app/widgets/input_field.dart';
import 'package:patient_app/widgets/language_toggle_button.dart';
import 'package:patient_app/widgets/login_signup_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ConnectivityController controller = Get.put(ConnectivityController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }
    if (password.isEmpty) {
      Get.snackbar("Error", "Please enter your password");
      return;
    }

    setState(() => loading = true);

    try {
      final result = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        Get.offAll(() => HomeScreen());
      }
    } on AuthException catch (e) {
      Get.snackbar("Login Failed", e.message);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Row(
          children: [
            Image(
              image: AssetImage("assets/images/gov_logo.webp"),
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              final type = controller.connectionType.value;
              if (type == ConnectivityResult.none) {
                return ConnectivityIndicator(icon: Icons.signal_wifi_off);
              } else if (type == ConnectivityResult.wifi) {
                return ConnectivityIndicator(icon: Icons.wifi);
              } else if (type == ConnectivityResult.mobile) {
                return ConnectivityIndicator(icon: Icons.signal_cellular_4_bar);
              }
              return const SizedBox.shrink();
            }),
          ),
          IconButton(onPressed: () {}, icon: LanguageToggleButton()),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/images/login.json',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InputField(
                          hintText: "ram@gmail.com",
                          obscureText: false,
                          controller: emailController,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.password,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InputField(
                          hintText: "xxxxxxxx",
                          obscureText: true,
                          controller: passwordController,
                        ),
                      ],
                    ),
                  ),
                  LoginSignupButton(
                    text: AppLocalizations.of(context)!.login,
                    onPressed: loading ? null : () => login(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.donthaveanaccout,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.offAll(() => SignupScreen()),
                        child: Text(
                          AppLocalizations.of(context)!.signup,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (loading)
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
                          'Logging in...',
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
}
