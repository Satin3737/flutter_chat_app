import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/auth/widgets/user_image_picker.dart';

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
  File? _userImage;
  bool _isLogin = true;
  bool _isLoading = false;

  void _switchAuthMode() => setState(() => _isLogin = !_isLogin);

  void _pickImage(File image) => _userImage = image;

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

    if (_userImage == null && !_isLogin) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image.')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

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

        final storageRef = FirebaseStorage.instance
            .ref('user_images')
            .child('${_firebaseAuth.currentUser!.uid}.jpg');

        await storageRef.putFile(_userImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print('Image URL: $imageUrl');
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
    setState(() => _isLoading = false);
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
                if (!_isLogin) UserImagePicker(onImagePicked: _pickImage),
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
                if (_isLoading)
                  Container(
                    padding: EdgeInsets.all(24),
                    width: 100,
                    height: 100,
                    child: const CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  Column(
                    spacing: 4,
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
