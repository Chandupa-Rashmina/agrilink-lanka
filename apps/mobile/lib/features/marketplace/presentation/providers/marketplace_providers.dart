import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';
import '../../data/models/marketplace_dashboard.dart';
import '../../data/services/marketplace_service.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  throw StateError('MarketplaceService has not been configured.');
});

final marketplaceSearchProvider = StateProvider<String>((ref) => '');
final marketplaceCategoryFilterProvider = StateProvider<int?>((ref) => null);
final marketplaceDistrictFilterProvider = StateProvider<String>((ref) => '');
final marketplaceMinPriceProvider = StateProvider<double?>((ref) => null);
final marketplaceMaxPriceProvider = StateProvider<double?>((ref) => null);
final marketplaceNegotiableProvider = StateProvider<bool?>((ref) => null);
final marketplaceSortProvider = StateProvider<String>((ref) => 'newest');

final categoriesProvider = FutureProvider<List<MarketplaceCategory>>((ref) {
  return ref.watch(marketplaceServiceProvider).fetchCategories();
});

final marketplaceDashboardProvider = FutureProvider<MarketplaceDashboard>((
  ref,
) {
  return ref.watch(marketplaceServiceProvider).fetchDashboard();
});

final marketplaceListingsProvider = FutureProvider<List<MarketplaceListing>>((
  ref,
) {
  return ref
      .watch(marketplaceServiceProvider)
      .fetchListings(
        search: ref.watch(marketplaceSearchProvider),
        categoryId: ref.watch(marketplaceCategoryFilterProvider),
        district: ref.watch(marketplaceDistrictFilterProvider),
        minPrice: ref.watch(marketplaceMinPriceProvider),
        maxPrice: ref.watch(marketplaceMaxPriceProvider),
        negotiable: ref.watch(marketplaceNegotiableProvider),
        sort: ref.watch(marketplaceSortProvider),
      );
});

final myListingsProvider = FutureProvider<List<MarketplaceListing>>((ref) {
  return ref.watch(marketplaceServiceProvider).fetchMyListings();
});

final favoriteListingsProvider = FutureProvider<List<MarketplaceListing>>((
  ref,
) {
  return ref.watch(marketplaceServiceProvider).fetchFavorites();
});

final buyerInquiriesProvider = FutureProvider<List<MarketplaceInquiry>>((ref) {
  return ref.watch(marketplaceServiceProvider).fetchInquiries(role: 'buyer');
});

final sellerInquiriesProvider = FutureProvider<List<MarketplaceInquiry>>((ref) {
  return ref.watch(marketplaceServiceProvider).fetchInquiries(role: 'seller');
});

void invalidateMarketplaceOperations(WidgetRef ref) {
  ref.invalidate(marketplaceDashboardProvider);
  ref.invalidate(marketplaceListingsProvider);
  ref.invalidate(myListingsProvider);
  ref.invalidate(favoriteListingsProvider);
  ref.invalidate(buyerInquiriesProvider);
  ref.invalidate(sellerInquiriesProvider);
}
