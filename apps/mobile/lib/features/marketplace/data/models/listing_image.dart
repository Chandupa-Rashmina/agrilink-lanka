class MarketplaceListingImage {
  const MarketplaceListingImage({
    required this.id,
    required this.url,
    required this.sortOrder,
    required this.isCover,
  });

  factory MarketplaceListingImage.fromJson(Map<String, dynamic> json) {
    return MarketplaceListingImage(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isCover: json['is_cover'] as bool? ?? false,
    );
  }

  final int id;
  final String url;
  final int sortOrder;
  final bool isCover;
}
