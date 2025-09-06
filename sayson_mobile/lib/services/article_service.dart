import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/article_model.dart';

class ArticleService {
  static final ArticleService _singleton = ArticleService._internal();
  factory ArticleService() => _singleton;
  ArticleService._internal();

  Uri _collectionUri() => Uri.parse('$kBaseUrl/api/articles');
  Uri _detailUri(String id) => Uri.parse('$kBaseUrl/api/articles/$id');

  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;

    if (body is Map<String, dynamic>) {
      final keysLevel1 = ['data', 'articles', 'items', 'results', 'payload'];
      for (final k in keysLevel1) {
        final v = body[k];
        if (v is List) return v;
        if (v is Map<String, dynamic>) {
          if (v['docs'] is List) return List<dynamic>.from(v['docs'] as List);
          if (v['data'] is List) return List<dynamic>.from(v['data'] as List);
        }
      }
    }
    return <dynamic>[];
  }

  Map<String, dynamic> _extractObject(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(body['data']);
    }
    if (body is Map<String, dynamic>) {
      return body;
    }
    return <String, dynamic>{};
  }

  Future<List<Article>> listArticles({String? search}) async {
    final resp = await http.get(_collectionUri());

    if (kDebugMode) {
      debugPrint('GET ${resp.request?.url} -> ${resp.statusCode}');
      if (resp.body.length < 600) {
        debugPrint('Body: ${resp.body}');
      } else {
        debugPrint('Body(len): ${resp.body.length}');
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      final dataList = _extractList(body);
      var articles = dataList
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList();

      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        articles = articles
            .where((a) =>
                a.title.toLowerCase().contains(q) ||
                a.name.toLowerCase().contains(q) ||
                a.content.any((c) => c.toLowerCase().contains(q)))
            .toList();
      }
      return articles;
    } else {
      throw Exception('Failed to load articles: ${resp.statusCode}');
    }
  }

  Future<Article> getArticle(String id) async {
    final resp = await http.get(_detailUri(id));

    if (kDebugMode) {
      debugPrint('GET ${resp.request?.url} -> ${resp.statusCode}');
      if (resp.body.length < 600) {
        debugPrint('Body: ${resp.body}');
      } else {
        debugPrint('Body(len): ${resp.body.length}');
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      final obj = _extractObject(body);
      return Article.fromJson(obj);
    } else {
      throw Exception('Failed to get article: ${resp.statusCode}');
    }
  }

  Future<Article> createArticle(Article article) async {
    final resp = await http.post(
      _collectionUri(),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(article.toJson()),
    );

    if (kDebugMode) {
      debugPrint('POST ${resp.request?.url} -> ${resp.statusCode}');
      if (resp.body.length < 600) {
        debugPrint('Body: ${resp.body}');
      } else {
        debugPrint('Body(len): ${resp.body.length}');
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      final obj = _extractObject(body);
      return obj.isNotEmpty ? Article.fromJson(obj) : article;
    } else {
      throw Exception(
          'Failed to create article: ${resp.statusCode} - ${resp.body}');
    }
  }

  Future<Article> updateArticle(Article article) async {
    if (article.aid.isEmpty) throw Exception('Missing article id');

    final resp = await http.put(
      _detailUri(article.aid),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(article.toJson()),
    );

    if (kDebugMode) {
      debugPrint('PUT ${resp.request?.url} -> ${resp.statusCode}');
      if (resp.body.length < 600) {
        debugPrint('Body: ${resp.body}');
      } else {
        debugPrint('Body(len): ${resp.body.length}');
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = json.decode(resp.body);
      final obj = _extractObject(body);
      return obj.isNotEmpty ? Article.fromJson(obj) : article;
    } else {
      throw Exception(
          'Failed to update article: ${resp.statusCode} - ${resp.body}');
    }
  }

  Future<void> deleteArticle(String id) async {
    final resp = await http.delete(_detailUri(id));

    if (kDebugMode) {
      debugPrint('DELETE ${resp.request?.url} -> ${resp.statusCode}');
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return;
    } else {
      throw Exception('Failed to delete article: ${resp.statusCode}');
    }
  }
}
