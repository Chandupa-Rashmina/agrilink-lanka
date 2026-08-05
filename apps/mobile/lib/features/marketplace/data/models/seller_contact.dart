class SellerContact {
  const SellerContact({
    required this.sellerId,
    required this.name,
    required this.phone,
    required this.email,
    required this.district,
  });

  factory SellerContact.fromJson(Map<String, dynamic> json) {
    return SellerContact(
      sellerId: (json['seller_id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      district: json['district'] as String? ?? '',
    );
  }

  final int sellerId;
  final String name;
  final String phone;
  final String email;
  final String district;
}
