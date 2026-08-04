import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/partner_provider.dart';

class PartnerCreateScreen extends ConsumerStatefulWidget {
  const PartnerCreateScreen({super.key});

  @override
  ConsumerState<PartnerCreateScreen> createState() =>
      _PartnerCreateScreenState();
}

class _PartnerCreateScreenState extends ConsumerState<PartnerCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();

  String _type = 'farmer';
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(partnerServiceProvider);

      await service.createPartner(
        type: _type,
        name: _nameController.text.trim(),
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        district: _districtController.text,
      );

      ref.invalidate(partnerListProvider);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      setState(() {
        _errorMessage = _messageFromDio(error);
      });
    } on FormatException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }

      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return 'Unable to save the partner. Check the server connection.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Partner')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'farmer',
                    label: Text('Farmer'),
                    icon: Icon(Icons.agriculture),
                  ),
                  ButtonSegment(
                    value: 'supplier',
                    label: Text('Supplier'),
                    icon: Icon(Icons.local_shipping),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: _isSaving
                    ? null
                    : (selection) {
                        setState(() {
                          _type = selection.first;
                        });
                      },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Partner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
