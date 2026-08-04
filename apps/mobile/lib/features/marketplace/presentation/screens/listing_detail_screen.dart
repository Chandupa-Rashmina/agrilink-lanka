import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing.dart';
import '../providers/marketplace_providers.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({required this.listing, super.key});

  final MarketplaceListing listing;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  bool _isBusy = false;

  Future<void> _toggleFavorite() async {
    setState(() => _isBusy = true);

    try {
      await ref.read(marketplaceServiceProvider).addFavorite(widget.listing.id);
      ref.invalidate(favoriteListingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Listing saved.')));
      }
    } on DioException catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _sendInquiry() async {
    final controller = TextEditingController();

    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Contact seller'),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Write your inquiry or offer',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (message == null || message.isEmpty) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      await ref
          .read(marketplaceServiceProvider)
          .sendInquiry(listingId: widget.listing.id, message: message);
      ref.invalidate(inquiriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inquiry sent.')));
      }
    } on DioException catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showError(DioException error) {
    if (!mounted) {
      return;
    }

    final data = error.response?.data;
    String message = 'The request could not be completed.';

    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: [
          IconButton(
            onPressed: _isBusy ? null : _toggleFavorite,
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (listing.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                listing.imageUrl!,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 16),
          Text(listing.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'LKR ${listing.price.toStringAsFixed(2)} / ${listing.unit}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${listing.quantity.toStringAsFixed(0)} ${listing.unit} available',
          ),
          const Divider(height: 32),
          _InfoRow(label: 'Category', value: listing.categoryName),
          _InfoRow(label: 'District', value: listing.district),
          _InfoRow(
            label: 'Location',
            value: listing.location ?? 'Not provided',
          ),
          _InfoRow(label: 'Seller', value: listing.sellerName),
          _InfoRow(
            label: 'Negotiable',
            value: listing.isNegotiable ? 'Yes' : 'No',
          ),
          const SizedBox(height: 16),
          Text(
            listing.description?.trim().isNotEmpty == true
                ? listing.description!
                : 'No description provided.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isBusy ? null : _sendInquiry,
            icon: const Icon(Icons.message),
            label: const Text('Contact Seller'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
