class MarketplaceListing {
  const MarketplaceListing({
    required this.id,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.isNegotiable,
    required this.district,
    required this.status,
    required this.categoryId,
    required this.categoryName,
    required this.sellerId,
    required this.sellerName,
    this.description,
    this.location,
    this.availableDate,
    this.imageUrl,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    final category = Map<String, dynamic>.from(
      json['category'] as Map? ?? const {},
    );
    final seller = Map<String, dynamic>.from(
      json['seller'] as Map? ?? const {},
    );

    return MarketplaceListing(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      quantity: _asDouble(json['quantity']),
      unit: json['unit'] as String? ?? '',
      price: _asDouble(json['price']),
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      district: json['district'] as String? ?? '',
      location: json['location'] as String?,
      availableDate: json['available_date'] as String?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'active',
      categoryId: category['id'] as int? ?? 0,
      categoryName: category['name'] as String? ?? 'Uncategorized',
      sellerId: seller['id'] as int? ?? 0,
      sellerName: seller['name'] as String? ?? 'Unknown seller',
    );
  }

  final int id;
  final String title;
  final String? description;
  final double quantity;
  final String unit;
  final double price;
  final bool isNegotiable;
  final String district;
  final String? location;
  final String? availableDate;
  final String? imageUrl;
  final String status;
  final int categoryId;
  final String categoryName;
  final int sellerId;
  final String sellerName;

  MarketplaceListing copyWith({String? status}) {
    return MarketplaceListing(
      id: id,
      title: title,
      description: description,
      quantity: quantity,
      unit: unit,
      price: price,
      isNegotiable: isNegotiable,
      district: district,
      location: location,
      availableDate: availableDate,
      imageUrl: imageUrl,
      status: status ?? this.status,
      categoryId: categoryId,
      categoryName: categoryName,
      sellerId: sellerId,
      sellerName: sellerName,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
