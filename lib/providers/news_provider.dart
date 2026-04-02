import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsProvider with ChangeNotifier {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;
  Timer? _timer;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsProvider() {
    fetchNews();
    _timer = Timer.periodic(const Duration(hours: 1), (timer) => fetchNews());
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Anadolu Ajansı (AA) - Güncel Haberler RSS
      final response = await http.get(Uri.parse(
          'https://api.rss2json.com/v1/api.json?rss_url=https://www.aa.com.tr/tr/rss/default?cat=guncel'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final List items = data['items'];
          _articles = items.take(10).map((item) => NewsArticle.fromJson(item)).toList();
        } else {
          _error = 'Haberler alınamadı';
        }
      } else {
        _error = 'Sunucu hatası: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Bağlantı hatası: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
