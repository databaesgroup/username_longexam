import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../widgets/add_article_dialog.dart';
import '../constants.dart';
import 'article_detail_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final _svc = ArticleService();
  String _query = '';
  late Future<List<Article>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.listArticles();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _svc.listArticles(search: _query);
    });
  }

  Future<void> _addArticle() async {
    final created = await AddArticleDialog.show(
      context,
      title: 'Add Article',
      onSubmit: (draft) async => await _svc.createArticle(draft),
    );
    if (created != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Article created')));
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addArticle,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by title, author, or content...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                _query = v;
                _refresh();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Article>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text('Error: ${snapshot.error}'),
                          )),
                          TextButton(
                              onPressed: _refresh, child: const Text('Retry')),
                        ],
                      );
                    }
                    final items = snapshot.data ?? const <Article>[];
                    if (items.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No articles found')),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final a = items[index];
                        return _ArticleCard(
                          article: a,
                          onOpen: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    ArticleDetailScreen(article: a)));
                            setState(() {}); // reflect potential edits
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onOpen;
  const _ArticleCard({required this.article, required this.onOpen});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  int likes = 0;
  int comments = 0;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                    child: Text(
                        a.name.isNotEmpty ? a.name[0].toUpperCase() : '?')),
                title:
                    Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('by ${a.name.isEmpty ? 'Unknown' : a.name}'),
                trailing: Icon(
                    a.isActive ? Icons.check_circle : Icons.remove_circle,
                    color: a.isActive ? Colors.green : Colors.grey),
              ),
              const SizedBox(height: 8),
              if (a.content.isNotEmpty)
                Text(a.content.first,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    color: kLikeColor,
                    onPressed: () => setState(() => likes++),
                  ),
                  Text('$likes'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.mode_comment_outlined),
                    color: kCommentColor,
                    onPressed: () => setState(() => comments++),
                  ),
                  Text('$comments'),
                  const Spacer(),
                  TextButton.icon(
                      onPressed: widget.onOpen,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
