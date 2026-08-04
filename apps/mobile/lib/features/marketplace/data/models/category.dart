class MarketplaceCategory {
  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory MarketplaceCategory.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  final int id;
  final String name;
  final String slug;
}
