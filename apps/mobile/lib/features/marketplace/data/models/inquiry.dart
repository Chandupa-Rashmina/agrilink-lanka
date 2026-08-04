class MarketplaceInquiry {
  const MarketplaceInquiry({
    required this.id,
    required this.message,
    required this.status,
    required this.listingId,
    required this.listingTitle,
    required this.buyerName,
    required this.buyerEmail,
  });

  factory MarketplaceInquiry.fromJson(Map<String, dynamic> json) {
    final listing = Map<String, dynamic>.from(
      json['listing'] as Map? ?? const {},
    );
    final buyer = Map<String, dynamic>.from(json['buyer'] as Map? ?? const {});

    return MarketplaceInquiry(
      id: json['id'] as int,
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      listingId: listing['id'] as int? ?? 0,
      listingTitle: listing['title'] as String? ?? 'Listing',
      buyerName: buyer['name'] as String? ?? 'Buyer',
      buyerEmail: buyer['email'] as String? ?? '',
    );
  }

  final int id;
  final String message;
  final String status;
  final int listingId;
  final String listingTitle;
  final String buyerName;
  final String buyerEmail;
}
