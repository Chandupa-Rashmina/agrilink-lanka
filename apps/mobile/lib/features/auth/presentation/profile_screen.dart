import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _district;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name);
    _email = TextEditingController(text: user?.email);
    _phone = TextEditingController(text: user?.phone);
    _district = TextEditingController(text: user?.district);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _district.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final saved = await context.read<AuthProvider>().updateProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      district: _district.text.trim(),
    );

    if (saved && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final item in [
              (_name, 'Name', TextInputType.name),
              (_email, 'Email', TextInputType.emailAddress),
              (_phone, 'Phone', TextInputType.phone),
              (_district, 'District', TextInputType.text),
            ]) ...[
              TextFormField(
                controller: item.$1,
                keyboardType: item.$3,
                decoration: InputDecoration(
                  labelText: item.$2,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? '${item.$2} is required.'
                    : null,
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: auth.isLoading ? null : _save,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
