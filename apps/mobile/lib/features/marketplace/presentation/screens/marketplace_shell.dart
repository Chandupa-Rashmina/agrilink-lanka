import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../../../auth/presentation/auth_provider.dart';
import '../../../auth/presentation/profile_screen.dart';
import 'create_listing_screen.dart';
import 'favorites_screen.dart';
import 'inquiries_screen.dart';
import 'marketplace_feed_screen.dart';
import 'my_listings_screen.dart';

class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({super.key});

  @override
  State<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int _index = 0;

  static const _titles = [
    'Marketplace',
    'Sell',
    'My Listings',
    'Saved',
    'Inquiries',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MarketplaceFeedScreen(),
      CreateListingScreen(
        onCreated: () {
          setState(() => _index = 2);
        },
      ),
      const MyListingsScreen(),
      const FavoritesScreen(),
      const InquiriesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder: (_) => const [
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
