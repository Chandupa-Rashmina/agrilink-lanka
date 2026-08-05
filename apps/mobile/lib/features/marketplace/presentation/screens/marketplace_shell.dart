import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/profile_screen.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/marketplace_providers.dart';
import 'create_listing_screen.dart';
import 'favorites_screen.dart';
import 'inquiries_screen.dart';
import 'marketplace_dashboard_screen.dart';
import 'marketplace_feed_screen.dart';
import 'my_listings_screen.dart';

class MarketplaceShell extends ConsumerStatefulWidget {
  const MarketplaceShell({super.key});

  @override
  ConsumerState<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends ConsumerState<MarketplaceShell> {
  int _index = 0;

  static const _titles = [
    'Marketplace',
    'Sell',
    'My Listings',
    'Saved',
    'Inquiries',
  ];

  Future<void> _openFilters() async {
    final minController = TextEditingController(
      text: ref.read(marketplaceMinPriceProvider)?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: ref.read(marketplaceMaxPriceProvider)?.toString() ?? '',
    );
    bool? negotiable = ref.read(marketplaceNegotiableProvider);
    String sort = ref.read(marketplaceSortProvider);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Marketplace filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minimum price'),
                ),
                TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Maximum price'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool?>(
                  initialValue: negotiable,
                  decoration: const InputDecoration(labelText: 'Negotiable'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Any')),
                    DropdownMenuItem(value: true, child: Text('Yes')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => negotiable = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: sort,
                  decoration: const InputDecoration(labelText: 'Sort'),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text('Lowest price'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text('Highest price'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => sort = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(marketplaceMinPriceProvider.notifier).state = null;
                ref.read(marketplaceMaxPriceProvider.notifier).state = null;
                ref.read(marketplaceNegotiableProvider.notifier).state = null;
                ref.read(marketplaceSortProvider.notifier).state = 'newest';
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(marketplaceMinPriceProvider.notifier).state =
                    double.tryParse(minController.text);
                ref.read(marketplaceMaxPriceProvider.notifier).state =
                    double.tryParse(maxController.text);
                ref.read(marketplaceNegotiableProvider.notifier).state =
                    negotiable;
                ref.read(marketplaceSortProvider.notifier).state = sort;
                Navigator.pop(dialogContext);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );

    minController.dispose();
    maxController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MarketplaceFeedScreen(),
      CreateListingScreen(onCreated: () => setState(() => _index = 2)),
      const MyListingsScreen(),
      const FavoritesScreen(),
      const InquiriesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (_index == 0)
            IconButton(
              tooltip: 'Filters',
              onPressed: _openFilters,
              icon: const Icon(Icons.tune),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MarketplaceDashboardScreen(),
                  ),
                );
              } else if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'dashboard', child: Text('Dashboard')),
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Sell',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Mine',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Inquiries',
          ),
        ],
      ),
    );
  }
}
