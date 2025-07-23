import 'package:flutter/material.dart';
import 'package:snap_chef_5/screens/onboarding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapChef',
      theme: ThemeData(
        primaryColor: const Color(0xFF637FE7), // Deep Blue
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF637FE7), // Deep Blue
          secondary: const Color(0xFFF3756D), // Salmon
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
