import 'package:flutter/material.dart';

import '../../data/models/partner.dart';
import 'partner_edit_screen.dart';

class PartnerDetailScreen extends StatefulWidget {
  const PartnerDetailScreen({required this.partner, super.key});

  final Partner partner;

  @override
  State<PartnerDetailScreen> createState() => _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends State<PartnerDetailScreen> {
  late Partner _partner;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _edit,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
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
          _DetailTile(icon: Icons.phone, label: 'Phone', value: _partner.phone),
          _DetailTile(icon: Icons.email, label: 'Email', value: _partner.email),
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
            onPressed: _edit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Partner'),
          ),
        ],
      ),
    );
  }
}

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
