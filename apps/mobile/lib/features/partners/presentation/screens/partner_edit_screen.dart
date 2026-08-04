import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/partner.dart';
import '../providers/partner_provider.dart';

class PartnerEditScreen extends ConsumerStatefulWidget {
  const PartnerEditScreen({required this.partner, super.key});

  final Partner partner;

  @override
  ConsumerState<PartnerEditScreen> createState() => _PartnerEditScreenState();
}

class _PartnerEditScreenState extends ConsumerState<PartnerEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _districtController;

  late String _type;
  late bool _isActive;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final partner = widget.partner;

    _type = partner.type;
    _isActive = partner.isActive;
    _nameController = TextEditingController(text: partner.name);
    _phoneController = TextEditingController(text: partner.phone ?? '');
    _emailController = TextEditingController(text: partner.email ?? '');
    _addressController = TextEditingController(text: partner.address ?? '');
    _districtController = TextEditingController(text: partner.district ?? '');
  }

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

      final updatedPartner = await service.updatePartner(
        id: widget.partner.id,
        type: _type,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        district: _districtController.text,
        isActive: _isActive,
      );

      ref.invalidate(partnerListProvider);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(updatedPartner);
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

    return 'Unable to update the partner.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Partner')),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
