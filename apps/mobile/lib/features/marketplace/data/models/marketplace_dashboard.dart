class MarketplaceDashboard {
  const MarketplaceDashboard({
    required this.totalListings,
    required this.activeListings,
    required this.pausedListings,
    required this.soldListings,
    required this.sellerPendingInquiries,
    required this.sellerAcceptedInquiries,
    required this.favorites,
    required this.buyerPendingInquiries,
    required this.buyerAcceptedInquiries,
    required this.buyerRejectedInquiries,
  });

  factory MarketplaceDashboard.fromJson(Map<String, dynamic> json) {
    final seller = Map<String, dynamic>.from(
      json['seller'] as Map? ?? const {},
    );
    final buyer = Map<String, dynamic>.from(json['buyer'] as Map? ?? const {});

    int value(Map<String, dynamic> source, String key) {
      return (source[key] as num?)?.toInt() ?? 0;
    }

    return MarketplaceDashboard(
      totalListings: value(seller, 'total_listings'),
      activeListings: value(seller, 'active'),
      pausedListings: value(seller, 'paused'),
      soldListings: value(seller, 'sold'),
      sellerPendingInquiries: value(seller, 'pending_inquiries'),
      sellerAcceptedInquiries: value(seller, 'accepted_inquiries'),
      favorites: value(buyer, 'favorites'),
      buyerPendingInquiries: value(buyer, 'pending_inquiries'),
      buyerAcceptedInquiries: value(buyer, 'accepted_inquiries'),
      buyerRejectedInquiries: value(buyer, 'rejected_inquiries'),
    );
  }

  final int totalListings;
  final int activeListings;
  final int pausedListings;
  final int soldListings;
  final int sellerPendingInquiries;
  final int sellerAcceptedInquiries;
  final int favorites;
  final int buyerPendingInquiries;
  final int buyerAcceptedInquiries;
  final int buyerRejectedInquiries;
}
