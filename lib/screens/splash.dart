import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const TestScreen()),
    // );

    // Delay display of splash screen for 3 seconds
    Future.delayed(const Duration(seconds: 1), () async {
      if (await getBoolFromSF(BL_USER_LOGGED_IN)) {
        // Navigate to home screen after splash screen is displayed
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Navigate to home screen after splash screen is displayed
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/midwayscreen');
      }
      // // Navigate to home screen after splash screen is displayed
      // Navigator.pushReplacementNamed(context, '/midwayscreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF06A3F6),
        child: Center(
          child: Image.asset(
            'assets/images/ic_logo.png',
            width: 280,
            height: 165,
          ),
        ),
      ),
    );
  }
}
