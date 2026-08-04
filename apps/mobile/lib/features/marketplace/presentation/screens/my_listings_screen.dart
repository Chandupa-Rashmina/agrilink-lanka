import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_providers.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(myListingsProvider);

    return listings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () => ref.invalidate(myListingsProvider),
          child: const Text('Retry'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('You have no listings yet.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myListingsProvider);
            await ref.read(myListingsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final listing = items[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(listing.title),
                  subtitle: Text(
                    '${listing.quantity.toStringAsFixed(0)} ${listing.unit} • ${listing.status}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'edit') {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditListingScreen(listing: listing),
                          ),
                        );
                      } else if (action == 'sold') {
                        await ref
                            .read(marketplaceServiceProvider)
                            .markSold(listing.id);
                      } else if (action == 'delete') {
                        await ref
                            .read(marketplaceServiceProvider)
                            .deleteListing(listing.id);
                      }

                      ref.invalidate(myListingsProvider);
                      ref.invalidate(marketplaceListingsProvider);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'sold', child: Text('Mark sold')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
