import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing.dart';
import '../providers/marketplace_providers.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({required this.listing, super.key});

  final MarketplaceListing listing;

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _price;
  late final TextEditingController _district;
  late final TextEditingController _location;
  late int _categoryId;
  late bool _negotiable;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _title = TextEditingController(text: listing.title);
    _description = TextEditingController(text: listing.description);
    _quantity = TextEditingController(text: listing.quantity.toString());
    _unit = TextEditingController(text: listing.unit);
    _price = TextEditingController(text: listing.price.toString());
    _district = TextEditingController(text: listing.district);
    _location = TextEditingController(text: listing.location);
    _categoryId = listing.categoryId;
    _negotiable = listing.isNegotiable;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _quantity.dispose();
    _unit.dispose();
    _price.dispose();
    _district.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) {
      return;
    }

    setState(() => _saving = true);

    try {
      await ref
          .read(marketplaceServiceProvider)
          .updateListing(
            listingId: widget.listing.id,
            categoryId: _categoryId,
            title: _title.text,
            description: _description.text,
            quantity: double.parse(_quantity.text),
            unit: _unit.text,
            price: double.parse(_price.text),
            district: _district.text,
            location: _location.text,
            isNegotiable: _negotiable,
          );

      ref.invalidate(myListingsProvider);
      ref.invalidate(marketplaceListingsProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            categories.when(
              data: (items) => DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _categoryId = value);
                  }
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Unable to load categories.'),
            ),
            const SizedBox(height: 12),
            for (final item in [
              (_title, 'Title'),
              (_description, 'Description'),
              (_quantity, 'Quantity'),
              (_unit, 'Unit'),
              (_price, 'Price'),
              (_district, 'District'),
              (_location, 'Location'),
            ]) ...[
              TextFormField(
                controller: item.$1,
                decoration: InputDecoration(
                  labelText: item.$2,
                  border: const OutlineInputBorder(),
                ),
                validator: item.$2 == 'Description' || item.$2 == 'Location'
                    ? null
                    : (value) => value == null || value.trim().isEmpty
                          ? '${item.$2} is required.'
                          : null,
              ),
              const SizedBox(height: 12),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Negotiable'),
              value: _negotiable,
              onChanged: (value) => setState(() => _negotiable = value),
            ),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
