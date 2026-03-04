

import 'package:flutter/material.dart';
import 'package:patient_app/widgets/lineargradient.dart';

class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        colors1: [Colors.blueAccent],
        colors2: [Colors.purpleAccent],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/splash.png', width: 200, height: 200),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Patient App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}