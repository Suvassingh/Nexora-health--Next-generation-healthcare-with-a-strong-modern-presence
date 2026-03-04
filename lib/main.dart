import 'package:flutter/material.dart';
import 'package:patient_app/splash_screen.dart';


void main (){
  runApp(const PatientApp());
}


class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}