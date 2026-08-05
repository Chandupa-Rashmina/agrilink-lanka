import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing.dart';
import '../providers/marketplace_providers.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    MarketplaceListing listing,
    String status,
  ) async {
    await ref
        .read(marketplaceServiceProvider)
        .updateListingStatus(listingId: listing.id, status: status);

    invalidateMarketplaceOperations(ref);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Listing changed to $status.')));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MarketplaceListing listing,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('This permanently deletes "${listing.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(marketplaceServiceProvider).deleteListing(listing.id);
    invalidateMarketplaceOperations(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(myListingsProvider);
    final dashboard = ref.watch(marketplaceDashboardProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myListingsProvider);
        ref.invalidate(marketplaceDashboardProvider);
        await Future.wait([
          ref.read(myListingsProvider.future),
          ref.read(marketplaceDashboardProvider.future),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        children: [
          dashboard.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (data) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _Count(label: 'Active', value: data.activeListings),
                    _Count(label: 'Paused', value: data.pausedListings),
                    _Count(label: 'Sold', value: data.soldListings),
                    _Count(
                      label: 'Inquiries',
                      value: data.sellerPendingInquiries,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          listings.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(myListingsProvider),
                child: const Text('Retry'),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('You have no listings yet.')),
                );
              }

              return Column(
                children: [
                  for (final listing in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            listing.status == 'active'
                                ? Icons.visibility
                                : listing.status == 'paused'
                                ? Icons.pause_circle_outline
                                : Icons.check_circle_outline,
                          ),
                          title: Text(listing.title),
                          subtitle: Text(
                            '${listing.quantity.toStringAsFixed(0)} '
                            '${listing.unit} • ${listing.status}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) async {
                              switch (action) {
                                case 'edit':
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditListingScreen(listing: listing),
                                    ),
                                  );
                                  invalidateMarketplaceOperations(ref);
                                case 'pause':
                                  await _changeStatus(
                                    context,
                                    ref,
                                    listing,
                                    'paused',
                                  );
                                case 'resume':
                                  await _changeStatus(
                                    context,
                                    ref,
                                    listing,
                                    'active',
                                  );
                                case 'sold':
                                  await _changeStatus(
                                    context,
                                    ref,
                                    listing,
                                    'sold',
                                  );
                                case 'delete':
                                  await _delete(context, ref, listing);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              if (listing.status == 'active')
                                const PopupMenuItem(
                                  value: 'pause',
                                  child: Text('Pause'),
                                ),
                              if (listing.status == 'paused')
                                const PopupMenuItem(
                                  value: 'resume',
                                  child: Text('Resume'),
                                ),
                              if (listing.status != 'sold')
                                const PopupMenuItem(
                                  value: 'sold',
                                  child: Text('Mark sold'),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value');
  }
}
