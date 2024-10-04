import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/onboarding3.png'),
          const SizedBox(height: 20),
          const Text('We bring the store to your door', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Order from a wide selection of 5000+ fresh produce and groceries at the comfort of your home',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
