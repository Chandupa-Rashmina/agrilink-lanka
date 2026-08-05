import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../providers/marketplace_providers.dart';
import 'map_picker_screen.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({this.onCreated, super.key});

  final VoidCallback? onCreated;

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController(text: 'kg');
  final _price = TextEditingController();
  final _district = TextEditingController();
  final _location = TextEditingController();

  int? _categoryId;
  bool _negotiable = false;
  bool _saving = false;
  XFile? _image;
  LatLng? _coordinates;

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

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1600,
    );

    if (image != null) {
      setState(() => _image = image);
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
    if (!_formKey.currentState!.validate() || _categoryId == null || _saving) {
      return;
    }

    setState(() => _saving = true);

    try {
      await ref
          .read(marketplaceServiceProvider)
          .createListing(
            categoryId: _categoryId!,
            title: _title.text,
            description: _description.text,
            quantity: double.parse(_quantity.text),
            unit: _unit.text,
            price: double.parse(_price.text),
            district: _district.text,
            location: _location.text,
            latitude: _coordinates?.latitude,
            longitude: _coordinates?.longitude,
            isNegotiable: _negotiable,
            imagePath: _image?.path,
          );

      ref.invalidate(marketplaceListingsProvider);
      ref.invalidate(myListingsProvider);

      _formKey.currentState!.reset();
      _title.clear();
      _description.clear();
      _quantity.clear();
      _unit.text = 'kg';
      _price.clear();
      _district.clear();
      _location.clear();

      setState(() {
        _categoryId = null;
        _negotiable = false;
        _image = null;
        _coordinates = null;
      });

      widget.onCreated?.call();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Listing published.')));
      }
    } on DioException catch (error) {
      if (mounted) {
        final data = error.response?.data;
        final message = data is Map && data['message'] is String
            ? data['message'] as String
            : 'Unable to publish listing.';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(
            'Sell agricultural stock',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          categories.when(
            data: (items) => DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category *',
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
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) =>
                  value == null ? 'Category is required.' : null,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Unable to load categories.'),
          ),
          const SizedBox(height: 12),
          _TextField(
            controller: _title,
            label: 'Title *',
            validator: _required,
          ),
          const SizedBox(height: 12),
          _TextField(
            controller: _description,
            label: 'Description',
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TextField(
                  controller: _quantity,
                  label: 'Quantity *',
                  keyboardType: TextInputType.number,
                  validator: _positiveNumber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TextField(
                  controller: _unit,
                  label: 'Unit *',
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TextField(
            controller: _price,
            label: 'Price per unit (LKR) *',
            keyboardType: TextInputType.number,
            validator: _nonNegativeNumber,
          ),
          const SizedBox(height: 12),
          _TextField(
            controller: _district,
            label: 'District *',
            validator: _required,
          ),
          const SizedBox(height: 12),
          _TextField(controller: _location, label: 'Location'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Price is negotiable'),
            value: _negotiable,
            onChanged: (value) => setState(() => _negotiable = value),
          ),
          OutlinedButton.icon(
            onPressed: _pickLocation,
            icon: const Icon(Icons.map_outlined),
            label: Text(
              _coordinates == null
                  ? 'Choose pickup/farm location'
                  : 'Map location selected',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(_image == null ? 'Choose photo' : 'Photo selected'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish),
            label: Text(_saving ? 'Publishing...' : 'Publish Listing'),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required.' : null;
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number <= 0 ? 'Enter a valid amount.' : null;
  }

  String? _nonNegativeNumber(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number < 0 ? 'Enter a valid price.' : null;
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
