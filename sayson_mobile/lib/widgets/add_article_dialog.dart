import 'package:flutter/material.dart';
import '../models/article_model.dart';

typedef ArticleSubmit = Future<Article?> Function(Article);

class AddArticleDialog extends StatefulWidget {
  final String title;
  final Article? initial;
  final ArticleSubmit onSubmit;
  const AddArticleDialog(
      {super.key, required this.title, required this.onSubmit, this.initial});

  static Future<Article?> show(BuildContext context,
      {required String title,
      Article? initial,
      required ArticleSubmit onSubmit}) {
    return showDialog<Article?>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AddArticleDialog(title: title, onSubmit: onSubmit, initial: initial),
    );
  }

  @override
  State<AddArticleDialog> createState() => _AddArticleDialogState();
}

class _AddArticleDialogState extends State<AddArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _nameCtrl = TextEditingController(text: init?.name ?? '');
    _titleCtrl = TextEditingController(text: init?.title ?? '');
    _contentCtrl = TextEditingController(
        text: (init?.content ?? const <String>[]).join('\n'));
    _isActive = init?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final article = Article(
        aid: widget.initial?.aid ?? '',
        name: _nameCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim().isEmpty
            ? <String>[]
            : _contentCtrl.text
                .split(RegExp(r'\r?\n'))
                .where((e) => e.trim().isNotEmpty)
                .toList(),
        isActive: _isActive,
      );
      final result = await widget.onSubmit(article);
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Author name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Content (one line per paragraph)'),
                    minLines: 4,
                    maxLines: 8,
                  ),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Active'),
                  ),
                ],
              ),
            ),
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
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(null),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: _saving ? null : _handleSave, child: const Text('Save'))
      ],
    );
  }
}
