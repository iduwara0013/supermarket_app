import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/onboarding1.png'),
          const SizedBox(height: 20),
          const Text('Groceries without Stress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
