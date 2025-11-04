class AssetImage {
  final int? id;
  final String url;

  AssetImage({required this.id, required this.url});

  factory AssetImage.fromJson(Map<dynamic, dynamic> json) {
    return AssetImage(id: json['id'] as int?, url: json['url'] as String);
  }
}
