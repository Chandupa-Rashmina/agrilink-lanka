import 'package:flutter/material.dart';

import '../../data/models/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({required this.listing, required this.onTap, super.key});

  final MarketplaceListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  listing.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                ),
              )
            else
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: _ImagePlaceholder(),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'LKR ${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.quantity.toStringAsFixed(0)} ${listing.unit} • ${listing.district}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.categoryName} • ${listing.sellerName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.agriculture, size: 56)),
    );
  }
}
