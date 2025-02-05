import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true;

  void _switchAuthMode() => setState(() => _isLogin = !_isLogin);

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      if (_isLogin) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'Authentication failed. Please try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  validator: _emailValidator,
                  onSaved: (value) => _email = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: _passwordValidator,
                  onSaved: (value) => _password = value!,
                ),
                Column(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      onPressed: _submitForm,
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                    ),
                    TextButton(
                      onPressed: _switchAuthMode,
                      child: Text(
                        _isLogin
                            ? 'Create new account'
                            : 'I already have an account',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
