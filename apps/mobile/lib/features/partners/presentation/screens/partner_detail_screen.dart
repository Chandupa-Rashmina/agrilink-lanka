import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/partner.dart';
import '../providers/partner_provider.dart';
import 'partner_edit_screen.dart';

class PartnerDetailScreen extends ConsumerStatefulWidget {
  const PartnerDetailScreen({required this.partner, super.key});

  final Partner partner;

  @override
  ConsumerState<PartnerDetailScreen> createState() =>
      _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends ConsumerState<PartnerDetailScreen> {
  late Partner _partner;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _partner = widget.partner;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Partner>(
      MaterialPageRoute(builder: (_) => PartnerEditScreen(partner: _partner)),
    );

    if (updated != null && mounted) {
      setState(() {
        _partner = updated;
      });
    }
  }

  Future<void> _toggleActive() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final updated = await ref
          .read(partnerServiceProvider)
          .updatePartner(
            id: _partner.id,
            type: _partner.type,
            name: _partner.name,
            phone: _partner.phone,
            email: _partner.email,
            address: _partner.address,
            district: _partner.district,
            isActive: !_partner.isActive,
          );

      ref.invalidate(partnerListProvider);

      if (!mounted) return;

      setState(() => _partner = updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isActive ? 'Partner activated.' : 'Partner deactivated.',
          ),
        ),
      );
    } on DioException catch (error) {
      if (mounted) _showError(_messageFromDio(error));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _delete() async {
    if (_isProcessing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete partner?'),
        content: Text('Delete ${_partner.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(partnerServiceProvider).deletePartner(_partner.id);
      ref.invalidate(partnerListProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      if (mounted) _showError(_messageFromDio(error));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    return 'The request could not be completed.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _isProcessing ? null : _edit,
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<_PartnerAction>(
            enabled: !_isProcessing,
            onSelected: (action) {
              switch (action) {
                case _PartnerAction.toggleActive:
                  _toggleActive();
                case _PartnerAction.delete:
                  _delete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _PartnerAction.toggleActive,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _partner.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                  title: Text(_partner.isActive ? 'Deactivate' : 'Activate'),
                ),
              ),
              const PopupMenuItem(
                value: _PartnerAction.delete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Icon(
                    _partner.type == 'farmer'
                        ? Icons.agriculture
                        : Icons.local_shipping,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _partner.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(_partner.type.toUpperCase(), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _DetailTile(
                icon: Icons.phone,
                label: 'Phone',
                value: _partner.phone,
              ),
              _DetailTile(
                icon: Icons.email,
                label: 'Email',
                value: _partner.email,
              ),
              _DetailTile(
                icon: Icons.location_city,
                label: 'District',
                value: _partner.district,
              ),
              _DetailTile(
                icon: Icons.home,
                label: 'Address',
                value: _partner.address,
              ),
              _DetailTile(
                icon: _partner.isActive ? Icons.check_circle : Icons.block,
                label: 'Status',
                value: _partner.isActive ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _edit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Partner'),
              ),
            ],
          ),
          if (_isProcessing)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

enum _PartnerAction { toggleActive, delete }

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value == null || value!.trim().isEmpty ? 'Not provided' : value!,
        ),
      ),
    );
  }
}
