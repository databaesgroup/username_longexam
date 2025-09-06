import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _editing = false;
  bool _saving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _resetControllers();
  }

  void _resetControllers() {
    final a = widget.article;
    _nameCtrl = TextEditingController(text: a.name);
    _titleCtrl = TextEditingController(text: a.title);
    _contentCtrl = TextEditingController(text: a.content.join('\n'));
    _isActive = a.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      widget.article
        ..name = _nameCtrl.text.trim()
        ..title = _titleCtrl.text.trim()
        ..content = _contentCtrl.text
            .split(RegExp(r'\r?\n'))
            .where((e) => e.trim().isNotEmpty)
            .toList()
        ..isActive = _isActive;

      final updated = await ArticleService().updateArticle(widget.article);
      setState(() {
        _saving = false;
        _editing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Article updated')));
      setState(() {
        widget.article
          ..name = updated.name
          ..title = updated.title
          ..content = updated.content
          ..isActive = updated.isActive;
      });
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _editing ? 'Edit Article' : 'Article Detail';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
              tooltip: 'Edit',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _editing ? _buildEditForm(context) : _buildReadOnly(context),
          ),
          if (_saving)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _editing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () {
                                setState(() {
                                  _editing = false;
                                  _resetControllers();
                                });
                              },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: const Text('Save'))),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildReadOnly(BuildContext context) {
    final a = widget.article;
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
              child: Text(a.name.isNotEmpty ? a.name[0].toUpperCase() : '?')),
          title:
              Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
          subtitle: Text('by ${a.name.isEmpty ? 'Unknown' : a.name}'),
          trailing: Chip(
            label: Text(a.isActive ? 'Active' : 'Inactive'),
            backgroundColor: a.isActive
                ? Colors.green.withOpacity(.2)
                : Colors.grey.withOpacity(.2),
          ),
        ),
        const SizedBox(height: 12),
        ...a.content.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(p, style: Theme.of(context).textTheme.bodyLarge),
            )),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Author name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentCtrl,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(
              labelText: 'Content (one line per paragraph)'),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _isActive,
          onChanged: (v) => setState(() => _isActive = v),
          title: const Text('Active'),
        ),
      ],
    );
  }
}
