import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_providers.dart';

class MarketplaceDashboardScreen extends ConsumerWidget {
  const MarketplaceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(marketplaceDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace Dashboard')),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(marketplaceDashboardProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(marketplaceDashboardProvider);
            await ref.read(marketplaceDashboardProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Selling', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _Grid(
                values: [
                  ('All listings', data.totalListings),
                  ('Active', data.activeListings),
                  ('Paused', data.pausedListings),
                  ('Sold', data.soldListings),
                  ('Pending inquiries', data.sellerPendingInquiries),
                  ('Accepted inquiries', data.sellerAcceptedInquiries),
                ],
              ),
              const SizedBox(height: 24),
              Text('Buying', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _Grid(
                values: [
                  ('Saved', data.favorites),
                  ('Waiting', data.buyerPendingInquiries),
                  ('Accepted', data.buyerAcceptedInquiries),
                  ('Rejected', data.buyerRejectedInquiries),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.values});

  final List<(String, int)> values;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: values.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = values[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.$2.toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(item.$1),
              ],
            ),
          ),
        );
      },
    );
  }
}
