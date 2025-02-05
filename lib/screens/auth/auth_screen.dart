import 'package:flutter/material.dart';

import 'widgets/auth_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              spacing: 24,
              children: [
                Image.asset(
                  'assets/images/chat.png',
                  width: 200,
                ),
                const AuthForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
