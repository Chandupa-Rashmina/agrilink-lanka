class MarketplaceInquiry {
  const MarketplaceInquiry({
    required this.id,
    required this.message,
    required this.status,
    required this.role,
    required this.listingId,
    required this.listingTitle,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerPhone,
  });

  factory MarketplaceInquiry.fromJson(Map<String, dynamic> json) {
    final listing = Map<String, dynamic>.from(
      json['listing'] as Map? ?? const {},
    );
    final buyer = Map<String, dynamic>.from(json['buyer'] as Map? ?? const {});
    final seller = Map<String, dynamic>.from(
      json['seller'] as Map? ?? const {},
    );

    return MarketplaceInquiry(
      id: json['id'] as int,
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      role: json['role'] as String? ?? 'buyer',
      listingId: listing['id'] as int? ?? 0,
      listingTitle: listing['title'] as String? ?? 'Listing',
      buyerName: buyer['name'] as String? ?? 'Buyer',
      buyerEmail: buyer['email'] as String? ?? '',
      buyerPhone: buyer['phone'] as String? ?? '',
      sellerName: seller['name'] as String? ?? 'Seller',
      sellerEmail: seller['email'] as String? ?? '',
      sellerPhone: seller['phone'] as String? ?? '',
    );
  }

  final int id;
  final String message;
  final String status;
  final String role;
  final int listingId;
  final String listingTitle;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String sellerName;
  final String sellerEmail;
  final String sellerPhone;

  bool get isSellerView => role == 'seller';
}
