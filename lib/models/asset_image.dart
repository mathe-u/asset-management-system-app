class AssetImage {
  final int id;
  final String url;

  AssetImage({required this.id, required this.url});

  factory AssetImage.fromJson(Map<dynamic, dynamic> json) {
    return AssetImage(id: json['id'], url: json['url']);
  }
}
