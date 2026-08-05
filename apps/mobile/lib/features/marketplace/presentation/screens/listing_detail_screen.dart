import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/listing.dart';
import '../../data/models/seller_contact.dart';
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

  bool get _isOwner {
    final userId = ref.read(authControllerProvider).valueOrNull?.user?.id;
    return userId == widget.listing.sellerId;
  }

  Future<SellerContact?> _contact() async {
    try {
      return await ref
          .read(marketplaceServiceProvider)
          .fetchSellerContact(widget.listing.id);
    } on DioException catch (error) {
      _showError(error);
      return null;
    }
  }

  Future<void> _callSeller() async {
    final contact = await _contact();

    if (contact == null || contact.phone.trim().isEmpty) {
      _showMessage('Seller phone number is not available.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: contact.phone.trim());
    if (!await launchUrl(uri)) {
      _showMessage('No phone application is available.');
    }
  }

  Future<void> _openWhatsApp() async {
    final contact = await _contact();

    if (contact == null || contact.phone.trim().isEmpty) {
      _showMessage('Seller phone number is not available.');
      return;
    }

    final phone = _internationalPhone(contact.phone);
    final message = Uri.encodeComponent(
      'Hello ${contact.name}, I am interested in '
      '"${widget.listing.title}" on AgriLink Lanka.',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$message');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('WhatsApp could not be opened.');
    }
  }

  Future<void> _shareListing() async {
    final listing = widget.listing;
    final location = listing.hasCoordinates
        ? '\nMap: https://www.google.com/maps/search/?api=1&query='
              '${listing.latitude},${listing.longitude}'
        : '';

    await SharePlus.instance.share(
      ShareParams(
        text:
            '${listing.title}\n'
            'LKR ${listing.price.toStringAsFixed(2)} / ${listing.unit}\n'
            '${listing.quantity.toStringAsFixed(0)} ${listing.unit} available\n'
            '${listing.district}$location\n'
            'Shared from AgriLink Lanka',
      ),
    );
  }

  Future<void> _openDirections() async {
    final listing = widget.listing;

    if (!listing.hasCoordinates) {
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${listing.latitude},${listing.longitude}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Directions could not be opened.');
    }
  }

  String _internationalPhone(String value) {
    var phone = value.replaceAll(RegExp(r'[^0-9+]'), '');

    if (phone.startsWith('+')) {
      return phone.substring(1);
    }

    if (phone.startsWith('0')) {
      return '94${phone.substring(1)}';
    }

    return phone;
  }

  Future<void> _toggleFavorite() async {
    if (_isOwner) {
      _showMessage('You cannot save your own listing.');
      return;
    }

    setState(() => _isBusy = true);

    try {
      await ref.read(marketplaceServiceProvider).addFavorite(widget.listing.id);
      ref.invalidate(favoriteListingsProvider);
      _showMessage('Listing saved.');
    } on DioException catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _sendInquiry() async {
    if (_isOwner) {
      _showMessage('You cannot inquire about your own listing.');
      return;
    }

    final controller = TextEditingController();

    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
      ),
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
      ref.invalidate(buyerInquiriesProvider);
      ref.invalidate(sellerInquiriesProvider);
      _showMessage('Inquiry sent.');
    } on DioException catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showError(DioException error) {
    final data = error.response?.data;
    final message = data is Map && data['message'] is String
        ? data['message'] as String
        : 'The request could not be completed.';

    _showMessage(message);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final isOwner = _isOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _shareListing,
            icon: const Icon(Icons.share_outlined),
          ),
          if (!isOwner)
            IconButton(
              tooltip: 'Save',
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
          if (listing.hasCoordinates) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      listing.latitude!,
                      listing.longitude!,
                    ),
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'lk.agrilink.mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(listing.latitude!, listing.longitude!),
                          width: 46,
                          height: 46,
                          child: const Icon(
                            Icons.location_pin,
                            size: 46,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Open Directions'),
            ),
          ],
          const SizedBox(height: 24),
          if (isOwner)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'This is your listing. Buyer contact actions are hidden.',
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _callSeller,
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isBusy ? null : _sendInquiry,
              icon: const Icon(Icons.message),
              label: const Text('Send Inquiry'),
            ),
          ],
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
