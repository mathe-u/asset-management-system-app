class Asset {
  final String name;
  final String code;
  final String category;
  final String status;
  final String custodian;
  final String location;
  final String barcode;

  Asset({
    required this.name,
    required this.code,
    required this.category,
    required this.status,
    required this.custodian,
    required this.location,
    required this.barcode,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      name: json['name'],
      code: json['code'],
      category: json['category'] ?? '',
      status: json['status'],
      custodian: json['custodian'] ?? '',
      location: json['location'] ?? '',
      barcode: json['barcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
