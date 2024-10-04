import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/onboarding2.png'),
          const SizedBox(height: 20),
          const Text('Feed your family the best food', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
