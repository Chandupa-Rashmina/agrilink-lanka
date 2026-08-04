import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_providers.dart';
import 'listing_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteListingsProvider);

    return favorites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () => ref.invalidate(favoriteListingsProvider),
          child: const Text('Retry'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No saved listings.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final listing = items[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(listing.title),
                subtitle: Text(
                  'LKR ${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                trailing: IconButton(
                  onPressed: () async {
                    await ref
                        .read(marketplaceServiceProvider)
                        .removeFavorite(listing.id);
                    ref.invalidate(favoriteListingsProvider);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
