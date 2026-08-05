import 'listing_image.dart';

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
    required this.images,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.sellerDistrict,
    this.createdAt,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    final category = Map<String, dynamic>.from(
      json['category'] as Map? ?? const {},
    );
    final seller = Map<String, dynamic>.from(
      json['seller'] as Map? ?? const {},
    );

    double number(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    double? nullableNumber(dynamic value) {
      if (value == null) {
        return null;
      }

      return value is num
          ? value.toDouble()
          : double.tryParse(value.toString());
    }

    final images = (json['images'] as List? ?? const [])
        .map(
          (item) => MarketplaceListingImage.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    return MarketplaceListing(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      quantity: number(json['quantity']),
      unit: json['unit'] as String? ?? '',
      price: number(json['price']),
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      district: json['district'] as String? ?? '',
      location: json['location'] as String?,
      latitude: nullableNumber(json['latitude']),
      longitude: nullableNumber(json['longitude']),
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'active',
      categoryId: (category['id'] as num?)?.toInt() ?? 0,
      categoryName: category['name'] as String? ?? 'Uncategorized',
      sellerId: (seller['id'] as num?)?.toInt() ?? 0,
      sellerName: seller['name'] as String? ?? 'Unknown seller',
      images: images,
      sellerDistrict: seller['district'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
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
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String status;
  final int categoryId;
  final String categoryName;
  final int sellerId;
  final String sellerName;
  final List<MarketplaceListingImage> images;
  final String? sellerDistrict;
  final DateTime? createdAt;

  bool get hasCoordinates => latitude != null && longitude != null;

  List<String> get imageUrls {
    if (images.isNotEmpty) {
      return images.map((image) => image.url).toList();
    }

    return imageUrl == null ? const [] : [imageUrl!];
  }
}
