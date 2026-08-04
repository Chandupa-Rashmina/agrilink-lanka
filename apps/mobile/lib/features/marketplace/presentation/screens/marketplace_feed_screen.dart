import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_providers.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class MarketplaceFeedScreen extends ConsumerStatefulWidget {
  const MarketplaceFeedScreen({super.key});

  @override
  ConsumerState<MarketplaceFeedScreen> createState() =>
      _MarketplaceFeedScreenState();
}

class _MarketplaceFeedScreenState extends ConsumerState<MarketplaceFeedScreen> {
  final _searchController = TextEditingController();
  final _districtController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(marketplaceSearchProvider.notifier).state = _searchController.text
        .trim();
    ref.read(marketplaceDistrictFilterProvider.notifier).state =
        _districtController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final listings = ref.watch(marketplaceListingsProvider);
    final selectedCategory = ref.watch(marketplaceCategoryFilterProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(marketplaceListingsProvider);
        await ref.read(marketplaceListingsProvider.future);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SearchBar(
                    controller: _searchController,
                    hintText: 'Search crops, products or equipment',
                    onSubmitted: (_) => _applyFilters(),
                    trailing: [
                      IconButton(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _districtController,
                    decoration: InputDecoration(
                      labelText: 'District',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      suffixIcon: IconButton(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.check),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  categories.when(
                    data: (items) => SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: selectedCategory == null,
                            onSelected: (_) {
                              ref
                                      .read(
                                        marketplaceCategoryFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  null;
                            },
                          ),
                          const SizedBox(width: 8),
                          ...items.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category.name),
                                selected: selectedCategory == category.id,
                                onSelected: (_) {
                                  ref
                                          .read(
                                            marketplaceCategoryFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      category.id;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          listings.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => SliverFillRemaining(
              child: Center(
                child: FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(marketplaceListingsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No active listings found.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final listing = items[index];

                    return ListingCard(
                      listing: listing,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listing: listing),
                          ),
                        );
                      },
                    );
                  }, childCount: items.length),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 430,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
