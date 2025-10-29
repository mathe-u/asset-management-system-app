import 'asset_image.dart';

class Asset {
  final String name;
  final String code;
  final String category;
  final String status;
  final String custodian;
  final String location;
  final String barcode;
  final List<AssetImage> images;

  Asset({
    required this.name,
    required this.code,
    required this.category,
    required this.status,
    required this.custodian,
    required this.location,
    required this.barcode,
    required this.images,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageList = json['images'];

    // if (imageList.isNotEmpty) {
    //   for (var img in imageList) {
    //     if (img['url'].isNotEmpty) {
    //       print(AssetImage.fromJson(img).url);
    //     } else {
    //       print(img['url']);
    //     }
    //   }
    // } else {
    //   print('[]');
    // }
    final List<AssetImage> assetImages = imageList.isNotEmpty
        ? imageList
              .map<AssetImage>((item) => AssetImage.fromJson(item))
              .toList()
        : [];

    return Asset(
      name: json['name'],
      code: json['code'],
      category: json['category'] ?? '',
      status: json['status'],
      custodian: json['custodian'] ?? '',
      location: json['location'] ?? '',
      barcode: json['barcode'],
      images: assetImages,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
