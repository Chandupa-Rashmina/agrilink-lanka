import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _district = TextEditingController();
  final _password = TextEditingController();

  bool _registerMode = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _district.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();

    if (_registerMode) {
      await auth.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        district: _district.text.trim(),
        password: _password.text,
      );
    } else {
      await auth.login(email: _email.text.trim(), password: _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'AgriLink Lanka',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _registerMode
                          ? 'Create a buyer and seller account.'
                          : 'Buy and sell agricultural stock.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (_registerMode) ...[
                      _Field(controller: _name, label: 'Name'),
                      const SizedBox(height: 12),
                    ],
                    _Field(
                      controller: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (_registerMode) ...[
                      const SizedBox(height: 12),
                      _Field(
                        controller: _phone,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _Field(controller: _district, label: 'District'),
                    ],
                    const SizedBox(height: 12),
                    _Field(
                      controller: _password,
                      label: 'Password',
                      obscureText: true,
                      minimumLength: _registerMode ? 8 : 1,
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registerMode ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              setState(() => _registerMode = !_registerMode);
                            },
                      child: Text(
                        _registerMode
                            ? 'Already have an account? Sign in'
                            : 'Create a new account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.minimumLength = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int minimumLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().length < minimumLength) {
          return minimumLength > 1
              ? 'Use at least $minimumLength characters.'
              : '$label is required.';
        }

        return null;
      },
    );
  }
}
