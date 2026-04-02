class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    String description = json['description'] ?? '';
    String imageUrl = '';

    // 1. rss2json tarafından sağlanan standart görsel alanlarını kontrol et
    if (json['enclosure'] != null && json['enclosure']['link'] != null) {
      imageUrl = json['enclosure']['link'];
    } else if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      imageUrl = json['thumbnail'];
    }

    // 2. Eğer görsel bulunamadıysa, description (HTML) içindeki img tag'ini ara
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      final imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"');
      final match = imgRegExp.firstMatch(description);
      if (match != null && match.groupCount >= 1) {
        imageUrl = match.group(1)!;
      }
    }

    // 3. Hala boşsa veya Anadolu Ajansı'nın bazen kullandığı placeholder ise varsayılan bir görsel ver
    if (imageUrl.isEmpty || imageUrl.contains('aa_logo')) {
      imageUrl = 'https://picsum.photos/800/600?random=${json['title'].hashCode}';
    }

    return NewsArticle(
      title: json['title'] ?? '',
      description: description,
      url: json['link'] ?? '',
      urlToImage: imageUrl,
      publishedAt: DateTime.tryParse(json['pubDate'] ?? '') ?? DateTime.now(),
    );
  }
}
