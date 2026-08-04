import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';
import '../../data/services/marketplace_service.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  throw StateError('MarketplaceService has not been configured.');
});

final marketplaceSearchProvider = StateProvider<String>((ref) => '');
final marketplaceCategoryFilterProvider = StateProvider<int?>((ref) => null);
final marketplaceDistrictFilterProvider = StateProvider<String>((ref) => '');

final categoriesProvider = FutureProvider<List<MarketplaceCategory>>((ref) {
  return ref.watch(marketplaceServiceProvider).fetchCategories();
});

final marketplaceListingsProvider = FutureProvider<List<MarketplaceListing>>((
  ref,
) {
  final search = ref.watch(marketplaceSearchProvider);
  final categoryId = ref.watch(marketplaceCategoryFilterProvider);
  final district = ref.watch(marketplaceDistrictFilterProvider);

  return ref
      .watch(marketplaceServiceProvider)
      .fetchListings(
        search: search,
        categoryId: categoryId,
        district: district,
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
