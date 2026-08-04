class Partner {
  const Partner({
    required this.id,
    required this.type,
    required this.name,
    required this.isActive,
    this.phone,
    this.email,
    this.address,
    this.district,
  });

  final int id;
  final String type;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? district;
  final bool isActive;

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      district: json['district'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
