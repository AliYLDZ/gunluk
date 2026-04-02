import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String time;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.time,
  });

  String _cleanContent(String text) {
    // 1. HTML etiketlerini temizle
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    
    // 2. "src:https..." veya çıplak URL bağlantılarını temizle
    cleaned = cleaned.replaceAll(RegExp(r'src:https?://\S+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'https?://\S+'), '');
    
    // 3. Gereksiz boşlukları temizle
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    final cleanedContent = _cleanContent(content);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haber Detayı'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    cleanedContent.isNotEmpty ? cleanedContent : "Haber içeriği bulunamadı.",
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
