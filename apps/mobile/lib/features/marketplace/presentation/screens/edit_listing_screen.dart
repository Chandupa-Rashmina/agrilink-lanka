import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/listing.dart';
import '../providers/marketplace_providers.dart';
import 'map_picker_screen.dart';

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
  LatLng? _coordinates;
  final List<XFile> _newImages = [];
  late var _existingImages = [...widget.listing.images];

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
    _coordinates = listing.hasCoordinates
        ? LatLng(listing.latitude!, listing.longitude!)
        : null;
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

  Future<void> _pickImages() async {
    final remaining = 5 - _existingImages.length - _newImages.length;
    if (remaining <= 0) {
      return;
    }

    final selected = await ImagePicker().pickMultiImage(
      imageQuality: 75,
      maxWidth: 1600,
      limit: remaining,
    );

    if (selected.isNotEmpty && mounted) {
      setState(() => _newImages.addAll(selected.take(remaining)));
    }
  }

  Future<void> _deleteExistingImage(int imageId) async {
    await ref
        .read(marketplaceServiceProvider)
        .deleteListingImage(listingId: widget.listing.id, imageId: imageId);

    if (mounted) {
      setState(
        () => _existingImages.removeWhere((image) => image.id == imageId),
      );
    }
  }

  Future<void> _setCover(int imageId) async {
    final updated = await ref
        .read(marketplaceServiceProvider)
        .setListingCoverImage(listingId: widget.listing.id, imageId: imageId);

    if (mounted) {
      setState(() => _existingImages = [...updated.images]);
    }
  }

  Future<void> _pickLocation() async {
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLatitude: _coordinates?.latitude,
          initialLongitude: _coordinates?.longitude,
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _coordinates = selected);
    }
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
            latitude: _coordinates?.latitude,
            longitude: _coordinates?.longitude,
            newImagePaths: _newImages.map((image) => image.path).toList(),
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
            OutlinedButton.icon(
              onPressed: _existingImages.length + _newImages.length >= 5
                  ? null
                  : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Add photos '
                '(${_existingImages.length + _newImages.length}/5)',
              ),
            ),
            if (_existingImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Existing photos'),
              const SizedBox(height: 6),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final image = _existingImages[index];

                    return SizedBox(
                      width: 108,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                image.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 2,
                            bottom: 2,
                            child: IconButton.filled(
                              tooltip: 'Set as cover',
                              visualDensity: VisualDensity.compact,
                              onPressed: image.isCover
                                  ? null
                                  : () => _setCover(image.id),
                              icon: Icon(
                                image.isCover ? Icons.star : Icons.star_border,
                                size: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: IconButton.filled(
                              tooltip: 'Delete photo',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _deleteExistingImage(image.id),
                              icon: const Icon(Icons.delete_outline, size: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_newImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('New photos'),
              const SizedBox(height: 6),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_newImages[index].path),
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: IconButton.filled(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() => _newImages.removeAt(index));
                            },
                            icon: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map_outlined),
              label: Text(
                _coordinates == null
                    ? 'Choose pickup/farm location'
                    : 'Change map location',
              ),
            ),
            const SizedBox(height: 12),
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
